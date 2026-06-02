import 'package:farm2fork_mobile/features/shipments/data/models/shipment.dart';

abstract class ShipmentsRepository {
  Future<List<Shipment>> getShipmentsByTransporter(String transporterId);
  Future<Shipment> updateShipmentStatus({
    required String shipmentId,
    required ShipmentStatus status,
    required String note,
    required String updatedBy,
  });
}
