import 'package:flutter/material.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';

/// Shared text field for all auth screens.
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.small.copyWith(color: AppColors.textMuted),
        suffixIcon: suffixIcon,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
        ),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),
    );
  }
}

/// Inline error banner for auth forms.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.errorRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.3)),
      ),
      child: Text(
        message,
        style: AppTextStyles.small.copyWith(color: AppColors.errorRed),
      ),
    );
  }
}

/// Step indicator for multi-step signup forms.
class AuthStepIndicator extends StatelessWidget {
  const AuthStepIndicator({
    super.key,
    required this.label,
    required this.progress,
  });
  final String label;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundLight,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.small.copyWith(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceMedium,
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
        ],
      ),
    );
  }
}
