import 'package:farm2fork_mobile/features/traceability/data/utils/trace_id_parser.dart';
import 'package:flutter_test/flutter_test.dart';

const _id = '6a2fe77bb77795516febc287';

void main() {
  test('accepts a bare id, normalizing case and whitespace', () {
    expect(parseTraceProductId('  ${_id.toUpperCase()} '), _id);
  });

  test('extracts the id from a scanned QR trace link', () {
    expect(parseTraceProductId('https://farm2fork.com/trace/$_id'), _id);
    expect(parseTraceProductId('http://localhost:3001/trace/$_id/'), _id);
    expect(parseTraceProductId('https://x.pk/trace/$_id?src=qr#top'), _id);
  });

  test('rejects input that cannot be a product id', () {
    expect(parseTraceProductId(''), isNull);
    expect(parseTraceProductId('prod_001'), isNull);
    expect(parseTraceProductId('https://farm2fork.com/trace/'), isNull);
    expect(parseTraceProductId('${_id}00'), isNull);
  });

  test('shortens long ledger hashes but keeps short ones', () {
    expect(shortenTxHash('abc123'), 'abc123');
    expect(
      shortenTxHash('0123456789abcdefghijklmnopqrstuvwxyz'),
      '0123456789…stuvwxyz',
    );
  });
}
