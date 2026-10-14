import 'package:farm2fork_mobile/core/config/app_config.dart';
import 'package:farm2fork_mobile/core/network/network_providers.dart';
import 'package:farm2fork_mobile/features/listings/data/repositories/api_listings_repository.dart';
import 'package:farm2fork_mobile/features/listings/data/repositories/listings_repository.dart';
import 'package:farm2fork_mobile/features/listings/data/repositories/mock_listings_repository.dart';
import 'package:farm2fork_mobile/features/listings/data/services/listings_api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Real `/products` farmer endpoints by default; the mock only when
/// [AppConfig.useMocks] is set.
final listingsRepositoryProvider = Provider<ListingsRepository>((ref) {
  if (AppConfig.useMocks) return MockListingsRepository();
  return ApiListingsRepository(ListingsApiService(ref.watch(dioProvider)));
});
