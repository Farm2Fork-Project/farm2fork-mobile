import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/features/cart/presentation/screens/cart_screen.dart';
import 'package:farm2fork_mobile/features/marketplace/presentation/screens/marketplace_screen.dart';
import 'package:farm2fork_mobile/features/marketplace/presentation/screens/product_detail_screen.dart';
import 'package:farm2fork_mobile/features/orders/presentation/screens/orders_screen.dart';
import 'package:farm2fork_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:farm2fork_mobile/features/traceability/presentation/screens/trace_scanner_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

const _activeRoleUntilAuth = AppUserRole.buyer;

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/marketplace',
  routes: [
    GoRoute(
      path: '/marketplace/products/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ProductDetailScreen(productId: id);
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return Farm2ForkTabShell(
          navigationShell: navigationShell,
          role: _activeRoleUntilAuth,
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/marketplace',
              builder: (context, state) => const MarketplaceScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/trace',
              builder: (context, state) => const TraceScannerScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/cart',
              builder: (context, state) => const CartScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/orders',
              builder: (context, state) => const OrdersScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class Farm2ForkTabShell extends StatelessWidget {
  const Farm2ForkTabShell({
    super.key,
    required this.navigationShell,
    required this.role,
  });

  final StatefulNavigationShell navigationShell;
  final AppUserRole role;

  @override
  Widget build(BuildContext context) {
    final navItems = AppNavConfig.forRole(role);

    return PersistentTabView.router(
      navigationShell: navigationShell,
      tabs: [
        for (final item in navItems)
          PersistentRouterTabConfig(
            item: ItemConfig(
              icon: Icon(item.icon),
              title: item.labelBuilder(context),
              activeForegroundColor: AppColors.primaryGreenDark,
              inactiveForegroundColor: AppColors.textMuted,
              textStyle: AppTextStyles.label,
              iconSize: 24,
            ),
          ),
      ],
      navBarBuilder: (navBarConfig) => Style16BottomNavBar(
        navBarConfig: navBarConfig,
        navBarDecoration: NavBarDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, -8),
            ),
          ],
        ),
      ),
    );
  }
}
