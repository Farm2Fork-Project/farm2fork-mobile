import 'package:dio/dio.dart';
import 'package:farm2fork_mobile/features/payments/data/repositories/api_payments_repository.dart';
import 'package:farm2fork_mobile/features/payments/data/services/payments_api_service.dart';
import 'package:farm2fork_mobile/features/payments/data/models/payment.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubApi extends PaymentsApiService {
  _StubApi(this.response, {this.pages = const {}}) : super(Dio());
  final Map<int, Map<String, dynamic>> pages;
  final requestedPages = <int>[];
  final Map<String, dynamic> response;
  Map<String, dynamic>? sent;
  String? requestedPaymentId;

  @override
  Future<Map<String, dynamic>> initiatePayment({
    required String orderId,
    required String gateway,
  }) async {
    sent = {'orderId': orderId, 'gateway': gateway};
    return response;
  }

  @override
  Future<Map<String, dynamic>> listPayments({int page = 1}) async {
    requestedPages.add(page);
    return pages[page] ?? {'data': [], 'totalPages': 1};
  }

  @override
  Future<Map<String, dynamic>> getPayment(String paymentId) async {
    requestedPaymentId = paymentId;
    return response;
  }
}

void main() {
  test('cold-start lookup finds an older payment on a later page', () async {
    final api = _StubApi(
      {},
      pages: {
        1: {
          'data': [
            {'id': 'newer', 'orderId': 'other'},
          ],
          'totalPages': 2,
        },
        2: {
          'data': [
            {'id': 'saved', 'orderId': 'requested', 'status': 'success'},
          ],
          'totalPages': 2,
        },
      },
    );
    final payment = await ApiPaymentsRepository(api).findForOrder('requested');
    expect(payment?.id, 'saved');
    expect(payment?.status, PaymentStatus.success);
    expect(api.requestedPages, [1, 2]);
    expect(api.sent, isNull);
  });

  test('absent cold-start payment returns null without initiating', () async {
    final api = _StubApi({});
    expect(await ApiPaymentsRepository(api).findForOrder('missing'), isNull);
    expect(api.requestedPages, [1]);
    expect(api.sent, isNull);
  });
  test('preserves a hosted URL for a pending Safepay payment', () async {
    final api = _StubApi({
      'payment': {
        'id': 'payment-1',
        'orderId': 'order-1',
        'amount': 210,
        'currency': 'PKR',
        'gateway': 'safepay',
        'status': 'pending',
      },
      'checkoutUrl':
          'https://sandbox.api.getsafepay.com/checkout/pay?tracker=test',
    });
    final payment = await ApiPaymentsRepository(api).initiate('order-1');
    expect(
      payment.checkoutUrl,
      'https://sandbox.api.getsafepay.com/checkout/pay?tracker=test',
    );
  });

  test(
    'reads the real bare payment DTO without initiating a tracker',
    () async {
      final api = _StubApi({
        'id': 'payment-2',
        'orderId': 'order-2',
        'amount': 210,
        'currency': 'PKR',
        'gateway': 'safepay',
        'status': 'success',
      });
      final payment = await ApiPaymentsRepository(api).get('payment-2');
      expect(payment.status, PaymentStatus.success);
      expect(api.sent, isNull);
    },
  );

  test(
    'maps a successful payment and sends no client-derived amount',
    () async {
      final api = _StubApi({
        'payment': {
          'id': 'payment-1',
          'orderId': 'order-1',
          'amount': 870,
          'currency': 'PKR',
          'status': 'success',
          'createdAt': '2026-08-11T00:00:00.000Z',
        },
      });

      final payment = await ApiPaymentsRepository(api).initiate('order-1');

      expect(payment.status, PaymentStatus.success);
      expect(payment.amount, 870);
      expect(api.sent, {'orderId': 'order-1', 'gateway': 'safepay'});
    },
  );

  test('loads a persisted payment by its backend id', () async {
    final api = _StubApi({
      'payment': {
        'id': 'payment-2',
        'orderId': 'order-2',
        'amount': '970',
        'currency': 'PKR',
        'status': 'pending',
        'createdAt': '2026-08-11T00:00:00.000Z',
      },
    });

    final payment = await ApiPaymentsRepository(api).get('payment-2');

    expect(api.requestedPaymentId, 'payment-2');
    expect(payment.id, 'payment-2');
    expect(payment.status, PaymentStatus.pending);
    expect(payment.amount, 970);
  });
}
