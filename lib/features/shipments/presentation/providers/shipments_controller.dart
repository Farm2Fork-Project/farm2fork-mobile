import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/shipments/data/models/shipment.dart';
import 'package:farm2fork_mobile/features/shipments/data/repositories/mock_shipments_repository.dart';

final shipmentsControllerProvider =
    AsyncNotifierProvider<ShipmentsController, List<Shipment>>(
      ShipmentsController.new,
    );

class ShipmentsController extends AsyncNotifier<List<Shipment>> {
  @override
  Future<List<Shipment>> build() async {
    final authState = ref.watch(authControllerProvider).asData?.value;
    if (authState == null || authState.user == null) {
      return [];
    }
    final repository = ref.watch(shipmentsRepositoryProvider);
    return repository.getShipmentsByTransporter(authState.user!.id);
  }

  Future<void> fetchShipments() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final authState = ref.read(authControllerProvider).asData?.value;
      if (authState == null || authState.user == null) return [];
      return ref
          .read(shipmentsRepositoryProvider)
          .getShipmentsByTransporter(authState.user!.id);
    });
  }

  Future<void> updateShipmentStatus({
    required String shipmentId,
    required ShipmentStatus status,
    required String note,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final authState = ref.read(authControllerProvider).asData?.value;
      if (authState == null || authState.user == null) {
        throw Exception('Unauthorized');
      }
      final repository = ref.read(shipmentsRepositoryProvider);
      await repository.updateShipmentStatus(
        shipmentId: shipmentId,
        status: status,
        note: note,
        updatedBy: authState.user!.email,
      );
      return repository.getShipmentsByTransporter(authState.user!.id);
    });
  }
}
