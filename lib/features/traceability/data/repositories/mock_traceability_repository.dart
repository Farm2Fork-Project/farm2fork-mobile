import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product_category.dart';
import 'package:farm2fork_mobile/features/traceability/data/models/product_trace.dart';
import 'traceability_repository.dart';

/// Offline trace for `USE_MOCKS=true` builds. Carries data only (names,
/// places, hashes); every label on screen comes from the ARB files. Exercises
/// all three ledger states so the UI can be reviewed without a backend.
class MockTraceabilityRepository implements TraceabilityRepository {
  static const knownProductId = '6a2fe77bb77795516febc287';

  @override
  Future<ProductTrace?> fetchProductTrace(String productId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (productId != knownProductId) return null;

    final now = DateTime.now();
    TraceLedger confirmed(String hash, int block, DateTime at) => TraceLedger(
      status: TraceLedgerStatus.confirmed,
      txHash: hash,
      blockNumber: block,
      confirmedAt: at,
    );

    final events = [
      TraceEvent(
        id: 'e1',
        type: TraceEventType.listed,
        occurredAt: now.subtract(const Duration(days: 4)),
        location: 'Multan, Punjab',
        ledger: confirmed(
          'b7e3c1f09a4d2e6b8c5a1f3d7e9b0c2a4f6e8d1b3c5a7e9f0d2b4c6e8a1f3d5b',
          42,
          now.subtract(const Duration(days: 4)),
        ),
      ),
      TraceEvent(
        id: 'e2',
        type: TraceEventType.paymentConfirmed,
        occurredAt: now.subtract(const Duration(days: 3)),
        reference: '874368',
        ledger: confirmed(
          '8fce8259ab5aad0fee09b7767efcb62851942a3a0da9a9970193dd50af8292c2',
          100,
          now.subtract(const Duration(days: 3)),
        ),
      ),
      TraceEvent(
        id: 'e3',
        type: TraceEventType.shipmentPickedUp,
        occurredAt: now.subtract(const Duration(days: 1)),
        location: 'Multan, Punjab',
        reference: '874377',
        ledger: confirmed(
          'b9c1d40ed0ec9100611b6e52454c020f795ac2c0b48d65a8f31f12122c691962',
          102,
          now.subtract(const Duration(days: 1)),
        ),
      ),
      TraceEvent(
        id: 'e4',
        type: TraceEventType.shipmentInTransit,
        occurredAt: now.subtract(const Duration(hours: 5)),
        location: 'Multan, Punjab',
        reference: '874377',
        ledger: const TraceLedger(status: TraceLedgerStatus.pending),
      ),
    ];

    return ProductTrace(
      product: TraceProductSummary(
        id: knownProductId,
        name: 'Chaunsa Mangoes',
        category: ProductCategory.fruits,
        unit: ProductUnit.kg,
        status: ProductStatus.active,
        qualityGrade: QualityGrade.a,
        listedAt: now.subtract(const Duration(days: 4)),
      ),
      farm: const TraceFarm(
        farmName: 'Green Valley Farm',
        city: 'Multan',
        province: 'Punjab',
      ),
      events: events,
      totalEvents: events.length,
      confirmedEvents: 3,
      originVerified: true,
    );
  }
}
