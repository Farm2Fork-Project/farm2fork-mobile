import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_badge.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/orders/data/models/order.dart';
import 'package:farm2fork_mobile/features/orders/presentation/providers/orders_controller.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersControllerProvider);
    final userRole = ref.watch(authControllerProvider).asData?.value.user?.role;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: Text(context.l10n.orders, style: AppTextStyles.h2),
          elevation: 0,
          backgroundColor: AppColors.backgroundLight,
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: AppColors.primaryGreen,
            labelColor: AppColors.primaryGreen,
            unselectedLabelColor: AppColors.textMuted,
            labelStyle: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: AppTextStyles.body,
            tabs: const [
              Tab(text: 'Active'), // Will localize or keep simple
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: SafeArea(
          child: ordersAsync.when(
            data: (orders) {
              if (orders.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 64,
                          color: AppColors.textMuted.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          context.l10n.noDataFound,
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final activeOrders = orders
                  .where(
                    (o) =>
                        o.status == OrderStatus.pending ||
                        o.status == OrderStatus.paid ||
                        o.status == OrderStatus.processing ||
                        o.status == OrderStatus.shipped,
                  )
                  .toList();

              final completedOrders = orders
                  .where(
                    (o) =>
                        o.status == OrderStatus.delivered ||
                        o.status == OrderStatus.cancelled,
                  )
                  .toList();

              return TabBarView(
                children: [
                  _OrdersList(orders: activeOrders, role: userRole),
                  _OrdersList(orders: completedOrders, role: userRole),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            ),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.errorRed,
                    size: 48,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(context.l10n.errorOccurred, style: AppTextStyles.body),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () => ref
                        .read(ordersControllerProvider.notifier)
                        .fetchOrders(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                    ),
                    child: Text(
                      context.l10n.retry,
                      style: const TextStyle(color: AppColors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  const _OrdersList({required this.orders, required this.role});
  final List<Order> orders;
  final dynamic role; // AppUserRole

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Text(
            context.l10n.noDataFound,
            style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _OrderCard(order: order, role: role),
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.role});
  final Order order;
  final dynamic role; // AppUserRole

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (order.status) {
      OrderStatus.pending => AppColors.accentYellow,
      OrderStatus.paid || OrderStatus.processing => AppColors.secondaryBlue,
      OrderStatus.shipped => AppColors.primaryGreen,
      OrderStatus.delivered => AppColors.success,
      OrderStatus.cancelled => AppColors.errorRed,
    };

    final statusText = switch (order.status) {
      OrderStatus.pending => 'Pending',
      OrderStatus.paid => 'Paid',
      OrderStatus.processing => 'Processing',
      OrderStatus.shipped => 'Shipped',
      OrderStatus.delivered => 'Delivered',
      OrderStatus.cancelled => 'Cancelled',
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: ID and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.id}',
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreenDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(order.createdAt),
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              AppBadge(
                label: statusText,
                backgroundColor: statusColor.withValues(alpha: 0.12),
                foregroundColor: statusColor,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.surfaceMedium, height: 1),
          const SizedBox(height: AppSpacing.md),

          // Items listing
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            itemBuilder: (context, idx) {
              final item = order.items[idx];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.body,
                          children: [
                            TextSpan(
                              text: item.productName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: '  x ${item.quantity} ${item.unit}',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      context.l10n.currencyAmount(
                        item.subtotal.toStringAsFixed(0),
                      ),
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(color: AppColors.surfaceMedium, height: 1),
          const SizedBox(height: AppSpacing.md),

          // Totals
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.subtotal,
                style: AppTextStyles.small.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                context.l10n.currencyAmount(
                  order.totalAmount.toStringAsFixed(0),
                ),
                style: AppTextStyles.small.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.platformFeeWithPercent(
                  order.platformFeePercent.toStringAsFixed(0),
                ),
                style: AppTextStyles.small.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                context.l10n.currencyAmount(
                  order.platformFeeAmount.toStringAsFixed(0),
                ),
                style: AppTextStyles.small.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.grandTotal,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                context.l10n.currencyAmount(
                  order.grandTotal.toStringAsFixed(0),
                ),
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.primaryGreenDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          // Role-specific fields
          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.surfaceMedium, height: 1),
          const SizedBox(height: AppSpacing.md),
          _buildRoleSpecificDetails(context),
        ],
      ),
    );
  }

  Widget _buildRoleSpecificDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.location_on_rounded,
              size: 16,
              color: AppColors.primaryGreen,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.location,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${order.shippingAddress.street}, ${order.shippingAddress.city}, ${order.shippingAddress.province}',
                    style: AppTextStyles.small,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
