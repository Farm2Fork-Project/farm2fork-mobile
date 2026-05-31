import 'package:freezed_annotation/freezed_annotation.dart';
import 'cart_item.dart';
import 'cart_pricing_config.dart';

part 'farmer_cart_group.freezed.dart';

@freezed
abstract class FarmerCartGroup with _$FarmerCartGroup {
  const factory FarmerCartGroup({
    required String farmerId,
    required String farmerName,
    required String farmName,
    required List<CartItem> items,
    @Default(CartPricingConfig.fallback) CartPricingConfig pricingConfig,
  }) = _FarmerCartGroup;

  const FarmerCartGroup._();

  double get itemsSubtotal =>
      items.fold(0.0, (sum, item) => sum + item.subtotal);

  double get platformFeePercent => pricingConfig.platformFeePercent;

  double get platformFee => pricingConfig.platformFeeFor(itemsSubtotal);

  double get grandTotal => itemsSubtotal + platformFee;

  FarmerCartGroup withPricing(CartPricingConfig config) =>
      copyWith(pricingConfig: config);
}
