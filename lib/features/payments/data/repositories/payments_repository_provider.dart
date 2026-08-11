import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/config/app_config.dart';
import 'package:farm2fork_mobile/core/network/network_providers.dart';
import 'package:farm2fork_mobile/features/payments/data/repositories/api_payments_repository.dart';
import 'package:farm2fork_mobile/features/payments/data/repositories/mock_payments_repository.dart';
import 'package:farm2fork_mobile/features/payments/data/repositories/payments_repository.dart';
import 'package:farm2fork_mobile/features/payments/data/services/payments_api_service.dart';

final paymentsRepositoryProvider = Provider<PaymentsRepository>((ref) {
  if (AppConfig.useMocks) return MockPaymentsRepository();
  return ApiPaymentsRepository(PaymentsApiService(ref.watch(dioProvider)));
});
