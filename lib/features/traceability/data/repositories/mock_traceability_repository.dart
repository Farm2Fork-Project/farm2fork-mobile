import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'traceability_repository.dart';

final traceabilityRepositoryProvider = Provider<TraceabilityRepository>((ref) {
  return MockTraceabilityRepository();
});

class MockTraceabilityRepository implements TraceabilityRepository {
  @override
  Future<List<TraceabilityEvent>> fetchTraceJourney(String productId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final now = DateTime.now();

    return [
      ListingTraceEvent(
        timestamp: now.subtract(const Duration(days: 4)),
        txHash: 'tx_fabric_f2f_819ab0d2b99210cfa0981e4c7d',
        location: 'Multan, Punjab (Hassan Organic Farm)',
        actorName: 'Ali Hassan',
        details:
            'Crops listed on marketplace. Quality grade: A. Initial batch size: 200 kg.',
      ),
      PaymentTraceEvent(
        timestamp: now.subtract(const Duration(days: 3)),
        txHash: 'tx_fabric_f2f_a119c4d92ee88a912bb09cde78',
        location: 'Lahore, Punjab (JazzCash Gateway)',
        actorName: 'Muhammad Junaid',
        details:
            'Payment of Rs 1,680 confirmed. Platform fee of 5% collected successfully.',
      ),
      ShipmentTraceEvent(
        eventType: 'Shipment Dispatch (Picked Up)',
        timestamp: now.subtract(const Duration(days: 1)),
        txHash: 'tx_fabric_f2f_c0199ddb2ee90e11ba099c27ee',
        location: 'Multan, Punjab (Hassan Organic Farm)',
        actorName: 'Qaim Raza',
        actorRole: 'Transporter',
        details: 'Shipment loaded successfully. License number: LHR-2026-DESI.',
      ),
      ShipmentTraceEvent(
        eventType: 'Delivery Completed',
        timestamp: now.subtract(const Duration(hours: 4)),
        txHash: 'tx_fabric_f2f_d991bce98c21a00a12bb774cd2',
        location: 'Lahore, Punjab (Gulberg III Warehouse)',
        actorName: 'Qaim Raza',
        actorRole: 'Transporter',
        details:
            'Produce hand-delivered to buyer. Quality check at delivery verified: Fresh.',
      ),
    ];
  }
}
