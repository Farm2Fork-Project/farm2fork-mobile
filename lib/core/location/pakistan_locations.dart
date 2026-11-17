import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/location/geo_point.dart';

/// How far (km) a map pin may sit from the chosen city centre before the user
/// is asked to confirm it.
const double cityPinRadiusKm = 60;

const String pakistanLocationsAsset = 'assets/data/pakistan-locations.json';

/// A city from the bundled dataset, with its centre point.
class PakistanCity {
  const PakistanCity({
    required this.name,
    required this.province,
    required this.centre,
  });

  final String name;

  /// Province name exactly as the backend expects it (wire value).
  final String province;
  final GeoPoint centre;
}

class PakistanProvinceCities {
  const PakistanProvinceCities({required this.name, required this.cities});

  final String name;
  final List<PakistanCity> cities;
}

/// Province -> city data, parsed once from the bundled JSON asset.
class PakistanLocations {
  const PakistanLocations({required this.attribution, required this.provinces});

  factory PakistanLocations.fromJson(Map<String, dynamic> json) {
    final provinces = <PakistanProvinceCities>[];
    for (final p in json['provinces'] as List<dynamic>) {
      final name = (p as Map<String, dynamic>)['name'] as String;
      final cities = [
        for (final c in p['cities'] as List<dynamic>)
          PakistanCity(
            name: (c as Map<String, dynamic>)['name'] as String,
            province: name,
            centre: GeoPoint(
              (c['lat'] as num).toDouble(),
              (c['lng'] as num).toDouble(),
            ),
          ),
      ]..sort((a, b) => a.name.compareTo(b.name));
      provinces.add(PakistanProvinceCities(name: name, cities: cities));
    }
    return PakistanLocations(
      attribution: json['attribution'] as String? ?? '',
      provinces: provinces,
    );
  }

  factory PakistanLocations.parse(String source) =>
      PakistanLocations.fromJson(jsonDecode(source) as Map<String, dynamic>);

  /// Licence/attribution text that must be visible in the app.
  final String attribution;
  final List<PakistanProvinceCities> provinces;

  int get cityCount => provinces.fold(0, (n, p) => n + p.cities.length);

  List<PakistanCity> citiesOf(String province) {
    for (final p in provinces) {
      if (p.name == province) return p.cities;
    }
    return const [];
  }

  /// Case-insensitive lookup, used for cities saved before the picker existed.
  PakistanCity? find(String? province, String? city) {
    final wanted = city?.trim().toLowerCase();
    if (province == null || wanted == null || wanted.isEmpty) return null;
    for (final c in citiesOf(province)) {
      if (c.name.toLowerCase() == wanted) return c;
    }
    return null;
  }
}

/// Parsed once per app run.
final pakistanLocationsProvider = FutureProvider<PakistanLocations>((
  ref,
) async {
  final source = await rootBundle.loadString(pakistanLocationsAsset);
  return PakistanLocations.parse(source);
});

/// True when [pin] is further than [cityPinRadiusKm] from the city centre.
bool pinIsFarFromCity(GeoPoint pin, GeoPoint cityCentre) =>
    pin.distanceKmTo(cityCentre) > cityPinRadiusKm;
