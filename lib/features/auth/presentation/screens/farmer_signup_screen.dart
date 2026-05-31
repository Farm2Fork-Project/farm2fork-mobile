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

const _availableCrops = [
  'Wheat', 'Rice', 'Cotton', 'Sugarcane', 'Maize',
  'Tomatoes', 'Onions', 'Potatoes', 'Mangoes', 'Citrus',
];

class FarmerSignupScreen extends ConsumerStatefulWidget {
  const FarmerSignupScreen({super.key});

  @override
  ConsumerState<FarmerSignupScreen> createState() =>
      _FarmerSignupScreenState();
}

class _FarmerSignupScreenState extends ConsumerState<FarmerSignupScreen> {
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  int _currentStep = 0;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;

  final _farmNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _farmSizeController = TextEditingController();
  final _certController = TextEditingController();
  final Set<String> _selectedCrops = {};

  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _farmNameController.dispose();
    _locationController.dispose();
    _farmSizeController.dispose();
    _certController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_step2Key.currentState!.validate()) return;
    if (_selectedCrops.isEmpty) {
      setState(() => _errorMessage = context.l10n.cropTypes);
      return;
    }
    setState(() => _errorMessage = null);

    await ref.read(authControllerProvider.notifier).signUp(
          request: FarmerSignUpRequest(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            farmName: _farmNameController.text.trim(),
            location: _locationController.text.trim(),
            farmSize: _farmSizeController.text.trim(),
            cropTypes: _selectedCrops.toList(),
            certifications: _certController.text.trim().isEmpty
                ? []
                : _certController.text
                    .split(',')
                    .map((e) => e.trim())
                    .toList(),
          ),
        );

    if (!mounted) return;
    if (ref.read(authControllerProvider).hasError) {
      setState(() => _errorMessage = context.l10n.invalidCredentials);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.signUpSuccess)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(context.l10n.roleFarmer, style: AppTextStyles.h3),
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
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? context.l10n.signUpName : null,
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
          SectionHeader(title: context.l10n.farmInfo),
          const SizedBox(height: AppSpacing.md),
          if (_errorMessage != null) ...[
            AuthErrorBanner(message: _errorMessage!),
            const SizedBox(height: AppSpacing.md),
          ],
          AuthTextField(
            controller: _farmNameController,
            label: context.l10n.farmName,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? context.l10n.farmName : null,
          ),
          const SizedBox(height: AppSpacing.md),
          AuthTextField(
            controller: _locationController,
            label: context.l10n.farmLocation,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? context.l10n.farmLocation
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          AuthTextField(
            controller: _farmSizeController,
            label: context.l10n.farmSize,
            keyboardType: TextInputType.number,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? context.l10n.farmSize : null,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.cropTypes,
            style: AppTextStyles.small.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final crop in _availableCrops)
                FilterChip(
                  label: Text(crop),
                  selected: _selectedCrops.contains(crop),
                  onSelected: (_) => setState(() {
                    _selectedCrops.contains(crop)
                        ? _selectedCrops.remove(crop)
                        : _selectedCrops.add(crop);
                  }),
                  selectedColor: AppColors.primaryGreenSoft,
                  checkmarkColor: AppColors.primaryGreenDark,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AuthTextField(
            controller: _certController,
            label: context.l10n.certifications,
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
