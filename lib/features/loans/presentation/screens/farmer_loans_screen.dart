import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/media/photo_picker.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/utils/number_formatters.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/core/widgets/app_state_placeholder.dart';
import 'package:farm2fork_mobile/core/widgets/app_text_field.dart';
import 'package:farm2fork_mobile/features/loans/data/loans.dart';
import 'package:farm2fork_mobile/features/loans/presentation/loan_widgets.dart';

/// Farmer microfinance (US-10): apply once at a time, follow the review and
/// the repayment schedule.
class FarmerLoansScreen extends ConsumerWidget {
  const FarmerLoansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final loans = ref.watch(myLoansProvider);
    final hasOpen = loans.asData?.value.any((l) => l.isOpen) ?? true;
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: Text(l10n.loansTitle, style: AppTextStyles.h3)),
      body: RefreshIndicator(
        color: AppColors.primaryGreen,
        onRefresh: () => ref.refresh(myLoansProvider.future),
        child: loans.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          ),
          error: (_, _) =>
              AppErrorState(onRetry: () => ref.invalidate(myLoansProvider)),
          data: (list) => ListView(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            children: [
              AppCard(
                backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.06),
                borderColor: AppColors.primaryGreen,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.loansFarmerIntroTitle, style: AppTextStyles.h3),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.loansFarmerIntroBody,
                      style: AppTextStyles.small.copyWith(height: 1.4),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: l10n.loanApply,
                      icon: Icons.add_rounded,
                      expand: true,
                      onPressed: hasOpen ? null : () => _openApply(context),
                    ),
                    if (hasOpen && list.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.loanOneAtATime,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (list.isEmpty)
                AppEmptyState(
                  message: l10n.loansNone,
                  icon: Icons.account_balance_rounded,
                )
              else
                for (final loan in list)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _LoanCard(loan: loan),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  void _openApply(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _ApplySheet(),
  );
}

class _LoanCard extends StatelessWidget {
  const _LoanCard({required this.loan});

  final LoanApplication loan;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppCard(
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
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.loanTermsSummary(
              loan.durationMonths,
              formatShortDate(loan.createdAt, Localizations.localeOf(context)),
            ),
            style: AppTextStyles.small.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(loan.purpose, style: AppTextStyles.body),
          if (loan.reviewNote != null && loan.reviewNote!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.loanReviewerNote(loan.reviewNote!),
              style: AppTextStyles.small.copyWith(
                color: loan.status == LoanStatus.rejected
                    ? AppColors.errorRed
                    : AppColors.textDark,
              ),
            ),
          ],
          if (loan.schedule.isNotEmpty) ...[
            const Divider(
              height: AppSpacing.lg,
              color: AppColors.surfaceMedium,
            ),
            RepaymentScheduleView(loan: loan),
          ],
        ],
      ),
    );
  }
}

class _ApplySheet extends ConsumerStatefulWidget {
  const _ApplySheet();

  @override
  ConsumerState<_ApplySheet> createState() => _ApplySheetState();
}

class _ApplySheetState extends ConsumerState<_ApplySheet> {
  static const _durations = [3, 6, 9, 12, 18, 24, 36];

  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _purpose = TextEditingController();
  int _months = 6;
  final List<XFile> _documents = [];
  bool _sending = false;

  @override
  void dispose() {
    _amount.dispose();
    _purpose.dispose();
    super.dispose();
  }

  Future<void> _addDocument(ImageSource source) async {
    final photo = await ref.read(photoPickerProvider)(source);
    if (photo != null && mounted) setState(() => _documents.add(photo));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    try {
      await ref
          .read(loansRepositoryProvider)
          .apply(
            amount: double.parse(_amount.text.trim()),
            purpose: _purpose.text.trim(),
            durationMonths: _months,
            documents: _documents,
          );
      ref.invalidate(myLoansProvider);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.loanSubmitted)));
      }
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.loanSubmitFailed)));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final limits = ref.watch(loanLimitsProvider).asData?.value;
    final locale = Localizations.localeOf(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pagePadding,
          0,
          AppSpacing.pagePadding,
          AppSpacing.pagePadding,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.loanApply, style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _amount,
                label: l10n.loanAmountLabel,
                hintText: limits == null
                    ? null
                    : l10n.loanAmountRange(
                        formatCurrencyAmount(limits.minAmount, locale),
                        formatCurrencyAmount(limits.maxAmount, locale),
                      ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final amount = double.tryParse(v?.trim() ?? '');
                  if (amount == null || amount <= 0) return l10n.fieldRequired;
                  if (limits != null &&
                      (amount < limits.minAmount ||
                          amount > limits.maxAmount)) {
                    return l10n.loanAmountRange(
                      formatCurrencyAmount(limits.minAmount, locale),
                      formatCurrencyAmount(limits.maxAmount, locale),
                    );
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<int>(
                initialValue: _months,
                decoration: InputDecoration(labelText: l10n.loanDurationLabel),
                items: [
                  for (final m in _durations)
                    DropdownMenuItem(value: m, child: Text(l10n.loanMonths(m))),
                ],
                onChanged: (m) => setState(() => _months = m ?? _months),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _purpose,
                label: l10n.loanPurposeLabel,
                hintText: l10n.loanPurposeHint,
                maxLines: 3,
                maxLength: 500,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(l10n.loanDocumentsLabel, style: AppTextStyles.label),
              Text(
                l10n.loanDocumentsHint,
                style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final doc in _documents)
                    InputChip(
                      avatar: const Icon(Icons.description_rounded, size: 18),
                      label: Text(doc.name, overflow: TextOverflow.ellipsis),
                      onDeleted: () => setState(() => _documents.remove(doc)),
                    ),
                  if (_documents.length < (limits?.maxDocuments ?? 4)) ...[
                    ActionChip(
                      avatar: const Icon(Icons.photo_camera_rounded, size: 18),
                      label: Text(l10n.takePhoto),
                      onPressed: () => _addDocument(ImageSource.camera),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.photo_library_rounded, size: 18),
                      label: Text(l10n.chooseFromGallery),
                      onPressed: () => _addDocument(ImageSource.gallery),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: l10n.loanSubmit,
                icon: Icons.send_rounded,
                expand: true,
                isLoading: _sending,
                onPressed: _sending ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
