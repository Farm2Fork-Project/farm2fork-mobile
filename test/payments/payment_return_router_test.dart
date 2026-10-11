import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/app/router.dart';
import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/core/localization/generated/app_localizations.dart';
import 'package:farm2fork_mobile/features/auth/data/models/auth_user.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/payments/data/repositories/mock_payments_repository.dart';
import 'package:farm2fork_mobile/features/payments/data/repositories/payments_repository_provider.dart';
import 'package:farm2fork_mobile/features/payments/presentation/providers/payment_controller.dart';

class _BuyerAuth extends AuthController {
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

void main() {
  testWidgets(
    'the native callback URI routes into an authenticated status-only payment screen',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          authControllerProvider.overrideWith(_BuyerAuth.new),
          paymentsRepositoryProvider.overrideWithValue(
            MockPaymentsRepository(),
          ),
          paymentSimulatorEnabledProvider.overrideWithValue(false),
        ],
      );
      addTearDown(container.dispose);
      await container.read(authControllerProvider.future);
      final router = container.read(goRouterProvider);
      addTearDown(router.dispose);
      router.go(
        'farm2fork://app/payments?orderId=66a2fe77bb77795516febc50&result=complete&status=success',
      );
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
      expect(find.text('Payment pending'), findsNWidgets(2));
      expect(find.text('Payment complete'), findsNothing);
      expect(find.text('Continue with Safepay'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
