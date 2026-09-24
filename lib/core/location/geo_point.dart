import 'dart:math' as math;

/// A latitude/longitude pair independent of any map SDK.
class GeoPoint {
  const GeoPoint(this.lat, this.lng);

  final double lat;
  final double lng;

  /// Generous bounding box around Pakistan (same as the backend's).
  bool get isInPakistan =>
      lat >= 23.5 && lat <= 37.2 && lng >= 60.5 && lng <= 77.9;

  Map<String, double> toJson() => {'lat': lat, 'lng': lng};

  static GeoPoint? tryParse(Object? json) {
    if (json is! Map) return null;
    final lat = json['lat'];
    final lng = json['lng'];
    if (lat is! num || lng is! num) return null;
    return GeoPoint(lat.toDouble(), lng.toDouble());
  }

  /// Great-circle distance in kilometres.
  double distanceKmTo(GeoPoint other) {
    double rad(double deg) => deg * math.pi / 180;
    final dLat = rad(other.lat - lat);
    final dLng = rad(other.lng - lng);
    final h =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(rad(lat)) *
            math.cos(rad(other.lat)) *
            math.pow(math.sin(dLng / 2), 2);
    return 2 * 6371.0088 * math.asin(math.min(1, math.sqrt(h)));
  }

  @override
  bool operator ==(Object other) =>
      other is GeoPoint && other.lat == lat && other.lng == lng;

  @override
  int get hashCode => Object.hash(lat, lng);

  @override
  String toString() => '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
}

/// Centre of Pakistan's farming heartland, used before a pin exists.
const GeoPoint defaultMapCenter = GeoPoint(31.0, 72.5);
