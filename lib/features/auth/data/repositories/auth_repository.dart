import 'package:farm2fork_mobile/features/auth/data/models/auth_user.dart';
import 'package:farm2fork_mobile/features/auth/data/models/onboarding_request.dart';

/// Result of exchanging a verified Firebase identity with the backend.
sealed class FirebaseSignInOutcome {
  const FirebaseSignInOutcome();
}

/// The identity is linked to a Farm2Fork account and is now signed in.
class FirebaseSignedIn extends FirebaseSignInOutcome {
  const FirebaseSignedIn(this.user);
  final AuthUser user;
}

/// Authenticated with Firebase, but no Farm2Fork account exists yet — the user
/// must complete onboarding (choose a role and provide profile/KYC).
class FirebaseOnboardingRequired extends FirebaseSignInOutcome {
  const FirebaseOnboardingRequired({required this.email, this.displayName});
  final String email;
  final String? displayName;
}

sealed class SignUpRequest {
  const SignUpRequest({
    required this.name,
    required this.email,
    required this.password,
  });
  final String name;
  final String email;
  final String password;
}

class BuyerSignUpRequest extends SignUpRequest {
  const BuyerSignUpRequest({
    required super.name,
    required super.email,
    required super.password,
    this.phone,
  });
  final String? phone;
}

class FarmerSignUpRequest extends SignUpRequest {
  const FarmerSignUpRequest({
    required super.name,
    required super.email,
    required super.password,
    required this.farmName,
    required this.location,
    required this.farmSize,
    required this.cropTypes,
    this.certifications = const [],
  });
  final String farmName;
  final String location;
  final String farmSize;
  final List<String> cropTypes;
  final List<String> certifications;
}

class TransporterSignUpRequest extends SignUpRequest {
  const TransporterSignUpRequest({
    required super.name,
    required super.email,
    required super.password,
    required this.vehicleType,
    required this.vehicleLicense,
    required this.serviceArea,
    this.cnic,
    this.availabilityStatus = 'available',
  });
  final String vehicleType;
  final String vehicleLicense;
  final String serviceArea;
  final String? cnic;
  final String availabilityStatus;
}

abstract class AuthRepository {
  /// Restore a persisted backend session (validates the stored JWT via /auth/me).
  Future<AuthUser?> restoreSession();

  /// Google sign-in → backend session, or onboarding-required for a new identity.
  Future<FirebaseSignInOutcome> signInWithGoogle();

  /// Email/password sign-in → backend session, or onboarding-required.
  Future<FirebaseSignInOutcome> signInWithEmail({
    required String email,
    required String password,
  });

  /// Complete first-time onboarding for the current Firebase identity.
  Future<AuthUser> completeOnboarding(OnboardingRequest request);

  Future<void> signOut();

  // --- Legacy mock-era API (retired once the Firebase UI lands). ---
  @Deprecated('Use signInWithEmail / signInWithGoogle')
  Future<AuthUser> signIn({required String email, required String password});
  @Deprecated('Use completeOnboarding')
  Future<AuthUser> signUp({required SignUpRequest request});
}
