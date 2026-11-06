import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/app/router.dart';
import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/core/network/network_providers.dart';
import 'package:farm2fork_mobile/core/storage/token_storage.dart';
import 'package:farm2fork_mobile/core/localization/generated/app_localizations.dart';
import 'package:farm2fork_mobile/features/auth/data/models/auth_user.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/orders/presentation/screens/order_detail_screen.dart';

const path = '/orders/6a2fe77bb77795516febc287';

class _Auth extends AuthController {
  @override
  Future<AuthState> build() async => const AuthState(
    status: AuthStatus.authenticated,
    user: AuthUser(
      id: 'buyer-test',
      email: 'buyer@example.test',
      role: AppUserRole.buyer,
      isVerified: true,
      isActive: true,
    ),
  );
}

class _Storage extends TokenStorage {
  bool cleared = false;
  @override
  Future<void> clear() async {
    cleared = true;
  }
}

void main() {
  testWidgets(
    'an authenticated user with an expired JWT reaches login and retains the exact order',
    (tester) async {
      final storage = _Storage();
      final container = ProviderContainer(
        overrides: [
          authControllerProvider.overrideWith(_Auth.new),
          tokenStorageProvider.overrideWithValue(storage),
          orderDetailProvider('6a2fe77bb77795516febc287').overrideWith(
            (ref) async => throw const ApiException(ApiErrorKind.unauthorized),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(authControllerProvider.future);
      final router = container.read(goRouterProvider);
      addTearDown(router.dispose);
      router.go(path);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: ScreenUtilInit(
            designSize: const Size(360, 690),
            builder: (_, _) => MaterialApp.router(
              routerConfig: router,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        container.read(authControllerProvider).value!.isAuthenticated,
        isTrue,
      );
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/auth/login');
      expect(
        router.routeInformationProvider.value.uri.queryParameters['next'],
        path,
      );
      expect(
        container.read(authControllerProvider).value!.isAuthenticated,
        isFalse,
      );
      expect(storage.cleared, isTrue);
      expect(find.text('Welcome back'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
