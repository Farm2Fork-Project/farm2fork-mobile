import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/features/payments/data/models/payment.dart';
import 'package:farm2fork_mobile/features/payments/data/repositories/payments_repository.dart';
import 'package:farm2fork_mobile/features/payments/data/services/payments_api_service.dart';

class ApiPaymentsRepository implements PaymentsRepository {
  ApiPaymentsRepository(this._api, {this.useSimulator = false});

  final bool useSimulator;

  final PaymentsApiService _api;

  @override
  Future<Payment> initiate(String orderId) async {
    final body = await _api.initiatePayment(
      orderId: orderId,
      gateway: useSimulator ? 'jazzcash' : 'safepay',
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

  @override
  Future<Payment?> findForOrder(String orderId) async {
    for (var page = 1; ; page++) {
      final body = await _api.listPayments(page: page);
      final data = body['data'];
      if (data is! List) throw const ApiException(ApiErrorKind.unknown);
      for (final dto in data) {
        if (dto is Map<String, dynamic> && dto['orderId'] == orderId) {
          return _paymentFromBody(dto);
        }
      }
      final totalPages = body['totalPages'];
      if (totalPages is! num ||
          totalPages < page ||
          data.isEmpty ||
          page >= totalPages) {
        return null;
      }
    }
  }

  Payment _paymentFromBody(Map<String, dynamic> body) {
    final dto = body['payment'] ?? body;
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
      gateway: dto['gateway'] as String?,
      checkoutUrl: body['checkoutUrl'] as String?,
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
