class OrderQuote {
  const OrderQuote({
    required this.totalAmount,
    required this.platformFeePercent,
    required this.platformFeeAmount,
    required this.deliveryFee,
    required this.deliveryDistanceKm,
    required this.grandTotal,
  });
  final double totalAmount,
      platformFeePercent,
      platformFeeAmount,
      deliveryFee,
      deliveryDistanceKm,
      grandTotal;
  factory OrderQuote.fromJson(Map<String, dynamic> json) {
    double number(String key) {
      final value = json[key];
      if (value is! num || !value.isFinite || value < 0) {
        throw FormatException('Invalid quote $key');
      }
      return value.toDouble();
    }

    return OrderQuote(
      totalAmount: number('totalAmount'),
      platformFeePercent: number('platformFeePercent'),
      platformFeeAmount: number('platformFeeAmount'),
      deliveryFee: number('deliveryFee'),
      deliveryDistanceKm: number('deliveryDistanceKm'),
      grandTotal: number('grandTotal'),
    );
  }
}
