import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/features/notifications/push_registration.dart';

void main() {
  test('account change invalidates a deferred SDK registration', () async {
    final operations = PushOperations()..beginSession('a');
    final token = Completer<String>();
    final writes = <String>[];
    final pending = operations.register((current) async {
      final value = await token.future;
      if (!current()) return false;
      writes.add(value);
      return true;
    });
    await Future<void>.delayed(Duration.zero);
    operations.beginSession('b');
    token.complete('old-user-token');
    expect(await pending, false);
    expect(writes, isEmpty);
  });
  test(
    'revocation drains an in-flight PUT and blocks subsequent refreshes',
    () async {
      final operations = PushOperations()..beginSession('a');
      final put = Completer<void>();
      final events = <String>[];
      final registration = operations.register((current) async {
        if (!current()) return false;
        events.add('PUT');
        await put.future;
        return current();
      });
      await Future<void>.delayed(Duration.zero);
      final cleanup = operations.revoke(() async {
        events.add('DELETE');
      });
      expect(events, ['PUT']);
      put.complete();
      await cleanup;
      expect(await registration, false);
      expect(events, ['PUT', 'DELETE']);
      expect(await operations.register((current) async => current()), false);
      operations.enable();
      expect(await operations.register((current) async => current()), true);
    },
  );
}
