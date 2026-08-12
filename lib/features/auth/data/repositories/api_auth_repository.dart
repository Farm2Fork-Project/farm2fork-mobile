import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/core/storage/token_storage.dart';
import 'package:farm2fork_mobile/features/auth/data/models/auth_user.dart';
import 'package:farm2fork_mobile/features/auth/data/models/onboarding_request.dart';
import 'package:farm2fork_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:farm2fork_mobile/features/auth/data/services/auth_api_service.dart';
import 'package:farm2fork_mobile/features/auth/data/services/firebase_auth_gateway.dart';

/// Real [AuthRepository]: Firebase authenticates, the backend authorizes.
///
/// Flow: obtain a Firebase ID token (Google or email/password) → exchange it at
/// `POST /auth/firebase` for a Farm2Fork JWT. A 409 means the identity has no
/// account yet, so the caller routes into onboarding, which posts role + KYC to
/// `POST /auth/firebase/onboard/{role}`.
class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._gateway, this._api, this._tokenStorage);

  final FirebaseAuthGateway _gateway;
  final AuthApiService _api;
  final TokenStorage _tokenStorage;

  @override
  Future<AuthUser?> restoreSession() async {
    final token = await _tokenStorage.readAccessToken();
    if (token == null || token.isEmpty) return null;
    try {
      final body = await _api.me();
      return _userFromJson(body);
    } on ApiException catch (e) {
      if (e.kind == ApiErrorKind.unauthorized) {
        await _tokenStorage.clear();
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<FirebaseSignInOutcome> signInWithGoogle() async {
    final idToken = await _gateway.signInWithGoogle();
    return _exchange(
      idToken,
      fallbackEmail: _gateway.currentEmail,
      displayName: _gateway.currentDisplayName,
    );
  }

  @override
  Future<FirebaseSignInOutcome> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final idToken = await _gateway.signInWithEmailPassword(
      email: email,
      password: password,
    );
    return _exchange(idToken, fallbackEmail: email);
  }

  @override
  Future<AuthUser> completeOnboarding(OnboardingRequest request) async {
    final idToken = await _idTokenForOnboarding(request.credential);
    final body = <String, dynamic>{
      'idToken': idToken,
      if (request.phone != null && request.phone!.isNotEmpty)
        'phone': request.phone,
      ...request.toProfileJson(),
    };
    final response = await _api.onboard(request.role.backendPath, body);
    return _persistSession(response);
  }

  @override
  Future<void> signOut() async {
    await _tokenStorage.clear();
    await _gateway.signOut();
  }

  // A new Google identity is already Firebase-signed-in, so reuse its token.
  // A new email/password identity is created here as part of onboarding.
  Future<String> _idTokenForOnboarding(OnboardingCredential credential) async {
    switch (credential) {
      case EmailPasswordOnboardingCredential(:final email, :final password):
        return _gateway.registerWithEmailPassword(
          email: email,
          password: password,
        );
      case GoogleOnboardingCredential():
        final token = await _gateway.currentIdToken();
        if (token == null) {
          throw const ApiException(ApiErrorKind.unauthorized);
        }
        return token;
    }
  }

  Future<FirebaseSignInOutcome> _exchange(
    String idToken, {
    String? fallbackEmail,
    String? displayName,
  }) async {
    try {
      final response = await _api.signInWithFirebase(idToken);
      return FirebaseSignedIn(await _persistSession(response));
    } on ApiException catch (e) {
      // /auth/firebase returns 409 only for ONBOARDING_REQUIRED.
      if (e.statusCode == 409) {
        return FirebaseOnboardingRequired(
          email: fallbackEmail ?? '',
          displayName: displayName,
        );
      }
      rethrow;
    }
  }

  Future<AuthUser> _persistSession(Map<String, dynamic> body) async {
    final token = body['accessToken'] as String?;
    if (token == null || token.isEmpty) {
      throw const ApiException(ApiErrorKind.unknown);
    }
    await _tokenStorage.writeAccessToken(token);
    final user = body['user'];
    if (user is! Map<String, dynamic>) {
      throw const ApiException(ApiErrorKind.unknown);
    }
    return _userFromJson(user);
  }

  AuthUser _userFromJson(Map<String, dynamic> json) => AuthUser(
    id: (json['id'] as String?) ?? (json['_id'] as String?) ?? '',
    email: (json['email'] as String?) ?? '',
    role: AuthUser.roleFromBackend(json['role'] as String),
    isVerified: (json['isVerified'] as bool?) ?? false,
    isActive: (json['isActive'] as bool?) ?? true,
  );

  // --- Legacy mock-era API (retired with the old screens in the next slice). ---

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    final outcome = await signInWithEmail(email: email, password: password);
    return switch (outcome) {
      FirebaseSignedIn(:final user) => user,
      FirebaseOnboardingRequired() => throw const ApiException(
        ApiErrorKind.unauthorized,
      ),
    };
  }

  @override
  Future<AuthUser> signUp({required SignUpRequest request}) {
    throw UnimplementedError(
      'Legacy signUp is replaced by completeOnboarding for the Firebase flow',
    );
  }
}
