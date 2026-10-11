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
final pushControllerProvider = AsyncNotifierProvider<PushController, bool>(
  PushController.new,
);

// Independent from authControllerProvider so sign-out can clear the token before
// clearing the JWT without introducing a provider dependency cycle.
final pushLogoutCleanupProvider = Provider<Future<void> Function(String)>((
  ref,
) {
  return (userId) async {
    if (AppConfig.useMocks || Firebase.apps.isEmpty) return;
    const storage = FlutterSecureStorage();
    final key = 'push.enabled.$userId';
    if (await storage.read(key: key) != 'true') return;
    await ref.read(dioProvider).delete('/notifications/device-token');
    await ref.read(pushGatewayProvider).deleteToken();
    await storage.delete(key: key);
  };
});

class PushController extends AsyncNotifier<bool> {
  static const _storage = FlutterSecureStorage();
  PushRegistration get _registration => PushRegistration(
    ref.read(pushGatewayProvider),
    (token) async {
      await ref
          .read(dioProvider)
          .put('/notifications/device-token', data: {'token': token});
    },
    () async {
      await ref.read(dioProvider).delete('/notifications/device-token');
    },
  );
  String? get _userId => ref.read(authControllerProvider).value?.user?.id;
  String _key(String userId) => 'push.enabled.$userId';
  @override
  Future<bool> build() async {
    final user = ref.watch(authControllerProvider).value?.user;
    if (user == null || AppConfig.useMocks) return false;
    final enabled = await _storage.read(key: _key(user.id)) == 'true';
    if (!enabled) return false;
    // Restoring a prior opt-in never opens a new permission prompt.
    final permission = await FirebaseMessaging.instance
        .getNotificationSettings();
    if (permission.authorizationStatus != AuthorizationStatus.authorized &&
        permission.authorizationStatus != AuthorizationStatus.provisional) {
      return false;
    }
    final token = await ref.read(pushGatewayProvider).getToken();
    if (!ref.mounted || _userId != user.id) return false;
    if (token != null) {
      await ref
          .read(dioProvider)
          .put('/notifications/device-token', data: {'token': token});
    }
    final subscription = FirebaseMessaging.instance.onTokenRefresh.listen((
      token,
    ) {
      if (_userId == user.id) {
        unawaitedRefresh(token);
      }
    });
    ref.onDispose(subscription.cancel);
    return token != null;
  }

  Future<void> unawaitedRefresh(String token) async {
    try {
      await ref
          .read(dioProvider)
          .put('/notifications/device-token', data: {'token': token});
    } catch (error, stack) {
      if (ref.mounted) state = AsyncError(error, stack);
    }
  }

  Future<bool> enable() async {
    final userId = _userId;
    if (userId == null || AppConfig.useMocks) return false;
    final enabled = await _registration.enable();
    if (enabled) {
      await _storage.write(key: _key(userId), value: 'true');
      ref.invalidateSelf();
    }
    return enabled;
  }

  Future<void> disable() async {
    final userId = _userId;
    if (userId == null) return;
    await _registration.disable();
    await _storage.delete(key: _key(userId));
    ref.invalidateSelf();
  }
}
