import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/utils/number_formatters.dart';
import 'package:farm2fork_mobile/core/widgets/app_badge.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/core/widgets/app_icon_circle_button.dart';
import 'package:farm2fork_mobile/features/cart/data/models/cart_item.dart';
import 'package:farm2fork_mobile/features/cart/data/models/farmer_cart_group.dart';
import 'package:farm2fork_mobile/features/cart/presentation/providers/cart_controller.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/auth/presentation/widgets/auth_required_sheet.dart';
import 'package:farm2fork_mobile/features/marketplace/presentation/utils/product_l10n.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(farmerCartGroupsProvider);
    final grandTotal = ref.watch(cartGrandTotalProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(context.l10n.yourCart, style: AppTextStyles.h3),
        actions: [
          if (groups.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClearCart(context, ref),
              child: Text(
                context.l10n.clearCart,
                style: AppTextStyles.small.copyWith(
                  color: AppColors.errorRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: groups.isEmpty
          ? _EmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.pagePadding),
                    itemCount: groups.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.lg),
                    itemBuilder: (context, i) =>
                        _FarmerGroupCard(group: groups[i]),
                  ),
                ),

                // ── Overall Grand Total Banner ──────────────────────────
                if (groups.length > 1) _GrandTotalBanner(total: grandTotal),
              ],
            ),
    );
  }

  void _confirmClearCart(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.clearCartConfirmTitle, style: AppTextStyles.h3),
        content: Text(
          context.l10n.clearCartConfirmMessage,
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.l10n.cancel,
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(cartControllerProvider.notifier).clear();
              Navigator.pop(ctx);
            },
            child: Text(
              context.l10n.clearCart,
              style: const TextStyle(
                color: AppColors.errorRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Farmer Group Card ────────────────────────────────────────────────────────

class _FarmerGroupCard extends ConsumerWidget {
  const _FarmerGroupCard({required this.group});
  final FarmerCartGroup group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider).asData?.value;
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Farmer Header ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryGreenSoft,
                  child: Text(
                    group.farmerName.isNotEmpty
                        ? group.farmerName[0].toUpperCase()
                        : '?',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.farmerName,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        group.farmName,
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.textDark.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                AppBadge(
                  label: context.l10n.checkout,
                  icon: Icons.verified_outlined,
                  backgroundColor: AppColors.secondaryBlueSoft,
                  foregroundColor: AppColors.secondaryBlue,
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.surfaceMedium),

          // ── Items ──────────────────────────────────────────────────────
          ...group.items.map(
            (item) => _CartItemRow(
              item: item,
              onRemove: () => ref
                  .read(cartControllerProvider.notifier)
                  .removeItem(item.product.id),
              onDecrement: () => ref
                  .read(cartControllerProvider.notifier)
                  .updateQuantity(item.product.id, item.quantity - 1),
              onIncrement: () => ref
                  .read(cartControllerProvider.notifier)
                  .updateQuantity(item.product.id, item.quantity + 1),
            ),
          ),

          const Divider(height: 1, color: AppColors.surfaceMedium),

          // ── Price Summary ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                _PriceRow(
                  label: context.l10n.subtotal,
                  amount: group.itemsSubtotal,
                ),
                const SizedBox(height: AppSpacing.xs),
                _PriceRow(
                  label: context.l10n.platformFeeWithPercent(
                    formatCompactNumber(
                      group.platformFeePercent,
                      Localizations.localeOf(context),
                    ),
                  ),
                  amount: group.platformFee,
                  labelColor: AppColors.textDark.withValues(alpha: 0.6),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Divider(color: AppColors.surfaceMedium),
                ),
                _PriceRow(
                  label: context.l10n.grandTotal,
                  amount: group.grandTotal,
                  isBold: true,
                  labelColor: AppColors.primaryGreen,
                  amountColor: AppColors.primaryGreen,
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Checkout Button ────────────────────────────────────────
                AppButton(
                  label: context.l10n.checkout,
                  icon: Icons.lock_outline_rounded,
                  expand: true,
                  onPressed: () {
                    if (authState?.isAuthenticated != true) {
                      showAuthRequiredSheet(
                        context,
                        title: context.l10n.loginRequired,
                        message: context.l10n.loginToCheckout,
                        icon: Icons.lock_outline_rounded,
                      );
                      return;
                    }
                    context.push('/checkout?farmerId=${group.farmerId}');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Cart Item Row ────────────────────────────────────────────────────────────

class _CartItemRow extends StatelessWidget {
  const _CartItemRow({
    required this.item,
    required this.onRemove,
    required this.onDecrement,
    required this.onIncrement,
  });

  final CartItem item;
  final VoidCallback onRemove;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          // Product icon placeholder
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryGreenSoft,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.eco_rounded,
              color: AppColors.primaryGreen,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Name + price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: AppTextStyles.small.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  context.l10n.priceAmountWithUnit(
                    formatCurrencyAmount(item.product.price, locale),
                    productUnitLabel(context, item.product.unit),
                  ),
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Quantity controls
          Row(
            children: [
              AppIconCircleButton(
                icon: Icons.remove_rounded,
                onTap: onDecrement,
                enabled: item.quantity > 1,
                visibleSize: 26,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text(
                  '${item.quantity}',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              AppIconCircleButton(
                icon: Icons.add_rounded,
                onTap: onIncrement,
                visibleSize: 26,
              ),
            ],
          ),

          // Remove button
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.errorRed,
              size: 20,
            ),
            onPressed: () {
              onRemove();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    context.l10n.itemRemoved,
                    style: AppTextStyles.small.copyWith(color: AppColors.white),
                  ),
                  backgroundColor: AppColors.errorRed,
                  duration: const Duration(milliseconds: 800),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Price Row ────────────────────────────────────────────────────────────────

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.amount,
    this.isBold = false,
    this.labelColor,
    this.amountColor,
  });

  final String label;
  final double amount;
  final bool isBold;
  final Color? labelColor;
  final Color? amountColor;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final style = isBold
        ? AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)
        : AppTextStyles.small;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: style.copyWith(color: labelColor ?? AppColors.textDark),
        ),
        Text(
          context.l10n.currencyAmount(formatCurrencyAmount(amount, locale)),
          style: style.copyWith(color: amountColor ?? AppColors.textDark),
        ),
      ],
    );
  }
}

// ─── Grand Total Banner (multi-farmer) ───────────────────────────────────────

class _GrandTotalBanner extends StatelessWidget {
  const _GrandTotalBanner({required this.total});
  final double total;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: const Border(top: BorderSide(color: AppColors.surfaceMedium)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.l10n.grandTotal,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(
            context.l10n.currencyAmount(formatCurrencyAmount(total, locale)),
            style: AppTextStyles.h3.copyWith(color: AppColors.primaryGreenDark),
          ),
        ],
      ),
    );
  }
}

// ─── Empty Cart ───────────────────────────────────────────────────────────────

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 88,
              color: AppColors.primaryGreen.withValues(alpha: 0.45),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              context.l10n.cartEmpty,
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.l10n.cartEmptySubtitle,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textDark.withValues(alpha: 0.55),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: context.l10n.shopNow,
              icon: Icons.store_rounded,
              onPressed: () => context.go(
                AppNavConfig.routeFor(
                  AppUserRole.buyer,
                  AppNavDestination.marketplace,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
