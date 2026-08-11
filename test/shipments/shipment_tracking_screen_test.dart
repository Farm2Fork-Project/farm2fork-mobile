import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/core/localization/generated/app_localizations.dart';
import 'package:farm2fork_mobile/features/shipments/data/models/available_delivery.dart';
import 'package:farm2fork_mobile/features/shipments/data/models/shipment.dart';
import 'package:farm2fork_mobile/features/shipments/data/repositories/shipments_repository.dart';
import 'package:farm2fork_mobile/features/shipments/data/repositories/shipments_repository_provider.dart';
import 'package:farm2fork_mobile/features/shipments/presentation/screens/shipment_tracking_screen.dart';

class _TrackingRepository extends ShipmentsRepository {
  @override
  Future<Shipment> getById(String shipmentId) async => Shipment(
    id: shipmentId,
    orderId: 'order-1',
    transporterId: 'transporter-1',
    status: ShipmentStatus.delivered,
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
        status: ShipmentStatus.delivered,
        timestamp: DateTime(2026, 8, 13),
        note: 'Delivered to buyer',
        updatedBy: 'transporter-1',
      ),
    ],
    estimatedDelivery: DateTime(2026, 8, 13),
    actualDelivery: DateTime(2026, 8, 13),
    createdAt: DateTime(2026, 8, 11),
    updatedAt: DateTime(2026, 8, 13),
  );

  @override
  Future<Shipment> claim(String orderId) => throw UnimplementedError();
  @override
  Future<List<AvailableDelivery>> getAvailable() async => const [];
  @override
  Future<List<Shipment>> getMine() async => const [];
  @override
  Future<Shipment> updateStatus({
    required String shipmentId,
    required ShipmentStatus status,
    required String note,
  }) => throw UnimplementedError();
}

void main() {
  testWidgets('shows a read-only shipment timeline', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shipmentsRepositoryProvider.overrideWithValue(_TrackingRepository()),
        ],
        child: ScreenUtilInit(
          designSize: const Size(360, 690),
          builder: (_, _) => const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ShipmentTrackingScreen(shipmentId: 'shipment-1'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Delivered to buyer'), findsOneWidget);
    expect(find.text('Claim delivery'), findsNothing);
  });
}
