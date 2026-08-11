import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/shipments/data/models/shipment.dart';
import 'package:farm2fork_mobile/features/shipments/data/models/available_delivery.dart';
import 'package:farm2fork_mobile/features/shipments/data/repositories/shipments_repository_provider.dart';

final shipmentsControllerProvider =
    AsyncNotifierProvider<ShipmentsController, ShipmentDashboard>(
      ShipmentsController.new,
    );

class ShipmentDashboard {
  const ShipmentDashboard({required this.available, required this.mine});

  final List<AvailableDelivery> available;
  final List<Shipment> mine;
}

class ShipmentsController extends AsyncNotifier<ShipmentDashboard> {
  @override
  Future<ShipmentDashboard> build() async {
    final authState = ref.watch(authControllerProvider).asData?.value;
    if (authState == null || authState.user == null) {
      return const ShipmentDashboard(available: [], mine: []);
    }
    return _load();
  }

  Future<void> fetchShipments() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<Shipment> claim(String orderId) async {
    final shipment = await ref.read(shipmentsRepositoryProvider).claim(orderId);
    await fetchShipments();
    return shipment;
  }

  Future<Shipment> updateShipmentStatus({
    required String shipmentId,
    required ShipmentStatus status,
    required String note,
  }) async {
    final shipment = await ref
        .read(shipmentsRepositoryProvider)
        .updateStatus(shipmentId: shipmentId, status: status, note: note);
    await fetchShipments();
    return shipment;
  }

  Future<ShipmentDashboard> _load() async {
    final authState = ref.read(authControllerProvider).asData?.value;
    if (authState?.user == null) {
      return const ShipmentDashboard(available: [], mine: []);
    }
    final repository = ref.read(shipmentsRepositoryProvider);
    final results = await Future.wait([
      repository.getAvailable(),
      repository.getMine(),
    ]);
    return ShipmentDashboard(
      available: results[0] as List<AvailableDelivery>,
      mine: results[1] as List<Shipment>,
    );
  }
}
