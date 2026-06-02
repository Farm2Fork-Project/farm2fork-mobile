// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shipment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShipmentAddress _$ShipmentAddressFromJson(Map<String, dynamic> json) =>
    _ShipmentAddress(
      street: json['street'] as String,
      city: json['city'] as String,
      province: json['province'] as String,
      zip: json['zip'] as String?,
    );

Map<String, dynamic> _$ShipmentAddressToJson(_ShipmentAddress instance) =>
    <String, dynamic>{
      'street': instance.street,
      'city': instance.city,
      'province': instance.province,
      'zip': instance.zip,
    };

_ShipmentStatusUpdate _$ShipmentStatusUpdateFromJson(
  Map<String, dynamic> json,
) => _ShipmentStatusUpdate(
  status: $enumDecode(_$ShipmentStatusEnumMap, json['status']),
  timestamp: DateTime.parse(json['timestamp'] as String),
  note: json['note'] as String,
  updatedBy: json['updatedBy'] as String,
);

Map<String, dynamic> _$ShipmentStatusUpdateToJson(
  _ShipmentStatusUpdate instance,
) => <String, dynamic>{
  'status': _$ShipmentStatusEnumMap[instance.status]!,
  'timestamp': instance.timestamp.toIso8601String(),
  'note': instance.note,
  'updatedBy': instance.updatedBy,
};

const _$ShipmentStatusEnumMap = {
  ShipmentStatus.assigned: 'assigned',
  ShipmentStatus.pickedUp: 'pickedUp',
  ShipmentStatus.inTransit: 'inTransit',
  ShipmentStatus.delivered: 'delivered',
  ShipmentStatus.failed: 'failed',
};

_Shipment _$ShipmentFromJson(Map<String, dynamic> json) => _Shipment(
  id: json['_id'] as String,
  orderId: json['orderId'] as String,
  transporterId: json['transporterId'] as String,
  status: $enumDecode(_$ShipmentStatusEnumMap, json['status']),
  pickupAddress: ShipmentAddress.fromJson(
    json['pickupAddress'] as Map<String, dynamic>,
  ),
  deliveryAddress: ShipmentAddress.fromJson(
    json['deliveryAddress'] as Map<String, dynamic>,
  ),
  statusHistory: (json['statusHistory'] as List<dynamic>)
      .map((e) => ShipmentStatusUpdate.fromJson(e as Map<String, dynamic>))
      .toList(),
  estimatedDelivery: DateTime.parse(json['estimatedDelivery'] as String),
  actualDelivery: json['actualDelivery'] == null
      ? null
      : DateTime.parse(json['actualDelivery'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ShipmentToJson(_Shipment instance) => <String, dynamic>{
  '_id': instance.id,
  'orderId': instance.orderId,
  'transporterId': instance.transporterId,
  'status': _$ShipmentStatusEnumMap[instance.status]!,
  'pickupAddress': instance.pickupAddress,
  'deliveryAddress': instance.deliveryAddress,
  'statusHistory': instance.statusHistory,
  'estimatedDelivery': instance.estimatedDelivery.toIso8601String(),
  'actualDelivery': instance.actualDelivery?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
