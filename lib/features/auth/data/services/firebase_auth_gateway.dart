import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Categories of Firebase auth failure, mapped to localizable UI messages.
enum AuthGatewayError {
  /// The user dismissed the Google sign-in sheet.
  cancelled,

  /// Wrong password, unknown user, or malformed email.
  invalidCredentials,

  /// Email already has a Firebase account.
  emailAlreadyInUse,

  /// Password does not meet Firebase strength rules.
  weakPassword,

  /// The Firebase account has been disabled.
  userDisabled,

  /// No connectivity while talking to Firebase.
  network,

  /// Too many attempts; Firebase is throttling.
  tooManyRequests,

  /// Anything else.
  unknown,
}

class AuthGatewayException implements Exception {
  const AuthGatewayException(this.error, {this.message});

  final AuthGatewayError error;
  final String? message;

  @override
  String toString() => 'AuthGatewayException($error, $message)';
}

/// Wraps Firebase Authentication + Google Sign-In. Every method returns a
/// Firebase ID token that the backend verifies (`POST /auth/firebase`).
/// Abstract so it can be faked in tests without the Firebase platform channels.
abstract class FirebaseAuthGateway {
  String? get currentEmail;
  String? get currentDisplayName;

  /// Interactive Google sign-in that establishes a Firebase session.
  Future<String> signInWithGoogle();

  /// Email/password sign-in for a returning user.
  Future<String> signInWithEmailPassword({
    required String email,
    required String password,
  });

  /// Create a new Firebase email/password account (used during onboarding).
  Future<String> registerWithEmailPassword({
    required String email,
    required String password,
  });

  /// A fresh ID token for the currently signed-in Firebase user, or null.
  Future<String?> currentIdToken();

  /// Sign out of both Firebase and Google.
  Future<void> signOut();
}

class FirebaseAuthGatewayImpl implements FirebaseAuthGateway {
  FirebaseAuthGatewayImpl({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
    : _auth = auth ?? FirebaseAuth.instance,
      _googleSignIn =
          googleSignIn ?? GoogleSignIn(scopes: const <String>['email']);

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  @override
  String? get currentEmail => _auth.currentUser?.email;

  @override
  String? get currentDisplayName => _auth.currentUser?.displayName;

  @override
  Future<String> signInWithGoogle() async {
    final GoogleSignInAccount? account;
    try {
      account = await _googleSignIn.signIn();
    } on Exception catch (e) {
      throw AuthGatewayException(AuthGatewayError.unknown, message: '$e');
    }
    if (account == null) {
      throw const AuthGatewayException(AuthGatewayError.cancelled);
    }

    final googleAuth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );
    try {
      final result = await _auth.signInWithCredential(credential);
      return _requireIdToken(result.user);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  @override
  Future<String> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _requireIdToken(result.user);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  @override
  Future<String> registerWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _requireIdToken(result.user);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  @override
  Future<String?> currentIdToken() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return user.getIdToken();
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<String> _requireIdToken(User? user) async {
    final token = user == null ? null : await user.getIdToken();
    if (token == null || token.isEmpty) {
      throw const AuthGatewayException(AuthGatewayError.unknown);
    }
    return token;
  }

  AuthGatewayException _mapFirebaseError(FirebaseAuthException e) {
    final error = switch (e.code) {
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' ||
      'invalid-email' => AuthGatewayError.invalidCredentials,
      'email-already-in-use' => AuthGatewayError.emailAlreadyInUse,
      'weak-password' => AuthGatewayError.weakPassword,
      'user-disabled' => AuthGatewayError.userDisabled,
      'network-request-failed' => AuthGatewayError.network,
      'too-many-requests' => AuthGatewayError.tooManyRequests,
      _ => AuthGatewayError.unknown,
    };
    return AuthGatewayException(error, message: e.message);
  }
}
