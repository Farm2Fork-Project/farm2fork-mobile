import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/onboarding_session.dart';
import 'package:farm2fork_mobile/features/auth/presentation/screens/email_verification_screen.dart';
import 'auth_test_support.dart';

Future<(FakeAuthRepository, ProviderContainer, GoRouter)> _open(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = const Size(360, 740);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final repo = FakeAuthRepository();
  final container = ProviderContainer(overrides: authOverrides(repo));
  addTearDown(container.dispose);
  container
      .read(onboardingSessionProvider.notifier)
      .start(
        const OnboardingSession(
          method: OnboardingMethod.emailPassword,
          email: 'ayesha@example.com',
        ),
      );
  final router = stubbedAuthRouter(
    initial: '/auth/verify',
    screens: {'/auth/verify': const EmailVerificationScreen()},
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: authTestApp(router: router, locale: locale, textScale: textScale),
    ),
  );
  await tester.pumpAndSettle();
  return (repo, container, router);
}

Finder get _resend =>
    find.widgetWithText(ElevatedButton, 'Resend verification email');

void main() {
  testWidgets('says where the email went and what to do', (tester) async {
    await _open(tester);
    expect(find.text('Verify your email'), findsOneWidget);
    expect(
      find.text(
        'Open the verification link we sent to ayesha@example.com, then return here.',
      ),
      findsOneWidget,
    );
    expect(
      find.text("Can't find it? Check your spam or junk folder."),
      findsOneWidget,
    );
    expect(find.text('I have verified my email'), findsOneWidget);
    expect(find.text('Use a different email'), findsOneWidget);
  });

  testWidgets('resend confirms, then waits out a cooldown', (tester) async {
    final (repo, _, _) = await _open(tester);
    await tester.tap(_resend);
    await tester.pump();
    await tester.pump();
    expect(repo.resends, 1);
    expect(
      find.text('A new verification email has been sent.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);

    // Locked for 45 seconds, counting down visibly.
    expect(find.text('Resend email in 45s'), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(
            find.widgetWithText(ElevatedButton, 'Resend email in 45s'),
          )
          .onPressed,
      isNull,
    );
    await tester.pump(const Duration(seconds: 10));
    expect(find.text('Resend email in 35s'), findsOneWidget);

    await tester.pump(const Duration(seconds: 35));
    expect(_resend, findsOneWidget);
    expect(tester.widget<ElevatedButton>(_resend).onPressed, isNotNull);
    await tester.tap(_resend);
    await tester.pump();
    await tester.pump();
    expect(repo.resends, 2);
    // Leave no timer running.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a failed resend is an error, with no cooldown', (tester) async {
    final (repo, _, _) = await _open(tester);
    repo.resendError = const ApiException(ApiErrorKind.network);
    await tester.tap(_resend);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    expect(find.textContaining('Resend email in'), findsNothing);
    expect(tester.widget<ElevatedButton>(_resend).onPressed, isNotNull);
  });

  testWidgets('"I have verified" explains when it is not verified yet', (
    tester,
  ) async {
    final (repo, _, _) = await _open(tester);
    repo.emailOutcome = const FirebaseVerificationRequired(
      email: 'ayesha@example.com',
    );
    await tester.tap(find.text('I have verified my email'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Your email is not verified yet. Check your inbox, then try again.',
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
  });

  testWidgets('"Use a different email" signs out and returns to login', (
    tester,
  ) async {
    final (repo, container, router) = await _open(tester);
    await tester.tap(find.text('Use a different email'));
    await tester.pumpAndSettle();
    expect(repo.signOuts, 1);
    expect(container.read(onboardingSessionProvider), isNull);
    expect(
      router.routerDelegate.currentConfiguration.last.matchedLocation,
      '/auth/login',
    );
  });

  testWidgets('Urdu at 1.3x text scale does not overflow', (tester) async {
    await _open(tester, locale: const Locale('ur'), textScale: 1.3);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byType(ElevatedButton).last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
