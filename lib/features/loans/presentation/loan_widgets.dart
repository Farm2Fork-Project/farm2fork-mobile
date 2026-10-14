import 'package:flutter/material.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/utils/number_formatters.dart';
import 'package:farm2fork_mobile/core/widgets/app_badge.dart';
import 'package:farm2fork_mobile/features/loans/data/loans.dart';

String loanMoney(BuildContext context, num amount) =>
    context.l10n.currencyAmount(
      formatCurrencyAmount(amount, Localizations.localeOf(context)),
    );

String loanStatusLabel(BuildContext context, LoanStatus status) =>
    switch (status) {
      LoanStatus.pending => context.l10n.loanStatusPending,
      LoanStatus.underReview => context.l10n.loanStatusUnderReview,
      LoanStatus.approved => context.l10n.loanStatusApproved,
      LoanStatus.rejected => context.l10n.loanStatusRejected,
      LoanStatus.repaid => context.l10n.loanStatusRepaid,
    };

class LoanStatusBadge extends StatelessWidget {
  const LoanStatusBadge({super.key, required this.status});

  final LoanStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      LoanStatus.pending => AppColors.accentYellow,
      LoanStatus.underReview => AppColors.secondaryBlue,
      LoanStatus.approved => AppColors.primaryGreen,
      LoanStatus.rejected => AppColors.errorRed,
      LoanStatus.repaid => AppColors.success,
    };
    return AppBadge(
      label: loanStatusLabel(context, status),
      backgroundColor: color.withValues(alpha: 0.12),
      foregroundColor: color,
    );
  }
}

class RepaymentScheduleView extends StatelessWidget {
  const RepaymentScheduleView({super.key, required this.loan, this.onMarkPaid});

  final LoanApplication loan;

  /// Partners only.
  final ValueChanged<Instalment>? onMarkPaid;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.loanRepaidProgress(
            loanMoney(context, loan.repaidAmount),
            loanMoney(context, loan.amount),
          ),
          style: AppTextStyles.small.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.xs),
        LinearProgressIndicator(
          value: loan.amount == 0 ? 0 : loan.repaidAmount / loan.amount,
          color: AppColors.primaryGreen,
          backgroundColor: AppColors.surfaceMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final i in loan.schedule)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              i.isPaid ? Icons.check_circle_rounded : Icons.schedule_rounded,
              color: i.isPaid ? AppColors.success : AppColors.textMuted,
            ),
            title: Text(
              l10n.loanInstalment(i.index + 1, loanMoney(context, i.amount)),
              style: AppTextStyles.small,
            ),
            subtitle: Text(
              i.isPaid && i.paidAt != null
                  ? l10n.loanPaidOn(formatShortDate(i.paidAt!, locale))
                  : l10n.loanDueOn(formatShortDate(i.dueDate, locale)),
              style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
            ),
            trailing: !i.isPaid && onMarkPaid != null
                ? TextButton(
                    onPressed: () => onMarkPaid!(i),
                    child: Text(l10n.loanMarkPaid),
                  )
                : null,
          ),
      ],
    );
  }
}
