import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import '../../data/services/order_trace_service.dart';

Future<void> showOrderQr(BuildContext context, String orderId) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => OrderQrSheet(orderId: orderId),
    );

class OrderQrSheet extends ConsumerWidget {
  const OrderQrSheet({super.key, required this.orderId});
  final String orderId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qr = ref.watch(orderQrProvider(orderId));
    final l10n = context.l10n;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .85,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.orderQrTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.orderQrDescription, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            qr.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
              error: (error, _) => Column(
                children: [
                  Text(l10n.orderQrUnavailable),
                  if ((error is ApiException && error.isUnauthorized) ||
                      (error is DioException &&
                          error.response?.statusCode == 401))
                    TextButton(
                      onPressed: () async {
                        final router = GoRouter.of(context);
                        Navigator.of(context).pop();
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
                      child: Text(l10n.login),
                    ),
                  TextButton(
                    onPressed: () => ref.invalidate(orderQrProvider(orderId)),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
              data: (value) => Column(
                children: [
                  Semantics(
                    label: l10n.orderQrTitle,
                    image: true,
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(8),
                      child: Image.memory(
                        base64Decode(value.image.split(',').last),
                        width: 240,
                        height: 240,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SelectableText(
                    value.url,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.copy_rounded),
                        label: Text(l10n.orderQrCopy),
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: value.url),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.orderQrCopied)),
                            );
                          }
                        },
                      ),
                      Builder(
                        builder: (buttonContext) => OutlinedButton.icon(
                          icon: const Icon(Icons.share_outlined),
                          label: Text(l10n.orderQrShare),
                          onPressed: () async {
                            final box =
                                buttonContext.findRenderObject() as RenderBox?;
                            try {
                              await SharePlus.instance.share(
                                ShareParams(
                                  text: value.url,
                                  files: [
                                    XFile.fromData(
                                      base64Decode(value.image.split(',').last),
                                      mimeType: 'image/png',
                                    ),
                                  ],
                                  fileNameOverrides: [
                                    'farm2fork-order-$orderId.png',
                                  ],
                                  sharePositionOrigin: box == null
                                      ? null
                                      : box.localToGlobal(Offset.zero) &
                                            box.size,
                                ),
                              );
                            } catch (_) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(l10n.traceLoadFailed)),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.route_outlined),
                    label: Text(l10n.orderQrView),
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.push('/trace/orders/$orderId');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
