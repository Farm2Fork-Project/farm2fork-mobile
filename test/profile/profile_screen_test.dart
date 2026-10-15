import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/features/auth/data/models/auth_user.dart';
import 'package:farm2fork_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'profile_test_support.dart';
import 'package:farm2fork_mobile/features/profile/presentation/providers/profile_controller.dart';
import 'package:farm2fork_mobile/features/profile/data/models/user_profile.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';

Future<TestAuth> _pump(
  WidgetTester tester, {
  AuthUser user = buyerUser,
  Locale locale = const Locale('en'),
  double textScale = 1.0,
}) async {
  // Account now also lists notifications, loans or community, so the page is
  // taller than the default test surface; ListView builds only what is near.
  tester.view.physicalSize = const Size(800, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final auth = TestAuth(user);
  await tester.pumpWidget(
    ProviderScope(
      overrides: profileOverrides(
        repo: FakeProfileRepository(buyerProfile()),
        auth: auth,
      ),
      child: testApp(
        child: const ProfileScreen(),
        locale: locale,
        textScale: textScale,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return auth;
}

class RecoverableProfile extends ProfileController {
  bool fail = true;
  @override
  Future<UserProfile> build() async {
    if (fail) throw StateError('offline');
    return buyerProfile();
  }
}

void main() {
  testWidgets(
    'profile load failure is visible and retry preserves account controls',
    (tester) async {
      final profile = RecoverableProfile();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(() => TestAuth()),
            profileControllerProvider.overrideWith(() => profile),
          ],
          child: testApp(child: const ProfileScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(
          "Couldn't load your profile. Check your connection and try again.",
        ),
        findsOneWidget,
      );
      expect(find.text('Ayesha Khan'), findsOneWidget);
      profile.fail = false;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          "Couldn't load your profile. Check your connection and try again.",
        ),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('header shows name, role, email, verified state and initials', (
    tester,
  ) async {
    await _pump(tester);
    expect(find.text('Ayesha Khan'), findsOneWidget);
    expect(find.text('Buyer'), findsOneWidget);
    expect(find.text('ayesha@example.test'), findsOneWidget);
    expect(find.text('Verified'), findsOneWidget);
    // No photo yet: initials stand in for it.
    expect(find.text('AK'), findsOneWidget);
  });

  testWidgets('an unverified email is called out', (tester) async {
    await _pump(
      tester,
      user: const AuthUser(
        id: 'u2',
        email: 'new@example.test',
        role: AppUserRole.farmer,
        isVerified: false,
        isActive: true,
      ),
    );
    expect(find.text('Not verified'), findsOneWidget);
    expect(find.text('Farmer'), findsOneWidget);
  });

  testWidgets('sections group Account, Preferences and Help', (tester) async {
    await _pump(tester);
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Edit profile'), findsOneWidget);
    expect(find.text('Preferences'), findsOneWidget);
    expect(find.text('Notification Settings'), findsOneWidget);
    expect(find.text('Language & Display'), findsOneWidget);
    expect(
      find.text('Help & Information', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('Privacy Policy', skipOffstage: false), findsOneWidget);
  });

  testWidgets('sign out confirms in place, with no dialog', (tester) async {
    final auth = await _pump(tester);
    await tester.scrollUntilVisible(
      find.text('Logout'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Log out?'), findsOneWidget);
    expect(auth.signOuts, 0);

    // Changed my mind.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Log out?'), findsNothing);
    expect(auth.signOuts, 0);

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Logout'));
    await tester.pumpAndSettle();
    expect(auth.signOuts, 1);
  });

  testWidgets('Urdu with large text does not overflow', (tester) async {
    await _pump(
      tester,
      user: const AuthUser(
        id: 'u3',
        email: 'a.very.long.email.address.for.testing@example-domain.test',
        role: AppUserRole.transporter,
        isVerified: false,
        isActive: true,
        fullName: 'محمد عبدالرحمن بن عبداللہ خان نیازی',
      ),
      locale: const Locale('ur'),
      textScale: 1.3,
    );
    expect(tester.takeException(), isNull);
    expect(find.text('ٹرانسپورٹر'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('لاگ آؤٹ'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('لاگ آؤٹ'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
