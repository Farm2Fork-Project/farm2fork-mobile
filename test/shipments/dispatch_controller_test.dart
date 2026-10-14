import 'package:farm2fork_mobile/core/location/geo_point.dart';
import 'package:farm2fork_mobile/core/location/location_service.dart';
import 'package:farm2fork_mobile/features/shipments/data/models/available_delivery.dart';
import 'package:farm2fork_mobile/features/shipments/data/models/shipment.dart';
import 'package:farm2fork_mobile/features/shipments/data/repositories/shipments_repository.dart';
import 'package:farm2fork_mobile/features/shipments/data/repositories/shipments_repository_provider.dart';
import 'package:farm2fork_mobile/features/shipments/presentation/providers/dispatch_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _here = GeoPoint(31.44, 73.12);

AvailableDelivery _offer(String orderId) => AvailableDelivery(
  orderId: orderId,
  pickupCity: 'Faisalabad',
  pickupProvince: 'Punjab',
  deliveryCity: 'Lahore',
  deliveryProvince: 'Punjab',
  itemCount: 1,
  createdAt: DateTime(2026, 9, 1),
  deliveryFee: 1270,
  deliveryDistanceKm: 44.6,
  distanceToPickupKm: 4.1,
  pickup: const GeoPoint(31.42, 73.08),
  dropoffArea: const GeoPoint(31.52, 74.36),
);

Shipment _shipment(String orderId) => Shipment(
  id: 'shipment-1',
  orderId: orderId,
  transporterId: 'transporter-1',
  status: ShipmentStatus.assigned,
  pickupAddress: const ShipmentAddress(
    street: 'Green Farm',
    city: 'Faisalabad',
    province: 'Punjab',
    lat: 31.42,
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
  estimatedDelivery: DateTime(2026, 9, 3),
  createdAt: DateTime(2026, 9, 1),
  updatedAt: DateTime(2026, 9, 1),
  deliveryFee: 1270,
);

class _Repo extends ShipmentsRepository {
  bool online = false;
  GeoPoint? sentLocation;
  Shipment? active;
  final declined = <String>[];
  var offers = [_offer('order-1'), _offer('order-2')];

  @override
  Future<TransporterStatus> getStatus() async => TransporterStatus(
    online: online,
    locationFresh: sentLocation != null,
    radiusKm: 25,
    activeShipmentId: active?.id,
  );

  @override
  Future<TransporterStatus> setAvailability({
    required bool online,
    GeoPoint? location,
  }) async {
    this.online = online;
    sentLocation = location ?? sentLocation;
    return getStatus();
  }

  @override
  Future<void> reportLocation(GeoPoint location) async =>
      sentLocation = location;

  @override
  Future<void> decline(String orderId) async => declined.add(orderId);

  @override
  Future<List<AvailableDelivery>> getAvailable() async =>
      offers.where((o) => !declined.contains(o.orderId)).toList();

  @override
  Future<Shipment> claim(String orderId) async {
    offers = [];
    return active = _shipment(orderId);
  }

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

class _FakeLocation implements LocationService {
  _FakeLocation({this.failure});

  final LocationFailure? failure;

  @override
  Future<GeoPoint> current() async {
    if (failure != null) throw LocationException(failure!);
    return _here;
  }

  @override
  Stream<GeoPoint> watch({int distanceFilterMeters = 200}) =>
      const Stream.empty();

  @override
  Future<void> openSettingsFor(LocationFailure failure) async {}
}

ProviderContainer _container(_Repo repo, {LocationFailure? failure}) {
  final container = ProviderContainer(
    overrides: [
      shipmentsRepositoryProvider.overrideWithValue(repo),
      locationServiceProvider.overrideWithValue(
        _FakeLocation(failure: failure),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test(
    'offline transporters see no offers; going online sends the location',
    () async {
      final repo = _Repo();
      final container = _container(repo);

      final offline = await container.read(dispatchControllerProvider.future);
      expect(offline.status.online, isFalse);
      expect(offline.offers, isEmpty);

      await container.read(dispatchControllerProvider.notifier).goOnline();

      final online = container.read(dispatchControllerProvider).requireValue;
      expect(repo.sentLocation, _here);
      expect(online.offers.map((o) => o.orderId), ['order-1', 'order-2']);
    },
  );

  test('a denied location permission keeps the transporter offline', () async {
    final repo = _Repo();
    final container = _container(repo, failure: LocationFailure.deniedForever);
    await container.read(dispatchControllerProvider.future);

    await expectLater(
      container.read(dispatchControllerProvider.notifier).goOnline(),
      throwsA(isA<LocationException>()),
    );
    expect(repo.online, isFalse);
  });

  test('declining hides the offer immediately and tells the server', () async {
    final repo = _Repo()..online = true;
    final container = _container(repo);
    await container.read(dispatchControllerProvider.future);

    await container
        .read(dispatchControllerProvider.notifier)
        .decline('order-1');

    expect(repo.declined, ['order-1']);
    expect(
      container
          .read(dispatchControllerProvider)
          .requireValue
          .offers
          .map((o) => o.orderId),
      ['order-2'],
    );
  });

  test(
    'accepting turns the offer into the active delivery with no other offers',
    () async {
      final repo = _Repo()..online = true;
      final container = _container(repo);
      await container.read(dispatchControllerProvider.future);

      await container
          .read(dispatchControllerProvider.notifier)
          .accept('order-2');

      final state = container.read(dispatchControllerProvider).requireValue;
      expect(state.active?.orderId, 'order-2');
      expect(state.offers, isEmpty);

      await container
          .read(dispatchControllerProvider.notifier)
          .advance(
            shipmentId: 'shipment-1',
            status: ShipmentStatus.pickedUp,
            note: 'n',
          );
      expect(
        container.read(dispatchControllerProvider).requireValue.active?.status,
        ShipmentStatus.pickedUp,
      );
    },
  );
}
