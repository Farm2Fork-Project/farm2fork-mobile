import 'dart:async';
import 'package:farm2fork_mobile/core/storage/token_storage.dart';
import 'package:farm2fork_mobile/app/navigation/order_auth_recovery.dart';
import 'package:farm2fork_mobile/features/orders/presentation/screens/order_detail_screen.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/auth/data/models/auth_user.dart';
import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/core/network/network_providers.dart';
import 'package:farm2fork_mobile/features/traceability/data/services/order_trace_service.dart';

class _Adapter implements HttpClientAdapter {
  final paths = <String>[];
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    paths.add(options.path);
    return ResponseBody.fromString(
      jsonEncode({
        'orderId': 'abc',
        'qrCode': 'https://farm2fork.tech/trace/orders/abc',
        'qrImageDataUri': 'data:image/png;base64,AA==',
      }),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _Storage extends TokenStorage {
  final deletion = Completer<void>();
  bool cleared = false;
  @override
  Future<void> clear() {
    cleared = true;
    return deletion.future;
  }
}

class _Auth extends AuthController {
  AuthState account(String id) => AuthState(
    status: AuthStatus.authenticated,
    user: AuthUser(
      id: id,
      email: '$id@test.invalid',
      role: AppUserRole.buyer,
      isVerified: true,
      isActive: true,
    ),
  );
  @override
  Future<AuthState> build() async => account('buyer-a');
  void switchAccount() => state = AsyncData(account('buyer-b'));
}

void main() {
  test(
    'stale authenticated session expires before local cleanup and retains login destination',
    () async {
      final storage = _Storage();
      final auth = _Auth();
      final container = ProviderContainer(
        overrides: [
          authControllerProvider.overrideWith(() => auth),
          tokenStorageProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);
      await container.read(authControllerProvider.future);
      expect(
        container.read(authControllerProvider).value!.isAuthenticated,
        isTrue,
      );
      final cleanup = auth.expireSession();
      expect(
        container.read(authControllerProvider).value!.status,
        AuthStatus.sessionExpired,
      );
      expect(storage.cleared, isTrue);
      const path = '/orders/6a2fe77bb77795516febc287';
      final recovery = OrderAuthRecovery();
      recovery.observe(
        Uri(path: '/auth/login', queryParameters: {'next': path}),
        authenticated: container
            .read(authControllerProvider)
            .value!
            .isAuthenticated,
      );
      recovery.observe(Uri.parse('/auth/verify'), authenticated: false);
      expect(recovery.consume(), path);
      storage.deletion.complete();
      await cleanup;
    },
  );

  test('loads QR only when requested and targets the exact order', () async {
    final adapter = _Adapter();
    final dio = Dio()..httpClientAdapter = adapter;
    final container = ProviderContainer(
      overrides: [
        dioProvider.overrideWithValue(dio),
        orderQrAccountProvider.overrideWithValue('buyer-a'),
      ],
    );
    addTearDown(container.dispose);
    expect(adapter.paths, isEmpty);
    final subscription = container.listen(orderQrProvider('abc'), (_, _) {});
    addTearDown(subscription.close);
    final qr = await container.read(orderQrProvider('abc').future);
    expect(qr.orderId, 'abc');
    expect(adapter.paths, ['/orders/abc/qr']);
  });
  test('account switch reloads QR and hides previous account data', () async {
    final adapter = _Adapter();
    final dio = Dio()..httpClientAdapter = adapter;
    final container = ProviderContainer(
      overrides: [
        dioProvider.overrideWithValue(dio),
        orderQrAccountProvider.overrideWithValue('buyer-a'),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(orderQrProvider('abc'), (_, _) {});
    addTearDown(subscription.close);
    await container.read(orderQrProvider('abc').future);
    container.updateOverrides([
      dioProvider.overrideWithValue(dio),
      orderQrAccountProvider.overrideWithValue('buyer-b'),
    ]);
    final state = container.read(orderQrProvider('abc'));
    expect(
      state.when(
        data: (_) => 'old-image',
        error: (_, _) => 'error',
        loading: () => 'loading',
      ),
      'loading',
    );
    await container.read(orderQrProvider('abc').future);
    expect(adapter.paths, ['/orders/abc/qr', '/orders/abc/qr']);
  });
  test(
    'private order details reload and hide prior account data on account switch',
    () async {
      final adapter = _Adapter();
      final dio = Dio()..httpClientAdapter = adapter;
      final auth = _Auth();
      final container = ProviderContainer(
        overrides: [
          dioProvider.overrideWithValue(dio),
          authControllerProvider.overrideWith(() => auth),
        ],
      );
      addTearDown(container.dispose);
      await container.read(authControllerProvider.future);
      final subscription = container.listen(
        orderDetailProvider('abc'),
        (_, _) {},
      );
      addTearDown(subscription.close);
      await container.read(orderDetailProvider('abc').future);
      auth.switchAccount();
      final state = container.read(orderDetailProvider('abc'));
      expect(
        state.when(
          data: (_) => 'private-data',
          error: (_, _) => 'error',
          loading: () => 'loading',
        ),
        'loading',
      );
      await container.read(orderDetailProvider('abc').future);
      expect(adapter.paths, ['/orders/abc', '/orders/abc']);
    },
  );
}
