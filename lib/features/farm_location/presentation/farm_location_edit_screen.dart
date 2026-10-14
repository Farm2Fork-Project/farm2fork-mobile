import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/location/geo_point.dart';
import 'package:farm2fork_mobile/core/maps/location_picker_screen.dart';
import 'package:farm2fork_mobile/core/maps/location_pin_field.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/core/widgets/app_notice_banner.dart';
import 'package:farm2fork_mobile/core/widgets/app_state_placeholder.dart';
import 'package:farm2fork_mobile/core/widgets/app_text_field.dart';
import 'package:farm2fork_mobile/features/farm_location/data/farm_location.dart';
import 'package:farm2fork_mobile/features/farm_location/presentation/province_dropdown.dart';

/// Change a farm's pickup address and map pin from Edit profile. The first
/// save still happens at sign-up (or the Listings prompt); this is for moving
/// or correcting it afterwards.
class FarmLocationEditScreen extends ConsumerWidget {
  const FarmLocationEditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(farmLocationProvider);
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(context.l10n.farmPickupLocation, style: AppTextStyles.h2),
      ),
      body: location.when(
        data: (value) => _FarmLocationEditForm(initial: value),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => AppErrorState(
          message: context.l10n.farmLocationSaveFailed,
          onRetry: () => ref.invalidate(farmLocationProvider),
        ),
      ),
    );
  }
}

class _FarmLocationEditForm extends ConsumerStatefulWidget {
  const _FarmLocationEditForm({required this.initial});

  final FarmLocation initial;

  @override
  ConsumerState<_FarmLocationEditForm> createState() =>
      _FarmLocationEditFormState();
}

class _FarmLocationEditFormState extends ConsumerState<_FarmLocationEditForm> {
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.farmPickupSaved),
          duration: AppDurations.quickConfirmation,
        ),
      );
      context.pop();
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
    const gap = SizedBox(height: AppSpacing.md);
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.farmPickupHelp,
              style: AppTextStyles.small.copyWith(
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _address,
              label: l10n.farmStreet,
              hintText: l10n.farmStreetHint,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              validator: required,
            ),
            gap,
            AppTextField(
              controller: _city,
              label: l10n.farmCity,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              validator: required,
            ),
            gap,
            ProvinceDropdown(
              value: _province,
              onChanged: (value) => setState(() => _province = value),
            ),
            gap,
            LocationPinField(
              purpose: LocationPickerPurpose.farm,
              initialValue: _pin,
              onChanged: (pin) => setState(() => _pin = pin),
            ),
            if (_failed) ...[
              const SizedBox(height: AppSpacing.lg),
              AppNoticeBanner(message: l10n.farmLocationSaveFailed),
            ],
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: l10n.farmLocationSave,
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
