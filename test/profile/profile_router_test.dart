import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/app/router.dart';
import 'package:farm2fork_mobile/core/localization/generated/app_localizations.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/profile/presentation/screens/edit_profile_screen.dart';
import 'profile_test_support.dart';

void main() {
  testWidgets(
    'a signed-in buyer opens Edit profile from the Profile tab through the real router',
    (tester) async {
      final repo = FakeProfileRepository(buyerProfile());
      final container = ProviderContainer(
        overrides: profileOverrides(repo: repo),
      );
      addTearDown(container.dispose);
      await container.read(authControllerProvider.future);
      final router = container.read(goRouterProvider);
      addTearDown(router.dispose);
      router.go('/buyer/profile');

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
      // The tab shell never settles on its own animations; step the clock.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Ayesha Khan'), findsOneWidget);
      await tester.ensureVisible(find.text('Edit profile'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Edit profile'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(EditProfileScreen), findsOneWidget);
      expect(find.text('Save changes'), findsOneWidget);
    },
  );
}
