import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/shipments/data/models/shipment.dart';
import 'package:farm2fork_mobile/features/shipments/data/repositories/shipments_repository_provider.dart';

final shipmentsControllerProvider =
    AsyncNotifierProvider<ShipmentsController, ShipmentDashboard>(
      ShipmentsController.new,
    );

/// The transporter's own deliveries, newest first. Offers live in
/// DispatchController.
class ShipmentDashboard {
  const ShipmentDashboard({required this.mine});

  final List<Shipment> mine;
}

class ShipmentsController extends AsyncNotifier<ShipmentDashboard> {
  @override
  Future<ShipmentDashboard> build() async {
    final authState = ref.watch(authControllerProvider).asData?.value;
    if (authState == null || authState.user == null) {
      return const ShipmentDashboard(mine: []);
    }
    return _load();
  }

  Future<void> fetchShipments() async {
    if (!state.hasValue) state = const AsyncLoading();
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
      return const ShipmentDashboard(mine: []);
    }
    return ShipmentDashboard(
      mine: await ref.read(shipmentsRepositoryProvider).getMine(),
    );
  }
}
