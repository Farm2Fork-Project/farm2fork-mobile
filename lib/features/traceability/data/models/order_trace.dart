import 'product_trace.dart';

class OrderTraceItem {
  const OrderTraceItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    this.unit,
  });
  final String productId;
  final String productName;
  final num quantity;
  final String? unit;
}

/// Explicit public snapshot. Private order DTOs never feed this view.
class OrderTrace {
  const OrderTrace({
    required this.id,
    required this.reference,
    required this.status,
    required this.paidAt,
    required this.items,
    required this.events,
    required this.confirmedEvents,
    required this.totalEvents,
    required this.originVerified,
    required this.ledgerCheck,
    this.farm,
  });
  final String id, reference, status;
  final DateTime paidAt;
  final List<OrderTraceItem> items;
  final List<TraceEvent> events;
  final TraceFarm? farm;
  final int totalEvents, confirmedEvents;
  final bool originVerified;
  final String? ledgerCheck;
  bool get independentlyVerified => originVerified && ledgerCheck == 'checked';

  factory OrderTrace.fromJson(Map<String, dynamic> json) {
    final order = Map<String, dynamic>.from(json['order'] as Map);
    final summary = Map<String, dynamic>.from(json['summary'] as Map);
    final farmer = json['farmer'] as Map?;
    final events = <TraceEvent>[];
    const types = {
      'listed': TraceEventType.listed,
      'payment_confirmed': TraceEventType.paymentConfirmed,
      'shipment_assigned': TraceEventType.shipmentAssigned,
      'shipment_picked_up': TraceEventType.shipmentPickedUp,
      'shipment_in_transit': TraceEventType.shipmentInTransit,
      'shipment_delivered': TraceEventType.shipmentDelivered,
      'shipment_failed': TraceEventType.shipmentFailed,
    };
    for (final raw in json['events'] as List) {
      final event = Map<String, dynamic>.from(raw as Map);
      final type = types[event['type']];
      if (type == null) continue;
      final ledger = Map<String, dynamic>.from(event['ledger'] as Map);
      events.add(
        TraceEvent(
          id: event['id'] as String,
          type: type,
          occurredAt: DateTime.parse(event['occurredAt'] as String).toLocal(),
          location: event['location'] as String?,
          reference: event['reference'] as String?,
          ledger: TraceLedger(
            status: switch (ledger['status']) {
              'confirmed' => TraceLedgerStatus.confirmed,
              'failed' => TraceLedgerStatus.failed,
              _ => TraceLedgerStatus.pending,
            },
            txHash: ledger['txHash'] as String?,
            blockNumber: (ledger['blockNumber'] as num?)?.toInt(),
            onChain: ledger['onChain'] as String?,
            confirmedAt: ledger['confirmedAt'] == null
                ? null
                : DateTime.parse(ledger['confirmedAt'] as String),
          ),
        ),
      );
    }
    return OrderTrace(
      id: order['id'] as String,
      reference: order['reference'] as String,
      status: order['status'] as String,
      paidAt: DateTime.parse(order['paidAt'] as String).toLocal(),
      items: (order['items'] as List)
          .map((raw) {
            final item = raw as Map;
            return OrderTraceItem(
              productId: item['productId'] as String,
              productName: item['productName'] as String,
              quantity: item['quantity'] as num,
              unit: item['unit'] as String?,
            );
          })
          .toList(growable: false),
      events: events,
      farm: farmer == null
          ? null
          : TraceFarm(
              farmName: farmer['farmName'] as String,
              city: farmer['city'] as String?,
              province: farmer['province'] as String?,
            ),
      totalEvents: (summary['totalEvents'] as num).toInt(),
      confirmedEvents: (summary['confirmedEvents'] as num).toInt(),
      originVerified: summary['originVerified'] == true,
      ledgerCheck: summary['ledgerCheck'] as String?,
    );
  }
}
