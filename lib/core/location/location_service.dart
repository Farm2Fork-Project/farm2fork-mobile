import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:farm2fork_mobile/core/location/geo_point.dart';

enum LocationFailure { serviceDisabled, denied, deniedForever, unavailable }

class LocationException implements Exception {
  const LocationException(this.failure);

  final LocationFailure failure;
}

/// Foreground location only: the app never asks for background access.
abstract class LocationService {
  /// Checks services and permission (asking once if needed), then returns
  /// the current position. Throws [LocationException].
  Future<GeoPoint> current();

  /// Position updates while the caller listens (e.g. transporter online).
  Stream<GeoPoint> watch({int distanceFilterMeters = 200});

  /// Opens the OS settings for the case a user must change it there.
  Future<void> openSettingsFor(LocationFailure failure);
}

/// Permission flow as recommended by the geolocator docs: services enabled
/// -> check permission -> request -> handle deniedForever via settings.
class GeolocatorLocationService implements LocationService {
  @override
  Future<GeoPoint> current() async {
    await _ensurePermission();
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      return GeoPoint(position.latitude, position.longitude);
    } on TimeoutException {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) return GeoPoint(last.latitude, last.longitude);
      throw const LocationException(LocationFailure.unavailable);
    }
  }

  @override
  Stream<GeoPoint> watch({int distanceFilterMeters = 200}) async* {
    await _ensurePermission();
    yield* Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilterMeters,
      ),
    ).map((p) => GeoPoint(p.latitude, p.longitude));
  }

  @override
  Future<void> openSettingsFor(LocationFailure failure) async {
    if (failure == LocationFailure.serviceDisabled) {
      await Geolocator.openLocationSettings();
    } else {
      await Geolocator.openAppSettings();
    }
  }

  Future<void> _ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException(LocationFailure.serviceDisabled);
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(LocationFailure.deniedForever);
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
      throw const LocationException(LocationFailure.denied);
    }
  }
}

final locationServiceProvider = Provider<LocationService>(
  (ref) => GeolocatorLocationService(),
);
