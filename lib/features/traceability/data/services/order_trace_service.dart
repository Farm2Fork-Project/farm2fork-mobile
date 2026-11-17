import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/network/network_providers.dart';
import '../models/order_trace.dart';

final orderTraceProvider = FutureProvider.autoDispose
    .family<OrderTrace, String>((ref, id) async {
      final cancel = CancelToken();
      ref.onDispose(() => cancel.cancel());
      final response = await ref
          .watch(dioProvider)
          .get<Map<String, dynamic>>(
            '/trace/orders/${Uri.encodeComponent(id)}',
            cancelToken: cancel,
          );
      return OrderTrace.fromJson(response.data!);
    });

class OrderQr {
  const OrderQr({
    required this.orderId,
    required this.url,
    required this.image,
  });
  final String orderId, url, image;
}

final orderQrAccountProvider = Provider<String?>(
  (ref) => ref.watch(
    authControllerProvider.select((auth) {
      final state = auth.asData?.value;
      return state?.isAuthenticated == true ? state!.user?.id : null;
    }),
  ),
);

final orderQrProvider = FutureProvider.autoDispose.family<OrderQr, String>((
  ref,
  id,
) async {
  // Watching account identity rebuilds this request and clears prior-account
  // data while cancellation releases any in-flight response.
  ref.watch(orderQrAccountProvider);
  final cancel = CancelToken();
  ref.onDispose(() => cancel.cancel());
  final response = await ref
      .watch(dioProvider)
      .get<Map<String, dynamic>>(
        '/orders/${Uri.encodeComponent(id)}/qr',
        cancelToken: cancel,
      );
  final body = response.data!;
  return OrderQr(
    orderId: body['orderId'] as String,
    url: body['qrCode'] as String,
    image: body['qrImageDataUri'] as String,
  );
});
