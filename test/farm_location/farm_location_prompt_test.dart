import 'package:farm2fork_mobile/core/localization/generated/app_localizations.dart';
import 'package:farm2fork_mobile/core/location/geo_point.dart';
import 'package:farm2fork_mobile/core/location/location_service.dart';
import 'package:farm2fork_mobile/core/maps/app_map.dart';
import 'package:farm2fork_mobile/core/maps/location_picker_screen.dart';
import 'package:farm2fork_mobile/features/farm_location/data/farm_location.dart';
import 'package:farm2fork_mobile/features/farm_location/presentation/farm_location_prompt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _gps = GeoPoint(30.1968, 71.4782);
const _panned = GeoPoint(30.2, 71.49);

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

class _Gps implements LocationService {
  @override
  Future<GeoPoint> current() async => _gps;

  @override
  Stream<GeoPoint> watch({int distanceFilterMeters = 200}) =>
      const Stream.empty();

  @override
  Future<void> openSettingsFor(LocationFailure failure) async {}
}

/// Stands in for the platform map: a button that "pans" the map.
Widget _fakeMap(AppMapConfig config) => Center(
  child: TextButton(
    key: const Key('pan-map'),
    onPressed: () => config.onCenterChanged?.call(_panned),
    child: const Text('map'),
  ),
);

Future<void> _pump(WidgetTester tester, _Repo repo) async {
  tester.view.physicalSize = const Size(360, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(
          body: SingleChildScrollView(child: FarmLocationPrompt()),
        ),
      ),
      GoRoute(
        path: LocationPickerScreen.route,
        builder: (_, state) =>
            LocationPickerScreen(args: state.extra! as LocationPickerArgs),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        farmLocationRepositoryProvider.overrideWithValue(repo),
        appMapBuilderProvider.overrideWithValue(_fakeMap),
        locationServiceProvider.overrideWithValue(_Gps()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (_, _) => MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
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
      pin: GeoPoint(34.0, 71.5),
    );
    expect(location.complete, isTrue);
    expect(location.toJson(), {
      'address': 'Chak 5',
      'city': 'Multan',
      'province': 'Khyber Pakhtunkhwa',
      'lat': 34.0,
      'lng': 71.5,
    });
    // Everything but the pin is still incomplete: delivery can't be priced.
    expect(
      const FarmLocation(
        address: 'Chak 5',
        city: 'Multan',
        province: PakistanProvince.punjab,
      ).complete,
      isFalse,
    );
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
          pin: _gps,
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
    expect(find.text('Pin the location on the map'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'Chak 5');
    await tester.tap(find.text('Select province'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sindh').last);
    await tester.pumpAndSettle();

    // Picker: starts at the GPS fix, the farmer nudges the map, confirms.
    await tester.tap(find.text('Pin farm on map'));
    await tester.pumpAndSettle();
    expect(find.text('Pin your farm'), findsOneWidget);
    await tester.tap(find.byKey(const Key('pan-map')));
    await tester.pump();
    await tester.tap(find.text('Confirm this spot'));
    await tester.pumpAndSettle();
    expect(find.text('Location pinned'), findsOneWidget);

    await tester.tap(find.text('Save location'));
    await tester.pumpAndSettle();

    expect(repo.saved?.toJson(), {
      'address': 'Chak 5',
      'city': 'Multan',
      'province': 'Sindh',
      'lat': _panned.lat,
      'lng': _panned.lng,
    });
    expect(find.text("Add your farm's pickup location"), findsNothing);
  });
}
