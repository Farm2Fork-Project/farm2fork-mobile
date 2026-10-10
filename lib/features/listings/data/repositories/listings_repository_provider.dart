import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/config/app_config.dart';
import 'package:farm2fork_mobile/core/network/network_providers.dart';
import '../services/listings_api_service.dart';
import 'api_listings_repository.dart';
import 'listings_repository.dart';
import 'mock_listings_repository.dart';

final listingsRepositoryProvider = Provider<ListingsRepository>((ref) {
  if (AppConfig.useMocks) return MockListingsRepository();
  return ApiListingsRepository(ListingsApiService(ref.watch(dioProvider)));
});
