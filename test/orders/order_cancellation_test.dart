import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/core/localization/generated/app_localizations.dart';
import 'package:farm2fork_mobile/features/auth/data/models/auth_user.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/orders/data/models/order.dart';
import 'package:farm2fork_mobile/features/orders/data/repositories/mock_orders_repository.dart';
import 'package:farm2fork_mobile/features/orders/data/repositories/orders_repository_provider.dart';
import 'package:farm2fork_mobile/features/orders/presentation/screens/orders_screen.dart';

class _BuyerAuth extends AuthController {
  @override
  Future<AuthState> build() async => AuthState(
    status: AuthStatus.authenticated,
    user: const AuthUser(
      id: 'buyer-1',
      email: 'buyer@example.test',
      role: AppUserRole.buyer,
      isVerified: true,
      isActive: true,
    ),
  );
}

class _Orders extends MockOrdersRepository {
  bool fail = true;
  int calls = 0;
  Order order = Order(
    id: 'draft-1',
    buyerId: 'buyer-1',
    farmerId: 'farmer-1',
    items: [],
    totalAmount: 100,
    platformFeePercent: 5,
    platformFeeAmount: 5,
    grandTotal: 105,
    shippingAddress: const OrderAddress(
      street: 'Test street',
      city: 'Lahore',
      province: 'Punjab',
    ),
    status: OrderStatus.pending,
    canCancel: true,
    createdAt: DateTime(2026, 10, 14),
    updatedAt: DateTime(2026, 10, 14),
  );
  @override
  Future<List<Order>> getOrdersByUser({
    required String userId,
    required AppUserRole role,
  }) async => [order];
  @override
  Future<Order> updateOrderStatus(String id, OrderStatus status) async {
    calls++;
    if (fail) throw StateError('Order changed');
    return order = order.copyWith(status: status, canCancel: false);
  }
}

void main() {
  testWidgets(
    'unpaid cancellation confirms, preserves failure and moves the saved order to history',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = _Orders();
      final router = GoRouter(
        routes: [GoRoute(path: "/", builder: (_, _) => const OrdersScreen())],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(_BuyerAuth.new),
            ordersRepositoryProvider.overrideWithValue(repo),
          ],
          child: ScreenUtilInit(
            designSize: const Size(360, 690),
            builder: (_, _) => MaterialApp.router(
              routerConfig: router,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(OrdersScreen)),
      );
      await tester.tap(find.text(l10n.cancelUnpaidOrder));
      await tester.pumpAndSettle();
      expect(repo.calls, 0);
      await tester.tap(find.text(l10n.cancelUnpaidOrder).last);
      await tester.pumpAndSettle();
      expect(repo.calls, 1);
      expect(find.text(l10n.orderCancelFailed), findsOneWidget);
      expect(find.text(l10n.orderStatusPending), findsOneWidget);
      ScaffoldMessenger.of(
        tester.element(find.byType(OrdersScreen)),
      ).hideCurrentSnackBar();
      await tester.pumpAndSettle();
      repo.fail = false;
      await tester.tap(find.text(l10n.cancelUnpaidOrder));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.cancelUnpaidOrder).last);
      await tester.pumpAndSettle();
      expect(repo.calls, 2);
      await tester.tap(find.text(l10n.ordersTabCompleted));
      await tester.pumpAndSettle();
      expect(find.text(l10n.orderStatusCancelled), findsWidgets);
      expect(find.text(l10n.cancelUnpaidOrder), findsNothing);
    },
  );
}
