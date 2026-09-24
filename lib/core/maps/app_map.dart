import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:farm2fork_mobile/core/location/geo_point.dart';

enum AppMarkerKind { pickup, dropoff, me }

class AppMarker {
  const AppMarker({
    required this.id,
    required this.at,
    required this.kind,
    this.title,
  });

  final String id;
  final GeoPoint at;
  final AppMarkerKind kind;
  final String? title;
}

class AppMapConfig {
  const AppMapConfig({
    required this.center,
    this.zoom = 12,
    this.markers = const [],
    this.fitMarkers = false,
    this.onCenterChanged,
    this.showMyLocation = false,
    this.interactive = true,
  });

  final GeoPoint center;
  final double zoom;
  final List<AppMarker> markers;

  /// Zooms out so every marker is visible.
  final bool fitMarkers;

  /// Called with the map centre while the user pans (location picker).
  final ValueChanged<GeoPoint>? onCenterChanged;
  final bool showMyLocation;
  final bool interactive;
}

typedef AppMapBuilder = Widget Function(AppMapConfig config);

/// Tests override this: platform map views cannot render in widget tests.
final appMapBuilderProvider = Provider<AppMapBuilder>(
  (ref) =>
      (config) => _GoogleAppMap(config: config),
);

/// The only place the app touches google_maps_flutter.
class AppMap extends ConsumerWidget {
  const AppMap({super.key, required this.config});

  final AppMapConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ref.watch(appMapBuilderProvider)(config);
}

class _GoogleAppMap extends StatefulWidget {
  const _GoogleAppMap({required this.config});

  final AppMapConfig config;

  @override
  State<_GoogleAppMap> createState() => _GoogleAppMapState();
}

class _GoogleAppMapState extends State<_GoogleAppMap> {
  GoogleMapController? _controller;

  LatLng _latLng(GeoPoint p) => LatLng(p.lat, p.lng);

  double _hue(AppMarkerKind kind) => switch (kind) {
    AppMarkerKind.pickup => BitmapDescriptor.hueGreen,
    AppMarkerKind.dropoff => BitmapDescriptor.hueOrange,
    AppMarkerKind.me => BitmapDescriptor.hueAzure,
  };

  @override
  void didUpdateWidget(covariant _GoogleAppMap old) {
    super.didUpdateWidget(old);
    if (widget.config.fitMarkers &&
        old.config.markers != widget.config.markers) {
      _fit();
    } else if (old.config.center != widget.config.center) {
      // A new centre (e.g. "use my location") moves the camera; panning
      // itself reports through onCenterChanged and never changes `center`.
      _controller?.animateCamera(
        CameraUpdate.newLatLngZoom(
          _latLng(widget.config.center),
          widget.config.zoom,
        ),
      );
    }
  }

  Future<void> _fit() async {
    final controller = _controller;
    final markers = widget.config.markers;
    if (controller == null || markers.length < 2) return;
    final lats = markers.map((m) => m.at.lat);
    final lngs = markers.map((m) => m.at.lng);
    final bounds = LatLngBounds(
      southwest: LatLng(
        lats.reduce((a, b) => a < b ? a : b),
        lngs.reduce((a, b) => a < b ? a : b),
      ),
      northeast: LatLng(
        lats.reduce((a, b) => a > b ? a : b),
        lngs.reduce((a, b) => a > b ? a : b),
      ),
    );
    await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 48));
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _latLng(config.center),
        zoom: config.zoom,
      ),
      markers: {
        for (final marker in config.markers)
          Marker(
            markerId: MarkerId(marker.id),
            position: _latLng(marker.at),
            icon: BitmapDescriptor.defaultMarkerWithHue(_hue(marker.kind)),
            infoWindow: marker.title == null
                ? InfoWindow.noText
                : InfoWindow(title: marker.title),
          ),
      },
      myLocationEnabled: config.showMyLocation,
      myLocationButtonEnabled: config.showMyLocation,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      scrollGesturesEnabled: config.interactive,
      zoomGesturesEnabled: config.interactive,
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
      onMapCreated: (controller) {
        _controller = controller;
        if (config.fitMarkers) {
          // Bounds need the map laid out first.
          WidgetsBinding.instance.addPostFrameCallback((_) => _fit());
        }
      },
      onCameraMove: config.onCenterChanged == null
          ? null
          : (position) => config.onCenterChanged!(
              GeoPoint(position.target.latitude, position.target.longitude),
            ),
    );
  }
}

/// Opens turn-by-turn directions in the Google Maps app (or browser).
Future<bool> openDirections(GeoPoint destination) {
  final uri = Uri.https('www.google.com', '/maps/dir/', {
    'api': '1',
    'destination': '${destination.lat},${destination.lng}',
    'travelmode': 'driving',
  });
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
