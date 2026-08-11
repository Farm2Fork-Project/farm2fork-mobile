import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/features/payments/data/models/payment.dart';
import 'package:farm2fork_mobile/features/payments/data/repositories/payments_repository.dart';
import 'package:farm2fork_mobile/features/payments/data/services/payments_api_service.dart';

class ApiPaymentsRepository implements PaymentsRepository {
  ApiPaymentsRepository(this._api);

  final PaymentsApiService _api;

  @override
  Future<Payment> initiate(String orderId) async {
    final body = await _api.initiatePayment(
      orderId: orderId,
      gateway: 'jazzcash',
    );
    return _paymentFromBody(body);
  }

  @override
  Future<Payment> simulate(String paymentId, PaymentStatus status) async {
    final body = await _api.simulatePayment(
      paymentId: paymentId,
      status: status.name,
    );
    return _paymentFromBody(body);
  }

  @override
  Future<Payment> get(String paymentId) async {
    return _paymentFromBody(await _api.getPayment(paymentId));
  }

  Payment _paymentFromBody(Map<String, dynamic> body) {
    final dto = body['payment'];
    if (dto is! Map<String, dynamic>) {
      throw const ApiException(ApiErrorKind.unknown);
    }
    final id = dto['id'] as String?;
    final persistedOrderId = dto['orderId'] as String?;
    if (id == null || id.isEmpty || persistedOrderId == null) {
      throw const ApiException(ApiErrorKind.unknown);
    }
    return Payment(
      id: id,
      orderId: persistedOrderId,
      amount: _number(dto['amount']),
      currency: (dto['currency'] as String?) ?? 'PKR',
      status: _status(dto['status'] as String?),
      createdAt:
          DateTime.tryParse(dto['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  double _number(Object? value) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

  PaymentStatus _status(String? value) => switch (value) {
    'success' => PaymentStatus.success,
    'failed' => PaymentStatus.failed,
    'refunded' => PaymentStatus.refunded,
    _ => PaymentStatus.pending,
  };
}
