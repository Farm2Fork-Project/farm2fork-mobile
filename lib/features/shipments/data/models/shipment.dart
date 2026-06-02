import 'package:freezed_annotation/freezed_annotation.dart';

part 'shipment.freezed.dart';
part 'shipment.g.dart';

enum ShipmentStatus {
  assigned,
  @JsonValue('picked_up')
  pickedUp,
  @JsonValue('in_transit')
  inTransit,
  delivered,
  failed,
}

@freezed
abstract class ShipmentAddress with _$ShipmentAddress {
  const factory ShipmentAddress({
    required String street,
    required String city,
    required String province,
    String? zip,
  }) = _ShipmentAddress;

  factory ShipmentAddress.fromJson(Map<String, dynamic> json) =>
      _$ShipmentAddressFromJson(json);
}

@freezed
abstract class ShipmentStatusUpdate with _$ShipmentStatusUpdate {
  const factory ShipmentStatusUpdate({
    required ShipmentStatus status,
    required DateTime timestamp,
    required String note,
    required String updatedBy,
  }) = _ShipmentStatusUpdate;

  factory ShipmentStatusUpdate.fromJson(Map<String, dynamic> json) =>
      _$ShipmentStatusUpdateFromJson(json);
}

@freezed
abstract class Shipment with _$Shipment {
  const factory Shipment({
    @JsonKey(name: '_id') required String id,
    required String orderId,
    required String transporterId,
    required ShipmentStatus status,
    required ShipmentAddress pickupAddress,
    required ShipmentAddress deliveryAddress,
    required List<ShipmentStatusUpdate> statusHistory,
    required DateTime estimatedDelivery,
    DateTime? actualDelivery,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Shipment;

  factory Shipment.fromJson(Map<String, dynamic> json) =>
      _$ShipmentFromJson(json);
}
