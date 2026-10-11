import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/config/app_config.dart';
import 'package:farm2fork_mobile/features/payments/data/models/payment.dart';
import 'package:farm2fork_mobile/features/payments/data/repositories/payments_repository_provider.dart';

class PaymentFlowResult {
  const PaymentFlowResult({
    required this.successfulOrderIds,
    required this.failedOrderIds,
    required this.pendingOrderIds,
    this.payments = const {},
    this.errorOrderIds = const [],
  });
  final List<String> successfulOrderIds;
  final List<String> failedOrderIds;
  final List<String> pendingOrderIds;
  final Map<String, Payment> payments;
  final List<String> errorOrderIds;
}

final paymentSimulatorEnabledProvider = Provider<bool>(
  (ref) => AppConfig.useMocks || AppConfig.paymentSimulatorEnabled,
);

class PaymentController extends AsyncNotifier<PaymentFlowResult?> {
  final _payments = <String, Payment>{};
  final _orders = <String>{};
  final _errors = <String>{};

  @override
  PaymentFlowResult? build() => null;

  /// Explicit checkout/retry: only this action is allowed to mint a tracker.
  Future<PaymentFlowResult> settle(List<String> orderIds) async {
    if (state.isLoading) return _result();
    _orders.addAll(orderIds);
    state = const AsyncLoading();
    final repository = ref.read(paymentsRepositoryProvider);
    for (final orderId in orderIds) {
      _errors.remove(orderId);
      try {
        var payment = await repository.initiate(orderId);
        if (ref.read(paymentSimulatorEnabledProvider) &&
            payment.gateway != 'safepay') {
          payment = await repository.simulate(
            payment.id,
            PaymentStatus.success,
          );
        }
        if (payment.orderId != orderId) {
          throw StateError('Payment order mismatch');
        }
        _payments[orderId] = payment;
      } on Object {
        _payments.remove(orderId);
        _errors.add(orderId);
      }
    }
    final result = _result();
    if (ref.mounted) state = AsyncData(result);
    return result;
  }

  /// Status reads, including browser resume and cold-start return, never initiate.
  Future<PaymentFlowResult> refresh(List<String> orderIds) async {
    if (state.isLoading) return _result();
    _orders
      ..clear()
      ..addAll(orderIds);
    _payments.removeWhere((orderId, _) => !_orders.contains(orderId));
    _errors.clear();
    state = const AsyncLoading();
    final repository = ref.read(paymentsRepositoryProvider);
    for (final orderId in orderIds) {
      try {
        final previous = _payments[orderId];
        final payment = previous == null
            ? await repository.findForOrder(orderId)
            : await repository.get(previous.id);
        if (payment != null) {
          if (payment.orderId != orderId) {
            throw StateError('Payment order mismatch');
          }
          _payments[orderId] = payment;
        }
      } on Object {
        // Do not show a stale success after a failed authenticated read.
        _payments.remove(orderId);
        _errors.add(orderId);
      }
    }
    final result = _result();
    if (ref.mounted) state = AsyncData(result);
    return result;
  }

  PaymentFlowResult _result() {
    final successful = <String>[];
    final failed = <String>[];
    final pending = <String>[];
    for (final orderId in _orders) {
      if (_errors.contains(orderId)) continue;
      switch (_payments[orderId]?.status) {
        case PaymentStatus.success:
          successful.add(orderId);
        case PaymentStatus.failed || PaymentStatus.refunded:
          failed.add(orderId);
        case PaymentStatus.pending || null:
          pending.add(orderId);
      }
    }
    return PaymentFlowResult(
      successfulOrderIds: successful,
      failedOrderIds: failed,
      pendingOrderIds: pending,
      payments: Map.unmodifiable(_payments),
      errorOrderIds: List.unmodifiable(_errors),
    );
  }
}

final paymentControllerProvider =
    AsyncNotifierProvider<PaymentController, PaymentFlowResult?>(
      PaymentController.new,
    );
