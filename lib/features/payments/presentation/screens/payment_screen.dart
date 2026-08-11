import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/features/payments/presentation/providers/payment_controller.dart';

class PaymentScreen extends ConsumerWidget {
  const PaymentScreen({super.key, required this.orderIds});

  final List<String> orderIds;

  Future<void> _completePayment(BuildContext context, WidgetRef ref) async {
    await ref.read(paymentControllerProvider.notifier).settle(orderIds);
    if (!context.mounted) return;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentState = ref.watch(paymentControllerProvider);
    final result = paymentState.asData?.value;
    final simulatorEnabled = ref.watch(paymentSimulatorEnabledProvider);
    final isLoading = paymentState.isLoading;
    final completed = result != null;
    final title = _title(context, result);
    final description = _description(context, result);
    final color = _color(result);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(context.l10n.paymentTitle, style: AppTextStyles.h3),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Column(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      color: color,
                      size: 36,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      title,
                      style: AppTextStyles.h3,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      description,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      context.l10n.paymentOrdersReadyCount(orderIds.length),
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              AppButton(
                expand: true,
                label: isLoading
                    ? context.l10n.loading
                    : simulatorEnabled && !completed
                    ? context.l10n.completeTestPayment
                    : context.l10n.viewOrders,
                onPressed: isLoading
                    ? null
                    : simulatorEnabled && !completed
                    ? () => _completePayment(context, ref)
                    : () => context.go(
                        AppNavConfig.routeFor(
                          AppUserRole.buyer,
                          AppNavDestination.orders,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _title(BuildContext context, PaymentFlowResult? result) {
    if (result == null || result.pendingOrderIds.isNotEmpty) {
      return context.l10n.paymentPending;
    }
    if (result.failedOrderIds.isNotEmpty) return context.l10n.paymentFailed;
    return context.l10n.paymentComplete;
  }

  String _description(BuildContext context, PaymentFlowResult? result) {
    if (result == null || result.pendingOrderIds.isNotEmpty) {
      return context.l10n.paymentPendingDescription;
    }
    if (result.failedOrderIds.isNotEmpty) {
      return context.l10n.paymentFailedCount(result.failedOrderIds.length);
    }
    return context.l10n.paymentCompletedCount(result.successfulOrderIds.length);
  }

  Color _color(PaymentFlowResult? result) {
    if (result == null || result.pendingOrderIds.isNotEmpty) {
      return AppColors.primaryGreen;
    }
    if (result.failedOrderIds.isNotEmpty) return AppColors.errorRed;
    return AppColors.success;
  }
}
