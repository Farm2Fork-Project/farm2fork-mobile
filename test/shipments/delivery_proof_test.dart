import 'package:farm2fork_mobile/features/shipments/data/models/shipment.dart';
import 'package:farm2fork_mobile/features/shipments/data/models/available_delivery.dart';
import 'package:farm2fork_mobile/features/shipments/presentation/providers/dispatch_controller.dart';
import 'package:farm2fork_mobile/features/shipments/presentation/widgets/delivery_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/features/shipments/presentation/widgets/buyer_delivery_code.dart';
import 'package:farm2fork_mobile/features/shipments/data/repositories/shipments_repository_provider.dart';
import 'package:farm2fork_mobile/features/shipments/data/repositories/mock_shipments_repository.dart';
import '../support/harness.dart';

class _Codes extends MockShipmentsRepository {
  int reissues = 0;
  @override
  Future<String> getDeliveryCode(String id, {bool reissue = false}) async {
    if (reissue) reissues++;
    return reissue ? '654321' : '123456';
  }
}

class _ProofController extends DispatchController {
  bool fail = true;
  @override
  Future<DispatchState> build() async => const DispatchState(
    status: TransporterStatus(
      online: false,
      locationFresh: false,
      radiusKm: 20,
    ),
    offers: [],
  );
  @override
  Future<void> complete(String id, String code, String note) async {
    if (fail) throw StateError('Invalid code');
  }
}

void main() {
  testWidgets('verification failure keeps code form open and permits retry', (
    tester,
  ) async {
    final controller = _ProofController();
    final shipment = (await tester.runAsync(() => MockShipmentsRepository().getMine()))!.first.copyWith(
      status: ShipmentStatus.inTransit,
    );
    await pumpScreen(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showDeliveryAction(context, shipment),
            child: const Text('Open'),
          ),
        ),
      ),
      overrides: [dispatchControllerProvider.overrideWith(() => controller)],
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '999999');
    await tester.tap(find.text('Verify code and complete'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Could not verify this code'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    controller.fail = false;
    await tester.tap(find.text('Verify code and complete'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('buyer code is hidden until requested and reissue replaces it', (
    tester,
  ) async {
    final repo = _Codes();
    await pumpScreen(
      tester,
      const Scaffold(body: BuyerDeliveryCode(shipmentId: 's')),
      overrides: [shipmentsRepositoryProvider.overrideWithValue(repo)],
    );
    expect(find.text('123456'), findsNothing);
    await tester.tap(find.text('Show delivery code'));
    await tester.pumpAndSettle();
    expect(find.text('123456'), findsOneWidget);
    await tester.tap(find.text('Issue a new code'));
    await tester.pumpAndSettle();
    expect(find.text('123456'), findsNothing);
    expect(find.text('654321'), findsOneWidget);
    expect(repo.reissues, 1);
  });
}
