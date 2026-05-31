import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Farm2Fork/features/marketplace/presentation/screens/marketplace_screen.dart';
import 'package:Farm2Fork/features/cart/presentation/screens/cart_screen.dart';
import 'package:Farm2Fork/features/orders/presentation/screens/orders_screen.dart';
import 'package:Farm2Fork/features/profile/presentation/screens/profile_screen.dart';
import 'package:Farm2Fork/core/localization/l10n_extension.dart';
import 'package:Farm2Fork/core/theme/app_colors.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/marketplace',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNestedNavigation(navigationShell: navigationShell);
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

class ScaffoldWithNestedNavigation extends StatelessWidget {
  const ScaffoldWithNestedNavigation({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.textDark.withValues(alpha: 0.6),
        backgroundColor: AppColors.white,
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.store),
            label: context.l10n.navHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_cart),
            label: context.l10n.navCart,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long),
            label: context.l10n.navOrders,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: context.l10n.navProfile,
          ),
        ],
        onTap: _goBranch,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
