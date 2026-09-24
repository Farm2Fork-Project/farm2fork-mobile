import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/core/widgets/app_state_placeholder.dart';
import 'package:farm2fork_mobile/features/loans/data/loans.dart';
import 'package:farm2fork_mobile/features/loans/presentation/loan_widgets.dart';

/// Financial partner review of one application.
class LoanReviewScreen extends ConsumerStatefulWidget {
  const LoanReviewScreen({super.key, required this.loanId});

  final String loanId;

  @override
  ConsumerState<LoanReviewScreen> createState() => _LoanReviewScreenState();
}

class _LoanReviewScreenState extends ConsumerState<LoanReviewScreen> {
  bool _busy = false;

  Future<void> _run(Future<void> Function(LoansRepository repo) action) async {
    setState(() => _busy = true);
    try {
      await action(ref.read(loansRepositoryProvider));
      ref
        ..invalidate(loanDetailProvider(widget.loanId))
        ..invalidate(loanQueueProvider);
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.loanActionFailed)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reject() async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => const _RejectDialog(),
    );
    if (reason == null) return;
    await _run(
      (repo) => repo.decide(widget.loanId, approve: false, note: reason),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final loan = ref.watch(loanDetailProvider(widget.loanId));
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(l10n.loanReviewTitle, style: AppTextStyles.h3),
      ),
      body: loan.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
        error: (_, _) => AppErrorState(
          onRetry: () => ref.invalidate(loanDetailProvider(widget.loanId)),
        ),
        data: (loan) {
          final applicant = loan.applicant;
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            loanMoney(context, loan.amount),
                            style: AppTextStyles.h2,
                          ),
                        ),
                        LoanStatusBadge(status: loan.status),
                      ],
                    ),
                    Text(
                      l10n.loanMonths(loan.durationMonths),
                      style: AppTextStyles.small,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(loan.purpose, style: AppTextStyles.body),
                    if (loan.reviewNote != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.loanReviewerNote(loan.reviewNote!),
                        style: AppTextStyles.small,
                      ),
                    ],
                  ],
                ),
              ),
              if (applicant != null) ...[
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(applicant.farmName, style: AppTextStyles.h3),
                      Text(
                        [
                          applicant.city,
                          applicant.province,
                        ].whereType<String>().join(', '),
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (applicant.landSizeAcres != null)
                        Text(
                          l10n.loanLandSize(
                            applicant.landSizeAcres!.toStringAsFixed(1),
                          ),
                          style: AppTextStyles.small,
                        ),
                      if (applicant.cropTypes.isNotEmpty)
                        Text(
                          l10n.loanCrops(applicant.cropTypes.join(', ')),
                          style: AppTextStyles.small,
                        ),
                      Text(
                        l10n.loanSalesHistory(
                          applicant.deliveredOrders,
                          loanMoney(context, applicant.deliveredRevenue),
                        ),
                        style: AppTextStyles.small.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (loan.documentUrls.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.loanDocumentsLabel, style: AppTextStyles.h3),
                      for (final (index, url) in loan.documentUrls.indexed)
                        TextButton.icon(
                          icon: const Icon(Icons.description_rounded),
                          label: Text(l10n.loanDocumentN(index + 1)),
                          onPressed: () => launchUrl(
                            Uri.parse(url),
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
                      Text(
                        l10n.loanDocumentsExpire,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (loan.schedule.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  child: RepaymentScheduleView(
                    loan: loan,
                    onMarkPaid: loan.status == LoanStatus.approved && !_busy
                        ? (i) => _run(
                            (repo) => repo.markInstalmentPaid(loan.id, i.index),
                          )
                        : null,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              if (loan.status == LoanStatus.pending)
                AppButton(
                  label: l10n.loanStartReview,
                  expand: true,
                  isLoading: _busy,
                  onPressed: _busy
                      ? null
                      : () => _run((repo) => repo.startReview(loan.id)),
                ),
              if (loan.status == LoanStatus.underReview)
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: l10n.loanReject,
                        variant: AppButtonVariant.danger,
                        onPressed: _busy ? null : _reject,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppButton(
                        label: l10n.loanApprove,
                        isLoading: _busy,
                        onPressed: _busy
                            ? null
                            : () => _run(
                                (repo) => repo.decide(loan.id, approve: true),
                              ),
                      ),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Owns its controller so it outlives the dialog's closing animation.
class _RejectDialog extends StatefulWidget {
  const _RejectDialog();

  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.loanRejectTitle),
      content: TextField(
        controller: _note,
        autofocus: true,
        maxLines: 3,
        decoration: InputDecoration(hintText: l10n.loanRejectHint),
      ),
      actions: [
        TextButton(onPressed: () => context.pop(), child: Text(l10n.cancel)),
        TextButton(
          onPressed: () {
            final note = _note.text.trim();
            if (note.isNotEmpty) context.pop(note);
          },
          child: Text(l10n.loanReject),
        ),
      ],
    );
  }
}
