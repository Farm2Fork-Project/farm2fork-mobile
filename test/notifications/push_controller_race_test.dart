import 'dart:async';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/core/network/network_providers.dart';
import 'package:farm2fork_mobile/features/auth/data/models/auth_user.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/notifications/push_controller.dart';
import 'package:farm2fork_mobile/features/notifications/push_registration.dart';

class _Auth extends AuthController {
  AuthState session(String id) => AuthState(
    status: AuthStatus.authenticated,
    user: AuthUser(
      id: id,
      email: '$id@example.test',
      role: AppUserRole.buyer,
      isVerified: true,
      isActive: true,
    ),
  );
  @override
  Future<AuthState> build() async => session('a');
  void switchAccount() => state = AsyncData(session('b'));
}

class _Gateway implements PushGateway {
  final token = Completer<String?>();
  final requested = Completer<void>();
  bool deleted = false;
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<String?> getToken() {
    requested.complete();
    return token.future;
  }

  @override
  Future<void> deleteToken() async {
    deleted = true;
  }
}

class _Adapter implements HttpClientAdapter {
  final requests = <String>[];
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancel,
  ) async {
    requests.add(options.method);
    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        'content-type': ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  for (final switchAccount in [true, false]) {
    test(
      switchAccount
          ? 'explicit opt-in ignores a token returned after account switch'
          : 'disable drains deferred token before deleting and prevents opt-in persistence',
      () async {
        final gateway = _Gateway();
        final adapter = _Adapter();
        final dio = Dio()..httpClientAdapter = adapter;
        final container = ProviderContainer(
          overrides: [
            authControllerProvider.overrideWith(_Auth.new),
            pushGatewayProvider.overrideWithValue(gateway),
            dioProvider.overrideWithValue(dio),
          ],
        );
        addTearDown(container.dispose);
        container.listen(pushControllerProvider, (_, _) {});
        await container.read(authControllerProvider.future);
        await container.read(pushControllerProvider.future);
        final push = container.read(pushControllerProvider.notifier);
        final pending = push.enable();
        await gateway.requested.future;
        Future<void>? disabled;
        if (switchAccount) {
          (container.read(authControllerProvider.notifier) as _Auth)
              .switchAccount();
          await container.read(pushControllerProvider.future);
        } else {
          disabled = push.disable();
        }
        gateway.token.complete('old-token');
        expect(await pending, false);
        if (disabled != null) await disabled;
        expect(adapter.requests, switchAccount ? isEmpty : ['DELETE']);
        expect(
          await const FlutterSecureStorage().read(key: 'push.enabled.a'),
          isNull,
        );
        expect(gateway.deleted, !switchAccount);
      },
    );
  }
}
