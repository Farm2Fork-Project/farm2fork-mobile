import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/config/app_config.dart';
import 'package:farm2fork_mobile/core/network/network_providers.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/profile/data/repositories/api_profile_repository.dart';
import 'package:farm2fork_mobile/features/profile/data/repositories/mock_profile_repository.dart';
import 'package:farm2fork_mobile/features/profile/data/repositories/profile_repository.dart';
import 'package:farm2fork_mobile/features/profile/data/services/profile_api_service.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  if (AppConfig.useMocks) {
    return MockProfileRepository(
      () => ref.read(authControllerProvider).value?.user,
    );
  }
  return ApiProfileRepository(ProfileApiService(ref.watch(dioProvider)));
});
