import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/core/config/app_config.dart';

void main() {
  test('defaults to the backend API prefix on the Android emulator', () {
    expect(AppConfig.apiBaseUrl, 'http://10.0.2.2:3000/api');
  });

  test('uses real repositories unless mock mode is explicitly enabled', () {
    expect(AppConfig.useMocks, isFalse);
  });
}
