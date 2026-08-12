import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/core/storage/token_storage.dart';
import 'package:farm2fork_mobile/features/auth/data/models/onboarding_request.dart';
import 'package:farm2fork_mobile/features/auth/data/repositories/api_auth_repository.dart';
import 'package:farm2fork_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:farm2fork_mobile/features/auth/data/services/auth_api_service.dart';
import 'package:farm2fork_mobile/features/auth/data/services/firebase_auth_gateway.dart';

class _FakeGateway implements FirebaseAuthGateway {
  String idToken = 'id-token';
  String? existingIdToken = 'current-token';
  int registerCalls = 0;
  int signOutCalls = 0;

  @override
  String? get currentEmail => 'user@example.com';
  @override
  String? get currentDisplayName => 'User';
  @override
  Future<String> signInWithGoogle() async => idToken;
  @override
  Future<String> signInWithEmailPassword({
    required String email,
    required String password,
  }) async => idToken;
  @override
  Future<String> registerWithEmailPassword({
    required String email,
    required String password,
  }) async {
    registerCalls++;
    return idToken;
  }

  @override
  Future<String?> currentIdToken() async => existingIdToken;
  @override
  Future<void> signOut() async => signOutCalls++;
}

class _FakeApi implements AuthApiService {
  Map<String, dynamic>? signInResponse;
  Object? signInError;
  Map<String, dynamic>? onboardResponse;
  Map<String, dynamic>? meResponse;
  Object? meError;
  String? lastIdToken;
  String? lastOnboardPath;
  Map<String, dynamic>? lastOnboardBody;

  @override
  Future<Map<String, dynamic>> signInWithFirebase(String idToken) async {
    lastIdToken = idToken;
    if (signInError != null) throw signInError!;
    return signInResponse!;
  }

  @override
  Future<Map<String, dynamic>> onboard(
    String rolePath,
    Map<String, dynamic> body,
  ) async {
    lastOnboardPath = rolePath;
    lastOnboardBody = body;
    return onboardResponse!;
  }

  @override
  Future<Map<String, dynamic>> me() async {
    if (meError != null) throw meError!;
    return meResponse!;
  }
}

class _FakeTokenStorage implements TokenStorage {
  String? token;
  int clearCalls = 0;

  @override
  Future<String?> readAccessToken() async => token;
  @override
  Future<void> writeAccessToken(String value) async => token = value;
  @override
  Future<void> clear() async {
    token = null;
    clearCalls++;
  }
}

Map<String, dynamic> _session(String role) => {
  'accessToken': 'jwt-123',
  'user': {
    'id': 'u1',
    'email': 'user@example.com',
    'role': role,
    'isVerified': true,
    'isActive': true,
  },
};

void main() {
  late _FakeGateway gateway;
  late _FakeApi api;
  late _FakeTokenStorage storage;
  late ApiAuthRepository repo;

  setUp(() {
    gateway = _FakeGateway();
    api = _FakeApi();
    storage = _FakeTokenStorage();
    repo = ApiAuthRepository(gateway, api, storage);
  });

  test('signInWithEmail returns the user and persists the JWT', () async {
    api.signInResponse = _session('farmer');

    final outcome = await repo.signInWithEmail(
      email: 'user@example.com',
      password: 'x',
    );

    expect(outcome, isA<FirebaseSignedIn>());
    expect((outcome as FirebaseSignedIn).user.role, AppUserRole.farmer);
    expect(storage.token, 'jwt-123');
    expect(api.lastIdToken, 'id-token');
  });

  test('a 409 from /auth/firebase surfaces onboarding-required', () async {
    api.signInError = const ApiException(ApiErrorKind.unknown, statusCode: 409);

    final outcome = await repo.signInWithEmail(
      email: 'new@example.com',
      password: 'x',
    );

    expect(outcome, isA<FirebaseOnboardingRequired>());
    expect((outcome as FirebaseOnboardingRequired).email, 'new@example.com');
    expect(storage.token, isNull);
  });

  test(
    'a Dio-wrapped 409 from /auth/firebase surfaces onboarding-required',
    () async {
      api.signInError = DioException(
        requestOptions: RequestOptions(path: '/auth/firebase'),
        error: const ApiException(ApiErrorKind.unknown, statusCode: 409),
      );

      final outcome = await repo.signInWithEmail(
        email: 'new@example.com',
        password: 'x',
      );

      expect(outcome, isA<FirebaseOnboardingRequired>());
      expect((outcome as FirebaseOnboardingRequired).email, 'new@example.com');
      expect(storage.token, isNull);
    },
  );

  test('Google onboarding reuses the current Firebase token', () async {
    api.onboardResponse = _session('buyer');

    final user = await repo.completeOnboarding(
      const BuyerOnboardingRequest(
        credential: GoogleOnboardingCredential(),
        cnic: '35202-1234567-1',
        businessName: 'Fresh Mart',
        businessType: 'retailer',
      ),
    );

    expect(user.role, AppUserRole.buyer);
    expect(api.lastOnboardPath, 'buyer');
    expect(api.lastOnboardBody!['idToken'], 'current-token');
    expect(api.lastOnboardBody!['businessName'], 'Fresh Mart');
    expect(gateway.registerCalls, 0);
    expect(storage.token, 'jwt-123');
  });

  test(
    'email/password onboarding creates the Firebase account first',
    () async {
      api.onboardResponse = _session('farmer');

      await repo.completeOnboarding(
        const FarmerOnboardingRequest(
          credential: EmailPasswordOnboardingCredential(
            email: 'f@example.com',
            password: 'StrongP@ss1',
          ),
          cnic: '35202-1234567-1',
          farmName: 'Green Acres',
        ),
      );

      expect(gateway.registerCalls, 1);
      expect(api.lastOnboardPath, 'farmer');
      expect(api.lastOnboardBody!['idToken'], 'id-token');
      expect(api.lastOnboardBody!['farmName'], 'Green Acres');
    },
  );

  test('restoreSession clears the token and returns null on 401', () async {
    storage.token = 'stale';
    api.meError = const ApiException(
      ApiErrorKind.unauthorized,
      statusCode: 401,
    );

    final user = await repo.restoreSession();

    expect(user, isNull);
    expect(storage.token, isNull);
    expect(storage.clearCalls, 1);
  });

  test('restoreSession clears the token for a Dio-wrapped 401', () async {
    storage.token = 'stale';
    api.meError = DioException(
      requestOptions: RequestOptions(path: '/auth/me'),
      error: const ApiException(ApiErrorKind.unauthorized, statusCode: 401),
    );

    final user = await repo.restoreSession();

    expect(user, isNull);
    expect(storage.token, isNull);
    expect(storage.clearCalls, 1);
  });

  test('restoreSession returns the user for a valid token', () async {
    storage.token = 'good';
    api.meResponse = {
      'id': 'u1',
      'email': 'user@example.com',
      'role': 'transporter',
      'isVerified': true,
      'isActive': true,
    };

    final user = await repo.restoreSession();

    expect(user, isNotNull);
    expect(user!.role, AppUserRole.transporter);
  });

  test('signOut clears the token and signs out of Firebase', () async {
    storage.token = 'x';

    await repo.signOut();

    expect(storage.token, isNull);
    expect(gateway.signOutCalls, 1);
  });
}
