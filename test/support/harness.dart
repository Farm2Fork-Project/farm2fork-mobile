import 'package:farm2fork_mobile/core/localization/generated/app_localizations.dart';
import 'package:farm2fork_mobile/core/location/geo_point.dart';
import 'package:farm2fork_mobile/core/location/location_service.dart';
import 'package:farm2fork_mobile/core/location/pakistan_locations.dart';
import 'package:farm2fork_mobile/core/maps/app_map.dart';
import 'package:farm2fork_mobile/core/maps/location_picker_screen.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// The bundled city list, parsed synchronously so widget tests never wait on
/// the asset bundle.
final testLocationsOverride = pakistanLocationsProvider.overrideWith(
  (ref) =>
      PakistanLocations.parse(File(pakistanLocationsAsset).readAsStringSync()),
);

const testGps = GeoPoint(31.5204, 74.3587);

class FakeLocationService implements LocationService {
  FakeLocationService([this.at = testGps]);

  final GeoPoint at;

  @override
  Future<GeoPoint> currentForPin() => current();

  @override
  Future<GeoPoint> current() async => at;

  @override
  Stream<GeoPoint> watch({int distanceFilterMeters = 200}) =>
      const Stream.empty();

  @override
  Future<void> openSettingsFor(LocationFailure failure) async {}
}

/// Platform map views can't render in widget tests.
Widget fakeMap(AppMapConfig config) =>
    SizedBox.expand(child: Text('map:${config.markers.length}'));

/// Pumps [home] inside a router that also serves the location picker and
/// records every other location it is asked to open.
Future<List<String>> pumpScreen(
  WidgetTester tester,
  Widget home, {
  List<Override> overrides = const [],
  Locale locale = const Locale('en'),
  LocationService? location,
  AppMapBuilder mapBuilder = fakeMap,
}) async {
  tester.view.physicalSize = const Size(390, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final visited = <String>[];
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => home),
      GoRoute(
        path: LocationPickerScreen.route,
        builder: (_, state) =>
            LocationPickerScreen(args: state.extra! as LocationPickerArgs),
      ),
      GoRoute(
        path: '/:rest(.*)',
        builder: (_, state) {
          visited.add(state.uri.toString());
          return Scaffold(body: Text('route:${state.uri}'));
        },
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appMapBuilderProvider.overrideWithValue(mapBuilder),
        locationServiceProvider.overrideWithValue(
          location ?? FakeLocationService(),
        ),
        testLocationsOverride,
        ...overrides,
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (_, _) => MaterialApp.router(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return visited;
}

/// Drives the Province -> City sheet opened by [field] (a finder for the
/// city picker field): taps [province], then [city].
Future<void> pickCity(
  WidgetTester tester,
  Finder field,
  String province,
  String city,
) async {
  await tester.ensureVisible(field);
  await tester.tap(
    find.descendant(of: field, matching: find.byType(InkWell)).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text(province).last);
  await tester.pumpAndSettle();
  // The list is lazy and long: search so the city is on screen.
  await tester.enterText(find.byType(TextField).last, city);
  await tester.pumpAndSettle();
  await tester.tap(find.text(city).last);
  await tester.pumpAndSettle();
}
