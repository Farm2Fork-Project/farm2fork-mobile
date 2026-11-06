import 'package:farm2fork_mobile/core/localization/generated/app_localizations.dart';
import 'package:farm2fork_mobile/core/location/geo_point.dart';
import 'package:farm2fork_mobile/core/maps/app_map.dart';
import 'package:farm2fork_mobile/features/shipments/data/models/shipment.dart';
import 'package:farm2fork_mobile/features/shipments/presentation/widgets/delivery_live_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Shipment _shipment({double? lat, double? lng, DateTime? at}) => Shipment(
  id: 's1',
  orderId: 'o1',
  transporterId: 't1',
  status: ShipmentStatus.inTransit,
  pickupAddress: const ShipmentAddress(
    street: 'Green Farm',
    city: 'Faisalabad',
    province: 'Punjab',
    lat: 31.41,
    lng: 73.08,
  ),
  deliveryAddress: const ShipmentAddress(
    street: 'Market Road',
    city: 'Lahore',
    province: 'Punjab',
    lat: 31.52,
    lng: 74.35,
  ),
  statusHistory: const [],
  transporterLat: lat,
  transporterLng: lng,
  transporterLocationAt: at,
  createdAt: DateTime(2026, 10, 22),
  updatedAt: DateTime(2026, 10, 22),
);

Future<List<AppMapConfig>> _pump(WidgetTester tester, Widget child) async {
  final configs = <AppMapConfig>[];
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appMapBuilderProvider.overrideWithValue((config) {
          configs.add(config);
          return const SizedBox.expand();
        }),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (_, _) => MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return configs;
}

void main() {
  final now = DateTime(2026, 10, 22, 12);

  testWidgets('buyer sees the transporter and their drop-off with its age', (
    tester,
  ) async {
    final configs = await _pump(
      tester,
      DeliveryLiveMap(
        shipment: _shipment(
          lat: 31.45,
          lng: 74.0,
          at: now.subtract(const Duration(minutes: 6)),
        ),
        forFarmer: false,
        now: now,
      ),
    );
    final markers = configs.last.markers;
    expect(markers.map((m) => m.kind), [
      AppMarkerKind.dropoff,
      AppMarkerKind.transporter,
    ]);
    expect(markers.first.at.lng, 74.35);
    expect(configs.last.fitMarkers, isTrue);
    expect(
      find.text('Transporter position updated 6 min ago.'),
      findsOneWidget,
    );
  });

  testWidgets('farmer sees their pickup pin and waits for a position', (
    tester,
  ) async {
    final configs = await _pump(
      tester,
      DeliveryLiveMap(shipment: _shipment(), forFarmer: true, now: now),
    );
    expect(configs.last.markers.single.kind, AppMarkerKind.pickup);
    expect(configs.last.markers.single.at.lat, 31.41);
    expect(
      find.textContaining('appears here while their app is open'),
      findsOneWidget,
    );
  });

  testWidgets('maps without a key show a fallback with a Google Maps link', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [mapsConfiguredProvider.overrideWith((ref) async => false)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              height: 200,
              child: AppMap(config: AppMapConfig(center: _point)),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining("map isn't available"), findsOneWidget);
    expect(find.text('Open in Google Maps'), findsOneWidget);
  });
}

const _point = GeoPoint(31.5, 74.3);
