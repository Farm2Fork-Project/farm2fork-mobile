import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/core/localization/generated/app_localizations.dart';
import 'package:farm2fork_mobile/features/cart/presentation/providers/cart_controller.dart';
import 'package:farm2fork_mobile/features/cart/presentation/screens/checkout_screen.dart';
import 'package:farm2fork_mobile/features/listings/data/services/farm_location_service.dart';
import 'package:farm2fork_mobile/features/listings/presentation/screens/farm_location_screen.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product_category.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/farmer_summary.dart';
import 'package:farm2fork_mobile/features/orders/data/models/order.dart';
import 'package:farm2fork_mobile/features/orders/data/repositories/orders_repository.dart';
import 'package:farm2fork_mobile/features/orders/data/repositories/orders_repository_provider.dart';
import 'package:farm2fork_mobile/features/orders/data/repositories/mock_orders_repository.dart';

class _Orders extends MockOrdersRepository {
  final addresses = <OrderAddress>[];
  int created = 0;
  @override
  Future<OrderQuote> quoteOrder({
    required List<OrderLine> items,
    required OrderAddress shippingAddress,
  }) async {
    addresses.add(shippingAddress);
    return const OrderQuote(
      totalAmount: 200,
      platformFeePercent: 5,
      platformFeeAmount: 10,
      deliveryFee: 180,
      deliveryDistanceKm: 2.5,
      grandTotal: 390,
    );
  }

  @override
  Future<Order> createOrder({
    required List<OrderLine> items,
    required OrderAddress shippingAddress,
  }) async {
    created++;
    throw StateError('Fixture stops before navigation');
  }
}

class _Farm extends FarmLocationService {
  _Farm() : super(Dio());
  final saved = <Map<String, dynamic>>[];
  @override
  Future<Map<String, dynamic>> get() async => {
    'address': 'Farm road',
    'city': 'Lahore',
    'province': 'Punjab',
    'lat': 31.5204,
    'lng': 74.3587,
    'complete': true,
  };
  @override
  Future<Map<String, dynamic>> save(Map<String, dynamic> input) async {
    saved.add(input);
    return {...input, 'complete': true};
  }
}

Widget _app(Widget home) => ScreenUtilInit(
  designSize: const Size(390, 844),
  builder: (context, child) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  ),
);
Finder _field(String label) => find.byWidgetPredicate(
  (w) => w is TextField && w.decoration?.labelText == label,
);
Future<void> _enter(WidgetTester tester, String label, String value) async {
  final field = _field(label);
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await tester.pump();
}

void main() {
  testWidgets(
    'checkout validates pins, quotes without orders, and invalidates changed addresses and carts',
    (tester) async {
      final repo = _Orders();
      final container = ProviderContainer(
        overrides: [ordersRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      container
          .read(cartControllerProvider.notifier)
          .addItem(
            const Product(
              id: 'p',
              farmerId: 'f',
              name: 'Tomatoes',
              category: ProductCategory.vegetables,
              description: '',
              price: 100,
              quantity: 20,
              unit: ProductUnit.kg,
              farmer: FarmerSummary(
                id: 'f',
                name: 'Farmer',
                farmName: 'Farm',
                farmLocationAddress: '',
              ),
            ),
            quantity: 2,
          );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _app(const CheckoutScreen()),
        ),
      );
      await tester.pumpAndSettle();
      await _enter(tester, 'Street Address', 'Mall road');
      await _enter(tester, 'City', 'Lahore');
      await _enter(tester, 'Province', 'Punjab');
      await _enter(tester, 'Delivery latitude', '0');
      await _enter(tester, 'Delivery longitude', '74.3587');
      await tester.tap(find.text('Get delivery quote'));
      await tester.pumpAndSettle();
      expect(repo.addresses, isEmpty);
      await _enter(tester, 'Delivery latitude', '31.5204');
      await tester.tap(find.text('Get delivery quote'));
      await tester.pumpAndSettle();
      expect(repo.addresses.single.lat, 31.5204);
      expect(repo.created, 0);
      expect(find.text('Get delivery quote'), findsNothing);
      await _enter(tester, 'City', 'Multan');
      expect(find.text('Get delivery quote'), findsOneWidget);
      await tester.tap(find.text('Get delivery quote'));
      await tester.pumpAndSettle();
      expect(repo.addresses.last.city, 'Multan');
      container.read(cartControllerProvider.notifier).updateQuantity('p', 3);
      await tester.pumpAndSettle();
      expect(find.text('Get delivery quote'), findsOneWidget);
      expect(repo.created, 0);
    },
  );
  testWidgets(
    'farmer loads and saves a complete pickup pin and rejects invalid coordinates',
    (tester) async {
      final farm = _Farm();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [farmLocationServiceProvider.overrideWithValue(farm)],
          child: _app(const FarmLocationScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(_field('City'), findsOneWidget);
      expect(find.text('Punjab'), findsOneWidget);
      await _enter(tester, 'Latitude', '0');
      await tester.ensureVisible(find.text('Save pickup location'));
      await tester.tap(find.text('Save pickup location'));
      await tester.pumpAndSettle();
      expect(farm.saved, isEmpty);
      await _enter(tester, 'Latitude', '31.5304');
      await tester.ensureVisible(find.text('Save pickup location'));
      await tester.tap(find.text('Save pickup location'));
      await tester.pumpAndSettle();
      expect(farm.saved.single, {
        'address': 'Farm road',
        'city': 'Lahore',
        'province': 'Punjab',
        'lat': 31.5304,
        'lng': 74.3587,
      });
      expect(find.text('Pickup location saved.'), findsOneWidget);
    },
  );
}
