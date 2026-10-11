import 'package:flutter/material.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/localization/generated/app_localizations.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/listings/data/repositories/listings_repository_provider.dart';
import 'package:farm2fork_mobile/features/listings/presentation/screens/create_listing_screen.dart';
import 'listings_controller_test.dart' show FarmerAuth, RecordingListings;

void main() {
  for (final language in ['en', 'ur']) {
    testWidgets(
      '$language failed save keeps input; retry returns after persistence',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repository = RecordingListings()..fail = true;
        final router = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => Scaffold(
                body: Builder(
                  builder: (context) => TextButton(
                    onPressed: () => context.push('/create'),
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
            GoRoute(
              path: '/create',
              builder: (_, _) => const CreateListingScreen(),
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authControllerProvider.overrideWith(FarmerAuth.new),
              listingsRepositoryProvider.overrideWithValue(repository),
            ],
            child: ScreenUtilInit(
              designSize: const Size(360, 690),
              builder: (_, _) => MaterialApp.router(
                routerConfig: router,
                locale: Locale(language),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        final l10n = AppLocalizations.of(
          tester.element(find.byType(CreateListingScreen)),
        );
        Future<void> fill(String label, String value) async {
          final field = find.widgetWithText(TextFormField, label);
          await tester.ensureVisible(field);
          await tester.enterText(field, value);
          await tester.pumpAndSettle();
        }

        await fill(l10n.produceName, 'Mangoes');
        await fill(l10n.description, 'Fresh harvest');
        await tester.tap(find.text(l10n.next));
        await tester.pumpAndSettle();
        await fill(l10n.priceWithCurrency, '300');
        await fill(l10n.quantity, '20');
        await tester.tap(
          find.widgetWithText(AppButton, l10n.createListingTitle),
        );
        await tester.pumpAndSettle();
        expect(find.byType(CreateListingScreen), findsOneWidget);
        expect(repository.creates, 1);
        expect(find.text(l10n.listingPublishFailed), findsOneWidget);
        expect(find.text('300'), findsOneWidget);
        expect(repository.creates, 1);
        ScaffoldMessenger.of(
          tester.element(find.byType(CreateListingScreen)),
        ).hideCurrentSnackBar();
        await tester.pumpAndSettle();
        repository.fail = false;
        await tester.tap(
          find.widgetWithText(AppButton, l10n.createListingTitle),
        );
        await tester.pumpAndSettle();
        expect(find.byType(CreateListingScreen), findsNothing);
        expect(repository.created!.id, 'server-id');
        expect(repository.creates, 2);
      },
    );
  }
}
