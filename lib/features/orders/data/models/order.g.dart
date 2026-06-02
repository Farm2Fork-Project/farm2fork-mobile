// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderAddress _$OrderAddressFromJson(Map<String, dynamic> json) =>
    _OrderAddress(
      street: json['street'] as String,
      city: json['city'] as String,
      province: json['province'] as String,
      zip: json['zip'] as String?,
    );

Map<String, dynamic> _$OrderAddressToJson(_OrderAddress instance) =>
    <String, dynamic>{
      'street': instance.street,
      'city': instance.city,
      'province': instance.province,
      'zip': instance.zip,
    };

_OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => _OrderItem(
  productId: json['productId'] as String,
  farmerId: json['farmerId'] as String,
  productName: json['productName'] as String,
  quantity: (json['quantity'] as num).toDouble(),
  unit: json['unit'] as String,
  unitPrice: (json['unitPrice'] as num).toDouble(),
  subtotal: (json['subtotal'] as num).toDouble(),
);

Map<String, dynamic> _$OrderItemToJson(_OrderItem instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'farmerId': instance.farmerId,
      'productName': instance.productName,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'unitPrice': instance.unitPrice,
      'subtotal': instance.subtotal,
    };

_Order _$OrderFromJson(Map<String, dynamic> json) => _Order(
  id: json['_id'] as String,
  buyerId: json['buyerId'] as String,
  farmerId: json['farmerId'] as String,
  items: (json['items'] as List<dynamic>)
      .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalAmount: (json['totalAmount'] as num).toDouble(),
  platformFeePercent: (json['platformFeePercent'] as num).toDouble(),
  platformFeeAmount: (json['platformFeeAmount'] as num).toDouble(),
  grandTotal: (json['grandTotal'] as num).toDouble(),
  shippingAddress: OrderAddress.fromJson(
    json['shippingAddress'] as Map<String, dynamic>,
  ),
  status: $enumDecode(_$OrderStatusEnumMap, json['status']),
  paymentId: json['paymentId'] as String?,
  shipmentId: json['shipmentId'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$OrderToJson(_Order instance) => <String, dynamic>{
  '_id': instance.id,
  'buyerId': instance.buyerId,
  'farmerId': instance.farmerId,
  'items': instance.items,
  'totalAmount': instance.totalAmount,
  'platformFeePercent': instance.platformFeePercent,
  'platformFeeAmount': instance.platformFeeAmount,
  'grandTotal': instance.grandTotal,
  'shippingAddress': instance.shippingAddress,
  'status': _$OrderStatusEnumMap[instance.status]!,
  'paymentId': instance.paymentId,
  'shipmentId': instance.shipmentId,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.paid: 'paid',
  OrderStatus.processing: 'processing',
  OrderStatus.shipped: 'shipped',
  OrderStatus.delivered: 'delivered',
  OrderStatus.cancelled: 'cancelled',
};
