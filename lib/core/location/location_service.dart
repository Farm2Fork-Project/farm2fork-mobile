import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:farm2fork_mobile/core/location/geo_point.dart';

enum LocationFailure {
  serviceDisabled,
  denied,
  deniedForever,
  timeout,

  /// A position came back but it is too coarse to trust (see
  /// [LocationException.approximate]).
  lowAccuracy,
  unavailable,
}

/// Fixes worse than this (metres) are reported as [LocationFailure.lowAccuracy].
const double maxTrustedAccuracyMeters = 500;

class LocationException implements Exception {
  const LocationException(this.failure, {this.approximate});

  final LocationFailure failure;

  /// The rough position for [LocationFailure.lowAccuracy]; callers may still
  /// move the map there and ask the user to adjust the pin.
  final GeoPoint? approximate;
}

/// Foreground location only: the app never asks for background access.
abstract class LocationService {
  /// Checks services and permission (asking once if needed), then returns
  /// the current position. Throws [LocationException].
  Future<GeoPoint> current();

  /// Like [current] but strict: throws [LocationFailure.lowAccuracy] (with the
  /// rough position) when the fix is too coarse to place a pin on, so the UI
  /// can ask the user to check and drag it.
  Future<GeoPoint> currentForPin();

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
    try {
      return (await _fix()).point;
    } on LocationException catch (e) {
      // Dispatch only needs a best-effort position.
      final rough = e.approximate;
      if (e.failure == LocationFailure.lowAccuracy && rough != null) {
        return rough;
      }
      rethrow;
    }
  }

  @override
  Future<GeoPoint> currentForPin() async => (await _fix()).point;

  Future<({GeoPoint point})> _fix() async {
    await _ensurePermission();
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      final point = GeoPoint(position.latitude, position.longitude);
      if (position.accuracy > maxTrustedAccuracyMeters) {
        throw LocationException(
          LocationFailure.lowAccuracy,
          approximate: point,
        );
      }
      return (point: point);
    } on TimeoutException {
      // A stale fix beats nothing; the user can still drag the pin.
      final last = await _lastKnown();
      if (last != null) {
        throw LocationException(LocationFailure.lowAccuracy, approximate: last);
      }
      throw const LocationException(LocationFailure.timeout);
    } on LocationServiceDisabledException {
      throw const LocationException(LocationFailure.serviceDisabled);
    } on PermissionDeniedException {
      throw const LocationException(LocationFailure.denied);
    } on LocationException {
      rethrow;
    } on Object {
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

  Future<GeoPoint?> _lastKnown() async {
    try {
      final p = await Geolocator.getLastKnownPosition();
      return p == null ? null : GeoPoint(p.latitude, p.longitude);
    } on Object {
      return null;
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
