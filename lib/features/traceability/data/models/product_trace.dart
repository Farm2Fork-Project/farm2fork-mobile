import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product_category.dart';

/// Supply-chain milestones a public trace can show, in lifecycle order.
enum TraceEventType {
  listed,
  paymentConfirmed,
  shipmentAssigned,
  shipmentPickedUp,
  shipmentInTransit,
  shipmentDelivered,
  shipmentFailed,
}

/// `pending` = durably queued for the ledger but not yet committed; only
/// `confirmed` events carry a Hyperledger Fabric transaction id.
enum TraceLedgerStatus { pending, confirmed, failed }

/// Whether the product's origin (its `listed` event) is proven on-chain.
enum TraceOrigin { verified, pending, missing }

class TraceLedger {
  const TraceLedger({
    required this.status,
    this.txHash,
    this.blockNumber,
    this.confirmedAt,
  });

  final TraceLedgerStatus status;
  final String? txHash;
  final int? blockNumber;
  final DateTime? confirmedAt;
}

class TraceEvent {
  const TraceEvent({
    required this.id,
    required this.type,
    required this.occurredAt,
    required this.ledger,
    this.location,
    this.reference,
  });

  final String id;
  final TraceEventType type;
  final DateTime occurredAt;

  /// City-level only, never a street address.
  final String? location;

  /// Short, non-identifying reference grouping one sale or delivery.
  final String? reference;
  final TraceLedger ledger;
}

class TraceProductSummary {
  const TraceProductSummary({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.status,
    required this.listedAt,
    this.qualityGrade,
    this.imageUrl,
  });

  final String id;
  final String name;
  final ProductCategory category;
  final ProductUnit unit;
  final ProductStatus status;
  final DateTime listedAt;
  final QualityGrade? qualityGrade;
  final String? imageUrl;
}

class TraceFarm {
  const TraceFarm({required this.farmName, this.city, this.province});

  final String farmName;
  final String? city;
  final String? province;

  String? get place {
    final parts = [
      city,
      province,
    ].whereType<String>().where((p) => p.isNotEmpty);
    return parts.isEmpty ? null : parts.join(', ');
  }
}

/// A product's public provenance journey from `GET /trace/products/:id`.
class ProductTrace {
  const ProductTrace({
    required this.product,
    required this.events,
    required this.totalEvents,
    required this.confirmedEvents,
    required this.originVerified,
    this.farm,
  });

  final TraceProductSummary product;
  final TraceFarm? farm;
  final List<TraceEvent> events;
  final int totalEvents;
  final int confirmedEvents;
  final bool originVerified;

  TraceOrigin get origin {
    if (originVerified) return TraceOrigin.verified;
    return events.any((e) => e.type == TraceEventType.listed)
        ? TraceOrigin.pending
        : TraceOrigin.missing;
  }
}
