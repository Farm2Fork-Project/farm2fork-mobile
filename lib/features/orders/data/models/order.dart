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
    // Drop-off pin; required for new orders (the delivery fee is priced
    // from it), absent on legacy ones.
    double? lat,
    double? lng,
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
    // Fixed delivery price frozen at checkout (0 on legacy orders).
    @Default(0) double deliveryFee,
    double? deliveryDistanceKm,
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

/// Server price for one farmer's cart, shown before the order is placed.
class OrderQuote {
  const OrderQuote({
    required this.totalAmount,
    required this.platformFeePercent,
    required this.platformFeeAmount,
    required this.deliveryFee,
    required this.deliveryDistanceKm,
    required this.grandTotal,
  });

  final double totalAmount;
  final double platformFeePercent;
  final double platformFeeAmount;
  final double deliveryFee;
  final double deliveryDistanceKm;
  final double grandTotal;
}
