import 'package:farm2fork_mobile/core/config/app_config.dart';
import 'package:farm2fork_mobile/core/network/network_providers.dart';
import 'package:farm2fork_mobile/features/shipments/data/repositories/api_shipments_repository.dart';
import 'package:farm2fork_mobile/features/shipments/data/repositories/mock_shipments_repository.dart';
import 'package:farm2fork_mobile/features/shipments/data/repositories/shipments_repository.dart';
import 'package:farm2fork_mobile/features/shipments/data/services/shipments_api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final shipmentsRepositoryProvider = Provider<ShipmentsRepository>((ref) {
  if (AppConfig.useMocks) return MockShipmentsRepository();
  return ApiShipmentsRepository(ShipmentsApiService(ref.watch(dioProvider)));
});
