import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/features/shipments/data/models/shipment.dart';
import 'shipments_repository.dart';

final shipmentsRepositoryProvider = Provider<ShipmentsRepository>((ref) {
  return MockShipmentsRepository();
});

class MockShipmentsRepository implements ShipmentsRepository {
  final List<Shipment> _shipments = [
    Shipment(
      id: 'ship_3001',
      orderId: 'ord_1001',
      transporterId: 'mock_transporter_001',
      status: ShipmentStatus.assigned,
      pickupAddress: const ShipmentAddress(
        street: 'Hassan Organic Farm, Multan Road',
        city: 'Multan',
        province: 'Punjab',
      ),
      deliveryAddress: const ShipmentAddress(
        street: 'Building 14B, Gulberg III',
        city: 'Lahore',
        province: 'Punjab',
        zip: '54000',
      ),
      statusHistory: [
        ShipmentStatusUpdate(
          status: ShipmentStatus.assigned,
          timestamp: DateTime.now().subtract(const Duration(hours: 4)),
          note: 'Shipment assigned to transporter',
          updatedBy: 'system_admin',
        ),
      ],
      estimatedDelivery: DateTime.now().add(const Duration(hours: 6)),
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    Shipment(
      id: 'ship_3002',
      orderId: 'ord_1002',
      transporterId: 'mock_transporter_001',
      status: ShipmentStatus.delivered,
      pickupAddress: const ShipmentAddress(
        street: 'Sindh Mango Estate, VIP Road',
        city: 'Hyderabad',
        province: 'Sindh',
      ),
      deliveryAddress: const ShipmentAddress(
        street: 'Building 14B, Gulberg III',
        city: 'Lahore',
        province: 'Punjab',
        zip: '54000',
      ),
      statusHistory: [
        ShipmentStatusUpdate(
          status: ShipmentStatus.assigned,
          timestamp: DateTime.now().subtract(const Duration(days: 4)),
          note: 'Shipment assigned to transporter',
          updatedBy: 'system_admin',
        ),
        ShipmentStatusUpdate(
          status: ShipmentStatus.pickedUp,
          timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
          note: 'Picked up from Hyderabad estate',
          updatedBy: 'transporter_001',
        ),
        ShipmentStatusUpdate(
          status: ShipmentStatus.inTransit,
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          note: 'Enroute via national highway',
          updatedBy: 'transporter_001',
        ),
        ShipmentStatusUpdate(
          status: ShipmentStatus.delivered,
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          note: 'Delivered directly to warehouse buyer',
          updatedBy: 'transporter_001',
        ),
      ],
      estimatedDelivery: DateTime.now().subtract(const Duration(days: 2)),
      actualDelivery: DateTime.now().subtract(const Duration(days: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Future<List<Shipment>> getShipmentsByTransporter(String transporterId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final normalizedId = transporterId.replaceAll('mock_', '');
    return _shipments
        .where(
          (s) =>
              s.transporterId == transporterId ||
              s.transporterId == normalizedId,
        )
        .toList();
  }

  @override
  Future<Shipment> updateShipmentStatus({
    required String shipmentId,
    required ShipmentStatus status,
    required String note,
    required String updatedBy,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final index = _shipments.indexWhere((s) => s.id == shipmentId);
    if (index == -1) throw Exception('Shipment not found');

    final shipment = _shipments[index];
    final updatedHistory =
        List<ShipmentStatusUpdate>.from(shipment.statusHistory)..add(
          ShipmentStatusUpdate(
            status: status,
            timestamp: DateTime.now(),
            note: note,
            updatedBy: updatedBy,
          ),
        );

    final updated = shipment.copyWith(
      status: status,
      statusHistory: updatedHistory,
      actualDelivery: status == ShipmentStatus.delivered
          ? DateTime.now()
          : shipment.actualDelivery,
      updatedAt: DateTime.now(),
    );

    _shipments[index] = updated;
    return updated;
  }
}
