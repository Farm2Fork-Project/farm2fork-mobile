import 'package:farm2fork_mobile/core/config/app_config.dart';
import 'package:farm2fork_mobile/core/network/network_providers.dart';
import 'package:farm2fork_mobile/features/ai/data/repositories/ai_repository.dart';
import 'package:farm2fork_mobile/features/ai/data/repositories/api_ai_repository.dart';
import 'package:farm2fork_mobile/features/ai/data/repositories/mock_ai_repository.dart';
import 'package:farm2fork_mobile/features/ai/data/services/ai_api_service.dart';
import 'package:farm2fork_mobile/features/ai/data/models/ai_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  if (AppConfig.useMocks) return MockAiRepository();
  return ApiAiRepository(AiApiService(ref.watch(dioProvider)));
});

/// Whether the AI service is up and if its grading model is trained.
final aiStatusProvider = FutureProvider.autoDispose<AiStatus>(
  (ref) => ref.watch(aiRepositoryProvider).status(),
);
