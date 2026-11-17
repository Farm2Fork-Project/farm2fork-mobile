import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/location/geo_point.dart';
import 'package:farm2fork_mobile/core/maps/location_picker_screen.dart';
import 'package:farm2fork_mobile/features/farm_location/presentation/city_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../support/harness.dart' show pickCity, testLocationsOverride;
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
        overrides: [
          ordersRepositoryProvider.overrideWithValue(repo),
          testLocationsOverride,
        ],
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
      final router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, _) => const CheckoutScreen()),
          GoRoute(
            path: LocationPickerScreen.route,
            builder: (context, _) => Scaffold(
              body: TextButton(
                onPressed: () => context.pop(const GeoPoint(31.5204, 74.3587)),
                child: const Text('Select test pin'),
              ),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: ScreenUtilInit(
            designSize: const Size(390, 844),
            builder: (_, _) => MaterialApp.router(
              routerConfig: router,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await _enter(tester, 'Street Address', 'Mall road');
      await pickCity(tester, find.byType(CityPickerField), 'Punjab', 'Lahore');
      await tester.tap(find.text('Get delivery quote'));
      await tester.pumpAndSettle();
      expect(repo.addresses, isEmpty);
      await tester.ensureVisible(find.text('Pin drop-off on map'));
      await tester.tap(find.text('Pin drop-off on map'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Select test pin'));
      await tester.pumpAndSettle();
      expect(repo.addresses.single.lat, 31.5204);
      expect(repo.created, 0);
      expect(find.text('Get delivery quote'), findsNothing);
      await pickCity(tester, find.byType(CityPickerField), 'Punjab', 'Multan');
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
    'farmer loads and saves a complete pickup pin from pickers only',
    (tester) async {
      final farm = _Farm();
      final router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, _) => const FarmLocationScreen()),
          GoRoute(
            path: LocationPickerScreen.route,
            builder: (context, _) => Scaffold(
              body: TextButton(
                onPressed: () => context.pop(const GeoPoint(31.5304, 74.3587)),
                child: const Text('Select test pin'),
              ),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            farmLocationServiceProvider.overrideWithValue(farm),
            testLocationsOverride,
          ],
          child: ScreenUtilInit(
            designSize: const Size(390, 844),
            builder: (_, _) => MaterialApp.router(
              routerConfig: router,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Lahore, Punjab'), findsOneWidget);
      expect(find.text('Latitude'), findsNothing);
      expect(find.text('Longitude'), findsNothing);
      await tester.ensureVisible(find.text('Change'));
      await tester.tap(find.text('Change'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Select test pin'));
      await tester.pumpAndSettle();
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
