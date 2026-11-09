import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:farm2fork_mobile/core/location/geo_point.dart';
import 'package:farm2fork_mobile/core/location/location_service.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';

enum AppMarkerKind { pickup, dropoff, me, transporter }

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

  /// Called with the map centre while the map moves (location picker).
  final ValueChanged<GeoPoint>? onCenterChanged;
  final bool showMyLocation;
  final bool interactive;
}

typedef AppMapBuilder = Widget Function(AppMapConfig config);

/// Tests override this: tile images cannot load in widget tests.
final appMapBuilderProvider = Provider<AppMapBuilder>(
  (ref) =>
      (config) => _OsmMap(config: config),
);

/// OpenStreetMap tiles need no API key. Keep [osmUserAgentPackage] unique to
/// the app: the tile policy requires an identifying User-Agent.
const String osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const String osmUserAgentPackage = 'com.farm2fork.app';

/// The only place the app touches flutter_map.
class AppMap extends ConsumerWidget {
  const AppMap({super.key, required this.config});

  final AppMapConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ref.watch(appMapBuilderProvider)(config);
}

class _OsmMap extends ConsumerStatefulWidget {
  const _OsmMap({required this.config});

  final AppMapConfig config;

  @override
  ConsumerState<_OsmMap> createState() => _OsmMapState();
}

class _OsmMapState extends ConsumerState<_OsmMap> {
  final _controller = MapController();
  bool _ready = false;
  StreamSubscription<GeoPoint>? _gps;
  GeoPoint? _here;

  LatLng _latLng(GeoPoint p) => LatLng(p.lat, p.lng);

  @override
  void initState() {
    super.initState();
    if (widget.config.showMyLocation) _watchMe();
  }

  /// Shows the device position as a blue dot (the SDK maps had one built in).
  void _watchMe() {
    try {
      _gps = ref
          .read(locationServiceProvider)
          .watch(distanceFilterMeters: 25)
          .listen(
            (p) {
              if (mounted) setState(() => _here = p);
            },
            onError: (_) {},
            cancelOnError: false,
          );
    } on Object {
      // No permission or no GPS: the map simply has no blue dot.
    }
  }

  @override
  void dispose() {
    _gps?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _OsmMap old) {
    super.didUpdateWidget(old);
    if (!_ready) return;
    final config = widget.config;
    // Camera moves report through onPositionChanged, which may call setState
    // in the owner; never do that while the tree is building.
    if (config.fitMarkers && old.config.markers != config.markers) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fit();
      });
    } else if (old.config.center != config.center) {
      // A new centre (a chosen city, "use my location") moves the camera;
      // panning itself reports through onCenterChanged and never changes
      // `center`.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _controller.move(_latLng(config.center), config.zoom);
      });
    }
  }

  void _fit() {
    final markers = widget.config.markers;
    if (markers.length < 2) return;
    _controller.fitCamera(
      CameraFit.coordinates(
        coordinates: [for (final m in markers) _latLng(m.at)],
        padding: const EdgeInsets.all(48),
        maxZoom: 16,
      ),
    );
  }

  static const _colors = {
    AppMarkerKind.pickup: AppColors.success,
    AppMarkerKind.dropoff: Color(0xFFE8890C),
    AppMarkerKind.me: AppColors.secondaryBlue,
    AppMarkerKind.transporter: Color(0xFF7B4FB3),
  };

  Marker _marker(AppMarker marker) {
    final icon = switch (marker.kind) {
      AppMarkerKind.transporter => Icons.local_shipping_rounded,
      AppMarkerKind.me => Icons.my_location_rounded,
      _ => Icons.location_on_rounded,
    };
    Widget child = Icon(icon, size: 40, color: _colors[marker.kind]);
    if (marker.title != null) {
      child = Tooltip(message: marker.title!, child: child);
    }
    return Marker(
      key: ValueKey(marker.id),
      point: _latLng(marker.at),
      width: 40,
      height: 40,
      // The pin's tip sits on the point; round icons are centred on it.
      alignment:
          marker.kind == AppMarkerKind.pickup ||
              marker.kind == AppMarkerKind.dropoff
          ? Alignment.topCenter
          : Alignment.center,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final markers = config.markers;
    AppMarker? ofKind(AppMarkerKind kind) {
      for (final m in markers) {
        if (m.kind == kind) return m;
      }
      return null;
    }

    final pickup = ofKind(AppMarkerKind.pickup);
    final dropoff = ofKind(AppMarkerKind.dropoff);
    return FlutterMap(
      mapController: _controller,
      options: MapOptions(
        initialCenter: _latLng(config.center),
        initialZoom: config.zoom,
        minZoom: 4,
        maxZoom: 18,
        backgroundColor: AppColors.surfaceLight,
        interactionOptions: InteractionOptions(
          flags: config.interactive
              ? InteractiveFlag.all & ~InteractiveFlag.rotate
              : InteractiveFlag.none,
        ),
        onMapReady: () {
          _ready = true;
          if (config.fitMarkers) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _fit();
            });
          }
        },
        onPositionChanged: config.onCenterChanged == null
            ? null
            : (camera, _) => widget.config.onCenterChanged?.call(
                GeoPoint(camera.center.latitude, camera.center.longitude),
              ),
      ),
      children: [
        TileLayer(
          urlTemplate: osmTileUrl,
          userAgentPackageName: osmUserAgentPackage,
          maxNativeZoom: 19,
        ),
        if (pickup != null && dropoff != null)
          PolylineLayer(
            polylines: [
              Polyline(
                points: [_latLng(pickup.at), _latLng(dropoff.at)],
                strokeWidth: 4,
                color: AppColors.secondaryBlue.withValues(alpha: 0.8),
                pattern: const StrokePattern.dotted(),
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            if (_here != null)
              _marker(AppMarker(id: 'gps', at: _here!, kind: AppMarkerKind.me)),
            for (final marker in markers) _marker(marker),
          ],
        ),
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              context.l10n.mapAttributionOpenStreetMap,
              onTap: () => launchUrl(
                Uri.https('www.openstreetmap.org', '/copyright'),
                mode: LaunchMode.externalApplication,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Shows a place in the Google Maps app (or browser); needs no API key.
Future<bool> openInMaps(GeoPoint place) {
  final uri = Uri.https('www.google.com', '/maps/search/', {
    'api': '1',
    'query': '${place.lat},${place.lng}',
  });
  return launchUrl(uri, mode: LaunchMode.externalApplication);
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
