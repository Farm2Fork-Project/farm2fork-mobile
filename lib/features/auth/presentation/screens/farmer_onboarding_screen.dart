import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/location/geo_point.dart';
import 'package:farm2fork_mobile/core/maps/location_picker_screen.dart';
import 'package:farm2fork_mobile/core/maps/location_pin_field.dart';
import 'package:farm2fork_mobile/features/farm_location/data/farm_location.dart';
import 'package:farm2fork_mobile/features/farm_location/presentation/province_dropdown.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/features/auth/data/models/onboarding_request.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/onboarding_session.dart';
import 'package:farm2fork_mobile/features/auth/presentation/utils/onboarding_support.dart';
import 'package:farm2fork_mobile/features/auth/presentation/widgets/auth_form_widgets.dart';
import 'package:farm2fork_mobile/features/auth/presentation/widgets/onboarding_scaffold.dart';

class FarmerOnboardingScreen extends ConsumerStatefulWidget {
  const FarmerOnboardingScreen({super.key});

  @override
  ConsumerState<FarmerOnboardingScreen> createState() =>
      _FarmerOnboardingScreenState();
}

class _FarmerOnboardingScreenState
    extends ConsumerState<FarmerOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _cnic = TextEditingController();
  final _phone = TextEditingController();
  final _farmName = TextEditingController();
  final _farmAddress = TextEditingController();
  final _farmCity = TextEditingController();
  PakistanProvince? _farmProvince;
  GeoPoint? _farmPin;
  final _cropTypes = TextEditingController();
  final _landSize = TextEditingController();
  String? _error;

  @override
  void dispose() {
    for (final c in [
      _email,
      _password,
      _cnic,
      _phone,
      _farmName,
      _farmAddress,
      _farmCity,
      _cropTypes,
      _landSize,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit(OnboardingSession session) {
    return submitOnboarding(
      ref,
      context,
      _formKey,
      () => FarmerOnboardingRequest(
        credential: buildOnboardingCredential(
          session,
          email: _email.text,
          password: _password.text,
        ),
        cnic: _cnic.text.trim(),
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        farmName: _farmName.text.trim(),
        farmAddress: _farmAddress.text.trim(),
        farmCity: _farmCity.text.trim(),
        // Validated as required by the form before this builder runs.
        farmProvince: _farmProvince!.wire,
        farmPin: _farmPin!,
        cropTypes: splitCommaList(_cropTypes.text),
        landSizeAcres: double.tryParse(_landSize.text.trim()),
      ),
      (msg) => setState(() => _error = msg),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(onboardingSessionProvider);
    if (session == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/auth/login');
      });
      return const Scaffold(body: SizedBox.shrink());
    }
    final submitting = ref.watch(authControllerProvider).isLoading;

    return OnboardingScaffold(
      roleTitle: context.l10n.roleFarmer,
      session: session,
      formKey: _formKey,
      emailController: _email,
      passwordController: _password,
      cnicController: _cnic,
      phoneController: _phone,
      errorMessage: _error,
      submitting: submitting,
      onSubmit: () => _submit(session),
      roleFields: [
        AuthTextField(
          controller: _farmName,
          label: context.l10n.farmName,
          validator: (v) => validateRequiredField(context, v),
        ),
        const SizedBox(height: AppSpacing.md),
        // Pickup location: required so transporters can collect orders.
        AuthTextField(
          controller: _farmAddress,
          label: context.l10n.farmStreet,
          hintText: context.l10n.farmStreetHint,
          validator: (v) => validateRequiredField(context, v),
        ),
        const SizedBox(height: AppSpacing.md),
        AuthTextField(
          controller: _farmCity,
          label: context.l10n.farmCity,
          validator: (v) => validateRequiredField(context, v),
        ),
        const SizedBox(height: AppSpacing.md),
        ProvinceDropdown(
          value: _farmProvince,
          onChanged: (value) => setState(() => _farmProvince = value),
        ),
        const SizedBox(height: AppSpacing.md),
        LocationPinField(
          purpose: LocationPickerPurpose.farm,
          initialValue: _farmPin,
          onChanged: (pin) => setState(() => _farmPin = pin),
        ),
        const SizedBox(height: AppSpacing.md),
        AuthTextField(
          controller: _cropTypes,
          label: context.l10n.cropTypes,
          hintText: context.l10n.cropTypesHint,
        ),
        const SizedBox(height: AppSpacing.md),
        AuthTextField(
          controller: _landSize,
          label: context.l10n.farmSize,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ],
    );
  }
}
