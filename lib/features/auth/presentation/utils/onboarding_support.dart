import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/features/auth/data/models/onboarding_request.dart';
import 'package:farm2fork_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:farm2fork_mobile/features/auth/data/services/firebase_auth_gateway.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/onboarding_session.dart';
import 'package:farm2fork_mobile/core/utils/pakistan_identity.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/onboarding_draft.dart';

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
  return _cnicRegExp.hasMatch(text) ? null : context.l10n.validationCnicInvalid;
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

String? validateFullNameField(BuildContext context, String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return context.l10n.validationRequired;
  return text.length < 2 || text.length > 80
      ? context.l10n.validationNameShort
      : null;
}

/// Phone is optional; when present it must normalise to an E.164 number.
String? validatePhoneField(BuildContext context, String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return null;
  return normalizePhone(text) == null
      ? context.l10n.validationPhoneInvalid
      : null;
}

/// Farm size is optional; when present it must be a number from 0 to 100000.
String? validateAcresField(BuildContext context, String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return null;
  final acres = double.tryParse(text);
  return acres == null || !acres.isFinite || acres < 0 || acres > 100000
      ? context.l10n.validationAcres
      : null;
}

String? validateVehicleNumberField(BuildContext context, String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return context.l10n.validationRequired;
  return text.length < 3 || text.length > 20
      ? context.l10n.validationVehicleNumber
      : null;
}

String? validateCoordinateField(
  BuildContext context,
  String? value,
  double min,
  double max,
) {
  final n = double.tryParse(value?.trim() ?? '');
  return n == null || !n.isFinite || n < min || n > max
      ? context.l10n.locationInvalid
      : null;
}

/// Pakistan's bounding box as accepted by the backend for a farm pin.
const pakistanLatRange = (23.5, 37.2);
const pakistanLngRange = (60.5, 77.9);

/// Provinces and territories the backend accepts (sent in English).
const pakistanProvinces = [
  'Punjab',
  'Sindh',
  'Khyber Pakhtunkhwa',
  'Balochistan',
  'Gilgit-Baltistan',
  'Azad Jammu and Kashmir',
  'Islamabad Capital Territory',
];

String provinceLabel(BuildContext context, String value) {
  final l10n = context.l10n;
  return switch (value) {
    'Punjab' => l10n.provincePunjab,
    'Sindh' => l10n.provinceSindh,
    'Khyber Pakhtunkhwa' => l10n.provinceKhyberPakhtunkhwa,
    'Balochistan' => l10n.provinceBalochistan,
    'Gilgit-Baltistan' => l10n.provinceGilgitBaltistan,
    'Azad Jammu and Kashmir' => l10n.provinceAzadKashmir,
    'Islamabad Capital Territory' => l10n.provinceIslamabad,
    _ => value,
  };
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
      AuthGatewayError.tooManyRequests => context.l10n.authErrorTooManyRequests,
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
      ApiErrorKind.network ||
      ApiErrorKind.timeout => context.l10n.authErrorNetwork,
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
  void Function(String?) setError, {
  void Function(Object error)? onFailure,
}) async {
  if (!formKey.currentState!.validate()) return;
  setError(null);

  final request = buildRequest();

  await ref.read(authControllerProvider.notifier).completeOnboarding(request);

  if (!context.mounted) return;
  final state = ref.read(authControllerProvider);
  if (state.hasError) {
    final error = state.error;
    if (error is ApiException && error.code == 'EMAIL_VERIFICATION_REQUIRED') {
      ref.read(onboardingSessionProvider.notifier).setPendingRequest(request);
      context.go('/auth/verify');
      return;
    }
    onFailure?.call(state.error!);
    setError(onboardingErrorMessage(context, state.error!));
  } else {
    ref.read(onboardingSessionProvider.notifier).clear();
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

/// Turns the stepped form's [draft] into the request the backend expects.
/// Individual buyers have no business, so their name stands in for the
/// business name the API still requires.
OnboardingRequest buildOnboardingRequest(
  OnboardingSession session,
  OnboardingDraft draft,
) {
  String v(OnboardingField f) => draft.value(f).trim();
  final credential = buildOnboardingCredential(
    session,
    email: v(OnboardingField.email),
    password: draft.value(OnboardingField.password),
  );
  final cnic = formatCnic(v(OnboardingField.cnic));
  final phoneText = v(OnboardingField.phone);
  final phone = phoneText.isEmpty ? null : normalizePhone(phoneText);
  final fullName = v(OnboardingField.fullName);

  return switch (draft.role) {
    OnboardingRole.farmer => FarmerOnboardingRequest(
      credential: credential,
      cnic: cnic,
      phone: phone,
      fullName: fullName,
      farmName: v(OnboardingField.farmName),
      farmLocation: FarmLocationInput(
        address: v(OnboardingField.address),
        city: v(OnboardingField.city),
        province: v(OnboardingField.province),
        lat: double.parse(v(OnboardingField.lat)),
        lng: double.parse(v(OnboardingField.lng)),
      ),
      cropTypes: splitCommaList(v(OnboardingField.cropTypes)),
      landSizeAcres: double.tryParse(v(OnboardingField.landSize)),
    ),
    OnboardingRole.transporter => TransporterOnboardingRequest(
      credential: credential,
      cnic: cnic,
      phone: phone,
      fullName: fullName,
      vehicleType: v(OnboardingField.vehicleType),
      vehicleNumber: v(OnboardingField.vehicleNumber),
      licenseNumber: v(OnboardingField.licenseNumber),
      serviceAreas: splitCommaList(v(OnboardingField.serviceAreas)),
    ),
    _ => () {
      final type = v(OnboardingField.businessType).isEmpty
          ? 'individual'
          : v(OnboardingField.businessType);
      return BuyerOnboardingRequest(
        credential: credential,
        cnic: cnic,
        phone: phone,
        fullName: fullName,
        businessName: type == 'individual'
            ? fullName
            : v(OnboardingField.businessName),
        businessType: type,
      );
    }(),
  };
}
