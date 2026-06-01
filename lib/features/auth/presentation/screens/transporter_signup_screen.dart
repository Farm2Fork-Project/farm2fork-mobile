import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/core/widgets/section_header.dart';
import 'package:farm2fork_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/auth/presentation/widgets/auth_form_widgets.dart';

const _vehicleTypes = [
  'Pickup',
  'Mini Truck',
  'Truck',
  'Reefer Truck',
  'Van',
  'Motorcycle',
];
const _availabilityOptions = ['available', 'busy', 'offline'];

class TransporterSignupScreen extends ConsumerStatefulWidget {
  const TransporterSignupScreen({super.key});

  @override
  ConsumerState<TransporterSignupScreen> createState() =>
      _TransporterSignupScreenState();
}

class _TransporterSignupScreenState
    extends ConsumerState<TransporterSignupScreen> {
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  int _currentStep = 0;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;

  String? _selectedVehicleType;
  final _licenseController = TextEditingController();
  final _serviceAreaController = TextEditingController();
  final _cnicController = TextEditingController();
  String _availabilityStatus = 'available';

  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _licenseController.dispose();
    _serviceAreaController.dispose();
    _cnicController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_step2Key.currentState!.validate()) return;
    setState(() => _errorMessage = null);

    await ref
        .read(authControllerProvider.notifier)
        .signUp(
          request: TransporterSignUpRequest(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            vehicleType: _selectedVehicleType!,
            vehicleLicense: _licenseController.text.trim(),
            serviceArea: _serviceAreaController.text.trim(),
            cnic: _cnicController.text.trim().isEmpty
                ? null
                : _cnicController.text.trim(),
            availabilityStatus: _availabilityStatus,
          ),
        );

    if (!mounted) return;
    if (ref.read(authControllerProvider).hasError) {
      setState(() => _errorMessage = context.l10n.invalidCredentials);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.signUpSuccess)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(context.l10n.roleTransporter, style: AppTextStyles.h3),
      ),
      body: Column(
        children: [
          AuthStepIndicator(
            label: context.l10n.stepNofM(_currentStep + 1, 2),
            progress: (_currentStep + 1) / 2,
          ),
          Expanded(
            child: _currentStep == 0 ? _buildStep1() : _buildStep2(isLoading),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Form(
      key: _step1Key,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: [
          SectionHeader(title: context.l10n.personalInfo),
          const SizedBox(height: AppSpacing.md),
          AuthTextField(
            controller: _nameController,
            label: context.l10n.signUpName,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? context.l10n.signUpName
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          AuthTextField(
            controller: _emailController,
            label: context.l10n.emailOrPhone,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? context.l10n.emailOrPhone
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          AuthTextField(
            controller: _phoneController,
            label: context.l10n.signUpPhone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: AppSpacing.md),
          AuthTextField(
            controller: _passwordController,
            label: context.l10n.password,
            obscureText: _obscurePassword,
            validator: (v) =>
                (v == null || v.length < 6) ? context.l10n.password : null,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: AppColors.textMuted,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AuthTextField(
            controller: _confirmController,
            label: context.l10n.confirmPassword,
            obscureText: true,
            validator: (v) => v != _passwordController.text
                ? context.l10n.confirmPassword
                : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: context.l10n.next,
            expand: true,
            onPressed: () {
              if (_step1Key.currentState!.validate()) {
                setState(() => _currentStep = 1);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep2(bool isLoading) {
    return Form(
      key: _step2Key,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: [
          SectionHeader(title: context.l10n.vehicleInfo),
          const SizedBox(height: AppSpacing.md),
          if (_errorMessage != null) ...[
            AuthErrorBanner(message: _errorMessage!),
            const SizedBox(height: AppSpacing.md),
          ],
          DropdownButtonFormField<String>(
            initialValue: _selectedVehicleType,
            decoration: InputDecoration(
              labelText: context.l10n.vehicleType,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            items: [
              for (final t in _vehicleTypes)
                DropdownMenuItem(value: t, child: Text(t)),
            ],
            validator: (v) => v == null ? context.l10n.vehicleType : null,
            onChanged: (v) => setState(() => _selectedVehicleType = v),
          ),
          const SizedBox(height: AppSpacing.md),
          AuthTextField(
            controller: _licenseController,
            label: context.l10n.vehicleLicense,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? context.l10n.vehicleLicense
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          AuthTextField(
            controller: _serviceAreaController,
            label: context.l10n.serviceArea,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? context.l10n.serviceArea
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          AuthTextField(
            controller: _cnicController,
            label: context.l10n.cnic,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            initialValue: _availabilityStatus,
            decoration: InputDecoration(
              labelText: context.l10n.availabilityStatus,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            items: [
              for (final s in _availabilityOptions)
                DropdownMenuItem(value: s, child: Text(s)),
            ],
            onChanged: (v) =>
                setState(() => _availabilityStatus = v ?? 'available'),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: context.l10n.back,
                  variant: AppButtonVariant.quiet,
                  expand: true,
                  onPressed: () => setState(() => _currentStep = 0),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  label: context.l10n.createAccount,
                  expand: true,
                  onPressed: isLoading ? null : _submit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
