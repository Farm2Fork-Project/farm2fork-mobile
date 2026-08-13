import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/features/auth/data/models/auth_user.dart';
import 'package:farm2fork_mobile/features/auth/data/models/onboarding_request.dart';
import 'package:farm2fork_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:farm2fork_mobile/features/auth/data/repositories/auth_repository_provider.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final repository = ref.watch(authRepositoryProvider);
    final user = await repository.restoreSession();
    if (user != null) {
      return AuthState(status: AuthStatus.authenticated, user: user);
    }
    return const AuthState(status: AuthStatus.guest);
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password);
      return AuthState(status: AuthStatus.authenticated, user: user);
    });
  }

  Future<void> signUp({required SignUpRequest request}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref
          .read(authRepositoryProvider)
          .signUp(request: request);
      return AuthState(status: AuthStatus.authenticated, user: user);
    });
  }

  /// Google sign-in. On success the state becomes authenticated; when the
  /// identity has no account yet the returned outcome is
  /// [FirebaseOnboardingRequired] and the caller routes into onboarding.
  Future<FirebaseSignInOutcome> signInWithGoogle() {
    return _runFirebaseSignIn(
      () => ref.read(authRepositoryProvider).signInWithGoogle(),
    );
  }

  /// Email/password sign-in for a returning user (same outcome semantics).
  Future<FirebaseSignInOutcome> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _runFirebaseSignIn(
      () => ref
          .read(authRepositoryProvider)
          .signInWithEmail(email: email, password: password),
    );
  }

  /// Refreshes the Firebase user after email verification and re-exchanges the
  /// ID token with the backend.
  Future<FirebaseSignInOutcome> refreshVerifiedEmailSession() {
    return _runFirebaseSignIn(
      () => ref.read(authRepositoryProvider).refreshVerifiedEmailSession(),
    );
  }

  Future<void> resendEmailVerification() {
    return ref.read(authRepositoryProvider).resendEmailVerification();
  }

  Future<void> sendPasswordReset({required String email}) {
    return ref.read(authRepositoryProvider).sendPasswordReset(email: email);
  }

  /// Complete first-time onboarding, then authenticate.
  Future<void> completeOnboarding(OnboardingRequest request) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref
          .read(authRepositoryProvider)
          .completeOnboarding(request);
      return AuthState(status: AuthStatus.authenticated, user: user);
    });
  }

  Future<FirebaseSignInOutcome> _runFirebaseSignIn(
    Future<FirebaseSignInOutcome> Function() action,
  ) async {
    state = const AsyncLoading();
    try {
      final outcome = await action();
      // A verification/onboarding requirement keeps the user in the guest
      // shell; the screen routes from the returned outcome.
      state = AsyncData(
        outcome is FirebaseSignedIn
            ? AuthState(status: AuthStatus.authenticated, user: outcome.user)
            : const AuthState(status: AuthStatus.guest),
      );
      return outcome;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signOut();
      return const AuthState(status: AuthStatus.unauthenticated);
    });
  }
}
