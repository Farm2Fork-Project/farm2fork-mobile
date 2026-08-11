enum PaymentStatus { pending, success, failed, refunded }

class Payment {
  const Payment({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String orderId;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final DateTime createdAt;
}
