class CartPricingConfig {
  const CartPricingConfig({required this.platformFeePercent});

  final double platformFeePercent;

  static const fallback = CartPricingConfig(platformFeePercent: 5);

  double platformFeeFor(double amount) => amount * (platformFeePercent / 100);
}
