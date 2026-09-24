import 'package:farm2fork_mobile/core/localization/generated/app_localizations.dart';
import 'package:farm2fork_mobile/features/farm_location/data/farm_location.dart';
import 'package:farm2fork_mobile/features/farm_location/presentation/farm_location_prompt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class _Repo implements FarmLocationRepository {
  _Repo(this.location);

  FarmLocation location;
  FarmLocation? saved;

  @override
  Future<FarmLocation> get() async => location;

  @override
  Future<FarmLocation> update(FarmLocation next) async =>
      location = saved = next;
}

Future<void> _pump(WidgetTester tester, _Repo repo) async {
  tester.view.physicalSize = const Size(360, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [farmLocationRepositoryProvider.overrideWithValue(repo)],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (_, _) => MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: SingleChildScrollView(child: FarmLocationPrompt()),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('wire format matches the backend province values', () {
    const location = FarmLocation(
      address: ' Chak 5 ',
      city: 'Multan',
      province: PakistanProvince.khyberPakhtunkhwa,
    );
    expect(location.complete, isTrue);
    expect(location.toJson(), {
      'address': 'Chak 5',
      'city': 'Multan',
      'province': 'Khyber Pakhtunkhwa',
    });
    expect(
      FarmLocation.fromJson({'city': 'Multan', 'province': 'Nowhere'}).complete,
      isFalse,
    );
  });

  testWidgets('hidden when the farm location is complete', (tester) async {
    await _pump(
      tester,
      _Repo(
        const FarmLocation(
          address: 'Chak 5',
          city: 'Multan',
          province: PakistanProvince.punjab,
        ),
      ),
    );
    expect(find.text("Add your farm's pickup location"), findsNothing);
  });

  testWidgets('incomplete location: validates, saves, then disappears', (
    tester,
  ) async {
    final repo = _Repo(const FarmLocation(city: 'Multan'));
    await _pump(tester, repo);
    expect(find.text("Add your farm's pickup location"), findsOneWidget);

    await tester.tap(find.text('Save location'));
    await tester.pumpAndSettle();
    expect(repo.saved, isNull);
    expect(find.text('This field is required'), findsNWidgets(2));

    await tester.enterText(find.byType(TextFormField).first, 'Chak 5');
    await tester.tap(find.text('Select province'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sindh').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save location'));
    await tester.pumpAndSettle();

    expect(repo.saved?.toJson(), {
      'address': 'Chak 5',
      'city': 'Multan',
      'province': 'Sindh',
    });
    expect(find.text("Add your farm's pickup location"), findsNothing);
  });
}
