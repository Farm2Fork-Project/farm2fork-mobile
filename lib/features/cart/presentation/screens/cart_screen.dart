import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Farm2Fork/core/theme/app_colors.dart';
import 'package:Farm2Fork/core/theme/app_sizes.dart';
import 'package:Farm2Fork/core/theme/app_typography.dart';
import 'package:Farm2Fork/core/localization/l10n_extension.dart';
import 'package:Farm2Fork/features/cart/data/models/farmer_cart_group.dart';
import 'package:Farm2Fork/features/cart/data/models/cart_item.dart';
import 'package:Farm2Fork/features/cart/presentation/providers/cart_controller.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(farmerCartGroupsProvider);
    final grandTotal = ref.watch(cartGrandTotalProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          context.l10n.yourCart,
          style: AppTextStyles.h2.copyWith(color: AppColors.primaryGreen),
        ),
        actions: [
          if (groups.isNotEmpty)
            TextButton(
              onPressed: () => ref.read(cartControllerProvider.notifier).clear(),
              child: Text(
                context.l10n.removeItem,
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
                    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
                    itemBuilder: (context, i) => _FarmerGroupCard(group: groups[i]),
                  ),
                ),

                // ── Overall Grand Total Banner ──────────────────────────
                if (groups.length > 1) _GrandTotalBanner(total: grandTotal),
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                  backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.15),
                  child: Text(
                    group.farmerName.isNotEmpty ? group.farmerName[0].toUpperCase() : '?',
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
                        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
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
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.surfaceMedium),

          // ── Items ──────────────────────────────────────────────────────
          ...group.items.map(
            (item) => _CartItemRow(
              item: item,
              onRemove: () => ref.read(cartControllerProvider.notifier).removeItem(item.product.id),
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
                _PriceRow(label: context.l10n.subtotal, amount: group.itemsSubtotal),
                const SizedBox(height: AppSpacing.xs),
                _PriceRow(
                  label: context.l10n.platformFee,
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Placeholder: real checkout will navigate to payment flow
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${context.l10n.checkout} — ${group.farmerName}',
                            style: AppTextStyles.small.copyWith(color: AppColors.white),
                          ),
                          backgroundColor: AppColors.secondaryBlue,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      textStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                    ),
                    child: Text(context.l10n.checkout),
                  ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          // Product icon placeholder
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(Icons.eco_rounded, color: AppColors.primaryGreen, size: 28),
          ),
          const SizedBox(width: AppSpacing.md),

          // Name + price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: AppTextStyles.small.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'PKR ${item.product.pricePerUnit.toStringAsFixed(0)}/${item.product.unit}',
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textDark.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),

          // Quantity controls
          Row(
            children: [
              _SmallQBtn(
                icon: Icons.remove_rounded,
                onTap: onDecrement,
                enabled: item.quantity > 1,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text(
                  '${item.quantity}',
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              _SmallQBtn(icon: Icons.add_rounded, onTap: onIncrement, enabled: true),
            ],
          ),

          const SizedBox(width: AppSpacing.sm),

          // Remove button
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.errorRed, size: 20),
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
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _SmallQBtn extends StatelessWidget {
  const _SmallQBtn({required this.icon, required this.onTap, required this.enabled});
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled
                ? AppColors.primaryGreen.withValues(alpha: 0.5)
                : AppColors.surfaceMedium,
          ),
        ),
        child: Icon(
          icon,
          size: 14,
          color: enabled ? AppColors.primaryGreen : AppColors.textDark.withValues(alpha: 0.3),
        ),
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
    final style = isBold
        ? AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)
        : AppTextStyles.small;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style.copyWith(color: labelColor ?? AppColors.textDark)),
        Text(
          'PKR ${amount.toStringAsFixed(2)}',
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.surfaceMedium)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.l10n.grandTotal,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(
            'PKR ${total.toStringAsFixed(2)}',
            style: AppTextStyles.h2.copyWith(color: AppColors.primaryGreen),
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
              color: AppColors.primaryGreen.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(context.l10n.cartEmpty, style: AppTextStyles.h2, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.l10n.cartEmptySubtitle,
              style: AppTextStyles.body.copyWith(color: AppColors.textDark.withValues(alpha: 0.55)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            ElevatedButton.icon(
              onPressed: () => context.go('/marketplace'),
              icon: const Icon(Icons.store_rounded),
              label: Text(context.l10n.shopNow),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.lg,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                textStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
