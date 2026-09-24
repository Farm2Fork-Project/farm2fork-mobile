import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/core/widgets/app_state_placeholder.dart';
import 'package:farm2fork_mobile/features/loans/data/loans.dart';
import 'package:farm2fork_mobile/features/loans/presentation/loan_widgets.dart';
import 'package:farm2fork_mobile/features/notifications/presentation/widgets/notification_bell.dart';

/// Financial partner queue: applications by status, newest first.
class LoansScreen extends ConsumerWidget {
  const LoansScreen({super.key});

  static String reviewRoute(String id) => '/finance/loans/$id';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final filter = ref.watch(loanQueueFilterProvider);
    final queue = ref.watch(loanQueueProvider);
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(l10n.loansTitle, style: AppTextStyles.h2),
        backgroundColor: AppColors.backgroundLight,
        centerTitle: true,
        actions: const [NotificationBell()],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding,
              ),
              children: [
                for (final status in [...LoanStatus.values, null])
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      end: AppSpacing.sm,
                    ),
                    child: ChoiceChip(
                      label: Text(
                        status == null
                            ? l10n.loanFilterAll
                            : loanStatusLabel(context, status),
                      ),
                      selected: filter == status,
                      onSelected: (_) => ref
                          .read(loanQueueFilterProvider.notifier)
                          .select(status),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primaryGreen,
              onRefresh: () => ref.refresh(loanQueueProvider.future),
              child: queue.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGreen,
                  ),
                ),
                error: (_, _) => AppErrorState(
                  onRetry: () => ref.invalidate(loanQueueProvider),
                ),
                data: (list) => list.isEmpty
                    ? AppEmptyState(
                        message: l10n.loanQueueEmpty,
                        icon: Icons.inbox_rounded,
                      )
                    : ListView(
                        padding: const EdgeInsets.all(AppSpacing.pagePadding),
                        children: [
                          for (final loan in list)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.md,
                              ),
                              child: InkWell(
                                onTap: () => context.push(reviewRoute(loan.id)),
                                child: AppCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              loan.applicant?.farmName ?? '',
                                              style: AppTextStyles.h3,
                                            ),
                                          ),
                                          LoanStatusBadge(status: loan.status),
                                        ],
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        '${loanMoney(context, loan.amount)} · ${l10n.loanMonths(loan.durationMonths)}',
                                        style: AppTextStyles.body.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        loan.purpose,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.small,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
