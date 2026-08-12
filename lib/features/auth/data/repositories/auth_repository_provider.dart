import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/config/app_config.dart';
import 'package:farm2fork_mobile/core/network/network_providers.dart';
import 'package:farm2fork_mobile/features/auth/data/repositories/api_auth_repository.dart';
import 'package:farm2fork_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:farm2fork_mobile/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:farm2fork_mobile/features/auth/data/services/auth_api_service.dart';
import 'package:farm2fork_mobile/features/auth/data/services/firebase_auth_gateway.dart';

/// Resolves to the real Firebase-backed auth repository, or the in-memory mock
/// when [AppConfig.useMocks] is set.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (AppConfig.useMocks) {
    return MockAuthRepository();
  }
  final dio = ref.watch(dioProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return ApiAuthRepository(
    FirebaseAuthGatewayImpl(),
    AuthApiService(dio),
    tokenStorage,
  );
});
