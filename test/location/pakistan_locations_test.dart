import 'dart:io';

import 'package:farm2fork_mobile/core/location/geo_point.dart';
import 'package:farm2fork_mobile/core/location/pakistan_locations.dart';
import 'package:farm2fork_mobile/features/farm_location/data/farm_location.dart';
import 'package:flutter_test/flutter_test.dart';

PakistanLocations _load() =>
    PakistanLocations.parse(File(pakistanLocationsAsset).readAsStringSync());

void main() {
  final data = _load();

  test(
    'every backend province has cities and every dataset province is known',
    () {
      final names = data.provinces.map((p) => p.name).toSet();
      expect(names, PakistanProvince.values.map((p) => p.wire).toSet());
      for (final p in data.provinces) {
        expect(p.cities, isNotEmpty, reason: '${p.name} has no cities');
      }
    },
  );

  test('every city lies inside the Pakistan bounds', () {
    expect(data.cityCount, greaterThanOrEqualTo(455));
    for (final p in data.provinces) {
      for (final c in p.cities) {
        expect(c.centre.lat, inInclusiveRange(23.5, 37.2), reason: c.name);
        expect(c.centre.lng, inInclusiveRange(60.5, 77.9), reason: c.name);
        expect(c.centre.isInPakistan, isTrue, reason: c.name);
        expect(c.province, p.name);
      }
    }
  });

  test('carries the ODbL attribution shown in About', () {
    expect(data.attribution, contains('ODbL'));
  });

  test('find is case-insensitive and scoped to the province', () {
    expect(data.find('Punjab', ' lahore ')?.name, 'Lahore');
    expect(data.find('Sindh', 'Lahore'), isNull);
    expect(data.find(null, 'Lahore'), isNull);
  });

  group('distance from the chosen city', () {
    final lahore = data.find('Punjab', 'Lahore')!.centre;

    test('a pin inside the radius needs no confirmation', () {
      expect(pinIsFarFromCity(const GeoPoint(31.60, 74.40), lahore), isFalse);
      expect(pinIsFarFromCity(lahore, lahore), isFalse);
    });

    test('a pin beyond $cityPinRadiusKm km asks for confirmation', () {
      // Faisalabad is ~110 km from Lahore.
      final faisalabad = data.find('Punjab', 'Faisalabad')!.centre;
      expect(pinIsFarFromCity(faisalabad, lahore), isTrue);
      // Karachi is ~1000 km away.
      expect(
        pinIsFarFromCity(data.find('Sindh', 'Karachi')!.centre, lahore),
        isTrue,
      );
    });
  });
}
