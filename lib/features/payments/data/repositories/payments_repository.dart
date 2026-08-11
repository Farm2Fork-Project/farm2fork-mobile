import 'package:farm2fork_mobile/features/payments/data/models/payment.dart';

abstract class PaymentsRepository {
  Future<Payment> initiate(String orderId);

  Future<Payment> simulate(String paymentId, PaymentStatus status);
}
