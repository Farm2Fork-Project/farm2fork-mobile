import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/core/widgets/app_state_placeholder.dart';
import '../../data/services/order_trace_service.dart';
import '../widgets/trace_journey_view.dart';

class OrderTraceScreen extends ConsumerWidget {
  const OrderTraceScreen({super.key, required this.orderId});
  final String orderId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final trace = ref.watch(orderTraceProvider(orderId));
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: Text(l10n.orderJourneyTitle)),
      body: SafeArea(
        child: trace.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => AppErrorState(
            message:
                error is ApiException && error.kind == ApiErrorKind.notFound
                ? l10n.orderTraceNotFoundDesc
                : l10n.traceLoadFailed,
            onRetry: () => ref.invalidate(orderTraceProvider(orderId)),
          ),
          data: (value) => ListView(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${value.reference}',
                      textDirection: TextDirection.ltr,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(switch (value.status) {
                      'paid' => l10n.orderStatusPaid,
                      'processing' => l10n.orderStatusProcessing,
                      'shipped' => l10n.orderStatusShipped,
                      'delivered' => l10n.orderStatusDelivered,
                      _ => l10n.orderTraceNotFound,
                    }),
                    const Divider(height: AppSpacing.xxl),
                    for (final item in value.items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '${item.productName} · ${item.quantity} ${item.unit ?? ''}',
                        ),
                      ),
                    const Divider(height: AppSpacing.xxl),
                    Text(
                      l10n.traceSourceFarm,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Text(
                      value.farm == null
                          ? l10n.traceFarmUnknown
                          : [
                              value.farm!.farmName,
                              value.farm!.place,
                            ].whereType<String>().join(' · '),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.orderTracePaidAt,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Text(
                      DateFormat.yMMMd(
                        Localizations.localeOf(context).languageCode,
                      ).add_jm().format(value.paidAt),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                backgroundColor: AppColors.surfaceLight,
                child: Text(
                  value.ledgerCheck == 'checked'
                      ? l10n.orderTraceLedgerChecked
                      : l10n.orderTraceLedgerUnavailable,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.traceJourneyTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                l10n.traceLedgerProgress(
                  value.confirmedEvents,
                  value.totalEvents,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (value.events.isEmpty) Text(l10n.traceJourneyEmpty),
              for (var i = 0; i < value.events.length; i++)
                TraceTimelineItem(
                  event: value.events[i],
                  isLast: i == value.events.length - 1,
                ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.orderJourneyPublic,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TextButton.icon(
                icon: const Icon(Icons.lock_outline),
                onPressed: () => context.push('/orders/$orderId'),
                label: Text(l10n.orderPrivateDetails),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
