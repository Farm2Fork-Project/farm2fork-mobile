import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:farm2fork_mobile/core/config/app_config.dart';
import 'package:farm2fork_mobile/core/network/network_providers.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'push_registration.dart';

class FirebasePushGateway implements PushGateway {
  @override
  Future<bool> requestPermission() async {
    final result = await FirebaseMessaging.instance.requestPermission();
    return result.authorizationStatus == AuthorizationStatus.authorized ||
        result.authorizationStatus == AuthorizationStatus.provisional;
  }

  @override
  Future<String?> getToken() => FirebaseMessaging.instance.getToken();
  @override
  Future<void> deleteToken() => FirebaseMessaging.instance.deleteToken();
}

final pushGatewayProvider = Provider<PushGateway>(
  (ref) => FirebasePushGateway(),
);
final pushOperationsProvider = Provider<PushOperations>(
  (ref) => PushOperations(),
);
final pushControllerProvider = AsyncNotifierProvider<PushController, bool>(
  PushController.new,
);

// Independent from authControllerProvider so sign-out can clear the token before
// clearing the JWT without introducing a provider dependency cycle.
final pushLogoutCleanupProvider = Provider<Future<void> Function(String)>((
  ref,
) {
  return (userId) => ref.read(pushOperationsProvider).revoke(() async {
    if (AppConfig.useMocks || Firebase.apps.isEmpty) return;
    const storage = FlutterSecureStorage();
    await ref.read(dioProvider).delete('/notifications/device-token');
    await ref.read(pushGatewayProvider).deleteToken();
    await storage.delete(key: 'push.enabled.$userId');
  });
});

class PushController extends AsyncNotifier<bool> {
  static const _storage = FlutterSecureStorage();
  String? get _userId => ref.read(authControllerProvider).value?.user?.id;
  String _key(String userId) => 'push.enabled.$userId';
  @override
  Future<bool> build() async {
    final user = ref.watch(authControllerProvider).value?.user;
    ref.read(pushOperationsProvider).beginSession(user?.id);
    if (user == null || AppConfig.useMocks || Firebase.apps.isEmpty) {
      return false;
    }
    final enabled = await _storage.read(key: _key(user.id)) == 'true';
    if (!enabled) return false;
    // Restoring a prior opt-in never opens a new permission prompt.
    final permission = await FirebaseMessaging.instance
        .getNotificationSettings();
    if (permission.authorizationStatus != AuthorizationStatus.authorized &&
        permission.authorizationStatus != AuthorizationStatus.provisional) {
      return false;
    }
    final restored = await _registerFor(user.id, requestPermission: false);
    if (!ref.mounted || _userId != user.id || !restored) return false;
    final subscription = FirebaseMessaging.instance.onTokenRefresh.listen((
      token,
    ) {
      if (_userId == user.id) {
        unawaitedRefresh(user.id, token);
      }
    });
    ref.onDispose(subscription.cancel);
    return restored;
  }

  Future<bool> _registerFor(
    String userId, {
    required bool requestPermission,
    String? refreshedToken,
  }) {
    final gateway = ref.read(pushGatewayProvider);
    final operations = ref.read(pushOperationsProvider);
    return operations.register((current) async {
      bool valid() => current() && ref.mounted && _userId == userId;
      if (!valid()) return false;
      if (requestPermission && !await gateway.requestPermission()) return false;
      if (!valid()) return false;
      final token = refreshedToken ?? await gateway.getToken();
      if (!valid() || token == null || token.isEmpty) return false;
      await ref
          .read(dioProvider)
          .put('/notifications/device-token', data: {'token': token});
      if (!valid()) return false;
      if (requestPermission) {
        await _storage.write(key: _key(userId), value: 'true');
      }
      return valid();
    });
  }

  Future<void> unawaitedRefresh(String userId, String token) async {
    try {
      await _registerFor(
        userId,
        requestPermission: false,
        refreshedToken: token,
      );
    } catch (error, stack) {
      if (ref.mounted) state = AsyncError(error, stack);
    }
  }

  Future<bool> enable() async {
    final userId = _userId;
    if (userId == null || AppConfig.useMocks) return false;
    ref.read(pushOperationsProvider).enable();
    final enabled = await _registerFor(userId, requestPermission: true);
    if (enabled && ref.mounted && _userId == userId) ref.invalidateSelf();
    return enabled;
  }

  Future<void> disable() async {
    final userId = _userId;
    if (userId == null) return;
    final operations = ref.read(pushOperationsProvider);
    await operations.revoke(() async {
      if (!ref.mounted || _userId != userId) return;
      await ref.read(dioProvider).delete('/notifications/device-token');
      await ref.read(pushGatewayProvider).deleteToken();
      await _storage.delete(key: _key(userId));
    });
    if (ref.mounted && _userId == userId) ref.invalidateSelf();
  }
}
