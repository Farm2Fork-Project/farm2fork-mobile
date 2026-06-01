import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/features/auth/data/models/auth_user.dart';
import 'package:farm2fork_mobile/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';

void main() {
  group('AuthUser', () {
    test('parses backend schema role values', () {
      expect(AuthUser.roleFromBackend('farmer'), AppUserRole.farmer);
      expect(AuthUser.roleFromBackend('buyer'), AppUserRole.buyer);
      expect(AuthUser.roleFromBackend('transporter'), AppUserRole.transporter);
      expect(
        AuthUser.roleFromBackend('financial_partner'),
        AppUserRole.financialPartner,
      );
      expect(AuthUser.roleFromBackend('admin'), AppUserRole.admin);
    });
  });

  group('AuthState', () {
    test('defaults to guest status', () {
      const state = AuthState();
      expect(state.status, AuthStatus.guest);
      expect(state.isAuthenticated, isFalse);
      expect(state.isGuest, isTrue);
      expect(state.role, isNull);
    });

    test('isGuest is true for unauthenticated and sessionExpired', () {
      expect(
        const AuthState(status: AuthStatus.unauthenticated).isGuest,
        isTrue,
      );
      expect(
        const AuthState(status: AuthStatus.sessionExpired).isGuest,
        isTrue,
      );
    });

    test('isGuest is false while loadingSession', () {
      expect(
        const AuthState(status: AuthStatus.loadingSession).isGuest,
        isFalse,
      );
    });

    test('authenticated state carries user and role', () {
      const user = AuthUser(
        id: 'u1',
        email: 'farmer@test.com',
        role: AppUserRole.farmer,
        isVerified: true,
        isActive: true,
      );
      const state = AuthState(status: AuthStatus.authenticated, user: user);
      expect(state.isAuthenticated, isTrue);
      expect(state.isGuest, isFalse);
      expect(state.role, AppUserRole.farmer);
    });
  });

  group('AuthController', () {
    test('starts in guest state when no session exists', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        ],
      );
      addTearDown(container.dispose);

      final state = await container.read(authControllerProvider.future);
      expect(state.status, AuthStatus.guest);
      expect(state.isAuthenticated, isFalse);
    });

    test(
      'signIn with valid credentials authenticates with correct role',
      () async {
        final container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(MockAuthRepository()),
          ],
        );
        addTearDown(container.dispose);

        await container.read(authControllerProvider.future);
        await container
            .read(authControllerProvider.notifier)
            .signIn(email: 'farmer@test.com', password: 'test1234');

        final state = container.read(authControllerProvider).value!;
        expect(state.status, AuthStatus.authenticated);
        expect(state.role, AppUserRole.farmer);
      },
    );

    test('signIn with wrong password results in error state', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authControllerProvider.future);
      await container
          .read(authControllerProvider.notifier)
          .signIn(email: 'buyer@test.com', password: 'wrong');

      expect(container.read(authControllerProvider).hasError, isTrue);
    });

    test('signOut sets status to unauthenticated', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authControllerProvider.future);
      await container
          .read(authControllerProvider.notifier)
          .signIn(email: 'buyer@test.com', password: 'test1234');
      await container.read(authControllerProvider.notifier).signOut();

      final state = container.read(authControllerProvider).value!;
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.isAuthenticated, isFalse);
    });
  });
}
