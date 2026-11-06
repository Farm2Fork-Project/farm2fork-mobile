import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/network/network_providers.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import '../../data/models/order.dart';
import '../../data/repositories/api_orders_repository.dart';
import '../../data/services/orders_api_service.dart';
import 'orders_screen.dart';

final orderDetailProvider = FutureProvider.autoDispose.family<Order, String>((
  ref,
  id,
) async {
  ref.watch(
    authControllerProvider.select((auth) {
      final state = auth.asData?.value;
      return state?.isAuthenticated == true ? state!.user?.id : null;
    }),
  );
  final dio = ref.watch(dioProvider);
  final cancel = CancelToken();
  ref.onDispose(() => cancel.cancel());
  final response = await dio.get<Map<String, dynamic>>(
    '/orders/${Uri.encodeComponent(id)}',
    cancelToken: cancel,
  );
  return ApiOrdersRepository(
    OrdersApiService(dio),
  ).orderFromDto(response.data!);
});

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});
  final String orderId;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.navOrders)),
    body: ref
        .watch(orderDetailProvider(orderId))
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(context.l10n.traceLoadFailed),
                if ((error is ApiException && error.isUnauthorized) ||
                    (error is DioException &&
                        error.response?.statusCode == 401))
                  TextButton(
                    onPressed: () async {
                      final router = GoRouter.of(context);
                      final cleanup = ref
                          .read(authControllerProvider.notifier)
                          .expireSession();
                      router.go(
                        Uri(
                          path: '/auth/login',
                          queryParameters: {'next': '/orders/$orderId'},
                        ).toString(),
                      );
                      await cleanup;
                    },
                    child: Text(context.l10n.login),
                  ),
                TextButton(
                  onPressed: () => ref.invalidate(orderDetailProvider(orderId)),
                  child: Text(context.l10n.retry),
                ),
              ],
            ),
          ),
          data: (order) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: OrderCard(
              order: order,
              role: ref.watch(authControllerProvider).asData?.value.role,
            ),
          ),
        ),
  );
}
