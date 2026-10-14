import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/config/app_config.dart';
import 'package:farm2fork_mobile/core/network/network_providers.dart';
import 'package:farm2fork_mobile/features/orders/data/repositories/api_orders_repository.dart';
import 'package:farm2fork_mobile/features/orders/data/repositories/mock_orders_repository.dart';
import 'package:farm2fork_mobile/features/orders/data/repositories/orders_repository.dart';
import 'package:farm2fork_mobile/features/orders/data/services/orders_api_service.dart';

/// Resolves to the real Dio-backed orders repository, or the in-memory mock
/// when [AppConfig.useMocks] is set.
final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  if (AppConfig.useMocks) {
    return MockOrdersRepository();
  }
  final dio = ref.watch(dioProvider);
  return ApiOrdersRepository(OrdersApiService(dio));
});
