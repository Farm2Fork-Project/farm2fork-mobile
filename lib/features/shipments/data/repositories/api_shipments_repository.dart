import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/core/location/geo_point.dart';
import 'package:farm2fork_mobile/features/shipments/data/models/available_delivery.dart';
import 'package:farm2fork_mobile/features/shipments/data/models/shipment.dart';
import 'package:farm2fork_mobile/features/shipments/data/repositories/shipments_repository.dart';
import 'package:farm2fork_mobile/features/shipments/data/services/shipments_api_service.dart';

class ApiShipmentsRepository extends ShipmentsRepository {
  ApiShipmentsRepository(this._api);

  final ShipmentsApiService _api;

  @override
  Future<List<AvailableDelivery>> getAvailable() async {
    final data = await _api.getAvailableDeliveries();
    return data.map(_availableFromDto).toList(growable: false);
  }

  @override
  Future<TransporterStatus> getStatus() async =>
      _statusFromDto(await _api.getStatus());

  @override
  Future<TransporterStatus> setAvailability({
    required bool online,
    GeoPoint? location,
  }) async => _statusFromDto(
    await _api.setAvailability({
      'online': online,
      if (location != null) 'location': location.toJson(),
    }),
  );

  @override
  Future<void> reportLocation(GeoPoint location) =>
      _api.reportLocation(location.toJson());

  @override
  Future<void> decline(String orderId) => _api.decline(orderId);

  @override
  Future<List<Shipment>> getMine() async {
    final data = await _api.getMyShipments();
    return data.map(_shipmentFromDto).toList(growable: false);
  }

  @override
  Future<Shipment> getById(String shipmentId) async {
    return _shipmentFromDto(await _api.getShipment(shipmentId));
  }

  @override
  Future<Shipment> claim(String orderId) async {
    return _shipmentFromDto(await _api.claimShipment(orderId));
  }

  @override
  Future<Shipment> updateStatus({
    required String shipmentId,
    required ShipmentStatus status,
    required String note,
  }) async {
    return _shipmentFromDto(
      await _api.updateShipmentStatus(
        shipmentId: shipmentId,
        status: _statusToWire(status),
        note: note,
      ),
    );
  }

  AvailableDelivery _availableFromDto(Map<String, dynamic> dto) {
    final items = dto['items'];
    return AvailableDelivery(
      orderId: _requiredString(dto, 'orderId'),
      pickupCity: _requiredString(dto, 'pickupCity'),
      pickupProvince: _requiredString(dto, 'pickupProvince'),
      deliveryCity: _requiredString(dto, 'deliveryCity'),
      deliveryProvince: _requiredString(dto, 'deliveryProvince'),
      itemCount: _number(dto['itemCount']).toInt(),
      createdAt: _date(dto['createdAt']),
      deliveryFee: _number(dto['deliveryFee']),
      deliveryDistanceKm: _number(dto['deliveryDistanceKm']),
      distanceToPickupKm: _number(dto['distanceToPickupKm']),
      pickup: _point(dto['pickup']),
      dropoffArea: _point(dto['dropoffArea']),
      farmName: dto['farmName'] as String?,
      items: items is List
          ? items
                .whereType<Map>()
                .map(
                  (item) => OfferItem(
                    productName: (item['productName'] as String?) ?? '',
                    quantity: _number(item['quantity']),
                  ),
                )
                .toList(growable: false)
          : const [],
    );
  }

  TransporterStatus _statusFromDto(Map<String, dynamic> dto) =>
      TransporterStatus(
        online: dto['online'] == true,
        locationFresh: dto['locationFresh'] == true,
        radiusKm: _number(dto['radiusKm']),
        lastLocationAt: dto['lastLocationAt'] == null
            ? null
            : _date(dto['lastLocationAt']),
        activeShipmentId: dto['activeShipmentId'] as String?,
      );

  GeoPoint _point(Object? value) {
    final point = GeoPoint.tryParse(value);
    if (point == null) throw const ApiException(ApiErrorKind.unknown);
    return point;
  }

  Shipment _shipmentFromDto(Map<String, dynamic> dto) {
    final history = dto['statusHistory'];
    if (history is! List) throw const ApiException(ApiErrorKind.unknown);
    return Shipment(
      id: _requiredString(dto, 'id'),
      orderId: _requiredString(dto, 'orderId'),
      transporterId: _requiredString(dto, 'transporterId'),
      status: _status(dto['status']),
      pickupAddress: _address(dto['pickupAddress']),
      deliveryAddress: _address(dto['deliveryAddress']),
      statusHistory: history.map(_historyEntry).toList(growable: false),
      estimatedDelivery: _date(dto['estimatedDelivery']),
      actualDelivery: dto['actualDelivery'] == null
          ? null
          : _date(dto['actualDelivery']),
      deliveryFee: (dto['deliveryFee'] as num?)?.toDouble(),
      createdAt: _date(dto['createdAt']),
      updatedAt: _date(dto['updatedAt']),
    );
  }

  ShipmentAddress _address(Object? value) {
    if (value is! Map) throw const ApiException(ApiErrorKind.unknown);
    final dto = Map<String, dynamic>.from(value);
    return ShipmentAddress(
      street: _requiredString(dto, 'street'),
      city: _requiredString(dto, 'city'),
      province: _requiredString(dto, 'province'),
      zip: dto['zip'] as String?,
      lat: (dto['lat'] as num?)?.toDouble(),
      lng: (dto['lng'] as num?)?.toDouble(),
    );
  }

  ShipmentStatusUpdate _historyEntry(Object? value) {
    if (value is! Map) throw const ApiException(ApiErrorKind.unknown);
    final dto = Map<String, dynamic>.from(value);
    return ShipmentStatusUpdate(
      status: _status(dto['status']),
      timestamp: _date(dto['timestamp']),
      note: _requiredString(dto, 'note'),
      updatedBy: _requiredString(dto, 'updatedBy'),
    );
  }

  String _requiredString(Map<String, dynamic> dto, String key) {
    final value = dto[key] as String?;
    if (value == null || value.isEmpty) {
      throw const ApiException(ApiErrorKind.unknown);
    }
    return value;
  }

  double _number(Object? value) {
    if (value is num) return value.toDouble();
    final parsed = value is String ? double.tryParse(value) : null;
    if (parsed == null) throw const ApiException(ApiErrorKind.unknown);
    return parsed;
  }

  DateTime _date(Object? value) {
    final parsed = value is String ? DateTime.tryParse(value) : null;
    if (parsed == null) throw const ApiException(ApiErrorKind.unknown);
    return parsed;
  }

  ShipmentStatus _status(Object? value) => switch (value) {
    'assigned' => ShipmentStatus.assigned,
    'picked_up' => ShipmentStatus.pickedUp,
    'in_transit' => ShipmentStatus.inTransit,
    'delivered' => ShipmentStatus.delivered,
    'failed' => ShipmentStatus.failed,
    _ => throw const ApiException(ApiErrorKind.unknown),
  };

  String _statusToWire(ShipmentStatus status) => switch (status) {
    ShipmentStatus.assigned => 'assigned',
    ShipmentStatus.pickedUp => 'picked_up',
    ShipmentStatus.inTransit => 'in_transit',
    ShipmentStatus.delivered => 'delivered',
    ShipmentStatus.failed => 'failed',
  };
}
