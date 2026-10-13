import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/utils/pakistan_identity.dart';
import 'package:farm2fork_mobile/core/widgets/app_notice_banner.dart';
import 'package:farm2fork_mobile/core/widgets/app_text_field.dart';

/// Shared text field for all auth screens. Thin alias over the app-wide
/// [AppTextField] so the many auth call sites didn't need to change.
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.suffixIcon,
    this.hintText,
    this.helperText,
    this.errorText,
    this.textInputAction,
    this.autofillHints,
    this.onChanged,
    this.onFieldSubmitted,
    this.focusNode,
    this.inputFormatters,
    this.autovalidateMode,
    this.textCapitalization = TextCapitalization.none,
    this.textDirection,
    this.autocorrect = true,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode? autovalidateMode;
  final TextCapitalization textCapitalization;
  final TextDirection? textDirection;
  final bool autocorrect;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      suffixIcon: suffixIcon,
      hintText: hintText,
      helperText: helperText,
      errorText: errorText,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      focusNode: focusNode,
      inputFormatters: inputFormatters,
      autovalidateMode: autovalidateMode,
      textCapitalization: textCapitalization,
      textDirection: textDirection,
      autocorrect: autocorrect,
    );
  }
}

/// Eye icon that shows or hides a password. 48dp, labelled for screen readers.
class PasswordVisibilityToggle extends StatelessWidget {
  const PasswordVisibilityToggle({
    super.key,
    required this.obscured,
    required this.onToggle,
  });

  final bool obscured;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final label = obscured
        ? context.l10n.showPassword
        : context.l10n.hidePassword;
    return IconButton(
      tooltip: label,
      icon: Icon(
        obscured ? Icons.visibility_off_rounded : Icons.visibility_rounded,
        color: AppColors.textMuted,
      ),
      onPressed: onToggle,
    );
  }
}

typedef AuthNoticeKind = AppNoticeKind;

/// Inline message for auth forms (see [AppNoticeBanner]).
class AuthNoticeBanner extends StatelessWidget {
  const AuthNoticeBanner({
    super.key,
    required this.message,
    this.kind = AuthNoticeKind.error,
  });

  final String message;
  final AuthNoticeKind kind;

  @override
  Widget build(BuildContext context) =>
      AppNoticeBanner(message: message, kind: kind);
}

/// Inline error banner for auth forms.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) =>
      AuthNoticeBanner(message: message, kind: AuthNoticeKind.error);
}

/// Segmented progress for the stepped sign-up: one segment per step, with the
/// label "Step 2 of 4" read out for screen readers.
class AuthStepIndicator extends StatelessWidget {
  const AuthStepIndicator({
    super.key,
    required this.current,
    required this.total,
  });

  /// 1-based.
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final label = context.l10n.onboardingStepLabel(current, total);
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                for (var i = 1; i <= total; i++) ...[
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      height: 4,
                      decoration: BoxDecoration(
                        color: i <= current
                            ? AppColors.primaryGreen
                            : AppColors.surfaceStrong,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  ),
                  if (i < total) const SizedBox(width: AppSpacing.xs),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            label,
            style: AppTextStyles.small.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// A few mutually exclusive options shown as tappable chips (48dp tall) rather
/// than a dropdown, so every choice is visible at once.
class AuthChoiceChips extends StatelessWidget {
  const AuthChoiceChips({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  final String label;

  /// value -> localized label.
  final Map<String, String> options;
  final String? value;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.small.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final entry in options.entries)
              ChoiceChip(
                label: Text(entry.value),
                selected: value == entry.key,
                onSelected: (_) => onChanged(entry.key),
                showCheckmark: true,
                materialTapTargetSize: MaterialTapTargetSize.padded,
                labelStyle: AppTextStyles.body.copyWith(
                  color: value == entry.key
                      ? AppColors.primaryGreenDark
                      : AppColors.textDark,
                  fontWeight: value == entry.key
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
                selectedColor: AppColors.primaryGreenSoft,
                backgroundColor: AppColors.white,
                side: BorderSide(
                  color: value == entry.key
                      ? AppColors.primaryGreen
                      : AppColors.surfaceMedium,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.md,
                ),
              ),
          ],
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            errorText!,
            style: AppTextStyles.small.copyWith(color: AppColors.errorRed),
          ),
        ],
      ],
    );
  }
}

/// Three-segment strength bar plus a text label, so strength is never conveyed
/// by colour alone.
class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final strength = passwordStrength(password);
    final level = strength.index + 1;
    final color = switch (strength) {
      PasswordStrength.weak => AppColors.errorRed,
      PasswordStrength.fair => AppColors.accentYellow,
      PasswordStrength.strong => AppColors.success,
    };
    final name = switch (strength) {
      PasswordStrength.weak => context.l10n.passwordStrengthWeak,
      PasswordStrength.fair => context.l10n.passwordStrengthFair,
      PasswordStrength.strong => context.l10n.passwordStrengthStrong,
    };
    return Semantics(
      label: context.l10n.passwordStrengthIs(name),
      excludeSemantics: true,
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                for (var i = 1; i <= 3; i++) ...[
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: i <= level ? color : AppColors.surfaceStrong,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  ),
                  if (i < 3) const SizedBox(width: AppSpacing.xs),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            name,
            style: AppTextStyles.small.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
