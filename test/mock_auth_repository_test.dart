import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:farm2fork_mobile/features/auth/data/repositories/mock_auth_repository.dart';

void main() {
  late MockAuthRepository repo;

  setUp(() => repo = MockAuthRepository());

  group('MockAuthRepository.restoreSession', () {
    test('returns null before any sign-in', () async {
      expect(await repo.restoreSession(), isNull);
    });

    test('returns user after sign-in', () async {
      await repo.signIn(email: 'buyer@test.com', password: 'test1234');
      expect(await repo.restoreSession(), isNotNull);
    });

    test('returns null after sign-out', () async {
      await repo.signIn(email: 'buyer@test.com', password: 'test1234');
      await repo.signOut();
      expect(await repo.restoreSession(), isNull);
    });
  });

  group('MockAuthRepository.signIn', () {
    test('buyer@test.com returns buyer role', () async {
      final user =
          await repo.signIn(email: 'buyer@test.com', password: 'test1234');
      expect(user.role, AppUserRole.buyer);
      expect(user.email, 'buyer@test.com');
    });

    test('farmer@test.com returns farmer role', () async {
      final user =
          await repo.signIn(email: 'farmer@test.com', password: 'test1234');
      expect(user.role, AppUserRole.farmer);
    });

    test('transporter@test.com returns transporter role', () async {
      final user = await repo.signIn(
          email: 'transporter@test.com', password: 'test1234');
      expect(user.role, AppUserRole.transporter);
    });

    test('wrong password throws', () {
      expect(
        () => repo.signIn(email: 'buyer@test.com', password: 'wrong'),
        throwsA(isA<Exception>()),
      );
    });

    test('unknown email throws', () {
      expect(
        () => repo.signIn(email: 'unknown@test.com', password: 'test1234'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('MockAuthRepository.signUp', () {
    test('buyer signup stores user as buyer role', () async {
      final user = await repo.signUp(
        request: const BuyerSignUpRequest(
          name: 'Ali',
          email: 'ali@example.com',
          password: 'pass123',
        ),
      );
      expect(user.role, AppUserRole.buyer);
      expect(user.email, 'ali@example.com');
    });

    test('farmer signup stores user as farmer role', () async {
      final user = await repo.signUp(
        request: const FarmerSignUpRequest(
          name: 'Ahmad',
          email: 'ahmad@farm.com',
          password: 'pass123',
          farmName: 'Green Valley',
          location: 'Punjab',
          farmSize: '10',
          cropTypes: ['Wheat', 'Rice'],
        ),
      );
      expect(user.role, AppUserRole.farmer);
    });

    test('transporter signup stores user as transporter role', () async {
      final user = await repo.signUp(
        request: const TransporterSignUpRequest(
          name: 'Usman',
          email: 'usman@transport.com',
          password: 'pass123',
          vehicleType: 'Truck',
          vehicleLicense: 'LHR-1234',
          serviceArea: 'Lahore',
        ),
      );
      expect(user.role, AppUserRole.transporter);
    });

    test('after signup, restoreSession returns the new user', () async {
      await repo.signUp(
        request: const BuyerSignUpRequest(
          name: 'Sara',
          email: 'sara@example.com',
          password: 'pass123',
        ),
      );
      final restored = await repo.restoreSession();
      expect(restored?.email, 'sara@example.com');
    });
  });
}
