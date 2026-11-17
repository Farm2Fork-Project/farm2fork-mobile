import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/app/navigation/order_auth_recovery.dart';

const orderPath = '/orders/6a2fe77bb77795516febc287';
void main() {
  test(
    'preserves exact order across login, verification and onboarding once',
    () {
      final recovery = OrderAuthRecovery();
      recovery.observe(Uri.parse(orderPath), authenticated: false);
      for (final path in ['/auth/login', '/auth/verify', '/auth/onboarding']) {
        recovery.observe(Uri.parse(path), authenticated: false);
      }
      recovery.observe(Uri.parse('/auth/onboarding'), authenticated: true);
      expect(recovery.consume(), orderPath);
      expect(recovery.consume(), isNull);
    },
  );
  test(
    'accepts validated next and rejects external or arbitrary destinations',
    () {
      for (final next in [
        'https://evil.test',
        '//evil.test',
        '/buyer/orders',
        '$orderPath?x=1',
        '/orders/bad',
      ]) {
        final recovery = OrderAuthRecovery();
        recovery.observe(
          Uri(path: '/auth/login', queryParameters: {'next': next}),
          authenticated: false,
        );
        expect(recovery.consume(), isNull);
      }
      final recovery = OrderAuthRecovery();
      recovery.observe(
        Uri(path: '/auth/login', queryParameters: {'next': orderPath}),
        authenticated: false,
      );
      expect(recovery.consume(), orderPath);
    },
  );
  test('leaving auth flow cancels pending destination', () {
    final recovery = OrderAuthRecovery();
    recovery.observe(Uri.parse(orderPath), authenticated: false);
    recovery.observe(Uri.parse('/guest/marketplace'), authenticated: false);
    expect(recovery.consume(), isNull);
  });
}
