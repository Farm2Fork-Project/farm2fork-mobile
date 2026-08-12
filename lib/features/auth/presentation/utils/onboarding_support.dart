import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/features/auth/data/models/onboarding_request.dart';
import 'package:farm2fork_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:farm2fork_mobile/features/auth/data/services/firebase_auth_gateway.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/onboarding_session.dart';
import 'package:farm2fork_mobile/features/auth/presentation/widgets/auth_form_widgets.dart';

final _cnicRegExp = RegExp(r'^\d{5}-?\d{7}-?\d$');
final _emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validateRequiredField(BuildContext context, String? value) {
  return (value == null || value.trim().isEmpty)
      ? context.l10n.validationRequired
      : null;
}

String? validateCnicField(BuildContext context, String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return context.l10n.validationRequired;
  return _cnicRegExp.hasMatch(text)
      ? null
      : context.l10n.validationCnicInvalid;
}

String? validateEmailField(BuildContext context, String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return context.l10n.validationRequired;
  return _emailRegExp.hasMatch(text)
      ? null
      : context.l10n.validationEmailInvalid;
}

String? validatePasswordField(BuildContext context, String? value) {
  final text = value ?? '';
  if (text.isEmpty) return context.l10n.validationRequired;
  return text.length < 8 ? context.l10n.validationPasswordShort : null;
}

/// Maps auth/network failures to a localized, user-facing message. Returns an
/// empty string for a user-cancelled sign-in (the caller shows nothing).
String onboardingErrorMessage(BuildContext context, Object error) {
  if (error is AuthGatewayException) {
    return switch (error.error) {
      AuthGatewayError.cancelled => '',
      AuthGatewayError.invalidCredentials => context.l10n.invalidCredentials,
      AuthGatewayError.emailAlreadyInUse => context.l10n.authErrorEmailInUse,
      AuthGatewayError.weakPassword => context.l10n.authErrorWeakPassword,
      AuthGatewayError.network => context.l10n.authErrorNetwork,
      AuthGatewayError.tooManyRequests =>
        context.l10n.authErrorTooManyRequests,
      AuthGatewayError.userDisabled => context.l10n.authErrorGeneric,
      AuthGatewayError.unknown => context.l10n.authErrorGeneric,
    };
  }
  if (error is ApiException) {
    // Backend conflicts (e.g. duplicate CNIC) and validation carry a useful
    // server message; other kinds map to a localized category.
    if (error.statusCode == 409 || error.kind == ApiErrorKind.validation) {
      return error.serverMessage ?? context.l10n.authErrorGeneric;
    }
    return switch (error.kind) {
      ApiErrorKind.network || ApiErrorKind.timeout =>
        context.l10n.authErrorNetwork,
      ApiErrorKind.unauthorized => context.l10n.invalidCredentials,
      _ => context.l10n.authErrorGeneric,
    };
  }
  return context.l10n.authErrorGeneric;
}

/// Builds the credential for the current onboarding method.
OnboardingCredential buildOnboardingCredential(
  OnboardingSession session, {
  required String email,
  required String password,
}) {
  return switch (session.method) {
    OnboardingMethod.google => const GoogleOnboardingCredential(),
    OnboardingMethod.emailPassword => EmailPasswordOnboardingCredential(
      email: email.trim(),
      password: password,
    ),
  };
}

/// Runs onboarding and reports a localized error via [setError] on failure.
/// On success it clears the onboarding session; the router redirect then routes
/// the now-authenticated user to their role home.
Future<void> submitOnboarding(
  WidgetRef ref,
  BuildContext context,
  GlobalKey<FormState> formKey,
  OnboardingRequest Function() buildRequest,
  void Function(String?) setError,
) async {
  if (!formKey.currentState!.validate()) return;
  setError(null);

  await ref
      .read(authControllerProvider.notifier)
      .completeOnboarding(buildRequest());

  if (!context.mounted) return;
  final state = ref.read(authControllerProvider);
  if (state.hasError) {
    setError(onboardingErrorMessage(context, state.error!));
  } else {
    ref.read(onboardingSessionProvider.notifier).clear();
  }
}

/// Email + password fields shown only for the new-account (email/password) path.
class OnboardingAccountFields extends StatefulWidget {
  const OnboardingAccountFields({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  State<OnboardingAccountFields> createState() =>
      _OnboardingAccountFieldsState();
}

class _OnboardingAccountFieldsState extends State<OnboardingAccountFields> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AuthTextField(
          controller: widget.emailController,
          label: context.l10n.email,
          keyboardType: TextInputType.emailAddress,
          validator: (v) => validateEmailField(context, v),
        ),
        const SizedBox(height: AppSpacing.md),
        AuthTextField(
          controller: widget.passwordController,
          label: context.l10n.password,
          obscureText: _obscure,
          validator: (v) => validatePasswordField(context, v),
          suffixIcon: IconButton(
            icon: Icon(
              _obscure
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: AppColors.textMuted,
            ),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

/// Helper to split a comma-separated field into a trimmed, non-empty list.
List<String> splitCommaList(String value) {
  return value
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList(growable: false);
}

/// Re-exported for screens that only need the outcome type.
typedef OnboardingOutcome = FirebaseSignInOutcome;
