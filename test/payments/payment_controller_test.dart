import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/features/payments/data/models/payment.dart';
import 'package:farm2fork_mobile/features/payments/data/repositories/payments_repository.dart';
import 'package:farm2fork_mobile/features/payments/data/repositories/payments_repository_provider.dart';
import 'package:farm2fork_mobile/features/payments/presentation/providers/payment_controller.dart';

class _RecordingPaymentsRepository implements PaymentsRepository {
  final initiatedOrderIds = <String>[];
  final settledPaymentIds = <String>[];

  @override
  Future<Payment> initiate(String orderId) async {
    initiatedOrderIds.add(orderId);
    return Payment(
      id: 'payment-$orderId',
      orderId: orderId,
      amount: 870,
      currency: 'PKR',
      status: PaymentStatus.pending,
      createdAt: DateTime(2026, 8, 11),
    );
  }

  @override
  Future<Payment> simulate(String paymentId, PaymentStatus status) async {
    settledPaymentIds.add(paymentId);
    return Payment(
      id: paymentId,
      orderId: paymentId.replaceFirst('payment-', ''),
      amount: 870,
      currency: 'PKR',
      status: status,
      createdAt: DateTime(2026, 8, 11),
    );
  }
}

void main() {
  test('settles one payment for every successfully created order', () async {
    final repo = _RecordingPaymentsRepository();
    final container = ProviderContainer(
      overrides: [paymentsRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    final result = await container
        .read(paymentControllerProvider.notifier)
        .settle(const ['order-a', 'order-b']);

    expect(repo.initiatedOrderIds, ['order-a', 'order-b']);
    expect(repo.settledPaymentIds, ['payment-order-a', 'payment-order-b']);
    expect(result.successfulOrderIds, ['order-a', 'order-b']);
    expect(result.failedOrderIds, isEmpty);
  });

  test(
    'leaves initiated payments pending when simulation is disabled',
    () async {
      final repo = _RecordingPaymentsRepository();
      final container = ProviderContainer(
        overrides: [
          paymentsRepositoryProvider.overrideWithValue(repo),
          paymentSimulatorEnabledProvider.overrideWithValue(false),
        ],
      );
      addTearDown(container.dispose);

      final result = await container
          .read(paymentControllerProvider.notifier)
          .settle(const ['order-a']);

      expect(repo.initiatedOrderIds, ['order-a']);
      expect(repo.settledPaymentIds, isEmpty);
      expect(result.successfulOrderIds, isEmpty);
      expect(result.failedOrderIds, isEmpty);
      expect(result.pendingOrderIds, ['order-a']);
    },
  );
}
