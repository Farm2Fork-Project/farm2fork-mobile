import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/core/widgets/app_state_placeholder.dart';
import 'package:farm2fork_mobile/core/utils/number_formatters.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/shipments/data/repositories/shipments_repository_provider.dart';

final deliveryEarningsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
      final auth = await ref.watch(authControllerProvider.future);
      if (auth.user?.role != AppUserRole.transporter) {
        throw StateError('Transporter required');
      }
      final data = await ref.read(shipmentsRepositoryProvider).getEarnings();
      final totals = data['totals'];
      if (totals is! Map ||
          !['earned', 'paid', 'unpaid'].every((key) => totals[key] is num) ||
          data['items'] is! List ||
          data['payouts'] is! List) {
        throw const FormatException('Invalid earnings response');
      }
      return data;
    });

class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    String money(Object? value) => l.currencyAmount(
      formatCurrencyAmount(
        value is num ? value : 0,
        Localizations.localeOf(context),
      ),
    );
    String date(Object? value) {
      final parsed = DateTime.tryParse('$value')?.toLocal();
      return parsed == null
          ? ''
          : MaterialLocalizations.of(context).formatMediumDate(parsed);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.deliveryEarnings)),
      body: ref
          .watch(deliveryEarningsProvider)
          .when(
            skipLoadingOnRefresh: false,
            skipLoadingOnReload: false,
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => AppErrorState(
              onRetry: () => ref.invalidate(deliveryEarningsProvider),
            ),
            data: (data) {
              final totals = data['totals'] as Map? ?? {};
              final items = (data['items'] as List? ?? []).whereType<Map>();
              final payouts = (data['payouts'] as List? ?? []).whereType<Map>();
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(deliveryEarningsProvider);
                  await ref.read(deliveryEarningsProvider.future);
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  children: [
                    AppCard(
                      child: Column(
                        children: [
                          for (final e in {
                            'earned': l.earnedTotal,
                            'unpaid': l.unpaidTotal,
                            'paid': l.paidTotal,
                          }.entries)
                            ListTile(
                              title: Text(e.value),
                              trailing: Text(money(totals[e.key])),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(l.manualPayoutNote),
                    const SizedBox(height: 8),
                    Text(l.earningsLedgerScope),
                    const SizedBox(height: 16),
                    if (items.isEmpty) Text(l.noEarningsYet),
                    for (final item in items)
                      AppCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            l.shipmentNumber('${item['shipmentId']}'),
                          ),
                          subtitle: Text(
                            '${date(item['earnedAt'])} · ${item['status'] == 'paid' ? l.paidTotal : l.unpaidTotal}',
                          ),
                          trailing: Text(money(item['amount'])),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Text(
                      l.payoutRecords,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (payouts.isEmpty) Text(l.noPayoutsYet),
                    for (final payout in payouts)
                      AppCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('${payout['reference'] ?? ''}'),
                          subtitle: Text('${date(payout['paidAt'])}${payout['reversesPayoutId'] != null ? '\n${l.payoutCorrectionRecord}' : ''}'),
                          trailing: Text(money(payout['amount'])),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
    );
  }
}
