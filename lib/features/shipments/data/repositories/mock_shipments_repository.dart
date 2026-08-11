import 'package:farm2fork_mobile/features/shipments/data/models/available_delivery.dart';
import 'package:farm2fork_mobile/features/shipments/data/models/shipment.dart';
import 'shipments_repository.dart';

class MockShipmentsRepository extends ShipmentsRepository {
  final List<AvailableDelivery> _available = [
    AvailableDelivery(
      orderId: 'ord_2001',
      pickupCity: 'Faisalabad',
      pickupProvince: 'Punjab',
      deliveryCity: 'Lahore',
      deliveryProvince: 'Punjab',
      itemCount: 2,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

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
  Future<List<AvailableDelivery>> getAvailable() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_available);
  }

  @override
  Future<List<Shipment>> getMine() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_shipments);
  }

  @override
  Future<Shipment> getById(String shipmentId) async {
    final shipment = _shipments.where((item) => item.id == shipmentId).firstOrNull;
    if (shipment == null) throw Exception('Shipment not found');
    return shipment;
  }

  @override
  Future<Shipment> claim(String orderId) async {
    final available = _available.where((item) => item.orderId == orderId).firstOrNull;
    if (available == null) throw Exception('Delivery is no longer available');
    final now = DateTime.now();
    final shipment = Shipment(
      id: 'ship_${now.microsecondsSinceEpoch}',
      orderId: available.orderId,
      transporterId: 'mock_transporter_001',
      status: ShipmentStatus.assigned,
      pickupAddress: ShipmentAddress(
        street: 'Mock Farm, ${available.pickupCity}',
        city: available.pickupCity,
        province: available.pickupProvince,
      ),
      deliveryAddress: ShipmentAddress(
        street: 'Mock Delivery Address',
        city: available.deliveryCity,
        province: available.deliveryProvince,
      ),
      statusHistory: [
        ShipmentStatusUpdate(
          status: ShipmentStatus.assigned,
          timestamp: now,
          note: 'Shipment claimed by transporter',
          updatedBy: 'mock_transporter_001',
        ),
      ],
      estimatedDelivery: now.add(const Duration(hours: 48)),
      createdAt: now,
      updatedAt: now,
    );
    _available.remove(available);
    _shipments.add(shipment);
    return shipment;
  }

  @override
  Future<Shipment> updateStatus({
    required String shipmentId,
    required ShipmentStatus status,
    required String note,
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
            updatedBy: 'mock_transporter_001',
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
