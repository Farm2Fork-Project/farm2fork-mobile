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

import 'package:farm2fork_mobile/features/orders/data/models/order.dart';
import 'package:farm2fork_mobile/features/orders/data/repositories/api_orders_repository.dart';
import 'package:farm2fork_mobile/features/orders/data/services/orders_api_service.dart';
import 'package:farm2fork_mobile/features/listings/data/services/farm_location_service.dart';

import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/features/auth/data/models/auth_user.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/shipments/data/repositories/api_shipments_repository.dart';
import 'package:farm2fork_mobile/features/shipments/data/repositories/shipments_repository_provider.dart';
import 'package:farm2fork_mobile/features/shipments/data/services/shipments_api_service.dart';
import 'package:farm2fork_mobile/features/shipments/data/services/transporter_dispatch_service.dart';
import 'package:farm2fork_mobile/features/shipments/data/models/shipment.dart';
import 'package:farm2fork_mobile/features/shipments/presentation/providers/shipments_controller.dart';

class _TransportAuth extends AuthController {
  @override
  Future<AuthState> build() async => const AuthState(
    status: AuthStatus.authenticated,
    user: AuthUser(
      id: String.fromEnvironment('CHECKOUT_TEST_TRANSPORTER_ID'),
      email: 'fixture@example.test',
      role: AppUserRole.transporter,
      isVerified: true,
      isActive: true,
    ),
  );
}

const api = String.fromEnvironment('CHECKOUT_TEST_API');
const token = String.fromEnvironment('CHECKOUT_TEST_BUYER_TOKEN');
const otherToken = String.fromEnvironment('CHECKOUT_TEST_OTHER_TOKEN');
const farmerToken = String.fromEnvironment('CHECKOUT_TEST_FARMER_TOKEN');
const secondFarmerToken = String.fromEnvironment(
  'CHECKOUT_TEST_SECOND_FARMER_TOKEN',
);
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
      final pickup = {
        'address': 'Fixture farm road',
        'city': 'Lahore',
        'province': 'Punjab',
        'lat': 31.5104,
        'lng': 74.35,
      };
      for (final farmerToken in [farmerToken, secondFarmerToken]) {
        final farmerDio = Dio(
          BaseOptions(
            baseUrl: api,
            headers: {'Authorization': 'Bearer $farmerToken'},
          ),
        );
        addTearDown(farmerDio.close);
        final farm = FarmLocationService(farmerDio);
        expect((await farm.get())['complete'], false);
        expect((await farm.save(pickup))['complete'], true);
      }
      await expectLater(
        FarmLocationService(dio).save(pickup),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            403,
          ),
        ),
      );
      final orderRepository = ApiOrdersRepository(OrdersApiService(dio));
      final orders = <String>[];
      for (final product in products) {
        final items = [(productId: product['id'] as String, quantity: 2)];
        const address = OrderAddress(
          street: '12 Mall Road',
          city: 'Lahore',
          province: 'Punjab',
          lat: 31.5204,
          lng: 74.3587,
        );
        final quote = await orderRepository.quoteOrder(
          items: items,
          shippingAddress: address,
        );
        expect(quote.deliveryFee, greaterThan(0));
        final order = await orderRepository.createOrder(
          items: items,
          shippingAddress: address,
        );
        expect(order.grandTotal, quote.grandTotal);
        expect(
          order.grandTotal,
          order.totalAmount + order.platformFeeAmount + order.deliveryFee,
        );
        expect(order.shippingAddress.lat, address.lat);
        orders.add(order.id);
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
      expect(
        Uri.parse(
          resumedUrl.queryParameters['redirect_url']!,
        ).queryParameters['mobileOrderId'],
        orders.first,
      );
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
        (await dio.get<Map<String, dynamic>>(
          '/products?status=active',
        )).data!['data'],
        isEmpty,
      );
      expect(
        (await repository.get(begun.payments[orders.first]!.id)).status,
        PaymentStatus.success,
      );

      if (const bool.fromEnvironment('CHECKOUT_TEST_DELIVERY')) {
        final transportDio = Dio(
          BaseOptions(
            baseUrl: api,
            headers: {
              'Authorization':
                  'Bearer ${const String.fromEnvironment('CHECKOUT_TEST_TRANSPORTER_TOKEN')}',
            },
          ),
        );
        final competitorDio = Dio(
          BaseOptions(
            baseUrl: api,
            headers: {
              'Authorization':
                  'Bearer ${const String.fromEnvironment('CHECKOUT_TEST_SECOND_TRANSPORTER_TOKEN')}',
            },
          ),
        );
        addTearDown(transportDio.close);
        addTearDown(competitorDio.close);
        final dispatch = TransporterDispatchService(transportDio);
        final transportRepo = ApiShipmentsRepository(
          ShipmentsApiService(transportDio),
        );
        final competitorRepo = ApiShipmentsRepository(
          ShipmentsApiService(competitorDio),
        );
        expect((await dispatch.getStatus()).online, false);
        expect(await transportRepo.getAvailable(), isEmpty);
        await TransporterDispatchService(
          competitorDio,
        ).setAvailability(true, lat: 31.52, lng: 74.35);
        final declineId = (await competitorRepo.getAvailable()).first.orderId;
        await competitorRepo.decline(declineId);
        expect(
          (await competitorRepo.getAvailable()).any(
            (o) => o.orderId == declineId,
          ),
          false,
        );
        await dispatch.setAvailability(true, lat: 31.52, lng: 74.35);
        await dispatch.updateLocation(31.521, 74.351);
        expect((await dispatch.getStatus()).locationFresh, true);
        final deliveries = ProviderContainer(
          overrides: [
            authControllerProvider.overrideWith(_TransportAuth.new),
            shipmentsRepositoryProvider.overrideWithValue(transportRepo),
          ],
        );
        addTearDown(deliveries.dispose);
        await deliveries.read(authControllerProvider.future);
        await deliveries.read(shipmentsControllerProvider.future);
        final deliveryController = deliveries.read(
          shipmentsControllerProvider.notifier,
        );
        expect(await transportRepo.getAvailable(), hasLength(2));
        for (var i = 0; i < 2; i++) {
          final offer = (await transportRepo.getAvailable()).first;
          expect(offer.deliveryFee, greaterThan(0));
          final shipment = await deliveryController.claim(offer.orderId);
          expect((await dispatch.getStatus()).activeShipmentId, shipment.id);
          expect(await transportRepo.getAvailable(), isEmpty);
          await expectLater(
            competitorRepo.claim(offer.orderId),
            throwsA(
              isA<DioException>().having(
                (e) => e.response?.statusCode,
                'status',
                409,
              ),
            ),
          );
          await expectLater(
            competitorRepo.updateStatus(
              shipmentId: shipment.id,
              status: ShipmentStatus.pickedUp,
              note: 'Wrong owner',
            ),
            throwsA(
              isA<DioException>().having(
                (e) => e.response?.statusCode,
                'status',
                403,
              ),
            ),
          );
          for (final status in [
            ShipmentStatus.pickedUp,
            ShipmentStatus.inTransit,
            ShipmentStatus.delivered,
          ]) {
            await deliveryController.updateShipmentStatus(
              shipmentId: shipment.id,
              status: status,
              note: 'Fixture ${status.name}',
            );
          }
          expect(
            (await transportRepo.getById(shipment.id)).statusHistory,
            hasLength(4),
          );
          expect((await dispatch.getStatus()).activeShipmentId, isNull);
        }
        expect(
          (await ApiShipmentsRepository(
            ShipmentsApiService(dio),
          ).getMine()).every((s) => s.status == ShipmentStatus.delivered),
          true,
        );
        final farmerDio = Dio(
          BaseOptions(
            baseUrl: api,
            headers: {'Authorization': 'Bearer $farmerToken'},
          ),
        );
        addTearDown(farmerDio.close);
        expect(
          await ApiShipmentsRepository(
            ShipmentsApiService(farmerDio),
          ).getMine(),
          hasLength(1),
        );
        await dispatch.setAvailability(false);
        expect((await dispatch.getStatus()).online, false);
      }
    },
    skip: api.isEmpty,
  );
}
