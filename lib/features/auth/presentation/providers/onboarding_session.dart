import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How the pending onboarding will obtain its Firebase identity.
enum OnboardingMethod {
  /// A Firebase session already exists (Google, or an email/password user whose
  /// backend account is missing). Onboarding reuses that session's token.
  google,

  /// A brand-new email/password account is created during onboarding.
  emailPassword,
}

/// The in-flight onboarding started from the login screen and carried across
/// the role-picker and KYC screens.
class OnboardingSession {
  const OnboardingSession({required this.method, this.email, this.displayName});

  final OnboardingMethod method;

  /// Known email for the Google path (shown read-only); null for a new
  /// email/password sign-up, where it is entered on the KYC form.
  final String? email;
  final String? displayName;

  bool get isEmailPassword => method == OnboardingMethod.emailPassword;
}

/// Holds the in-flight onboarding (null unless a flow is in progress).
class OnboardingSessionController extends Notifier<OnboardingSession?> {
  @override
  OnboardingSession? build() => null;

  void start(OnboardingSession session) => state = session;

  void clear() => state = null;
}

final onboardingSessionProvider =
    NotifierProvider<OnboardingSessionController, OnboardingSession?>(
      OnboardingSessionController.new,
    );
