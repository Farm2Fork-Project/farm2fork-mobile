import 'package:farm2fork_mobile/features/loans/data/loans.dart';
import 'package:farm2fork_mobile/features/loans/presentation/screens/farmer_loans_screen.dart';
import 'package:farm2fork_mobile/features/loans/presentation/screens/loan_review_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  testWidgets('farmer applies within the limits; only one open application', (
    tester,
  ) async {
    final repo = MockLoansRepository();
    await pumpScreen(
      tester,
      const FarmerLoansScreen(),
      overrides: [loansRepositoryProvider.overrideWithValue(repo)],
    );
    expect(find.text('No applications yet.'), findsOneWidget);

    await tester.tap(find.text('Apply for a loan'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), '5000');
    await tester.enterText(find.byType(TextFormField).at(1), 'Seeds for wheat');
    await tester.tap(find.text('Submit application'));
    await tester.pumpAndSettle();
    expect(find.text('Between Rs 10,000 and Rs 1,000,000'), findsWidgets);
    expect(await repo.mine(), isEmpty);

    await tester.enterText(find.byType(TextFormField).at(0), '120000');
    await tester.tap(find.text('Submit application'));
    await tester.pumpAndSettle();

    expect((await repo.mine()).single.amount, 120000);
    expect(find.text('Submitted'), findsOneWidget);
    final apply = tester.widget<ElevatedButton>(
      find.ancestor(
        of: find.text('Apply for a loan'),
        matching: find.byType(ElevatedButton),
      ),
    );
    expect(apply.onPressed, isNull);
    expect(find.textContaining('one application in progress'), findsOneWidget);
  });

  testWidgets('partner reviews, approves and records a repayment', (
    tester,
  ) async {
    final repo = MockLoansRepository();
    final loan = await repo.apply(
      amount: 90000,
      purpose: 'Tube-well repair',
      durationMonths: 3,
      documents: const [],
    );
    await pumpScreen(
      tester,
      LoanReviewScreen(loanId: loan.id),
      overrides: [loansRepositoryProvider.overrideWithValue(repo)],
    );

    await tester.tap(find.text('Start review'));
    await tester.pumpAndSettle();
    expect(find.text('Under review'), findsOneWidget);

    await tester.tap(find.text('Approve'));
    await tester.pumpAndSettle();
    expect(find.text('Approved'), findsOneWidget);
    expect(find.text('Instalment 1: Rs 30,000'), findsOneWidget);

    await tester.tap(find.text('Mark paid').first);
    await tester.pumpAndSettle();
    expect(find.text('Repaid Rs 30,000 of Rs 90,000'), findsOneWidget);
  });

  testWidgets('rejecting requires a reason the farmer will see', (
    tester,
  ) async {
    final repo = MockLoansRepository();
    final loan = await repo.apply(
      amount: 50000,
      purpose: 'Fertiliser',
      durationMonths: 6,
      documents: const [],
    );
    await repo.startReview(loan.id);
    await pumpScreen(
      tester,
      LoanReviewScreen(loanId: loan.id),
      overrides: [loansRepositoryProvider.overrideWithValue(repo)],
    );

    await tester.tap(find.text('Reject'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reject').last);
    await tester.pumpAndSettle();
    expect((await repo.byId(loan.id)).status, LoanStatus.underReview);

    await tester.enterText(find.byType(TextField).last, 'No sales history yet');
    await tester.tap(find.text('Reject').last);
    await tester.pumpAndSettle();
    final decided = await repo.byId(loan.id);
    expect(decided.status, LoanStatus.rejected);
    expect(decided.reviewNote, 'No sales history yet');
  });
}
