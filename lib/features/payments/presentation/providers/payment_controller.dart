import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/features/payments/data/models/payment.dart';
import 'package:farm2fork_mobile/features/payments/data/repositories/payments_repository_provider.dart';

class PaymentFlowResult {
  const PaymentFlowResult({
    required this.successfulOrderIds,
    required this.failedOrderIds,
  });

  final List<String> successfulOrderIds;
  final List<String> failedOrderIds;
}

class PaymentController extends AsyncNotifier<PaymentFlowResult?> {
  @override
  PaymentFlowResult? build() => null;

  Future<PaymentFlowResult> settle(List<String> orderIds) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final repository = ref.read(paymentsRepositoryProvider);
      final successful = <String>[];
      final failed = <String>[];

      for (final orderId in orderIds) {
        try {
          final payment = await repository.initiate(orderId);
          final settled = await repository.simulate(
            payment.id,
            PaymentStatus.success,
          );
          if (settled.status == PaymentStatus.success) {
            successful.add(orderId);
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
      );
    });
    state = result;
    return result.asData?.value ??
        PaymentFlowResult(successfulOrderIds: const [], failedOrderIds: orderIds);
  }
}

final paymentControllerProvider =
    AsyncNotifierProvider<PaymentController, PaymentFlowResult?>(
      PaymentController.new,
    );
