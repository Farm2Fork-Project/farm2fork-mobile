import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';

part 'cart_item.freezed.dart';
part 'cart_item.g.dart';

@freezed
abstract class CartItem with _$CartItem {
  const CartItem._();
  const factory CartItem({required Product product, @Default(1) int quantity}) =
      _CartItem;

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);
}

extension CartItemX on CartItem {
  double get subtotal => product.price * quantity;
  String get farmerId => product.farmerId;
  String get farmerName => product.farmer.name;
  String get farmName => product.farmer.farmName;
}
