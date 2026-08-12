import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/features/auth/data/models/auth_user.dart';
import 'package:farm2fork_mobile/features/auth/data/models/onboarding_request.dart';
import 'package:farm2fork_mobile/features/auth/data/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  static const _password = 'test1234';

  static const _testAccounts = {
    'buyer@test.com': AppUserRole.buyer,
    'farmer@test.com': AppUserRole.farmer,
    'transporter@test.com': AppUserRole.transporter,
  };

  final Map<String, _StoredUser> _users = {
    for (final entry in _testAccounts.entries)
      entry.key: _StoredUser(
        id: 'mock_${AuthUser.roleToBackend(entry.value)}_001',
        email: entry.key,
        role: entry.value,
        password: _password,
      ),
  };

  AuthUser? _currentUser;

  @override
  Future<AuthUser?> restoreSession() async => _currentUser;

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    final stored = _users[email.toLowerCase()];
    if (stored == null || stored.password != password) {
      throw Exception('invalid_credentials');
    }
    final user = stored.toAuthUser();
    _currentUser = user;
    return user;
  }

  @override
  Future<AuthUser> signUp({required SignUpRequest request}) async {
    final role = switch (request) {
      BuyerSignUpRequest() => AppUserRole.buyer,
      FarmerSignUpRequest() => AppUserRole.farmer,
      TransporterSignUpRequest() => AppUserRole.transporter,
    };
    final id =
        'mock_${AuthUser.roleToBackend(role)}_${DateTime.now().millisecondsSinceEpoch}';
    final stored = _StoredUser(
      id: id,
      email: request.email.toLowerCase(),
      role: role,
      password: request.password,
    );
    _users[stored.email] = stored;
    final user = stored.toAuthUser();
    _currentUser = user;
    return user;
  }

  @override
  Future<FirebaseSignInOutcome> signInWithGoogle() async {
    // Deterministic mock: a returning buyer signs straight in.
    final user = _users['buyer@test.com']!.toAuthUser();
    _currentUser = user;
    return FirebaseSignedIn(user);
  }

  @override
  Future<FirebaseSignInOutcome> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final user = await signIn(email: email, password: password);
    return FirebaseSignedIn(user);
  }

  @override
  Future<AuthUser> completeOnboarding(OnboardingRequest request) async {
    final role = switch (request.role) {
      OnboardingRole.farmer => AppUserRole.farmer,
      OnboardingRole.buyer => AppUserRole.buyer,
      OnboardingRole.transporter => AppUserRole.transporter,
    };
    final id =
        'mock_${AuthUser.roleToBackend(role)}_${DateTime.now().millisecondsSinceEpoch}';
    final user = AuthUser(
      id: id,
      email: _emailForCredential(request.credential),
      role: role,
      isVerified: true,
      isActive: true,
    );
    _currentUser = user;
    return user;
  }

  String _emailForCredential(OnboardingCredential credential) {
    return switch (credential) {
      EmailPasswordOnboardingCredential(:final email) => email.toLowerCase(),
      GoogleOnboardingCredential() => 'google.user@test.com',
    };
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }
}

class _StoredUser {
  const _StoredUser({
    required this.id,
    required this.email,
    required this.role,
    required this.password,
  });
  final String id;
  final String email;
  final AppUserRole role;
  final String password;

  AuthUser toAuthUser() => AuthUser(
    id: id,
    email: email,
    role: role,
    isVerified: true,
    isActive: true,
  );
}
