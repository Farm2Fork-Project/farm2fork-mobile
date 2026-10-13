import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:farm2fork_mobile/features/auth/data/services/firebase_auth_gateway.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/onboarding_session.dart';
import 'package:farm2fork_mobile/features/auth/presentation/screens/login_screen.dart';
import 'auth_test_support.dart';

Future<(ProviderContainer, FakeAuthRepository, GoRouterHandle)> _open(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  double textScale = 1.0,
  Size size = const Size(360, 740),
  double keyboard = 0,
}) async {
  // A typical Android phone, so ScreenUtil's scaling matches the real app.
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.view.viewInsets = FakeViewPadding(bottom: keyboard);
  addTearDown(tester.view.reset);
  final repo = FakeAuthRepository();
  final container = ProviderContainer(overrides: authOverrides(repo));
  addTearDown(container.dispose);
  final router = stubbedAuthRouter(
    initial: '/auth/login',
    screens: {'/auth/login': const LoginScreen()},
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: authTestApp(router: router, locale: locale, textScale: textScale),
    ),
  );
  await tester.pumpAndSettle();
  return (container, repo, GoRouterHandle(router));
}

class GoRouterHandle {
  GoRouterHandle(this.router);
  final GoRouter router;

  /// Where the user is now; for a pushed page that is the top-most match.
  String get location =>
      router.routerDelegate.currentConfiguration.last.matchedLocation;
}

Future<void> _tapLogin(WidgetTester tester, [String label = 'Login']) async {
  final button = find.widgetWithText(ElevatedButton, label);
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
}

Finder get _email => find.byType(TextFormField).at(0);
Finder get _password => find.byType(TextFormField).at(1);

void main() {
  testWidgets('is a compact sign-in with clear primary and secondary actions', (
    tester,
  ) async {
    await _open(tester);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('or use email'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Continue as guest'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
    // No stats, testimonials or hero card.
    expect(find.byType(Card), findsNothing);
  });

  testWidgets('fields declare keyboard actions and autofill hints', (
    tester,
  ) async {
    await _open(tester);
    final email = tester.widget<TextField>(
      find.descendant(of: _email, matching: find.byType(TextField)),
    );
    expect(email.keyboardType, TextInputType.emailAddress);
    expect(email.textInputAction, TextInputAction.next);
    expect(
      email.autofillHints,
      containsAll([AutofillHints.username, AutofillHints.email]),
    );
    final password = tester.widget<TextField>(
      find.descendant(of: _password, matching: find.byType(TextField)),
    );
    expect(password.textInputAction, TextInputAction.done);
    expect(password.autofillHints, [AutofillHints.password]);
    expect(password.obscureText, isTrue);
  });

  testWidgets('empty and malformed input is explained inline, nothing sent', (
    tester,
  ) async {
    final (_, repo, _) = await _open(tester);
    await _tapLogin(tester);
    await tester.pumpAndSettle();
    expect(find.text('This field is required'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);

    await tester.enterText(_email, 'not-an-email');
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(repo.signIns, isEmpty);
  });

  testWidgets('submits the trimmed email and password', (tester) async {
    final (_, repo, _) = await _open(tester);
    await tester.enterText(_email, '  ayesha@example.com ');
    await tester.enterText(_password, 'secret-pass');
    await _tapLogin(tester);
    await tester.pumpAndSettle();
    expect(repo.signIns.single.email, 'ayesha@example.com');
    expect(repo.signIns.single.password, 'secret-pass');
  });

  testWidgets('the keyboard "done" action signs in', (tester) async {
    final (_, repo, _) = await _open(tester);
    await tester.enterText(_email, 'ayesha@example.com');
    await tester.enterText(_password, 'secret-pass');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(repo.signIns, hasLength(1));
  });

  testWidgets('wrong credentials show a plain-language message inline', (
    tester,
  ) async {
    final (_, repo, _) = await _open(tester);
    repo.signInError = const AuthGatewayException(
      AuthGatewayError.invalidCredentials,
    );
    await tester.enterText(_email, 'ayesha@example.com');
    await tester.enterText(_password, 'wrong');
    await _tapLogin(tester);
    await tester.pumpAndSettle();
    expect(
      find.text('Incorrect email or password. Please try again.'),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('offline sign-in says so', (tester) async {
    final (_, repo, _) = await _open(tester);
    repo.signInError = const AuthGatewayException(AuthGatewayError.network);
    await tester.enterText(_email, 'ayesha@example.com');
    await tester.enterText(_password, 'secret-pass');
    await _tapLogin(tester);
    await tester.pumpAndSettle();
    expect(
      find.text('No internet connection. Check your network and try again.'),
      findsOneWidget,
    );
  });

  testWidgets('the eye icon shows and hides the password', (tester) async {
    await _open(tester);
    TextField field() => tester.widget<TextField>(
      find.descendant(of: _password, matching: find.byType(TextField)),
    );
    expect(field().obscureText, isTrue);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(field().obscureText, isFalse);
    expect(find.byTooltip('Hide password'), findsOneWidget);
  });

  testWidgets('forgot password needs an email, then confirms', (tester) async {
    final (_, repo, _) = await _open(tester);
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    expect(find.text('Enter your email address first.'), findsOneWidget);

    await tester.enterText(_email, 'ayesha@example.com');
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    expect(repo.resets, ['ayesha@example.com']);
    expect(
      find.text("If an account exists, we've sent a password-reset email."),
      findsOneWidget,
    );
    // It is a confirmation, not an error.
    expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
    expect(find.byIcon(Icons.error_outline_rounded), findsNothing);
  });

  testWidgets('Create account starts a fresh email sign-up', (tester) async {
    final (container, _, router) = await _open(tester);
    await tester.ensureVisible(find.text('Create Account'));
    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();
    expect(router.location, '/auth/onboarding');
    final session = container.read(onboardingSessionProvider)!;
    expect(session.isEmailPassword, isTrue);
  });

  testWidgets('a new Google identity is routed into onboarding', (
    tester,
  ) async {
    final (container, repo, router) = await _open(tester);
    repo.googleOutcome = const FirebaseOnboardingRequired(
      email: 'g@example.com',
      displayName: 'Gul Khan',
    );
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    expect(router.location, '/auth/onboarding');
    final session = container.read(onboardingSessionProvider)!;
    expect(session.isEmailPassword, isFalse);
    expect(session.email, 'g@example.com');
    expect(session.displayName, 'Gul Khan');
  });

  testWidgets('an unverified email is sent to the verify screen', (
    tester,
  ) async {
    final (_, repo, router) = await _open(tester);
    repo.emailOutcome = const FirebaseVerificationRequired(email: 'a@b.com');
    await tester.enterText(_email, 'a@b.com');
    await tester.enterText(_password, 'secret-pass');
    await _tapLogin(tester);
    await tester.pumpAndSettle();
    expect(router.location, '/auth/verify');
  });

  testWidgets('guest browsing is a quiet link to the guest marketplace', (
    tester,
  ) async {
    final (_, _, router) = await _open(tester);
    await tester.ensureVisible(find.text('Continue as guest'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue as guest'));
    await tester.pumpAndSettle();
    expect(router.location, '/guest/marketplace');
  });

  testWidgets('with the keyboard open the form scrolls and nothing overflows', (
    tester,
  ) async {
    await _open(tester, textScale: 1.3, size: const Size(360, 640));
    await tester.ensureVisible(_email);
    await tester.tap(_email);
    await tester.pumpAndSettle();

    // The keyboard opens (a 280dp bottom inset) over the focused field.
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(tester.getBottomLeft(_email).dy, lessThanOrEqualTo(640 - 280));

    // The keyboard's "next" key moves on, and the password field follows.
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pumpAndSettle();
    expect(tester.getBottomLeft(_password).dy, lessThanOrEqualTo(640 - 280));

    // The primary action is still reachable by scrolling.
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Urdu (RTL) at 1.3x text scale does not overflow', (
    tester,
  ) async {
    await _open(tester, locale: const Locale('ur'), textScale: 1.3);
    expect(tester.takeException(), isNull);
    expect(find.text('خوش آمدید'), findsOneWidget);
    expect(find.text('اکاؤنٹ بنائیں'), findsOneWidget);
    await _tapLogin(tester, 'لاگ ان');
    await tester.pumpAndSettle();
    expect(find.text('یہ خانہ ضروری ہے'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
