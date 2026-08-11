import 'package:farm2fork_mobile/features/payments/data/models/payment.dart';
import 'package:farm2fork_mobile/features/payments/data/repositories/payments_repository.dart';

class MockPaymentsRepository implements PaymentsRepository {
  final Map<String, Payment> _payments = {};

  @override
  Future<Payment> initiate(String orderId) async {
    final existing = _payments.values.where((p) => p.orderId == orderId);
    if (existing.isNotEmpty) return existing.first;

    final payment = Payment(
      id: 'pay_$orderId',
      orderId: orderId,
      amount: 0,
      currency: 'PKR',
      status: PaymentStatus.pending,
      createdAt: DateTime.now(),
    );
    _payments[payment.id] = payment;
    return payment;
  }

  @override
  Future<Payment> simulate(String paymentId, PaymentStatus status) async {
    final payment = _payments[paymentId];
    if (payment == null) throw StateError('Payment not found');
    final settled = Payment(
      id: payment.id,
      orderId: payment.orderId,
      amount: payment.amount,
      currency: payment.currency,
      status: status,
      createdAt: payment.createdAt,
    );
    _payments[paymentId] = settled;
    return settled;
  }
}
