import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';

/// The one text-field style for the whole app -- forms should reach for
/// this instead of a raw [TextFormField] so radius, borders, and spacing
/// stay identical everywhere (auth, checkout, listings, contact, etc.).
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.alignLabelWithHint = false,
    this.validator,
    this.suffixIcon,
    this.prefixIcon,
    this.textInputAction,
    this.autofillHints,
    this.onChanged,
    this.onFieldSubmitted,
    this.focusNode,
    this.inputFormatters,
    this.autovalidateMode,
    this.errorText,
    this.helperText,
    this.textCapitalization = TextCapitalization.none,
    this.textDirection,
    this.autocorrect = true,
    this.readOnly = false,
  });

  final TextEditingController controller;
  final String label;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final int maxLines;
  final bool alignLabelWithHint;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode? autovalidateMode;

  /// A server-side or cross-field error shown under the field; takes priority
  /// over [validator] messages while set.
  final String? errorText;
  final String? helperText;
  final TextCapitalization textCapitalization;

  /// Force LTR for technical values (email, phone, CNIC) inside RTL screens.
  final TextDirection? textDirection;
  final bool autocorrect;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      maxLines: obscureText ? 1 : maxLines,
      validator: validator,
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
      enableSuggestions: autocorrect,
      readOnly: readOnly,
      forceErrorText: errorText,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        helperMaxLines: 3,
        errorMaxLines: 3,
        helperStyle: AppTextStyles.small.copyWith(color: AppColors.textMuted),
        labelStyle: AppTextStyles.small.copyWith(color: AppColors.textMuted),
        hintText: hintText,
        hintStyle: AppTextStyles.small.copyWith(color: AppColors.textMuted),
        alignLabelWithHint: alignLabelWithHint,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
        ),
      ),
    );
  }
}
