import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/features/traceability/data/models/order_trace.dart';
import 'package:farm2fork_mobile/features/traceability/data/utils/trace_id_parser.dart';

const id = '6a2fe77bb77795516febc287';
void main() {
  test('recognizes canonical and scheme order links without confusing products', () {
    expect(parseTraceLink('https://farm2fork.tech/trace/orders/$id')?.kind, TraceLinkKind.order);
    expect(parseTraceLink('farm2fork://app/trace/orders/$id')?.id, id);
    expect(parseTraceProductId('https://farm2fork.tech/trace/orders/$id'), isNull);
    expect(parseTraceLink('https://farm2fork.tech/trace/$id')?.kind, TraceLinkKind.product);
  });
  test('rejects foreign links, arbitrary paths, credentials and unsupported schemes', () {
    for (final link in ['https://evil.test/trace/$id', 'https://farm2fork.tech/other/$id', 'https://name@farm2fork.tech/trace/$id', 'javascript:/trace/$id']) {
      expect(parseTraceLink(link), isNull, reason: link);
    }
  });
  test('maps snapshot quantities and proof without trusting unavailable readback', () {
    final trace = OrderTrace.fromJson({
      'order': {'id': id, 'reference': 'EBC287', 'status': 'paid', 'paidAt': '2026-10-28T10:00:00Z', 'items': [{'productId': id, 'productName': 'Mangoes', 'quantity': 2, 'unit': 'kg'}]},
      'farmer': {'farmName': 'Test farm'}, 'events': [],
      'summary': {'totalEvents': 0, 'confirmedEvents': 0, 'originVerified': true, 'ledgerCheck': 'unavailable'},
    });
    expect(trace.items.single.productName, 'Mangoes');
    expect(trace.independentlyVerified, isFalse);
  });
}
