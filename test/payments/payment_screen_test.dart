import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:farm2fork_mobile/core/localization/generated/app_localizations.dart';
import 'package:farm2fork_mobile/features/payments/presentation/providers/payment_controller.dart';
import 'package:farm2fork_mobile/features/payments/presentation/screens/payment_screen.dart';

void main() {
  testWidgets(
    'does not offer simulated payment completion when simulation is disabled',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [paymentSimulatorEnabledProvider.overrideWithValue(false)],
          child: ScreenUtilInit(
            designSize: const Size(360, 690),
            builder: (_, _) => const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: PaymentScreen(orderIds: ['order-a']),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Complete test payment'), findsNothing);
      expect(find.text('Payment pending'), findsOneWidget);
    },
  );
}
