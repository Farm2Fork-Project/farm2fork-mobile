import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'package:farm2fork_mobile/features/traceability/data/models/product_trace.dart';
import 'package:farm2fork_mobile/features/traceability/data/repositories/api_traceability_repository.dart';
import 'package:farm2fork_mobile/features/traceability/data/services/traceability_api_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubApi implements TraceabilityApiService {
  _StubApi({this.body, this.error});

  final Map<String, dynamic>? body;
  final ApiException? error;
  String? requested;

  @override
  Future<Map<String, dynamic>> fetchProductTrace(String productId) async {
    requested = productId;
    if (error != null) throw error!;
    return body!;
  }
}

Map<String, dynamic> _trace({
  List<Map<String, dynamic>>? events,
  Object? farmer = const {
    'farmName': 'Green Valley Farm',
    'city': 'Multan',
    'province': 'Punjab',
  },
  String? grade = 'A',
  bool originVerified = true,
}) => {
  'product': {
    'id': '6a2fe77bb77795516febc287',
    'name': 'Chaunsa Mangoes',
    'category': 'fruits',
    'unit': 'kg',
    'qualityGrade': ?grade,
    'status': 'sold_out',
    'listedAt': '2026-08-11T11:00:00.000Z',
  },
  'farmer': farmer,
  'events':
      events ??
      [
        {
          'id': 'e1',
          'type': 'listed',
          'occurredAt': '2026-08-11T11:00:00.000Z',
          'location': 'Multan, Punjab',
          'ledger': {
            'status': 'confirmed',
            'txHash': 'fabric-tx-1',
            'blockNumber': 42,
            'confirmedAt': '2026-08-11T11:00:04.000Z',
          },
        },
        {
          'id': 'e2',
          'type': 'shipment_in_transit',
          'occurredAt': '2026-08-12T09:00:00.000Z',
          'reference': 'C287A1',
          'ledger': {'status': 'pending'},
        },
      ],
  'summary': {
    'totalEvents': 2,
    'confirmedEvents': 1,
    'originVerified': originVerified,
  },
};

void main() {
  test('maps the public trace contract into typed models', () async {
    final api = _StubApi(body: _trace());
    final trace = await ApiTraceabilityRepository(
      api,
    ).fetchProductTrace('6a2fe77bb77795516febc287');

    expect(api.requested, '6a2fe77bb77795516febc287');
    expect(trace!.product.status, ProductStatus.soldOut);
    expect(trace.product.qualityGrade, QualityGrade.a);
    expect(trace.farm!.place, 'Multan, Punjab');
    expect(trace.origin, TraceOrigin.verified);
    expect(trace.events.map((e) => e.type), [
      TraceEventType.listed,
      TraceEventType.shipmentInTransit,
    ]);
    expect(trace.events.first.ledger.status, TraceLedgerStatus.confirmed);
    expect(trace.events.first.ledger.blockNumber, 42);
    expect(trace.events.last.ledger.status, TraceLedgerStatus.pending);
    expect(trace.events.last.reference, 'C287A1');
  });

  test('keeps an absent grade and farm absent instead of inventing them', () {
    final trace = ApiTraceabilityRepository.traceFromDto(
      _trace(grade: null, farmer: null),
    );
    expect(trace.product.qualityGrade, isNull);
    expect(trace.farm, isNull);
  });

  test('skips event types this client does not know yet', () {
    final trace = ApiTraceabilityRepository.traceFromDto(
      _trace(
        originVerified: false,
        events: [
          {
            'id': 'e9',
            'type': 'quality_inspected',
            'occurredAt': '2026-08-11T11:00:00.000Z',
            'ledger': {'status': 'pending'},
          },
        ],
      ),
    );
    expect(trace.events, isEmpty);
    expect(trace.origin, TraceOrigin.missing);
  });

  test(
    'returns null for an unknown product and rethrows other errors',
    () async {
      expect(
        await ApiTraceabilityRepository(
          _StubApi(error: const ApiException(ApiErrorKind.notFound)),
        ).fetchProductTrace('6a2fe77bb77795516febc287'),
        isNull,
      );
      expect(
        () => ApiTraceabilityRepository(
          _StubApi(error: const ApiException(ApiErrorKind.network)),
        ).fetchProductTrace('6a2fe77bb77795516febc287'),
        throwsA(isA<ApiException>()),
      );
    },
  );
}
