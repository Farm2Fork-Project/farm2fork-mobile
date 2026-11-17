import 'dart:io';

import 'package:farm2fork_mobile/core/location/geo_point.dart';
import 'package:farm2fork_mobile/core/location/location_service.dart';
import 'package:farm2fork_mobile/core/maps/app_map.dart';
import 'package:farm2fork_mobile/core/maps/location_picker_screen.dart';
import 'package:farm2fork_mobile/core/location/pakistan_locations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

class _Failing extends FakeLocationService {
  _Failing(this.failure, {this.rough});

  final LocationFailure failure;
  final GeoPoint? rough;

  @override
  Future<GeoPoint> currentForPin() async =>
      throw LocationException(failure, approximate: rough);
}

Finder get _coordinateFields => find.byWidgetPredicate(
  (w) =>
      w is TextField &&
      RegExp(
        'latitude|longitude',
        caseSensitive: false,
      ).hasMatch(w.decoration?.labelText ?? ''),
);

Widget _fakePanMap(AppMapConfig config) => Center(
  child: TextButton(
    key: const Key('pan'),
    onPressed: () => config.onCenterChanged?.call(const GeoPoint(31.0, 72.0)),
    child: Text('map:${config.markers.length}'),
  ),
);

void main() {
  testWidgets(
    'picker offers no coordinate dialog or latitude/longitude field',
    (tester) async {
      await pumpScreen(
        tester,
        const LocationPickerScreen(
          args: LocationPickerArgs(purpose: LocationPickerPurpose.farm),
        ),
      );
      expect(find.text('Enter coordinates'), findsNothing);
      expect(find.textContaining('oordinate'), findsNothing);
      expect(_coordinateFields, findsNothing);
      expect(find.byType(TextField), findsNothing);
    },
  );

  test('source tree contains no coordinate input strings or dialog', () {
    final offenders = <String>[];
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      if (f.path.contains('/generated/')) continue;
      final text = f.readAsStringSync();
      if (text.contains('_CoordinateDialog') ||
          text.contains('enterCoordinates') ||
          text.contains('locationLatitude') ||
          text.contains('locationLongitude')) {
        offenders.add(f.path);
      }
    }
    expect(offenders, isEmpty);
    expect(
      File('lib/l10n/app_en.arb').readAsStringSync(),
      isNot(contains('enterCoordinates')),
    );
  });

  group('GPS failures never block: the pin stays draggable', () {
    for (final entry in {
      LocationFailure.denied: 'needs location permission',
      LocationFailure.deniedForever: 'blocked',
      LocationFailure.serviceDisabled: 'turned off',
      LocationFailure.timeout: 'taking too long',
      LocationFailure.unavailable: "Couldn't get your location",
    }.entries) {
      testWidgets('${entry.key.name}: clear message, then pan + confirm', (
        tester,
      ) async {
        await pumpScreen(
          tester,
          const LocationPickerScreen(
            args: LocationPickerArgs(purpose: LocationPickerPurpose.farm),
          ),
          location: _Failing(entry.key),
          mapBuilder: _fakePanMap,
        );
        await tester.tap(find.text('Use my current location'));
        await tester.pumpAndSettle();
        expect(find.textContaining(entry.value), findsOneWidget);
        if (entry.key == LocationFailure.deniedForever ||
            entry.key == LocationFailure.serviceDisabled) {
          expect(find.text('Settings'), findsOneWidget);
        }
        // Fallback: drag the map (never type coordinates).
        await tester.tap(find.byKey(const Key('pan')));
        await tester.pump();
        expect(
          tester
              .widget<ElevatedButton>(
                find.ancestor(
                  of: find.text('Confirm this spot'),
                  matching: find.byType(ElevatedButton),
                ),
              )
              .onPressed,
          isNotNull,
        );
      });
    }

    testWidgets('low accuracy still moves the map and warns', (tester) async {
      await pumpScreen(
        tester,
        const LocationPickerScreen(
          args: LocationPickerArgs(purpose: LocationPickerPurpose.farm),
        ),
        location: _Failing(
          LocationFailure.lowAccuracy,
          rough: const GeoPoint(31.5, 74.3),
        ),
      );
      await tester.tap(find.text('Use my current location'));
      await tester.pumpAndSettle();
      expect(find.textContaining('not exact'), findsOneWidget);
      expect(find.text('map:1'), findsOneWidget, reason: 'me marker shown');
    });
  });

  group('pin far from the chosen city', () {
    final lahore = const GeoPoint(31.5204, 74.3587);
    Future<void> open(WidgetTester tester, GeoPoint pin) async {
      final results = <GeoPoint?>[];
      await pumpScreen(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () async => results.add(
              await Navigator.of(context).push<GeoPoint>(
                MaterialPageRoute(
                  builder: (_) => LocationPickerScreen(
                    args: LocationPickerArgs(
                      purpose: LocationPickerPurpose.farm,
                      initial: pin,
                      cityName: 'Lahore',
                      cityCentre: lahore,
                    ),
                  ),
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('near the city: confirms without a dialog', (tester) async {
      await open(tester, const GeoPoint(31.55, 74.40));
      await tester.tap(find.text('Confirm this spot'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(LocationPickerScreen), findsNothing);
    });

    testWidgets('far from the city: friendly confirm, move keeps the picker', (
      tester,
    ) async {
      await open(tester, const GeoPoint(30.19, 71.47)); // Multan, ~300 km
      await tester.tap(find.text('Confirm this spot'));
      await tester.pumpAndSettle();
      expect(find.text('Is this the right place?'), findsOneWidget);
      expect(find.textContaining('from Lahore'), findsOneWidget);
      await tester.tap(find.text('No, move the pin'));
      await tester.pumpAndSettle();
      expect(find.byType(LocationPickerScreen), findsOneWidget);

      await tester.tap(find.text('Confirm this spot'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Yes, use this spot'));
      await tester.pumpAndSettle();
      expect(find.byType(LocationPickerScreen), findsNothing);
    });

    testWidgets('outside Pakistan is still rejected', (tester) async {
      await open(tester, const GeoPoint(51.5, -0.12));
      await tester.tap(find.text('Confirm this spot'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Pakistan'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    });
  });

  test('city radius constant is 60 km', () => expect(cityPinRadiusKm, 60));
}
