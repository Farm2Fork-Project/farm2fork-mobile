import 'package:farm2fork_mobile/core/localization/generated/app_localizations.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product_category.dart';
import 'package:farm2fork_mobile/features/traceability/data/models/product_trace.dart';
import 'package:farm2fork_mobile/features/traceability/data/repositories/traceability_repository.dart';
import 'package:farm2fork_mobile/features/traceability/data/repositories/traceability_repository_provider.dart';
import 'package:farm2fork_mobile/features/traceability/presentation/screens/trace_scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const _id = '6a2fe77bb77795516febc287';

class _Repo implements TraceabilityRepository {
  _Repo(this.result, {this.fail = false});

  final ProductTrace? result;
  final bool fail;
  final requested = <String>[];

  @override
  Future<ProductTrace?> fetchProductTrace(String productId) async {
    requested.add(productId);
    if (fail) throw Exception('offline');
    return result;
  }
}

ProductTrace _trace({required bool originConfirmed}) {
  final listed = TraceEvent(
    id: 'e1',
    type: TraceEventType.listed,
    occurredAt: DateTime(2026, 8, 11, 11),
    location: 'Multan, Punjab',
    ledger: originConfirmed
        ? const TraceLedger(
            status: TraceLedgerStatus.confirmed,
            txHash:
                'b7e3c1f09a4d2e6b8c5a1f3d7e9b0c2a4f6e8d1b3c5a7e9f0d2b4c6e8a1f3d5b',
            blockNumber: 42,
          )
        : const TraceLedger(status: TraceLedgerStatus.pending),
  );
  return ProductTrace(
    product: TraceProductSummary(
      id: _id,
      name: 'Chaunsa Mangoes',
      category: ProductCategory.fruits,
      unit: ProductUnit.kg,
      status: ProductStatus.active,
      qualityGrade: QualityGrade.a,
      listedAt: DateTime(2026, 8, 11, 11),
    ),
    farm: const TraceFarm(
      farmName: 'Green Valley Farm',
      city: 'Multan',
      province: 'Punjab',
    ),
    events: [
      listed,
      TraceEvent(
        id: 'e2',
        type: TraceEventType.shipmentDelivered,
        occurredAt: DateTime(2026, 8, 13, 9),
        location: 'Lahore, Punjab',
        reference: 'C287A1',
        ledger: const TraceLedger(status: TraceLedgerStatus.failed),
      ),
    ],
    totalEvents: 2,
    confirmedEvents: originConfirmed ? 1 : 0,
    originVerified: originConfirmed,
  );
}

Future<void> _pump(
  WidgetTester tester,
  _Repo repo, {
  String? initialProductId,
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = const Size(360, 780);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [traceabilityRepositoryProvider.overrideWithValue(repo)],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (_, _) => MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: TraceScannerScreen(initialProductId: initialProductId),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('rejects a malformed id without calling the API', (tester) async {
    final repo = _Repo(null);
    await _pump(tester, repo);

    await tester.enterText(find.byType(TextFormField), 'prod_001');
    await tester.tap(find.text('Trace product'));
    await tester.pumpAndSettle();

    expect(find.textContaining("isn't a Farm2Fork product ID"), findsOneWidget);
    expect(repo.requested, isEmpty);
  });

  testWidgets('resolves a pasted QR link to the real journey', (tester) async {
    final repo = _Repo(_trace(originConfirmed: true));
    await _pump(tester, repo);

    await tester.enterText(
      find.byType(TextFormField),
      'https://farm2fork.com/trace/$_id',
    );
    await tester.tap(find.text('Trace product'));
    await tester.pumpAndSettle();

    expect(repo.requested, [_id]);
    expect(find.text('Origin verified on ledger'), findsOneWidget);
    expect(find.text('Chaunsa Mangoes'), findsOneWidget);
    expect(find.text('Green Valley Farm · Multan, Punjab'), findsOneWidget);
    expect(find.text('1 of 2 recorded on ledger'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Recorded on ledger'), 200);
    expect(find.text('Recorded on ledger'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Ledger recording failed'), 200);
    expect(find.text('Ledger recording failed'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('never shows verification while the origin is only queued', (
    tester,
  ) async {
    await _pump(
      tester,
      _Repo(_trace(originConfirmed: false)),
      initialProductId: _id,
    );

    expect(find.text('Origin awaiting ledger confirmation'), findsOneWidget);
    expect(find.text('Origin verified on ledger'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Awaiting ledger confirmation'),
      200,
    );
    expect(find.text('Awaiting ledger confirmation'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Ledger recording failed'), 200);
    expect(find.text('Recorded on ledger'), findsNothing);
  });

  testWidgets('tells the user when no product matches', (tester) async {
    await _pump(tester, _Repo(null), initialProductId: _id);
    expect(find.text('No product found for this code'), findsOneWidget);
  });

  testWidgets('offers a retry when the request fails', (tester) async {
    final failing = _Repo(null, fail: true);
    await _pump(tester, failing, initialProductId: _id);
    expect(
      find.text(
        "Couldn't load the journey. Check your connection and try again.",
      ),
      findsOneWidget,
    );
  });

  testWidgets('lays out in Urdu on a 360dp phone without overflow', (
    tester,
  ) async {
    await _pump(
      tester,
      _Repo(_trace(originConfirmed: true)),
      initialProductId: _id,
      locale: const Locale('ur'),
    );

    expect(find.text('ماخذ کی لیجر پر تصدیق ہو چکی ہے'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(TraceScannerScreen))),
      TextDirection.rtl,
    );
    await tester.scrollUntilVisible(find.text('لیجر پر درج نہیں ہو سکا'), 200);
    expect(tester.takeException(), isNull);
  });
}
