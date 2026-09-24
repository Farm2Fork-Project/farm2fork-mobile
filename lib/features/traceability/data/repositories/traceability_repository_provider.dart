import 'package:farm2fork_mobile/core/config/app_config.dart';
import 'package:farm2fork_mobile/core/network/network_providers.dart';
import 'package:farm2fork_mobile/features/traceability/data/repositories/api_traceability_repository.dart';
import 'package:farm2fork_mobile/features/traceability/data/repositories/mock_traceability_repository.dart';
import 'package:farm2fork_mobile/features/traceability/data/repositories/traceability_repository.dart';
import 'package:farm2fork_mobile/features/traceability/data/services/traceability_api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final traceabilityRepositoryProvider = Provider<TraceabilityRepository>((ref) {
  if (AppConfig.useMocks) return MockTraceabilityRepository();
  return ApiTraceabilityRepository(
    TraceabilityApiService(ref.watch(dioProvider)),
  );
});
