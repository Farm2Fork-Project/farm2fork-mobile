import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/features/auth/data/models/onboarding_request.dart';

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
  const OnboardingSession({
    required this.method,
    this.email,
    this.displayName,
    this.pendingRequest,
  });

  final OnboardingMethod method;

  /// Known email for the Google path (shown read-only); null for a new
  /// email/password sign-up, where it is entered on the KYC form.
  final String? email;
  final String? displayName;
  final OnboardingRequest? pendingRequest;

  bool get isEmailPassword => method == OnboardingMethod.emailPassword;
}

/// Holds the in-flight onboarding (null unless a flow is in progress).
class OnboardingSessionController extends Notifier<OnboardingSession?> {
  @override
  OnboardingSession? build() => null;

  void start(OnboardingSession session) => state = session;

  void setPendingRequest(OnboardingRequest request) {
    final session = state;
    if (session == null) return;
    final email = switch (request.credential) {
      EmailPasswordOnboardingCredential(:final email) => email,
      GoogleOnboardingCredential() => session.email,
    };
    state = OnboardingSession(
      method: session.method,
      email: email,
      displayName: session.displayName,
      pendingRequest: request,
    );
  }

  void clear() => state = null;
}

final onboardingSessionProvider =
    NotifierProvider<OnboardingSessionController, OnboardingSession?>(
      OnboardingSessionController.new,
    );
