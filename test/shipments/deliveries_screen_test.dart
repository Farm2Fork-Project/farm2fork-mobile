import 'package:farm2fork_mobile/core/location/geo_point.dart';
import 'package:farm2fork_mobile/features/notifications/data/notifications_repository.dart';
import 'package:farm2fork_mobile/features/shipments/data/models/available_delivery.dart';
import 'package:farm2fork_mobile/features/shipments/data/models/shipment.dart';
import 'package:farm2fork_mobile/features/shipments/data/repositories/shipments_repository.dart';
import 'package:farm2fork_mobile/features/shipments/data/repositories/shipments_repository_provider.dart';
import 'package:farm2fork_mobile/features/shipments/presentation/screens/deliveries_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

class _Repo extends ShipmentsRepository {
  bool online = false;
  GeoPoint? location;
  Shipment? active;
  final declined = <String>[];

  AvailableDelivery _offer(String id, String farm) => AvailableDelivery(
    orderId: id,
    pickupCity: 'Sheikhupura',
    pickupProvince: 'Punjab',
    deliveryCity: 'Lahore',
    deliveryProvince: 'Punjab',
    itemCount: 1,
    createdAt: DateTime(2026, 9, 1),
    deliveryFee: 1150,
    deliveryDistanceKm: 39.7,
    distanceToPickupKm: 3.6,
    pickup: const GeoPoint(31.6, 74.05),
    dropoffArea: const GeoPoint(31.52, 74.36),
    farmName: farm,
    items: const [OfferItem(productName: 'Mangoes', quantity: 5)],
  );

  @override
  Future<TransporterStatus> getStatus() async => TransporterStatus(
    online: online,
    locationFresh: location != null,
    radiusKm: 25,
    activeShipmentId: active?.id,
  );

  @override
  Future<TransporterStatus> setAvailability({
    required bool online,
    GeoPoint? location,
  }) async {
    this.online = online;
    this.location = location ?? this.location;
    return getStatus();
  }

  @override
  Future<void> reportLocation(GeoPoint location) async {}

  @override
  Future<void> decline(String orderId) async => declined.add(orderId);

  @override
  Future<List<AvailableDelivery>> getAvailable() async => [
    _offer('o1', 'Smoke Farm'),
    _offer('o2', 'Ravi Fields'),
  ].where((o) => !declined.contains(o.orderId)).toList();

  @override
  Future<Shipment> claim(String orderId) async => active = Shipment(
    id: 'ship-1',
    orderId: orderId,
    transporterId: 't1',
    status: ShipmentStatus.assigned,
    pickupAddress: const ShipmentAddress(
      street: 'Chak 12, Canal Road',
      city: 'Sheikhupura',
      province: 'Punjab',
      lat: 31.6,
      lng: 74.05,
    ),
    deliveryAddress: const ShipmentAddress(
      street: '21 Market Road',
      city: 'Lahore',
      province: 'Punjab',
      lat: 31.52,
      lng: 74.35,
    ),
    statusHistory: const [],
    estimatedDelivery: DateTime(2026, 9, 3),
    createdAt: DateTime(2026, 9, 1),
    updatedAt: DateTime(2026, 9, 1),
    deliveryFee: 1150,
  );

  @override
  Future<Shipment> getById(String shipmentId) async => active!;

  @override
  Future<List<Shipment>> getMine() async => [?active];

  @override
  Future<Shipment> updateStatus({
    required String shipmentId,
    required ShipmentStatus status,
    required String note,
  }) async => active = active!.copyWith(status: status);
}

void main() {
  testWidgets(
    'go online, see priced offers, decline one, accept one, then drive it',
    (tester) async {
      final repo = _Repo();
      await pumpScreen(
        tester,
        const DeliveriesScreen(),
        overrides: [
          shipmentsRepositoryProvider.overrideWithValue(repo),
          notificationsRepositoryProvider.overrideWithValue(
            MockNotificationsRepository(),
          ),
        ],
      );

      expect(find.text("You're offline"), findsOneWidget);
      expect(find.textContaining('Turn on the switch above'), findsOneWidget);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(repo.location, testGps);
      expect(find.text("You're online"), findsOneWidget);
      expect(find.text('Rs 1,150'), findsNWidgets(2));
      expect(find.text('Smoke Farm (Sheikhupura) → Lahore'), findsOneWidget);
      expect(find.text('3.6 km to pickup · 39.7 km trip'), findsNWidgets(2));

      await tester.tap(find.text('Decline').last);
      await tester.pumpAndSettle();
      expect(repo.declined, ['o2']);
      expect(find.text('Ravi Fields (Sheikhupura) → Lahore'), findsNothing);

      await tester.tap(find.text('Accept'));
      await tester.pumpAndSettle();
      expect(find.text('Your current delivery'), findsOneWidget);
      expect(find.text('You earn Rs 1,150'), findsOneWidget);
      expect(find.text('Navigate to pickup'), findsOneWidget);
      // Full address only after accepting.
      expect(find.text('21 Market Road, Lahore, Punjab'), findsOneWidget);

      await tester.tap(find.text('Confirm crop pickup'));
      await tester.pumpAndSettle();
      expect(repo.active?.status, ShipmentStatus.pickedUp);
      expect(find.text('Navigate to drop-off'), findsOneWidget);

      // Unmount so the location heartbeat timer is cancelled.
      await tester.pumpWidget(const SizedBox());
    },
  );
}
