import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/features/auth/data/models/onboarding_request.dart';
import 'package:farm2fork_mobile/features/auth/data/services/firebase_auth_gateway.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/onboarding_draft.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/onboarding_session.dart';
import 'package:farm2fork_mobile/features/auth/presentation/screens/onboarding_flow_screen.dart';
import 'auth_test_support.dart';

class _Flow {
  _Flow(this.container, this.repo, this.router);
  final ProviderContainer container;
  final FakeAuthRepository repo;
  final GoRouter router;
  String get location =>
      router.routerDelegate.currentConfiguration.last.matchedLocation;
  OnboardingSession? get session => container.read(onboardingSessionProvider);
}

Future<_Flow> _open(
  WidgetTester tester, {
  OnboardingSession session = const OnboardingSession(
    method: OnboardingMethod.emailPassword,
  ),
  Locale locale = const Locale('en'),
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = const Size(360, 740);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final repo = FakeAuthRepository();
  final container = ProviderContainer(overrides: authOverrides(repo));
  addTearDown(container.dispose);
  container.read(onboardingSessionProvider.notifier).start(session);
  final router = stubbedAuthRouter(
    initial: '/auth/onboarding',
    screens: {'/auth/onboarding': const OnboardingFlowScreen()},
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: authTestApp(router: router, locale: locale, textScale: textScale),
    ),
  );
  await tester.pumpAndSettle();
  return _Flow(container, repo, router);
}

Finder _field(String label) => find.widgetWithText(TextFormField, label);

String _text(WidgetTester tester, String label) =>
    tester.widget<TextFormField>(_field(label)).controller!.text;

Future<void> _type(WidgetTester tester, String label, String text) async {
  await tester.ensureVisible(_field(label));
  await tester.enterText(_field(label), text);
  await tester.pump();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _next(WidgetTester tester) =>
    _tap(tester, find.widgetWithText(ElevatedButton, 'Next'));

Future<void> _accountStep(WidgetTester tester) async {
  await _type(tester, 'Email', 'ayesha@example.com');
  await _type(tester, 'Password', 'Sunflower42');
  await _next(tester);
}

void main() {
  testWidgets('starts on the role step with a progress indicator', (
    tester,
  ) async {
    await _open(tester);
    expect(find.text('How will you use Farm2Fork?'), findsOneWidget);
    expect(find.text('Step 1 of 4'), findsOneWidget);
    expect(find.text('Farmer'), findsOneWidget);
    expect(find.text('Buyer'), findsOneWidget);
    expect(find.text('Transporter'), findsOneWidget);
    // Choosing a role is the action: there is no Next button yet.
    expect(find.widgetWithText(ElevatedButton, 'Next'), findsNothing);
  });

  testWidgets('buyer / individual: four short steps, no business name', (
    tester,
  ) async {
    final flow = await _open(tester);
    await _tap(tester, find.text('Buyer'));

    expect(find.text('Create your sign-in'), findsOneWidget);
    expect(find.text('Step 2 of 4'), findsOneWidget);
    await _type(tester, 'Password', 'abc');
    expect(find.text('Weak'), findsOneWidget);
    await _type(tester, 'Password', 'Sunflower42');
    expect(find.text('Strong'), findsOneWidget);
    await _type(tester, 'Email', 'ayesha@example.com');
    await _next(tester);

    expect(find.text('About you'), findsOneWidget);
    expect(find.text('Step 3 of 4'), findsOneWidget);
    // Individual is the default, so there is no business name to type.
    expect(_field('Business Name'), findsNothing);
    expect(
      find.text(
        'Buying for yourself or your household. No business name needed.',
      ),
      findsOneWidget,
    );
    await _type(tester, 'Full Name', 'Ayesha Khan');
    await _next(tester);

    expect(find.text('Your identity'), findsOneWidget);
    expect(find.text('Step 4 of 4'), findsOneWidget);
    await _type(tester, 'CNIC', '3520212345671');
    expect(_text(tester, 'CNIC'), '35202-1234567-1');
    expect(find.text('13 digits entered'), findsOneWidget);
    await _type(tester, 'Phone Number (optional)', '0300 1234567');
    expect(find.text('Saved as +923001234567'), findsOneWidget);
    await _tap(tester, find.widgetWithText(ElevatedButton, 'Create Account'));

    final request = flow.repo.onboarded.single as BuyerOnboardingRequest;
    expect(request.businessType, 'individual');
    // The API still requires a business name: the buyer's own name stands in.
    expect(request.businessName, 'Ayesha Khan');
    expect(request.fullName, 'Ayesha Khan');
    expect(request.cnic, '35202-1234567-1');
    expect(request.phone, '+923001234567');
    final credential = request.credential as EmailPasswordOnboardingCredential;
    expect(credential.email, 'ayesha@example.com');
    expect(credential.password, 'Sunflower42');
    expect(flow.session, isNull, reason: 'the finished session is cleared');
  });

  testWidgets('a retailer must name the business', (tester) async {
    final flow = await _open(tester);
    await _tap(tester, find.text('Buyer'));
    await _accountStep(tester);
    await _type(tester, 'Full Name', 'Ayesha Khan');
    await _tap(tester, find.text('Retailer'));
    expect(_field('Business Name'), findsOneWidget);

    await _next(tester);
    expect(find.text('This field is required'), findsOneWidget);
    expect(find.text('About you'), findsOneWidget, reason: 'did not advance');

    await _type(tester, 'Business Name', 'Khan Traders');
    await _next(tester);
    await _type(tester, 'CNIC', '3520212345671');
    await _tap(tester, find.widgetWithText(ElevatedButton, 'Create Account'));
    final request = flow.repo.onboarded.single as BuyerOnboardingRequest;
    expect(request.businessType, 'retailer');
    expect(request.businessName, 'Khan Traders');
    expect(request.phone, isNull, reason: 'phone is optional');
  });

  testWidgets('each step validates before moving on', (tester) async {
    await _open(tester);
    await _tap(tester, find.text('Buyer'));

    await _type(tester, 'Email', 'nope');
    await _type(tester, 'Password', 'short');
    await _next(tester);
    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(find.text('Password must be at least 8 characters'), findsOneWidget);
    expect(find.text('Step 2 of 4'), findsOneWidget);

    await _type(tester, 'Email', 'a@b.com');
    await _type(tester, 'Password', 'longenough1');
    await _next(tester);
    await _next(tester);
    expect(
      find.text('This field is required'),
      findsOneWidget,
      reason: 'name is required',
    );
    await _type(tester, 'Full Name', 'A');
    await _next(tester);
    expect(
      find.text('Enter your full name (at least 2 letters)'),
      findsOneWidget,
    );
  });

  testWidgets('CNIC is checked live and must be 13 digits to continue', (
    tester,
  ) async {
    final flow = await _open(tester);
    await _tap(tester, find.text('Buyer'));
    await _accountStep(tester);
    await _type(tester, 'Full Name', 'Ayesha Khan');
    await _next(tester);

    await _type(tester, 'CNIC', '35202abc12');
    expect(find.text('7 of 13 digits'), findsOneWidget);
    await _type(tester, 'Phone Number (optional)', '12');
    await _tap(tester, find.widgetWithText(ElevatedButton, 'Create Account'));
    expect(
      find.text('Enter a valid CNIC (e.g. 35202-1234567-1)'),
      findsOneWidget,
    );
    expect(
      find.text('Enter a valid phone number, like 0300 1234567'),
      findsOneWidget,
    );
    expect(flow.repo.onboarded, isEmpty);
  });

  testWidgets('going back keeps everything that was typed', (tester) async {
    final flow = await _open(tester);
    await _tap(tester, find.text('Buyer'));
    await _accountStep(tester);
    await _type(tester, 'Full Name', 'Ayesha Khan');
    await _tap(tester, find.text('Wholesaler'));
    await _type(tester, 'Business Name', 'Bulk Mart');

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Create your sign-in'), findsOneWidget);
    expect(find.text('ayesha@example.com'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('How will you use Farm2Fork?'), findsOneWidget);
    // The chosen role is still highlighted; picking it again resumes.
    await _tap(tester, find.text('Buyer'));
    await _next(tester);
    expect(find.widgetWithText(TextFormField, 'Ayesha Khan'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Bulk Mart'), findsOneWidget);

    // The draft also lives in the session, so it survives leaving the route.
    final draft = flow.session!.draft;
    expect(draft.value(OnboardingField.businessType), 'wholesaler');
    expect(draft.value(OnboardingField.businessName), 'Bulk Mart');
  });

  testWidgets('changing role mid-way changes the steps', (tester) async {
    await _open(tester);
    await _tap(tester, find.text('Buyer'));
    expect(find.text('Step 2 of 4'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await _tap(tester, find.text('Farmer'));
    // Farmers add a pickup step.
    expect(find.text('Step 2 of 5'), findsOneWidget);
  });

  testWidgets('system back steps back through the flow, then leaves it', (
    tester,
  ) async {
    final flow = await _open(tester);
    await _tap(tester, find.text('Buyer'));
    expect(find.text('Create your sign-in'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('How will you use Farm2Fork?'), findsOneWidget);
    expect(flow.location, '/auth/onboarding');

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(flow.location, '/auth/login');
  });

  testWidgets('Google users skip the account step and see their identity', (
    tester,
  ) async {
    final flow = await _open(
      tester,
      session: const OnboardingSession(
        method: OnboardingMethod.google,
        email: 'g@example.com',
        displayName: 'Gul Khan',
      ),
    );
    expect(find.text('Step 1 of 3'), findsOneWidget);
    await _tap(tester, find.text('Buyer'));

    expect(find.text('About you'), findsOneWidget);
    expect(find.text('Step 2 of 3'), findsOneWidget);
    expect(find.text('Signed in with Google'), findsOneWidget);
    expect(find.text('g@example.com'), findsOneWidget);
    // Their Google name is offered, not retyped.
    expect(find.widgetWithText(TextFormField, 'Gul Khan'), findsOneWidget);
    await _next(tester);
    await _type(tester, 'CNIC', '3520212345671');
    await _tap(tester, find.widgetWithText(ElevatedButton, 'Create Account'));

    final request = flow.repo.onboarded.single;
    expect(request.credential, isA<GoogleOnboardingCredential>());
    expect(request.fullName, 'Gul Khan');
  });

  testWidgets('farmers give a farm and a pickup location the API accepts', (
    tester,
  ) async {
    final flow = await _open(tester);
    await _tap(tester, find.text('Farmer'));
    await _accountStep(tester);

    expect(find.text('About you and your farm'), findsOneWidget);
    expect(find.text('Step 3 of 5'), findsOneWidget);
    await _type(tester, 'Full Name', 'Muhammad Aslam');
    await _type(tester, 'Farm Name', 'Green Acres');
    await _type(tester, 'Crop Types (optional)', 'wheat, rice');
    await _type(tester, 'Farm Size (acres) (optional)', '12.5');
    await _next(tester);

    expect(find.text('Where do you load produce?'), findsOneWidget);
    expect(find.text('Step 4 of 5'), findsOneWidget);
    await _type(tester, 'Street Address', 'Chak 5, Canal Road');
    await _type(tester, 'City', 'Multan');
    await _type(tester, 'Latitude', '45');
    await _type(tester, 'Longitude', '71.5249');
    await _next(tester);
    expect(
      find.text('Enter valid coordinates inside Pakistan.'),
      findsOneWidget,
      reason: 'latitude 45 is outside Pakistan, province is missing',
    );
    expect(find.text('This field is required'), findsOneWidget);

    await _tap(tester, find.byType(DropdownButtonFormField<String>));
    await _tap(tester, find.text('Punjab').last);
    await _type(tester, 'Latitude', '30.1575');
    await _next(tester);

    expect(find.text('Step 5 of 5'), findsOneWidget);
    await _type(tester, 'CNIC', '3520212345671');
    await _tap(tester, find.widgetWithText(ElevatedButton, 'Create Account'));

    final request = flow.repo.onboarded.single as FarmerOnboardingRequest;
    expect(request.farmName, 'Green Acres');
    expect(request.cropTypes, ['wheat', 'rice']);
    expect(request.landSizeAcres, 12.5);
    expect(request.toProfileJson()['farmLocation'], {
      'address': 'Chak 5, Canal Road',
      'city': 'Multan',
      'province': 'Punjab',
      'lat': 30.1575,
      'lng': 71.5249,
    });
  });

  testWidgets('transporters must pick a vehicle', (tester) async {
    final flow = await _open(tester);
    await _tap(tester, find.text('Transporter'));
    await _accountStep(tester);

    expect(find.text('About you and your vehicle'), findsOneWidget);
    await _type(tester, 'Full Name', 'Bilal Ahmed');
    await _type(tester, 'Vehicle Number', 'LEA-1234');
    await _type(tester, 'Vehicle License Number', 'DL-998877');
    await _next(tester);
    expect(find.text('This field is required'), findsOneWidget);
    expect(find.text('About you and your vehicle'), findsOneWidget);

    await _tap(tester, find.text('Van'));
    await _next(tester);
    await _type(tester, 'CNIC', '3520212345671');
    await _tap(tester, find.widgetWithText(ElevatedButton, 'Create Account'));

    final request = flow.repo.onboarded.single as TransporterOnboardingRequest;
    expect(request.vehicleType, 'van');
    expect(request.vehicleNumber, 'LEA-1234');
    expect(request.licenseNumber, 'DL-998877');
  });

  group('failures', () {
    Future<_Flow> toIdentity(WidgetTester tester) async {
      final flow = await _open(tester);
      await _tap(tester, find.text('Buyer'));
      await _accountStep(tester);
      await _type(tester, 'Full Name', 'Ayesha Khan');
      await _next(tester);
      await _type(tester, 'CNIC', '3520212345671');
      return flow;
    }

    testWidgets('an email that already has an account sends you back to it', (
      tester,
    ) async {
      final flow = await toIdentity(tester);
      flow.repo.onboardingError = const AuthGatewayException(
        AuthGatewayError.emailAlreadyInUse,
      );
      await _tap(tester, find.widgetWithText(ElevatedButton, 'Create Account'));

      expect(find.text('Create your sign-in'), findsOneWidget);
      expect(
        find.text('This email already has an account. Try signing in.'),
        findsOneWidget,
      );
      // Typing a different address clears the message.
      await _type(tester, 'Email', 'other@example.com');
      await tester.pumpAndSettle();
      expect(find.textContaining('already has an account'), findsNothing);
    });

    testWidgets('a duplicate CNIC is explained on the identity step', (
      tester,
    ) async {
      final flow = await toIdentity(tester);
      flow.repo.onboardingError = const ApiException(
        ApiErrorKind.validation,
        statusCode: 409,
        serverMessage: 'CNIC is already registered',
      );
      await _tap(tester, find.widgetWithText(ElevatedButton, 'Create Account'));
      expect(find.text('CNIC is already registered'), findsOneWidget);
      expect(find.text('Your identity'), findsOneWidget);
      expect(_text(tester, 'CNIC'), '35202-1234567-1');
    });

    testWidgets(
      'an unverified email moves on to verification, keeping the form',
      (tester) async {
        final flow = await toIdentity(tester);
        flow.repo.onboardingError = const ApiException(
          ApiErrorKind.unauthorized,
          statusCode: 401,
          code: 'EMAIL_VERIFICATION_REQUIRED',
        );
        await _tap(
          tester,
          find.widgetWithText(ElevatedButton, 'Create Account'),
        );
        expect(flow.location, '/auth/verify');
        final session = flow.session!;
        expect(session.pendingRequest, isA<BuyerOnboardingRequest>());
        expect(session.email, 'ayesha@example.com');
        expect(session.draft.value(OnboardingField.fullName), 'Ayesha Khan');
      },
    );

    testWidgets('offline shows the network message, not a crash', (
      tester,
    ) async {
      final flow = await toIdentity(tester);
      flow.repo.onboardingError = const ApiException(ApiErrorKind.network);
      await _tap(tester, find.widgetWithText(ElevatedButton, 'Create Account'));
      expect(
        find.text('No internet connection. Check your network and try again.'),
        findsOneWidget,
      );
    });
  });

  testWidgets('Urdu (RTL) at 1.3x text scale: every step lays out', (
    tester,
  ) async {
    await _open(tester, locale: const Locale('ur'), textScale: 1.3);
    expect(tester.takeException(), isNull);
    expect(find.text('آپ فارم ٹو فورک کیسے استعمال کریں گے؟'), findsOneWidget);
    await _tap(tester, find.text('کاشتکار'));
    expect(tester.takeException(), isNull);
    await _type(tester, 'ای میل', 'ayesha@example.com');
    await _type(tester, 'پاس ورڈ', 'Sunflower42');
    await _tap(tester, find.widgetWithText(ElevatedButton, 'اگلا'));
    expect(tester.takeException(), isNull);
    await _type(tester, 'پورا نام', 'محمد عبدالرحمن بن عبداللہ خان نیازی');
    await _type(tester, 'فارم کا نام', 'سرسبز وادی کا جدید زرعی فارم');
    await _tap(tester, find.widgetWithText(ElevatedButton, 'اگلا'));
    expect(tester.takeException(), isNull);
    await _type(tester, 'گلی کا پتہ', 'چک نمبر پانچ، نہر روڈ، ملتان');
    await _type(tester, 'شہر', 'ملتان');
    await _tap(tester, find.widgetWithText(ElevatedButton, 'اگلا'));
    expect(tester.takeException(), isNull);
  });
}
