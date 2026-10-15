import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/core/localization/generated/app_localizations.dart';
import 'package:farm2fork_mobile/features/shipments/data/models/shipment.dart';
import 'package:farm2fork_mobile/features/shipments/data/services/transporter_dispatch_service.dart';
import 'package:farm2fork_mobile/features/shipments/presentation/providers/shipments_controller.dart';
import 'package:farm2fork_mobile/features/shipments/presentation/screens/shipments_screen.dart';
import 'package:dio/dio.dart';

class _Status extends TransporterDispatchService {
  _Status() : super(Dio());
  @override
  Future<TransporterStatus> getStatus() async => const TransporterStatus(
    online: true,
    locationFresh: true,
    radiusKm: 20,
    activeShipmentId: 'shipment-1',
  );
}

class _Deliveries extends ShipmentsController {
  bool fail = true;
  @override
  Future<ShipmentDashboard> build() async => ShipmentDashboard(
    mine: [
      Shipment(
        id: 'shipment-1',
        orderId: 'order-1',
        transporterId: 't',
        status: ShipmentStatus.assigned,
        pickupAddress: const ShipmentAddress(
          street: 'Farm road',
          city: 'Lahore',
          province: 'Punjab',
        ),
        deliveryAddress: const ShipmentAddress(
          street: 'Mall road',
          city: 'Lahore',
          province: 'Punjab',
        ),
        statusHistory: const [],
        deliveryFee: 180,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    ],
  );
  @override
  Future<Shipment> updateShipmentStatus({
    required String shipmentId,
    required ShipmentStatus status,
    required String note,
  }) async {
    if (fail) throw StateError('Network unavailable');
    final current = state.requireValue;
    final shipment = current.mine.single.copyWith(status: status);
    state = AsyncData(ShipmentDashboard(mine: [shipment]));
    return shipment;
  }
}

void main() {
  testWidgets('active deliveries are excluded from read-only history', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final deliveries = _Deliveries();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shipmentsControllerProvider.overrideWith(() => deliveries),
          transporterDispatchServiceProvider.overrideWithValue(_Status()),
        ],
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, _) => const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ShipmentsScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Confirm crop pickup'), findsNothing);
    expect(find.textContaining('No deliveries yet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
