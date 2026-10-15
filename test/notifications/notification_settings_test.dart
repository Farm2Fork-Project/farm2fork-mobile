import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../profile/profile_test_support.dart' show testApp;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/core/localization/generated/app_localizations.dart';
import 'package:farm2fork_mobile/core/network/network_providers.dart';
import 'package:farm2fork_mobile/features/auth/data/models/auth_user.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/notifications/push_controller.dart';
import 'package:farm2fork_mobile/features/profile/presentation/screens/notification_settings_screen.dart';

class _Auth extends AuthController {
  @override
  Future<AuthState> build() async => const AuthState(
    status: AuthStatus.authenticated,
    user: AuthUser(
      id: 'buyer',
      email: 'b@example.test',
      role: AppUserRole.buyer,
      isVerified: true,
      isActive: true,
    ),
  );
}

class _Push extends PushController {
  bool fail = true;
  @override
  Future<bool> build() async => false;
  @override
  Future<bool> enable() async {
    if (fail) throw StateError('offline');
    state = const AsyncData(true);
    return true;
  }
}

class _Adapter implements HttpClientAdapter {
  bool read = false;
  int fetches = 0;
  bool failInbox = false;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path == '/notifications/read-all') read = true;
    if (options.path == '/notifications') fetches++;
    return ResponseBody.fromString(
      jsonEncode(
        options.path == '/notifications'
            ? {
                'data': [
                  {
                    'id': 'n',
                    'title': 'Delivery complete',
                    'message': 'Your order arrived',
                    'isRead': read,
                  },
                ],
              }
            : {},
      ),
      options.path == '/notifications' && failInbox ? 500 : 200,
      headers: {
        'content-type': ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  for (final locale in ['en', 'ur']) {
    testWidgets(
      '$locale notification inbox loads and failed push opt-in stays retryable',
      (tester) async {
        final push = _Push();
        final adapter = _Adapter();
        final dio = Dio()..httpClientAdapter = adapter;
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authControllerProvider.overrideWith(_Auth.new),
              pushControllerProvider.overrideWith(() => push),
              dioProvider.overrideWithValue(dio),
            ],
            child: testApp(
              child: const NotificationSettingsScreen(),
              locale: Locale(locale),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final context = tester.element(find.byType(NotificationSettingsScreen));
        final l10n = AppLocalizations.of(context);
        await tester.scrollUntilVisible(find.text('Delivery complete'), 200);
        expect(find.text('Delivery complete'), findsOneWidget);
        await tester.scrollUntilVisible(find.text(l10n.pushEnable), -200);
        await tester.tap(find.text(l10n.pushEnable));
        await tester.pumpAndSettle();
        expect(find.text(l10n.errorOccurred), findsOneWidget);
        expect(find.text(l10n.pushEnable), findsOneWidget);
        push.fail = false;
        await tester.tap(find.text(l10n.pushEnable));
        await tester.pumpAndSettle();
        expect(find.text(l10n.pushDisable), findsOneWidget);
        await tester.ensureVisible(find.text(l10n.pushReadAll));
        await tester.tap(find.text(l10n.pushReadAll));
        await tester.pumpAndSettle();
        expect(adapter.read, true);
        final beforeRefresh = adapter.fetches;
        await tester.ensureVisible(find.text(l10n.dispatchRefresh));
        await tester.tap(find.text(l10n.dispatchRefresh));
        await tester.pumpAndSettle();
        expect(adapter.fetches, beforeRefresh + 1);
        adapter.failInbox = true;
        await tester.tap(find.text(l10n.dispatchRefresh));
        await tester.pumpAndSettle();
        expect(find.text(l10n.retry), findsOneWidget);
        adapter.failInbox = false;
        final beforeRetry = adapter.fetches;
        await tester.ensureVisible(find.text(l10n.retry));
        await tester.tap(find.text(l10n.retry));
        await tester.pumpAndSettle();
        expect(adapter.fetches, beforeRetry + 1);

        expect(find.byIcon(Icons.circle), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
