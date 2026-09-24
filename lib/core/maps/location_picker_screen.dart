import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/location/geo_point.dart';
import 'package:farm2fork_mobile/core/location/location_messages.dart';
import 'package:farm2fork_mobile/core/location/location_service.dart';
import 'package:farm2fork_mobile/core/maps/app_map.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';

/// Arguments for the picker route.
class LocationPickerArgs {
  const LocationPickerArgs({this.initial, required this.purpose});

  final GeoPoint? initial;
  final LocationPickerPurpose purpose;
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
  late GeoPoint _cameraCenter = widget.args.initial ?? defaultMapCenter;
  late GeoPoint _picked = _cameraCenter;
  late bool _hasChoice = widget.args.initial != null;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    // No pin yet: start from the device position when it's cheaply available.
    if (widget.args.initial == null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _useMyLocation(quiet: true),
      );
    }
  }

  Future<void> _useMyLocation({bool quiet = false}) async {
    final service = ref.read(locationServiceProvider);
    setState(() => _locating = true);
    try {
      final here = await service.current();
      if (!mounted) return;
      setState(() {
        _cameraCenter = here;
        _picked = here;
        _hasChoice = true;
      });
    } on LocationException catch (e) {
      if (mounted && !quiet) showLocationFailure(context, service, e.failure);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _confirm() {
    if (!_picked.isInPakistan) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.locationOutsidePakistan)),
      );
      return;
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
      body: Stack(
        children: [
          Positioned.fill(
            child: AppMap(
              config: AppMapConfig(
                center: _cameraCenter,
                zoom: widget.args.initial == null && !_hasChoice ? 6 : 16,
                showMyLocation: true,
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
          Positioned(
            left: AppSpacing.pagePadding,
            right: AppSpacing.pagePadding,
            bottom: AppSpacing.pagePadding,
            child: SafeArea(
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
