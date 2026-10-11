import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/features/notifications/push_registration.dart';

class _Gateway implements PushGateway {
  bool allowed = false;
  int deletions = 0;
  @override
  Future<bool> requestPermission() async => allowed;
  @override
  Future<String?> getToken() async => 'device';
  @override
  Future<void> deleteToken() async {
    deletions++;
  }
}

void main() {
  test(
    'permission denial does not register and enabled token is cleared on disable',
    () async {
      final gateway = _Gateway();
      final requests = <String>[];
      final registration = PushRegistration(
        gateway,
        (token) async {
          requests.add('register:$token');
        },
        () async {
          requests.add('clear');
        },
      );
      expect(await registration.enable(), false);
      expect(requests, isEmpty);
      gateway.allowed = true;
      expect(await registration.enable(), true);
      await registration.disable();
      expect(requests, ['register:device', 'clear']);
      expect(gateway.deletions, 1);
    },
  );
  test('backend registration failure stays retryable', () async {
    final gateway = _Gateway()..allowed = true;
    var fail = true;
    final registration = PushRegistration(gateway, (_) async {
      if (fail) throw StateError('offline');
    }, () async {});
    await expectLater(registration.enable(), throwsStateError);
    fail = false;
    expect(await registration.enable(), true);
  });
}
