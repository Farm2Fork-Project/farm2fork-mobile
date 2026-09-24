import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/location/geo_point.dart';
import 'package:farm2fork_mobile/core/maps/location_picker_screen.dart';
import 'package:farm2fork_mobile/core/maps/location_pin_field.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/core/widgets/app_text_field.dart';
import 'package:farm2fork_mobile/features/farm_location/data/farm_location.dart';
import 'package:farm2fork_mobile/features/farm_location/presentation/province_dropdown.dart';

/// Shown on My Listings only while the farm's pickup location is incomplete:
/// until then transporters cannot see or collect any of the farmer's orders.
class FarmLocationPrompt extends ConsumerWidget {
  const FarmLocationPrompt({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(farmLocationProvider).asData?.value;
    if (location == null || location.complete) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.md,
        AppSpacing.pagePadding,
        0,
      ),
      child: _FarmLocationForm(initial: location),
    );
  }
}

class _FarmLocationForm extends ConsumerStatefulWidget {
  const _FarmLocationForm({required this.initial});

  final FarmLocation initial;

  @override
  ConsumerState<_FarmLocationForm> createState() => _FarmLocationFormState();
}

class _FarmLocationFormState extends ConsumerState<_FarmLocationForm> {
  final _formKey = GlobalKey<FormState>();
  late final _address = TextEditingController(text: widget.initial.address);
  late final _city = TextEditingController(text: widget.initial.city);
  late PakistanProvince? _province = widget.initial.province;
  late GeoPoint? _pin = widget.initial.pin;
  bool _saving = false;
  bool _failed = false;

  @override
  void dispose() {
    _address.dispose();
    _city.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _failed = false;
    });
    try {
      await ref
          .read(farmLocationRepositoryProvider)
          .update(
            FarmLocation(
              address: _address.text,
              city: _city.text,
              province: _province,
              pin: _pin,
            ),
          );
      ref.invalidate(farmLocationProvider);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String? required(String? v) =>
        (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null;

    return AppCard(
      backgroundColor: AppColors.accentYellowSoft,
      borderColor: AppColors.accentYellow,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.textDark,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.farmLocationPromptTitle,
                    style: AppTextStyles.h3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.farmLocationPromptBody,
              style: AppTextStyles.small.copyWith(height: 1.4),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _address,
              label: l10n.farmStreet,
              hintText: l10n.farmStreetHint,
              validator: required,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _city,
              label: l10n.farmCity,
              validator: required,
            ),
            const SizedBox(height: AppSpacing.md),
            ProvinceDropdown(
              value: _province,
              onChanged: (value) => setState(() => _province = value),
            ),
            const SizedBox(height: AppSpacing.md),
            LocationPinField(
              purpose: LocationPickerPurpose.farm,
              initialValue: _pin,
              onChanged: (pin) => setState(() => _pin = pin),
            ),
            if (_failed) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.farmLocationSaveFailed,
                style: AppTextStyles.small.copyWith(color: AppColors.errorRed),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: l10n.farmLocationSave,
              icon: Icons.save_rounded,
              expand: true,
              isLoading: _saving,
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
