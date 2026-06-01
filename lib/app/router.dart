import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/features/auth/data/models/auth_user.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/auth/presentation/screens/buyer_signup_screen.dart';
import 'package:farm2fork_mobile/features/auth/presentation/screens/farmer_signup_screen.dart';
import 'package:farm2fork_mobile/features/auth/presentation/screens/guest_account_screen.dart';
import 'package:farm2fork_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:farm2fork_mobile/features/auth/presentation/screens/signup_screen.dart';
import 'package:farm2fork_mobile/features/auth/presentation/screens/transporter_signup_screen.dart';
import 'package:farm2fork_mobile/features/auth/presentation/widgets/auth_required_screen.dart';
import 'package:farm2fork_mobile/features/cart/presentation/screens/cart_screen.dart';
import 'package:farm2fork_mobile/features/feed/presentation/screens/feed_screen.dart';
import 'package:farm2fork_mobile/features/finance/presentation/screens/loans_screen.dart';
import 'package:farm2fork_mobile/features/listings/presentation/screens/create_listing_screen.dart';
import 'package:farm2fork_mobile/features/listings/presentation/screens/listings_screen.dart';
import 'package:farm2fork_mobile/features/marketplace/presentation/screens/marketplace_screen.dart';
import 'package:farm2fork_mobile/features/marketplace/presentation/screens/product_detail_screen.dart';
import 'package:farm2fork_mobile/features/orders/presentation/screens/orders_screen.dart';
import 'package:farm2fork_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:farm2fork_mobile/features/shipments/presentation/screens/shipments_screen.dart';
import 'package:farm2fork_mobile/features/traceability/presentation/screens/trace_scanner_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final _routerRefreshProvider = Provider<Listenable>((ref) {
  final notifier = ValueNotifier<int>(0);
  ref.listen(authControllerProvider, (_, _) => notifier.value++);
  ref.onDispose(notifier.dispose);
  return notifier;
});

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppNavConfig.guestHomeRoute,
    refreshListenable: ref.watch(_routerRefreshProvider),
    redirect: (context, state) {
      final authAsync = ref.read(authControllerProvider);
      final authState = authAsync.asData?.value;
      final status = authState?.status ?? AuthStatus.guest;

      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final isGuestRoute = state.matchedLocation.startsWith('/guest');

      if (status == AuthStatus.loadingSession || authAsync.isLoading) {
        return null;
      }

      if (status == AuthStatus.authenticated) {
        if (authState?.role == AppUserRole.admin) {
          return AppNavConfig.guestHomeRoute;
        }
        if (isAuthRoute || isGuestRoute) {
          return AppNavConfig.homeRouteForRole(authState!.role!);
        }
        if (!AppNavConfig.canAccessRouteForRole(
          role: authState!.role!,
          location: state.matchedLocation,
        )) {
          return AppNavConfig.homeRouteForRole(authState.role!);
        }
        return null;
      }

      // guest / unauthenticated / sessionExpired → guest shell
      if (!AppNavConfig.isPublicRoute(state.matchedLocation)) {
        return AppNavConfig.guestHomeRoute;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/auth/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/signup',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const SignupScreen(),
        routes: [
          GoRoute(path: 'buyer', builder: (_, _) => const BuyerSignupScreen()),
          GoRoute(
            path: 'farmer',
            builder: (_, _) => const FarmerSignupScreen(),
          ),
          GoRoute(
            path: 'transporter',
            builder: (_, _) => const TransporterSignupScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/marketplace/products/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProductDetailScreen(productId: id);
        },
      ),
      _guestShell(),
      _roleShell(AppUserRole.buyer),
      _roleShell(AppUserRole.farmer),
      _roleShell(AppUserRole.transporter),
      _roleShell(AppUserRole.financialPartner),
    ],
  );
});

// ── Guest shell ──────────────────────────────────────────────────────────────

StatefulShellRoute _guestShell() {
  final navItems = AppNavConfig.forGuest();
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) =>
        GuestTabShell(navigationShell: navigationShell),
    branches: [
      for (final item in navItems)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: item.route,
              builder: (_, _) => _guestScreenFor(item.destination),
            ),
          ],
        ),
    ],
  );
}

Widget _guestScreenFor(AppNavDestination destination) {
  return switch (destination) {
    AppNavDestination.marketplace => const MarketplaceScreen(),
    AppNavDestination.trace => const TraceScannerScreen(),
    AppNavDestination.cart => const AuthRequiredScreen(),
    AppNavDestination.profile => const GuestAccountScreen(),
    _ => const SizedBox.shrink(),
  };
}

// ── Role shells ──────────────────────────────────────────────────────────────

StatefulShellRoute _roleShell(AppUserRole role) {
  final navItems = AppNavConfig.forRole(role);
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) =>
        Farm2ForkTabShell(navigationShell: navigationShell, role: role),
    branches: [
      for (final item in navItems)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: item.route,
              builder: (_, _) => _screenFor(item.destination),
            ),
          ],
        ),
    ],
  );
}

Widget _screenFor(AppNavDestination destination) {
  return switch (destination) {
    AppNavDestination.marketplace => const MarketplaceScreen(),
    AppNavDestination.listings => const ListingsScreen(),
    AppNavDestination.createListing => const CreateListingScreen(),
    AppNavDestination.trace => const TraceScannerScreen(),
    AppNavDestination.cart => const CartScreen(),
    AppNavDestination.orders => const OrdersScreen(),
    AppNavDestination.shipments => const ShipmentsScreen(),
    AppNavDestination.loans => const LoansScreen(),
    AppNavDestination.feed => const FeedScreen(),
    AppNavDestination.profile => const ProfileScreen(),
  };
}

// ── Tab shell widgets ─────────────────────────────────────────────────────────

class GuestTabShell extends ConsumerStatefulWidget {
  const GuestTabShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<GuestTabShell> createState() => _GuestTabShellState();
}

class _GuestTabShellState extends ConsumerState<GuestTabShell> {
  @override
  void initState() {
    super.initState();
    ref.listenManual(authControllerProvider, (previous, next) {
      final status = next.asData?.value.status;
      if (status == AuthStatus.sessionExpired && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.sessionExpiredMessage)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => _buildTabView(
    context,
    navigationShell: widget.navigationShell,
    navItems: AppNavConfig.forGuest(),
  );
}

class Farm2ForkTabShell extends StatelessWidget {
  const Farm2ForkTabShell({
    super.key,
    required this.navigationShell,
    required this.role,
  });

  final StatefulNavigationShell navigationShell;
  final AppUserRole role;

  @override
  Widget build(BuildContext context) => _buildTabView(
    context,
    navigationShell: navigationShell,
    navItems: AppNavConfig.forRole(role),
  );
}

Widget _buildTabView(
  BuildContext context, {
  required StatefulNavigationShell navigationShell,
  required List<AppNavItem> navItems,
}) {
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
    navBarBuilder: (navBarConfig) => Style2BottomNavBar(
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
