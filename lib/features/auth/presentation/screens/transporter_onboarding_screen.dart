import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/features/auth/data/models/onboarding_request.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/onboarding_session.dart';
import 'package:farm2fork_mobile/features/auth/presentation/utils/onboarding_support.dart';
import 'package:farm2fork_mobile/features/auth/presentation/widgets/auth_form_widgets.dart';
import 'package:farm2fork_mobile/features/auth/presentation/widgets/onboarding_scaffold.dart';

/// Backend vehicleType enum values (labels are localized).
const _vehicleTypes = ['bike', 'rickshaw', 'van', 'truck'];

class TransporterOnboardingScreen extends ConsumerStatefulWidget {
  const TransporterOnboardingScreen({super.key});

  @override
  ConsumerState<TransporterOnboardingScreen> createState() =>
      _TransporterOnboardingScreenState();
}

class _TransporterOnboardingScreenState
    extends ConsumerState<TransporterOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _cnic = TextEditingController();
  final _phone = TextEditingController();
  final _vehicleNumber = TextEditingController();
  final _licenseNumber = TextEditingController();
  final _serviceAreas = TextEditingController();
  String? _vehicleType;
  String? _error;

  @override
  void dispose() {
    for (final c in [
      _email,
      _password,
      _cnic,
      _phone,
      _vehicleNumber,
      _licenseNumber,
      _serviceAreas,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String _vehicleTypeLabel(BuildContext context, String value) {
    return switch (value) {
      'rickshaw' => context.l10n.vehicleTypeRickshaw,
      'van' => context.l10n.vehicleTypeVan,
      'truck' => context.l10n.vehicleTypeTruck,
      _ => context.l10n.vehicleTypeBike,
    };
  }

  Future<void> _submit(OnboardingSession session) {
    return submitOnboarding(
      ref,
      context,
      _formKey,
      () => TransporterOnboardingRequest(
        credential: buildOnboardingCredential(
          session,
          email: _email.text,
          password: _password.text,
        ),
        cnic: _cnic.text.trim(),
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        vehicleType: _vehicleType ?? 'bike',
        vehicleNumber: _vehicleNumber.text.trim(),
        licenseNumber: _licenseNumber.text.trim(),
        serviceAreas: splitCommaList(_serviceAreas.text),
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
      roleTitle: context.l10n.roleTransporter,
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
        AuthDropdown(
          label: context.l10n.vehicleType,
          hint: context.l10n.selectVehicleType,
          value: _vehicleType,
          items: [
            for (final t in _vehicleTypes)
              DropdownMenuItem(
                value: t,
                child: Text(_vehicleTypeLabel(context, t)),
              ),
          ],
          onChanged: (v) => setState(() => _vehicleType = v),
          validator: (v) => validateRequiredField(context, v),
        ),
        const SizedBox(height: AppSpacing.md),
        AuthTextField(
          controller: _vehicleNumber,
          label: context.l10n.vehicleNumber,
          validator: (v) => validateRequiredField(context, v),
        ),
        const SizedBox(height: AppSpacing.md),
        AuthTextField(
          controller: _licenseNumber,
          label: context.l10n.vehicleLicense,
          validator: (v) => validateRequiredField(context, v),
        ),
        const SizedBox(height: AppSpacing.md),
        AuthTextField(
          controller: _serviceAreas,
          label: context.l10n.serviceArea,
          hintText: context.l10n.serviceAreasHint,
        ),
      ],
    );
  }
}
