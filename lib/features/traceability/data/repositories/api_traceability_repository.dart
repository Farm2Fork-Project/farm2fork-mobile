import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/features/marketplace/data/mappers/product_dto_mapper.dart';
import 'package:farm2fork_mobile/features/traceability/data/models/product_trace.dart';
import 'package:farm2fork_mobile/features/traceability/data/repositories/traceability_repository.dart';
import 'package:farm2fork_mobile/features/traceability/data/services/traceability_api_service.dart';

/// Real [TraceabilityRepository] over the public `GET /trace/products/:id`.
class ApiTraceabilityRepository implements TraceabilityRepository {
  ApiTraceabilityRepository(this._api);

  final TraceabilityApiService _api;

  @override
  Future<ProductTrace?> fetchProductTrace(String productId) async {
    try {
      return traceFromDto(await _api.fetchProductTrace(productId));
    } on ApiException catch (e) {
      if (e.kind == ApiErrorKind.notFound) return null;
      rethrow;
    }
  }

  /// Visible for tests.
  static ProductTrace traceFromDto(Map<String, dynamic> dto) {
    final product = _map(dto['product']);
    final summary = _map(dto['summary']);
    final farmer = dto['farmer'];
    final events = dto['events'];
    if (events is! List) throw const ApiException(ApiErrorKind.unknown);

    final grade = product['qualityGrade'] as String?;
    return ProductTrace(
      product: TraceProductSummary(
        id: _string(product, 'id'),
        name: _string(product, 'name'),
        category: ProductDtoMapper.categoryFromWire(
          product['category'] as String?,
        ),
        unit: ProductDtoMapper.unitFromWire(product['unit'] as String?),
        status: ProductDtoMapper.statusFromWire(product['status'] as String?),
        listedAt: _date(product['listedAt']),
        // Unlike the marketplace, an absent grade must stay absent here.
        qualityGrade: grade == null
            ? null
            : ProductDtoMapper.gradeFromWire(grade),
        imageUrl: product['imageUrl'] as String?,
      ),
      farm: farmer is Map
          ? TraceFarm(
              farmName: _string(Map<String, dynamic>.from(farmer), 'farmName'),
              city: farmer['city'] as String?,
              province: farmer['province'] as String?,
            )
          : null,
      // Event types this client doesn't know yet are skipped, not fatal.
      events: events
          .map(_event)
          .whereType<TraceEvent>()
          .toList(growable: false),
      totalEvents: (summary['totalEvents'] as num?)?.toInt() ?? 0,
      confirmedEvents: (summary['confirmedEvents'] as num?)?.toInt() ?? 0,
      originVerified: summary['originVerified'] == true,
    );
  }

  static TraceEvent? _event(Object? value) {
    final dto = _map(value);
    final type = switch (dto['type']) {
      'listed' => TraceEventType.listed,
      'payment_confirmed' => TraceEventType.paymentConfirmed,
      'shipment_assigned' => TraceEventType.shipmentAssigned,
      'shipment_picked_up' => TraceEventType.shipmentPickedUp,
      'shipment_in_transit' => TraceEventType.shipmentInTransit,
      'shipment_delivered' => TraceEventType.shipmentDelivered,
      'shipment_failed' => TraceEventType.shipmentFailed,
      _ => null,
    };
    if (type == null) return null;
    final ledger = _map(dto['ledger']);
    final confirmedAt = ledger['confirmedAt'];
    return TraceEvent(
      id: _string(dto, 'id'),
      type: type,
      occurredAt: _date(dto['occurredAt']),
      location: dto['location'] as String?,
      reference: dto['reference'] as String?,
      ledger: TraceLedger(
        status: switch (ledger['status']) {
          'confirmed' => TraceLedgerStatus.confirmed,
          'failed' => TraceLedgerStatus.failed,
          _ => TraceLedgerStatus.pending,
        },
        txHash: ledger['txHash'] as String?,
        blockNumber: (ledger['blockNumber'] as num?)?.toInt(),
        confirmedAt: confirmedAt == null ? null : _date(confirmedAt),
      ),
    );
  }

  static Map<String, dynamic> _map(Object? value) {
    if (value is! Map) throw const ApiException(ApiErrorKind.unknown);
    return Map<String, dynamic>.from(value);
  }

  static String _string(Map<String, dynamic> dto, String key) {
    final value = dto[key];
    if (value is! String || value.isEmpty) {
      throw const ApiException(ApiErrorKind.unknown);
    }
    return value;
  }

  static DateTime _date(Object? value) {
    final parsed = value is String ? DateTime.tryParse(value) : null;
    if (parsed == null) throw const ApiException(ApiErrorKind.unknown);
    return parsed.toLocal();
  }
}
