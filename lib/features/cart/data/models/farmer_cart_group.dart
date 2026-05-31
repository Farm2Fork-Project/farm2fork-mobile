import 'package:freezed_annotation/freezed_annotation.dart';
import 'cart_item.dart';

part 'farmer_cart_group.freezed.dart';

/// Platform fee rate applied per farmer group order (5%).
const double kPlatformFeeRate = 0.05;

@freezed
abstract class FarmerCartGroup with _$FarmerCartGroup {
  const factory FarmerCartGroup({
    required String farmerId,
    required String farmerName,
    required String farmName,
    required List<CartItem> items,
  }) = _FarmerCartGroup;

  const FarmerCartGroup._();

  double get itemsSubtotal => items.fold(0.0, (sum, item) => sum + item.subtotal);

  double get platformFee => itemsSubtotal * kPlatformFeeRate;

  double get grandTotal => itemsSubtotal + platformFee;
}
