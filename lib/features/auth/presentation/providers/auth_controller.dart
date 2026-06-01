import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/features/auth/data/models/auth_user.dart';
import 'package:farm2fork_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:farm2fork_mobile/features/auth/data/repositories/mock_auth_repository.dart';

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

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signOut();
      return const AuthState(status: AuthStatus.unauthenticated);
    });
  }
}
