import 'package:freezed_annotation/freezed_annotation.dart';

part 'order.freezed.dart';
part 'order.g.dart';

enum OrderStatus { pending, paid, processing, shipped, delivered, cancelled }

@freezed
abstract class OrderAddress with _$OrderAddress {
  const factory OrderAddress({
    required String street,
    required String city,
    required String province,
    String? zip,
  }) = _OrderAddress;

  factory OrderAddress.fromJson(Map<String, dynamic> json) =>
      _$OrderAddressFromJson(json);
}

@freezed
abstract class OrderItem with _$OrderItem {
  const factory OrderItem({
    required String productId,
    required String farmerId,
    required String productName,
    required double quantity,
    required String unit,
    required double unitPrice,
    required double subtotal,
  }) = _OrderItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);
}

@freezed
abstract class Order with _$Order {
  const factory Order({
    @JsonKey(name: '_id') required String id,
    required String buyerId,
    required String farmerId,
    required List<OrderItem> items,
    required double totalAmount,
    required double platformFeePercent,
    required double platformFeeAmount,
    required double grandTotal,
    required OrderAddress shippingAddress,
    required OrderStatus status,
    String? paymentId,
    String? shipmentId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}
