import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/location/geo_point.dart';
import 'package:farm2fork_mobile/core/location/location_messages.dart';
import 'package:farm2fork_mobile/core/location/location_service.dart';
import 'package:farm2fork_mobile/core/location/pakistan_locations.dart';
import 'package:farm2fork_mobile/core/maps/app_map.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';

/// Arguments for the picker route.
class LocationPickerArgs {
  const LocationPickerArgs({
    this.initial,
    required this.purpose,
    this.cityName,
    this.cityCentre,
  });

  final GeoPoint? initial;
  final LocationPickerPurpose purpose;

  /// The city chosen in the form: the map opens there, and a pin more than
  /// [cityPinRadiusKm] away asks for confirmation.
  final String? cityName;
  final GeoPoint? cityCentre;
}

enum LocationPickerPurpose { farm, dropoff }

/// Full-screen map with a fixed centre pin: the user pans the map under the
/// pin, optionally jumps to their GPS position, and confirms. Pops with the
/// chosen [GeoPoint], or null when cancelled.
class LocationPickerScreen extends ConsumerStatefulWidget {
  const LocationPickerScreen({super.key, required this.args});

  static const route = '/pick-location';

  final LocationPickerArgs args;

  @override
  ConsumerState<LocationPickerScreen> createState() =>
      _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  late GeoPoint _cameraCenter =
      widget.args.initial ?? widget.args.cityCentre ?? defaultMapCenter;
  late GeoPoint _picked = _cameraCenter;
  late bool _hasChoice = widget.args.initial != null;
  bool _locating = false;
  GeoPoint? _gps;

  @override
  void initState() {
    super.initState();
    // No pin and no city yet: start from the device position when it's
    // cheaply available. With a city chosen the map opens there instead.
    if (widget.args.initial == null && widget.args.cityCentre == null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _useMyLocation(quiet: true),
      );
    }
  }

  Future<void> _useMyLocation({bool quiet = false}) async {
    final service = ref.read(locationServiceProvider);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    setState(() => _locating = true);
    void moveTo(GeoPoint here) => setState(() {
      _gps = here;
      _cameraCenter = here;
      _picked = here;
      _hasChoice = true;
    });
    try {
      moveTo(await service.currentForPin());
    } on LocationException catch (e) {
      if (!mounted) return;
      // A rough fix still moves the map close; the user fine-tunes the pin.
      final rough = e.approximate;
      if (rough != null) moveTo(rough);
      if (!quiet) {
        showLocationFailure(
          context,
          service,
          e.failure,
          onRetry: () => _useMyLocation(),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _confirm() async {
    if (!_picked.isInPakistan) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.locationOutsidePakistan)),
      );
      return;
    }
    final centre = widget.args.cityCentre;
    if (centre != null && pinIsFarFromCity(_picked, centre)) {
      final keep = await showDialog<bool>(
        context: context,
        builder: (_) => _FarFromCityDialog(
          city: widget.args.cityName ?? '',
          km: _picked.distanceKmTo(centre),
        ),
      );
      if (keep != true || !mounted) return;
    }
    context.pop(_picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final farm = widget.args.purpose == LocationPickerPurpose.farm;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          farm ? l10n.pickFarmLocationTitle : l10n.pickDropoffTitle,
          style: AppTextStyles.h3,
        ),
      ),
      // The card sits below the map (not over it) so the OpenStreetMap
      // attribution stays visible and the pin marks the visible centre.
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: AppMap(
                    config: AppMapConfig(
                      center: _cameraCenter,
                      zoom: widget.args.initial != null || _gps != null
                          ? 16
                          : widget.args.cityCentre != null
                          ? 12
                          : 6,
                      markers: [
                        if (_gps != null)
                          AppMarker(
                            id: 'me',
                            at: _gps!,
                            kind: AppMarkerKind.me,
                          ),
                      ],
                      onCenterChanged: (center) => setState(() {
                        _picked = center;
                        _hasChoice = true;
                      }),
                    ),
                  ),
                ),
                // The pin's tip marks the map centre.
                const IgnorePointer(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 44),
                      child: Icon(
                        Icons.location_on_rounded,
                        size: 48,
                        color: AppColors.errorRed,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(16),
                color: AppColors.white,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        farm ? l10n.pickFarmLocationHint : l10n.pickDropoffHint,
                        style: AppTextStyles.small.copyWith(height: 1.4),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                        label: l10n.useMyLocation,
                        icon: Icons.my_location_rounded,
                        variant: AppButtonVariant.secondary,
                        expand: true,
                        isLoading: _locating,
                        onPressed: _locating ? null : _useMyLocation,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppButton(
                        label: l10n.confirmLocation,
                        icon: Icons.check_rounded,
                        expand: true,
                        onPressed: _hasChoice ? _confirm : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FarFromCityDialog extends StatelessWidget {
  const _FarFromCityDialog({required this.city, required this.km});

  final String city;
  final double km;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.pinFarFromCityTitle),
      content: Text(l10n.pinFarFromCityBody(km.round().toString(), city)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.pinFarFromCityMove),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.pinFarFromCityKeep),
        ),
      ],
    );
  }
}
