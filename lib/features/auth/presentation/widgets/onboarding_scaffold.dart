import 'package:flutter/material.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/core/widgets/section_header.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/onboarding_session.dart';
import 'package:farm2fork_mobile/features/auth/presentation/utils/onboarding_support.dart';
import 'package:farm2fork_mobile/features/auth/presentation/widgets/auth_form_widgets.dart';

/// Common chrome for the per-role KYC screens: header, credential/email block,
/// role-specific fields, CNIC + phone, error banner, and submit button.
class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    super.key,
    required this.roleTitle,
    required this.session,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.cnicController,
    required this.phoneController,
    required this.roleFields,
    required this.errorMessage,
    required this.submitting,
    required this.onSubmit,
  });

  final String roleTitle;
  final OnboardingSession session;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController cnicController;
  final TextEditingController phoneController;
  final List<Widget> roleFields;
  final String? errorMessage;
  final bool submitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: Text(roleTitle, style: AppTextStyles.h3)),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            children: [
              SectionHeader(
                title: context.l10n.onboardingCompleteProfile,
                subtitle: context.l10n.onboardingProfileSubtitle,
              ),
              const SizedBox(height: AppSpacing.md),
              if (session.isEmailPassword)
                OnboardingAccountFields(
                  emailController: emailController,
                  passwordController: passwordController,
                )
              else if ((session.email ?? '').isNotEmpty) ...[
                _OnboardingEmailChip(email: session.email!),
                const SizedBox(height: AppSpacing.md),
              ],
              ...roleFields,
              const SizedBox(height: AppSpacing.md),
              AuthTextField(
                controller: cnicController,
                label: context.l10n.fieldCnic,
                keyboardType: TextInputType.number,
                validator: (v) => validateCnicField(context, v),
              ),
              const SizedBox(height: AppSpacing.md),
              AuthTextField(
                controller: phoneController,
                label: context.l10n.signUpPhone,
                keyboardType: TextInputType.phone,
              ),
              if (errorMessage != null && errorMessage!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                AuthErrorBanner(message: errorMessage!),
              ],
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: context.l10n.createAccount,
                expand: true,
                onPressed: submitting ? null : onSubmit,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dropdown styled to match [AuthTextField] for consistent onboarding forms.
class AuthDropdown extends StatelessWidget {
  const AuthDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  final String label;
  final String hint;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: AppTextStyles.small.copyWith(color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.surfaceMedium),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.surfaceMedium),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(
            color: AppColors.primaryGreen,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _OnboardingEmailChip extends StatelessWidget {
  const _OnboardingEmailChip({required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryGreenSoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified_user_rounded,
            size: 18,
            color: AppColors.primaryGreenDark,
          ),
          const SizedBox(width: AppSpacing.sm),
          // Email is a technical value: keep it LTR even in an RTL layout.
          Expanded(
            child: Text(
              email,
              textDirection: TextDirection.ltr,
              style: AppTextStyles.small.copyWith(
                color: AppColors.primaryGreenDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
