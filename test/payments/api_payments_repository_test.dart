import 'package:dio/dio.dart';
import 'package:farm2fork_mobile/features/payments/data/repositories/api_payments_repository.dart';
import 'package:farm2fork_mobile/features/payments/data/services/payments_api_service.dart';
import 'package:farm2fork_mobile/features/payments/data/models/payment.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubApi extends PaymentsApiService {
  _StubApi(this.response) : super(Dio());
  final Map<String, dynamic> response;
  Map<String, dynamic>? sent;

  @override
  Future<Map<String, dynamic>> initiatePayment({
    required String orderId,
    required String gateway,
  }) async {
    sent = {'orderId': orderId, 'gateway': gateway};
    return response;
  }
}

void main() {
  test('maps a successful payment and sends no client-derived amount', () async {
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
    expect(api.sent, {'orderId': 'order-1', 'gateway': 'jazzcash'});
  });
}
