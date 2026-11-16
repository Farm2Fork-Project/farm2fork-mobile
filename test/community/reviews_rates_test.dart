import 'package:farm2fork_mobile/features/rates/rates.dart';
import 'package:farm2fork_mobile/features/reviews/reviews.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  testWidgets('a buyer rates a delivered order once', (tester) async {
    final repo = MockReviewsRepository();
    await pumpScreen(
      tester,
      const Scaffold(body: OrderReviewAction(orderId: 'order_9')),
      overrides: [reviewsRepositoryProvider.overrideWithValue(repo)],
    );
    await tester.tap(find.text('Rate this order'));
    await tester.pumpAndSettle();
    // No rating chosen yet: nothing is sent.
    await tester.tap(find.text('Submit review'));
    await tester.pumpAndSettle();
    expect(await repo.mine(), isEmpty);

    await tester.tap(find.byTooltip('4 out of 5'));
    await tester.pump();
    await tester.tap(find.text('Submit review'));
    await tester.pumpAndSettle();

    final mine = await repo.mine();
    expect(mine.single.rating, 4);
    expect(mine.single.orderId, 'order_9');
    expect(find.text('Your rating'), findsOneWidget);
    expect(find.text('Rate this order'), findsNothing);
  });

  testWidgets('product page shows the farmer rating and replies', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const Scaffold(
        body: SingleChildScrollView(
          child: FarmerReviewsCard(farmerId: 'mock_farmer_001'),
        ),
      ),
      overrides: [
        reviewsRepositoryProvider.overrideWithValue(MockReviewsRepository()),
      ],
    );
    expect(find.text('4.5'), findsOneWidget);
    expect(find.text('2 reviews'), findsOneWidget);
    expect(find.text("Farmer's reply"), findsOneWidget);
  });

  testWidgets('mandi rates list can be searched', (tester) async {
    await pumpScreen(
      tester,
      const MandiRatesScreen(),
      overrides: [
        ratesRepositoryProvider.overrideWithValue(MockRatesRepository()),
      ],
    );
    expect(find.text('Lahore'), findsOneWidget);
    expect(find.text('Wheat'), findsOneWidget);
    expect(find.text('per 100 kg'), findsWidgets);
    await tester.enterText(find.byType(TextField), 'mango');
    await tester.pumpAndSettle();
    expect(find.text('Mango (Chaunsa)'), findsOneWidget);
    expect(find.text('Wheat'), findsNothing);
  });
}
