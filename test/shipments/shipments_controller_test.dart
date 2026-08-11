import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/features/auth/data/models/auth_user.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/shipments/data/models/available_delivery.dart';
import 'package:farm2fork_mobile/features/shipments/data/models/shipment.dart';
import 'package:farm2fork_mobile/features/shipments/data/repositories/shipments_repository.dart';
import 'package:farm2fork_mobile/features/shipments/data/repositories/shipments_repository_provider.dart';
import 'package:farm2fork_mobile/features/shipments/presentation/providers/shipments_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestAuthController extends AuthController {
  @override
  Future<AuthState> build() async => AuthState(
    status: AuthStatus.authenticated,
    user: const AuthUser(
      id: 'transporter-1',
      email: 'transporter@example.com',
      role: AppUserRole.transporter,
      isVerified: true,
      isActive: true,
    ),
  );
}

class _RecordingShipmentsRepository extends ShipmentsRepository {
  final claimedOrderIds = <String>[];
  var available = <AvailableDelivery>[
    AvailableDelivery(
      orderId: 'order-1',
      pickupCity: 'Faisalabad',
      pickupProvince: 'Punjab',
      deliveryCity: 'Lahore',
      deliveryProvince: 'Punjab',
      itemCount: 2,
      createdAt: DateTime(2026, 8, 11),
    ),
  ];
  var mine = <Shipment>[];

  @override
  Future<Shipment> claim(String orderId) async {
    claimedOrderIds.add(orderId);
    available = [];
    final shipment = _shipment(orderId);
    mine = [shipment];
    return shipment;
  }

  @override
  Future<List<AvailableDelivery>> getAvailable() async => available;

  @override
  Future<Shipment> getById(String shipmentId) async => _shipment('order-1');

  @override
  Future<List<Shipment>> getMine() async => mine;

  @override
  Future<Shipment> updateStatus({
    required String shipmentId,
    required ShipmentStatus status,
    required String note,
  }) async => _shipment('order-1').copyWith(status: status);
}

Shipment _shipment(String orderId) => Shipment(
  id: 'shipment-1',
  orderId: orderId,
  transporterId: 'transporter-1',
  status: ShipmentStatus.assigned,
  pickupAddress: const ShipmentAddress(
    street: 'Green Farm',
    city: 'Faisalabad',
    province: 'Punjab',
  ),
  deliveryAddress: const ShipmentAddress(
    street: 'Market Road',
    city: 'Lahore',
    province: 'Punjab',
  ),
  statusHistory: [
    ShipmentStatusUpdate(
      status: ShipmentStatus.assigned,
      timestamp: DateTime(2026, 8, 11),
      note: 'Claimed',
      updatedBy: 'transporter-1',
    ),
  ],
  estimatedDelivery: DateTime(2026, 8, 13),
  createdAt: DateTime(2026, 8, 11),
  updatedAt: DateTime(2026, 8, 11),
);

void main() {
  test(
    'claim refreshes the transporter available and owned delivery lists',
    () async {
      final repo = _RecordingShipmentsRepository();
      final container = ProviderContainer(
        overrides: [
          authControllerProvider.overrideWith(_TestAuthController.new),
          shipmentsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final claimed = await container
          .read(shipmentsControllerProvider.notifier)
          .claim('order-1');

      expect(claimed.status, ShipmentStatus.assigned);
      expect(repo.claimedOrderIds, ['order-1']);
      expect(
        container.read(shipmentsControllerProvider).requireValue.available,
        isEmpty,
      );
      expect(
        container.read(shipmentsControllerProvider).requireValue.mine.single.id,
        'shipment-1',
      );
    },
  );
}
