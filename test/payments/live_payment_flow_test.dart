import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/features/payments/data/repositories/api_payments_repository.dart';
import 'package:farm2fork_mobile/features/payments/data/repositories/payments_repository_provider.dart';
import 'package:farm2fork_mobile/features/payments/data/services/payments_api_service.dart';
import 'package:farm2fork_mobile/features/payments/data/models/payment.dart';
import 'package:farm2fork_mobile/features/payments/presentation/providers/payment_controller.dart';

const api = String.fromEnvironment('CHECKOUT_TEST_API');
const token = String.fromEnvironment('CHECKOUT_TEST_BUYER_TOKEN');
const otherToken = String.fromEnvironment('CHECKOUT_TEST_OTHER_TOKEN');
const secret = String.fromEnvironment('CHECKOUT_TEST_WEBHOOK_SECRET');
void main() {
  test(
    'mobile payment refresh/retry and signed settlement use real HTTP persistence',
    () async {
      final dio = Dio(
        BaseOptions(baseUrl: api, headers: {'Authorization': 'Bearer $token'}),
      );
      final other = Dio(
        BaseOptions(
          baseUrl: api,
          headers: {'Authorization': 'Bearer $otherToken'},
        ),
      );
      addTearDown(() {
        dio.close();
        other.close();
      });
      final repository = ApiPaymentsRepository(PaymentsApiService(dio));
      final container = ProviderContainer(
        overrides: [
          paymentsRepositoryProvider.overrideWithValue(repository),
          paymentSimulatorEnabledProvider.overrideWithValue(false),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(paymentControllerProvider.notifier);
      final products =
          (await dio.get<Map<String, dynamic>>('/products')).data!['data']
              as List;
      final orders = <String>[];
      for (final product in products) {
        final order = (await dio.post<Map<String, dynamic>>(
          '/orders',
          data: {
            'items': [
              {'productId': product['id'], 'quantity': 2},
            ],
            'shippingAddress': {
              'street': '12 Mall Road',
              'city': 'Lahore',
              'province': 'Punjab',
            },
          },
        )).data!;
        expect(order['grandTotal'], 210);
        orders.add(order['id'] as String);
      }
      expect(orders, hasLength(2));
      final uninitiated = await controller.refresh(orders);
      expect(uninitiated.pendingOrderIds, orders);
      expect(uninitiated.payments, isEmpty);
      final begun = await controller.settle(orders);
      expect(begun.pendingOrderIds, orders);
      expect(begun.errorOrderIds, isEmpty);
      final firstUrl = Uri.parse(begun.payments[orders.first]!.checkoutUrl!);
      final returnUrl = Uri.parse(firstUrl.queryParameters['redirect_url']!);
      expect(returnUrl.path, '/order/complete');
      expect(returnUrl.queryParameters['mobileOrderId'], orders.first);
      final tracker = firstUrl.queryParameters['tracker'];
      await controller.refresh(orders);
      // Repeated status reads retain the tracker, rather than starting another.
      final resumed = await controller.settle([orders.first]);
      final resumedUrl = Uri.parse(
        resumed.payments[orders.first]!.checkoutUrl!,
      );
      expect(resumedUrl.queryParameters['order_id'], orders.first);
      expect(resumedUrl.queryParameters['tracker'], isNot(tracker));
      await expectLater(
        other.post(
          '/payments',
          data: {
            'orderId': orders.first,
            'gateway': 'safepay',
            'client': 'mobile',
          },
        ),
        throwsA(
          isA<DioException>().having(
            (error) => error.response?.statusCode,
            'status',
            403,
          ),
        ),
      );
      Future<void> callback(Uri url, String type) async {
        final data = {
          'tracker': {'token': url.queryParameters['tracker']},
        };
        final signature = Hmac(
          sha512,
          utf8.encode(secret),
        ).convert(utf8.encode(jsonEncode(data))).toString();
        await dio.post(
          '/payments/webhook/safepay',
          data: {'type': type, 'data': data},
          options: Options(headers: {'x-sfpy-signature': signature}),
        );
      }

      await callback(resumedUrl, 'payment.succeeded');
      await callback(resumedUrl, 'payment.succeeded');
      final secondUrl = Uri.parse(begun.payments[orders.last]!.checkoutUrl!);
      await callback(secondUrl, 'payment.failed');
      final refreshed = await controller.refresh(orders);
      expect(refreshed.successfulOrderIds, [orders.first]);
      expect(refreshed.failedOrderIds, [orders.last]);
      final retry = await controller.settle([orders.last]);
      await callback(
        Uri.parse(retry.payments[orders.last]!.checkoutUrl!),
        'payment.succeeded',
      );
      // A new container models cold-start deep-link recovery using persisted reads.
      final cold = ProviderContainer(
        overrides: [
          paymentsRepositoryProvider.overrideWithValue(repository),
          paymentSimulatorEnabledProvider.overrideWithValue(false),
        ],
      );
      addTearDown(cold.dispose);
      final finalState = await cold
          .read(paymentControllerProvider.notifier)
          .refresh(orders);
      expect(finalState.successfulOrderIds, orders);
      expect(finalState.errorOrderIds, isEmpty);
      expect(
        (await dio.get<Map<String, dynamic>>('/orders')).data!['data'],
        hasLength(2),
      );
      expect(
        (await dio.get<Map<String, dynamic>>('/payments')).data!['data'],
        hasLength(2),
      );
      expect(
        (await dio.get<Map<String, dynamic>>('/products?status=active')).data!['data'],
        isEmpty,
      );
      expect(
        (await repository.get(begun.payments[orders.first]!.id)).status,
        PaymentStatus.success,
      );
    },
    skip: api.isEmpty,
  );
}
