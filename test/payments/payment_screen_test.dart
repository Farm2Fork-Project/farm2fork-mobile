import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:farm2fork_mobile/core/localization/generated/app_localizations.dart';
import 'package:farm2fork_mobile/features/payments/data/models/payment.dart';
import 'package:farm2fork_mobile/features/payments/data/repositories/payments_repository.dart';
import 'package:farm2fork_mobile/features/payments/data/repositories/payments_repository_provider.dart';
import 'package:farm2fork_mobile/features/payments/presentation/providers/checkout_launcher.dart';
import 'package:farm2fork_mobile/features/payments/presentation/providers/payment_controller.dart';
import 'package:farm2fork_mobile/features/payments/presentation/screens/payment_screen.dart';

class _Repo implements PaymentsRepository {
  var status = PaymentStatus.pending;
  var initiations = 0;
  var reads = 0;
  var simulations = 0;
  String? url = 'https://sandbox.api.getsafepay.com/checkout/pay?tracker=test';
  Payment payment() => Payment(
    id: 'payment-1',
    orderId: 'order-a',
    amount: 210,
    currency: 'PKR',
    status: status,
    createdAt: DateTime(2026),
    gateway: 'safepay',
    checkoutUrl: url,
  );
  @override
  Future<Payment> initiate(String orderId) async {
    initiations++;
    return payment();
  }

  @override
  Future<Payment?> findForOrder(String orderId) async {
    reads++;
    return payment();
  }

  @override
  Future<Payment> get(String paymentId) async {
    reads++;
    return payment();
  }

  @override
  Future<Payment> simulate(String paymentId, PaymentStatus status) async {
    simulations++;
    return payment();
  }
}

Future<void> _mount(
  WidgetTester tester,
  _Repo repo, {
  String locale = 'en',
  CheckoutLauncher? launcher,
  String? result,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        paymentsRepositoryProvider.overrideWithValue(repo),
        paymentSimulatorEnabledProvider.overrideWithValue(false),
        checkoutLauncherProvider.overrideWithValue(
          launcher ?? (_) async => true,
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (_, _) => MaterialApp(
          locale: Locale(locale),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PaymentScreen(
            orderIds: const ['order-a'],
            returnResult: result,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'status screen only reads and never offers simulated settlement',
    (tester) async {
      final repo = _Repo();
      await _mount(tester, repo, result: 'complete');
      expect(find.text('Complete test payment'), findsNothing);
      expect(find.text('Payment pending'), findsNWidgets(2));
      expect(repo.reads, 1);
      expect(repo.initiations, 0);
      expect(repo.simulations, 0);
    },
  );
  testWidgets(
    'opens hosted checkout and refreshes on app resume without another initiation',
    (tester) async {
      final repo = _Repo();
      final opened = <Uri>[];
      await _mount(
        tester,
        repo,
        launcher: (uri) async {
          opened.add(uri);
          return true;
        },
      );
      await tester.tap(find.text('Continue with Safepay'));
      await tester.pumpAndSettle();
      expect(opened.single.host, 'sandbox.api.getsafepay.com');
      expect(repo.initiations, 1);
      repo.status = PaymentStatus.success;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(find.text('Payment complete'), findsNWidgets(2));
      expect(find.text('Continue with Safepay'), findsNothing);
      expect(repo.initiations, 1);
      expect(repo.reads, 2);
    },
  );
  for (final locale in ['en', 'ur']) {
    testWidgets('launch failure keeps retry available in $locale', (
      tester,
    ) async {
      final repo = _Repo();
      await _mount(
        tester,
        repo,
        locale: locale,
        launcher: (_) async => false,
        result: 'cancel',
      );
      final label = locale == 'en'
          ? 'Continue with Safepay'
          : 'Safepay کے ساتھ جاری رکھیں';
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(find.text(label), findsOneWidget);
      expect(repo.initiations, 1);
      expect(repo.simulations, 0);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('rejects an untrusted URL without calling the launcher', (
    tester,
  ) async {
    final repo = _Repo()..url = 'javascript:alert(1)';
    var opened = false;
    await _mount(
      tester,
      repo,
      launcher: (_) async {
        opened = true;
        return true;
      },
    );
    await tester.tap(find.text('Continue with Safepay'));
    await tester.pumpAndSettle();
    expect(opened, isFalse);
    expect(find.textContaining('Could not open'), findsOneWidget);
  });
}
