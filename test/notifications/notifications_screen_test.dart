import 'package:dio/dio.dart';
import '../profile/profile_test_support.dart' show TestAuth;
import 'package:farm2fork_mobile/features/auth/data/models/auth_user.dart';
import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/notifications/push_controller.dart';
import 'package:farm2fork_mobile/features/profile/presentation/screens/notification_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/theme/app_theme.dart';
import 'package:farm2fork_mobile/core/localization/generated/app_localizations.dart';
import 'package:farm2fork_mobile/features/notifications/data/notifications_repository.dart';
import 'package:farm2fork_mobile/features/notifications/presentation/screens/notifications_screen.dart';

class Inbox extends MockNotificationsRepository {
  bool fail = true;
  bool read = false;
  int readCalls = 0;
  int listCalls = 0;
  @override
  Future<List<AppNotification>> list() async {
    listCalls++;
    return [
      AppNotification(
        id: 'n',
        kind: NotificationKind.paymentConfirmed,
        title: 'Payment update',
        message: List.filled(
          15,
          'Your order payment has been received.',
        ).join(' '),
        isRead: read,
        createdAt: DateTime(2026, 10, 15),
      ),
    ];
  }

  @override
  Future<void> markRead(String id) async {
    readCalls++;
    if (fail) throw StateError('offline');
    read = true;
  }

  @override
  Future<void> markAllRead() async {
    if (fail) throw StateError('offline');
    read = true;
  }
}

class PushOff extends PushController {
  @override
  Future<bool> build() async => false;
}

void main() {
  test(
    'cached settings preview refetches when the signed-in account changes',
    () async {
      final repo = Inbox();
      final container = ProviderContainer(
        overrides: [
          notificationsRepositoryProvider.overrideWithValue(repo),
          authControllerProvider.overrideWith(TestAuth.new),
        ],
      );
      addTearDown(container.dispose);
      await container.read(authControllerProvider.future);
      final subscription = container.listen(
        notificationsInboxProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);
      await container.read(notificationsInboxProvider.future);
      final before = repo.listCalls;
      container
          .read(authControllerProvider.notifier)
          .updateCurrentUser(
            const AuthUser(
              id: 'second-account',
              email: 'second@example.test',
              role: AppUserRole.buyer,
              isVerified: true,
              isActive: true,
            ),
          );
      await container.read(notificationsInboxProvider.future);
      expect(repo.listCalls, before + 1);
    },
  );

  test(
    'notification pagination uses total and limit without totalPages',
    () async {
      final dio = Dio();
      final pages = <int>[];
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final page = options.queryParameters['page'] as int;
            pages.add(page);
            handler.resolve(
              Response(
                requestOptions: options,
                data: {
                  'data': [
                    {
                      'id': 'n$page',
                      'title': 'Update',
                      'message': 'Details',
                      'isRead': false,
                    },
                  ],
                  'total': 51,
                  'page': page,
                  'limit': 50,
                },
              ),
            );
          },
        ),
      );
      expect((await ApiNotificationsRepository(dio).list()).map((n) => n.id), [
        'n1',
        'n2',
      ]);
      expect(pages, [1, 2]);
    },
  );

  for (final locale in ['en', 'ur']) {
    testWidgets(
      '$locale detail stays readable on failed write, retry updates unread filter',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final repo = Inbox();
        final router = GoRouter(
          initialLocation: '/notifications',
          routes: [
            GoRoute(
              path: '/settings/notifications',
              builder: (_, _) => const NotificationSettingsScreen(),
            ),
            GoRoute(
              path: '/notifications',
              builder: (_, _) => const NotificationsScreen(),
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              notificationsRepositoryProvider.overrideWithValue(repo),
              authControllerProvider.overrideWith(TestAuth.new),
              pushControllerProvider.overrideWith(PushOff.new),
            ],
            child: ScreenUtilInit(
              designSize: const Size(360, 690),
              builder: (_, _) => MaterialApp.router(
                theme: AppTheme.lightTheme,
                locale: Locale(locale),
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                routerConfig: router,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final l10n = AppLocalizations.of(
          tester.element(find.byType(NotificationsScreen)),
        );
        await tester.tap(find.text('Payment update'));
        await tester.pumpAndSettle();
        expect(find.byType(BottomSheet), findsOneWidget);
        expect(repo.readCalls, 1);
        expect(repo.read, false);
        expect(tester.takeException(), isNull);
        await tester.tap(find.byTooltip(l10n.close));
        await tester.pumpAndSettle();
        expect(find.text(l10n.notificationUpdateFailed), findsOneWidget);
        expect(find.text(l10n.pushUnread), findsOneWidget);
        repo.fail = false;
        await tester.tap(find.text(l10n.markAllRead));
        await tester.pumpAndSettle();
        expect(repo.read, true);
        await tester.tap(
          find.widgetWithText(ChoiceChip, '${l10n.pushUnread} (0)'),
        );
        await tester.pumpAndSettle();
        expect(find.text(l10n.notificationCaughtUp), findsOneWidget);
        expect(find.text('Payment update'), findsNothing);
        expect(tester.takeException(), isNull);
        await tester.tap(find.byTooltip(l10n.notificationSettings));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text(l10n.notificationViewInbox),
          200,
        );
        await tester.tap(find.text(l10n.notificationViewInbox));
        await tester.pumpAndSettle();
        expect(find.text(l10n.pushUnread), findsNothing);
        expect(
          find.widgetWithText(ChoiceChip, '${l10n.pushUnread} (0)'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
