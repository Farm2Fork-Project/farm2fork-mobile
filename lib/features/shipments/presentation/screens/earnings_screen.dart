import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
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

    Widget muted(String text) => Text(
      text,
      style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: Text(l.deliveryEarnings, style: AppTextStyles.h2)),
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
                  padding: const EdgeInsets.all(AppSpacing.pagePadding),
                  children: [
                    AppCard(
                      backgroundColor: AppColors.primaryGreenDark,
                      borderColor: AppColors.primaryGreenDark,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.unpaidTotal,
                            style: AppTextStyles.small.copyWith(
                              color: AppColors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          Text(
                            money(totals['unpaid']),
                            style: AppTextStyles.h1.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              for (final e in {
                                'earned': l.earnedTotal,
                                'paid': l.paidTotal,
                              }.entries)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        e.value,
                                        style: AppTextStyles.label.copyWith(
                                          color: AppColors.white.withValues(
                                            alpha: 0.7,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        money(totals[e.key]),
                                        style: AppTextStyles.body.copyWith(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '${l.manualPayoutNote} ${l.earningsLedgerScope}',
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.textMuted,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(l.deliveriesTitle, style: AppTextStyles.h3),
                    const SizedBox(height: AppSpacing.sm),
                    if (items.isEmpty) muted(l.noEarningsYet),
                    for (final item in items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: AppCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      date(item['earnedAt']),
                                      style: AppTextStyles.body.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      item['status'] == 'paid'
                                          ? l.paidTotal
                                          : l.unpaidTotal,
                                      style: AppTextStyles.small.copyWith(
                                        color: item['status'] == 'paid'
                                            ? AppColors.success
                                            : AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                money(item['amount']),
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(l.payoutRecords, style: AppTextStyles.h3),
                    const SizedBox(height: AppSpacing.sm),
                    if (payouts.isEmpty) muted(l.noPayoutsYet),
                    for (final payout in payouts)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: AppCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      date(payout['paidAt']),
                                      style: AppTextStyles.body.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${payout['reference'] ?? ''}',
                                      textDirection: TextDirection.ltr,
                                      style: AppTextStyles.small.copyWith(
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    if (payout['reversesPayoutId'] != null)
                                      Text(
                                        l.payoutCorrectionRecord,
                                        style: AppTextStyles.small.copyWith(
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                money(payout['amount']),
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
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
