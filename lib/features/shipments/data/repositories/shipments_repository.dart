import 'package:farm2fork_mobile/core/location/geo_point.dart';
import 'package:farm2fork_mobile/features/shipments/data/models/available_delivery.dart';
import 'package:farm2fork_mobile/features/shipments/data/models/shipment.dart';

abstract class ShipmentsRepository {
  /// Offers near the transporter's last location (empty while offline or
  /// during a delivery).
  Future<List<AvailableDelivery>> getAvailable();

  Future<TransporterStatus> getStatus();

  /// Going online requires the current [location].
  Future<TransporterStatus> setAvailability({
    required bool online,
    GeoPoint? location,
  });

  /// Foreground heartbeat while online.
  Future<void> reportLocation(GeoPoint location);

  /// Hides an offer for this transporter.
  Future<void> decline(String orderId);

  Future<List<Shipment>> getMine();

  Future<Shipment> getById(String shipmentId);

  Future<Shipment> claim(String orderId);

  Future<Shipment> updateStatus({
    required String shipmentId,
    required ShipmentStatus status,
    required String note,
  });

  /// Temporary compatibility for the existing transporter screen. The backend
  /// identifies the caller from the JWT; no transporter id is sent by clients.
  Future<List<Shipment>> getShipmentsByTransporter(String transporterId) =>
      getMine();

  /// Temporary compatibility for the existing transporter screen. The real
  /// API ignores the deprecated client identity and sends only status + note.
  Future<Shipment> updateShipmentStatus({
    required String shipmentId,
    required ShipmentStatus status,
    required String note,
    required String updatedBy,
  }) => updateStatus(shipmentId: shipmentId, status: status, note: note);
}
