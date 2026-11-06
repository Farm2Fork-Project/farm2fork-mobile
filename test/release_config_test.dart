import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/core/config/release_config.dart';

void main() {
  List<String> validate({
    String api = 'https://api.example.com/api',
    String trace = 'https://example.com',
    String host = 'example.com',
    bool explicit = true,
    String mocks = 'false',
    String simulator = 'false',
  }) => validateReleaseConfig(
    apiBaseUrl: api,
    publicTraceOrigin: trace,
    traceLinkHost: host,
    apiExplicit: explicit,
    traceExplicit: explicit,
    useMocks: mocks,
    paymentSimulator: simulator,
  );
  test(
    'explicit HTTPS production configuration passes',
    () => expect(validate(), isEmpty),
  );
  test('omitted configuration and emulator default fail', () {
    expect(validate(explicit: false), isNotEmpty);
    expect(validate(api: 'http://10.0.2.2:3000/api'), isNotEmpty);
    expect(validate(api: 'https://localhost/api'), isNotEmpty);
  });
  test('credentials, non-origin trace URL and host mismatch fail', () {
    expect(validate(api: 'https://user:password@example.com/api'), isNotEmpty);
    expect(validate(trace: 'https://example.com/trace'), isNotEmpty);
    expect(validate(host: 'other.example.com'), isNotEmpty);
  });
  test('mock, simulator and malformed boolean values fail', () {
    for (final value in ['true', '1', 'FALSE', '']) {
      expect(validate(mocks: value), isNotEmpty);
      expect(validate(simulator: value), isNotEmpty);
    }
  });
}
