import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/config/app_config.dart';
import 'package:farm2fork_mobile/features/payments/data/models/payment.dart';
import 'package:farm2fork_mobile/features/payments/data/repositories/payments_repository_provider.dart';

class PaymentFlowResult {
  const PaymentFlowResult({
    required this.successfulOrderIds,
    required this.failedOrderIds,
    required this.pendingOrderIds,
  });

  final List<String> successfulOrderIds;
  final List<String> failedOrderIds;
  final List<String> pendingOrderIds;
}

final paymentSimulatorEnabledProvider = Provider<bool>(
  (ref) => AppConfig.useMocks || AppConfig.paymentSimulatorEnabled,
);

class PaymentController extends AsyncNotifier<PaymentFlowResult?> {
  @override
  PaymentFlowResult? build() => null;

  Future<PaymentFlowResult> settle(List<String> orderIds) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final repository = ref.read(paymentsRepositoryProvider);
      final successful = <String>[];
      final failed = <String>[];
      final pending = <String>[];
      final simulatorEnabled = ref.read(paymentSimulatorEnabledProvider);

      for (final orderId in orderIds) {
        try {
          final payment = await repository.initiate(orderId);
          if (!simulatorEnabled) {
            switch (payment.status) {
              case PaymentStatus.success:
                successful.add(orderId);
              case PaymentStatus.failed:
              case PaymentStatus.refunded:
                failed.add(orderId);
              case PaymentStatus.pending:
                pending.add(orderId);
            }
            continue;
          }
          final settled = await repository.simulate(
            payment.id,
            PaymentStatus.success,
          );
          if (settled.status == PaymentStatus.success) {
            successful.add(orderId);
          } else if (settled.status == PaymentStatus.pending) {
            pending.add(orderId);
          } else {
            failed.add(orderId);
          }
        } on Object {
          failed.add(orderId);
        }
      }

      return PaymentFlowResult(
        successfulOrderIds: successful,
        failedOrderIds: failed,
        pendingOrderIds: pending,
      );
    });
    state = result;
    return result.asData?.value ??
        PaymentFlowResult(
          successfulOrderIds: const [],
          failedOrderIds: orderIds,
          pendingOrderIds: const [],
        );
  }
}

final paymentControllerProvider =
    AsyncNotifierProvider<PaymentController, PaymentFlowResult?>(
      PaymentController.new,
    );
