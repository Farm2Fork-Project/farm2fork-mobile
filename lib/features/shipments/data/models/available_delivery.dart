import 'package:farm2fork_mobile/core/location/geo_point.dart';

class OfferItem {
  const OfferItem({required this.productName, required this.quantity});

  final String productName;
  final double quantity;
}

/// A delivery offered to a nearby online transporter at a fixed price. The
/// pickup is the farm's exact pin; the drop-off is only an approximate area
/// (~1 km) without a street until the transporter accepts.
class AvailableDelivery {
  const AvailableDelivery({
    required this.orderId,
    required this.pickupCity,
    required this.pickupProvince,
    required this.deliveryCity,
    required this.deliveryProvince,
    required this.itemCount,
    required this.createdAt,
    required this.deliveryFee,
    required this.deliveryDistanceKm,
    required this.distanceToPickupKm,
    required this.pickup,
    required this.dropoffArea,
    this.farmName,
    this.items = const [],
  });

  final String orderId;
  final String pickupCity;
  final String pickupProvince;
  final String deliveryCity;
  final String deliveryProvince;
  final int itemCount;
  final DateTime createdAt;

  /// What the transporter earns (PKR).
  final double deliveryFee;

  /// Estimated road distance farm -> drop-off.
  final double deliveryDistanceKm;

  /// Straight-line distance from the transporter to the farm.
  final double distanceToPickupKm;
  final GeoPoint pickup;
  final GeoPoint dropoffArea;
  final String? farmName;
  final List<OfferItem> items;
}

/// The transporter's own dispatch state from the server.
class TransporterStatus {
  const TransporterStatus({
    required this.online,
    required this.locationFresh,
    required this.radiusKm,
    this.lastLocationAt,
    this.activeShipmentId,
  });

  final bool online;

  /// False when the last reported location is too old to match offers.
  final bool locationFresh;
  final double radiusKm;
  final DateTime? lastLocationAt;

  /// Set while a delivery is in progress (one at a time).
  final String? activeShipmentId;
}
