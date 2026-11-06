import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:farm2fork_mobile/features/auth/data/services/firebase_auth_gateway.dart';

class _User extends Fake implements User {
  @override
  Future<String?> getIdToken([bool forceRefresh = false]) async {
    throw FirebaseAuthException(code: 'network-request-failed');
  }

  @override
  Future<void> reload() async {}
}

class _Credential extends Fake implements UserCredential {
  @override
  User get user => _User();
}

class _GoogleTokens extends Fake implements GoogleSignInAuthentication {
  @override
  String get idToken => 'test-token';
  @override
  String get accessToken => 'test-access';
}

class _Account extends Fake implements GoogleSignInAccount {
  @override
  Future<GoogleSignInAuthentication> get authentication async =>
      _GoogleTokens();
}

class _Google extends Fake implements GoogleSignIn {
  @override
  Future<GoogleSignInAccount?> signIn() async => _Account();
}

class _Auth extends Fake implements FirebaseAuth {
  @override
  Future<UserCredential> signInWithCredential(
    AuthCredential credential,
  ) async => _Credential();
  @override
  User get currentUser => _User();
  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async => _Credential();
  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async => _Credential();
}

void main() {
  for (final action in ['google', 'login', 'register', 'refresh']) {
    test('$action maps asynchronous ID-token errors inside catch', () async {
      final gateway = FirebaseAuthGatewayImpl(
        auth: _Auth(),
        googleSignIn: _Google(),
      );
      final request = switch (action) {
        'google' => gateway.signInWithGoogle(),
        'login' => gateway.signInWithEmailPassword(
          email: 'x@example.com',
          password: 'test',
        ),
        'register' => gateway.registerWithEmailPassword(
          email: 'x@example.com',
          password: 'test',
        ),
        _ => gateway.refreshIdToken(),
      };
      await expectLater(
        request,
        throwsA(
          isA<AuthGatewayException>().having(
            (e) => e.error,
            'error',
            AuthGatewayError.network,
          ),
        ),
      );
    });
  }
}
