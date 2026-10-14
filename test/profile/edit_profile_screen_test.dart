import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/profile/data/models/user_profile.dart';
import 'package:farm2fork_mobile/features/profile/presentation/screens/edit_profile_screen.dart';
import 'profile_test_support.dart';

class _Harness {
  _Harness(this.tester, this.container, this.repo, this.avatar);
  final WidgetTester tester;
  final ProviderContainer container;
  final FakeProfileRepository repo;
  final FakeAvatarSource avatar;
}

Future<_Harness> _open(
  WidgetTester tester, {
  UserProfile? profile,
  Locale locale = const Locale('en'),
  double textScale = 1.0,
}) async {
  final repo = FakeProfileRepository(profile ?? buyerProfile());
  final avatar = FakeAvatarSource();
  final container = ProviderContainer(
    overrides: profileOverrides(repo: repo, avatar: avatar),
  );
  addTearDown(container.dispose);
  await container.read(authControllerProvider.future);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: testRouterApp(
        child: const EditProfileScreen(),
        locale: locale,
        textScale: textScale,
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return _Harness(tester, container, repo, avatar);
}

Finder get _save => find.widgetWithText(ElevatedButton, 'Save changes');
bool _saveEnabled(WidgetTester t) =>
    t.widget<ElevatedButton>(_save).onPressed != null;

void main() {
  testWidgets('shows the profile; save stays off until something changes', (
    tester,
  ) async {
    await _open(tester);
    expect(find.widgetWithText(TextFormField, 'Ayesha Khan'), findsOneWidget);
    expect(
      find.widgetWithText(TextFormField, 'Khan Traders', skipOffstage: false),
      findsOneWidget,
    );
    // Identity is shown but locked.
    expect(find.text('ayesha@example.test'), findsOneWidget);
    expect(find.text('*********5671'), findsOneWidget);
    expect(
      find.byIcon(Icons.lock_outline_rounded, skipOffstage: false),
      findsNWidgets(2),
    );
    expect(_saveEnabled(tester), isFalse);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Ayesha Khan'),
      'Ayesha K.',
    );
    await tester.pump();
    expect(_saveEnabled(tester), isTrue);

    // Typing the original value back is not a change.
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Ayesha K.'),
      'Ayesha Khan',
    );
    await tester.pump();
    expect(_saveEnabled(tester), isFalse);
  });

  testWidgets('saves only the changed field and refreshes the auth user', (
    tester,
  ) async {
    final h = await _open(tester);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Ayesha Khan'),
      'Ayesha Malik',
    );
    await tester.pump();
    await tester.tap(_save);
    await tester.pumpAndSettle();

    expect(h.repo.updates.single.toJson(), {'fullName': 'Ayesha Malik'});
    expect(find.text('Profile updated.'), findsOneWidget);
    expect(_saveEnabled(tester), isFalse);
    expect(
      h.container.read(authControllerProvider).value!.user!.fullName,
      'Ayesha Malik',
    );
  });

  testWidgets('a typed phone number is normalised before it is sent', (
    tester,
  ) async {
    final h = await _open(tester);
    await tester.enterText(
      find.widgetWithText(TextFormField, '+923001234567'),
      '0311 7654321',
    );
    await tester.pump();
    expect(find.text('Saved as +923117654321'), findsOneWidget);
    await tester.tap(_save);
    await tester.pumpAndSettle();
    expect(h.repo.updates.single.toJson(), {'phone': '+923117654321'});
  });

  testWidgets('invalid values are explained and nothing is sent', (
    tester,
  ) async {
    final h = await _open(tester);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Ayesha Khan'),
      'A',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, '+923001234567'),
      '12',
    );
    await tester.pump();
    await tester.tap(_save);
    await tester.pumpAndSettle();
    expect(
      find.text('Enter your full name (at least 2 letters)'),
      findsOneWidget,
    );
    expect(
      find.text('Enter a valid phone number, like 0300 1234567'),
      findsOneWidget,
    );
    expect(h.repo.updates, isEmpty);
  });

  testWidgets('a field the server rejects gets its own message', (
    tester,
  ) async {
    final h = await _open(tester);
    h.repo.updateError = const ApiException(
      ApiErrorKind.validation,
      statusCode: 400,
      serverMessage: 'phone must be a valid phone number',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, '+923001234567'),
      '0311 7654321',
    );
    await tester.pump();
    await tester.tap(_save);
    await tester.pumpAndSettle();

    expect(
      find.text('“Phone Number” was not accepted. Check it and try again.'),
      findsOneWidget,
    );
    // Editing again clears the stale server message.
    await tester.enterText(
      find.widgetWithText(TextFormField, '0311 7654321'),
      '0322 1112223',
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('was not accepted'), findsNothing);
  });

  testWidgets('a network failure keeps the edits and offers another try', (
    tester,
  ) async {
    final h = await _open(tester);
    h.repo.updateError = const ApiException(ApiErrorKind.network);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Ayesha Khan'),
      'Ayesha Malik',
    );
    await tester.pump();
    await tester.tap(_save);
    await tester.pumpAndSettle();
    expect(
      find.text('No internet connection. Check your network and try again.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextFormField, 'Ayesha Malik'), findsOneWidget);
    expect(_saveEnabled(tester), isTrue);

    h.repo.updateError = null;
    await tester.tap(_save);
    await tester.pumpAndSettle();
    expect(h.repo.updates.single.fullName, 'Ayesha Malik');
  });

  testWidgets('leaving with unsaved edits asks first', (tester) async {
    await _open(tester);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Ayesha Khan'),
      'Changed',
    );
    await tester.pump();

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsOneWidget);

    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsNothing);
    expect(find.byType(EditProfileScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.byType(EditProfileScreen), findsNothing);
  });

  testWidgets('leaving without edits needs no confirmation', (tester) async {
    await _open(tester);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsNothing);
    expect(find.byType(EditProfileScreen), findsNothing);
  });

  group('profile photo', () {
    testWidgets('picks from the gallery and uploads the cropped photo', (
      tester,
    ) async {
      final h = await _open(tester);
      expect(find.text('Remove photo'), findsNothing);

      await tester.tap(find.text('Add photo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose from gallery'));
      await tester.pumpAndSettle();

      expect(h.avatar.lastSource?.name, 'gallery');
      expect(h.repo.uploads.single.bytes, [0xFF, 0xD8, 0xFF, 0xD9]);
      expect(find.text('Photo updated.'), findsOneWidget);
      expect(find.text('Change photo'), findsOneWidget);
      expect(find.text('Remove photo'), findsOneWidget);
      expect(
        h.container.read(authControllerProvider).value!.user!.avatarUrl,
        isNotNull,
      );
    });

    testWidgets('the camera is offered and cancelling does nothing', (
      tester,
    ) async {
      final h = await _open(tester);
      h.avatar.result = null;
      await tester.tap(find.text('Add photo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Take a photo'));
      await tester.pumpAndSettle();
      expect(h.avatar.lastSource?.name, 'camera');
      expect(h.repo.uploads, isEmpty);
      expect(find.text('Photo updated.'), findsNothing);
    });

    testWidgets('removing a photo calls DELETE and falls back to initials', (
      tester,
    ) async {
      final h = await _open(
        tester,
        profile: buyerProfile(avatarUrl: 'data:image/jpeg;base64,/9j/4AAQ'),
      );
      await tester.tap(find.text('Remove photo'));
      await tester.pumpAndSettle();
      expect(h.repo.removes, 1);
      expect(find.text('Photo removed.'), findsOneWidget);
      expect(find.text('Remove photo'), findsNothing);
      expect(find.text('AK'), findsOneWidget);
    });

    testWidgets('permission and upload failures are explained', (tester) async {
      final h = await _open(tester);
      h.avatar.error = PlatformException(code: 'photo_access_denied');
      await tester.tap(find.text('Add photo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose from gallery'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Check the app'), findsOneWidget);

      h.avatar.error = null;
      h.repo.uploadError = const ApiException(ApiErrorKind.server);
      await tester.tap(find.text('Add photo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose from gallery'));
      await tester.pumpAndSettle();
      expect(find.textContaining("Couldn't update your photo"), findsOneWidget);
      expect(find.text('Photo updated.'), findsNothing);
    });
  });

  group('roles', () {
    testWidgets('farmers edit farm details and reach the pickup location', (
      tester,
    ) async {
      final h = await _open(tester, profile: farmerProfile());
      expect(
        find.widgetWithText(TextFormField, 'سبز وادی فارم'),
        findsOneWidget,
      );
      expect(find.widgetWithText(TextFormField, 'گندم, ٹماٹر'), findsOneWidget);
      expect(find.text('Multan, Punjab'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'گندم, ٹماٹر'),
        'گندم, چاول',
      );
      await tester.pump();
      expect(_saveEnabled(tester), isTrue);
      // Farmers have no business-type chips.
      expect(find.text('Individual'), findsNothing);
      expect(h.repo.updates, isEmpty);

      await tester.ensureVisible(find.text('Farm pickup location'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Farm pickup location'));
      await tester.pumpAndSettle();
      expect(find.text('farm location page'), findsOneWidget);
    });

    testWidgets('buyers can switch to individual and the business name goes', (
      tester,
    ) async {
      final h = await _open(tester);
      expect(
        find.widgetWithText(TextFormField, 'Khan Traders'),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        find.text('Individual'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Individual'));
      await tester.pump();
      expect(find.widgetWithText(TextFormField, 'Khan Traders'), findsNothing);
      await tester.tap(_save);
      await tester.pumpAndSettle();
      expect(h.repo.updates.single.toJson(), {'businessType': 'individual'});
    });

    testWidgets('transporters edit their vehicle', (tester) async {
      final h = await _open(tester, profile: transporterProfile());
      await tester.scrollUntilVisible(
        find.text('Truck'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Truck'));
      await tester.pump();
      await tester.tap(_save);
      await tester.pumpAndSettle();
      expect(h.repo.updates.single.toJson(), {'vehicleType': 'truck'});
    });
  });

  testWidgets('Urdu at 1.3x text scale lays out for every role', (
    tester,
  ) async {
    for (final profile in [
      buyerProfile(fullName: 'عائشہ خان'),
      farmerProfile(),
      transporterProfile(),
    ]) {
      await _open(
        tester,
        profile: profile,
        locale: const Locale('ur'),
        textScale: 1.3,
      );
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(
        find.byIcon(Icons.lock_outline_rounded).first,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    }
  });
}
