abstract class TraceabilityEvent {
  String get eventType;
  DateTime get timestamp;
  String get txHash;
  String get location;
  String get actorName;
  String get actorRole;
  String get details;
}

class ListingTraceEvent implements TraceabilityEvent {
  ListingTraceEvent({
    required this.timestamp,
    required this.txHash,
    required this.location,
    required this.actorName,
    required this.details,
  });

  @override
  String get eventType => 'Product Listing';
  @override
  final DateTime timestamp;
  @override
  final String txHash;
  @override
  final String location;
  @override
  final String actorName;
  @override
  String get actorRole => 'Farmer';
  @override
  final String details;
}

class PaymentTraceEvent implements TraceabilityEvent {
  PaymentTraceEvent({
    required this.timestamp,
    required this.txHash,
    required this.location,
    required this.actorName,
    required this.details,
  });

  @override
  String get eventType => 'Payment Confirmed';
  @override
  final DateTime timestamp;
  @override
  final String txHash;
  @override
  final String location;
  @override
  final String actorName;
  @override
  String get actorRole => 'Buyer';
  @override
  final String details;
}

class ShipmentTraceEvent implements TraceabilityEvent {
  ShipmentTraceEvent({
    required this.eventType,
    required this.timestamp,
    required this.txHash,
    required this.location,
    required this.actorName,
    required this.actorRole,
    required this.details,
  });

  @override
  final String eventType; // Picked Up, In Transit, Delivered
  @override
  final DateTime timestamp;
  @override
  final String txHash;
  @override
  final String location;
  @override
  final String actorName;
  @override
  final String actorRole; // Transporter
  @override
  final String details;
}

abstract class TraceabilityRepository {
  Future<List<TraceabilityEvent>> fetchTraceJourney(String productId);
}
