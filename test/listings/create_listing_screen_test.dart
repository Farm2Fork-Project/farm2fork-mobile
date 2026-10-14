import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:farm2fork_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:farm2fork_mobile/features/listings/data/models/new_listing.dart';
import 'package:farm2fork_mobile/features/ai/data/models/ai_models.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
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

class _CropListings extends RecordingListings {
  NewListing? lastSubmitted;
  int updates = 0;
  Product? updated;
  @override
  Future<Product> updateListing(String id, NewListing listing) async {
    updates++;
    lastSubmitted = listing;
    if (this.fail) throw StateError("Offline");
    updated = listings.first.copyWith(
      name: listing.name,
      description: listing.description,
      price: listing.price,
      quantity: listing.quantity,
      unit: listing.unit,
      qualityGrade: listing.qualityGrade,
      images: listing.images,
    );
    return updated!;
  }

  @override
  Future<Product> createListing(String farmerId, NewListing listing) {
    lastSubmitted = listing;
    return super.createListing(farmerId, listing);
  }
}

void main() {
  setUpAll(() async {
    final font = Platform.environment['FLOW_REVIEW_SANS_FONT'];
    if (font == null) return;
    final sans = FontLoader('Roboto')
      ..addFont(
        Future.value(ByteData.sublistView(await File(font).readAsBytes())),
      );
    await sans.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(
        Future.value(
          ByteData.sublistView(
            await File(
              '${File(font).parent.path}/MaterialIcons-Regular.otf',
            ).readAsBytes(),
          ),
        ),
      );
    await icons.load();
    final urdu = FontLoader('NotoNastaliqUrdu')
      ..addFont(rootBundle.load('assets/fonts/NotoNastaliqUrdu-Regular.ttf'));
    await urdu.load();
  });
  for (final editing in [false, true]) {
    for (final language in ['en', 'ur']) {
      testWidgets(
        '$language ${editing ? 'edit' : 'create'} failed save keeps input; retry returns after persistence',
        (tester) async {
          tester.view.physicalSize = const Size(360, 800);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final reviewKey = GlobalKey();
          final repository = _CropListings()..fail = true;
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
                builder: (_, _) => CreateListingScreen(
                  initialProduct: editing ? repository.listings.first : null,
                ),
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
                builder: (_, _) => RepaintBoundary(
                  key: reviewKey,
                  child: MaterialApp.router(
                    theme: AppTheme.lightTheme.copyWith(
                      textTheme: AppTheme.lightTheme.textTheme.apply(
                        fontFamily: "Roboto",
                      ),
                      primaryTextTheme: AppTheme.lightTheme.primaryTextTheme
                          .apply(fontFamily: "Roboto"),
                    ),
                    routerConfig: router,
                    locale: Locale(language),
                    localizationsDelegates:
                        AppLocalizations.localizationsDelegates,
                    supportedLocales: AppLocalizations.supportedLocales,
                  ),
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

          await fill(l10n.produceName, 'Cotton');
          final cropSelector = find.byType(
            DropdownButtonFormField<GradableCrop>,
          );
          await tester.ensureVisible(cropSelector);
          await tester.tap(cropSelector);
          await tester.pumpAndSettle();
          await tester.tap(find.text(l10n.cropOther).last);
          await tester.pumpAndSettle();
          expect(find.text(l10n.aiOtherCropNoGrading), findsOneWidget);
          final gradeSelector = find.byType(
            DropdownButtonFormField<QualityGrade>,
          );
          await tester.ensureVisible(gradeSelector);
          await tester.tap(gradeSelector);
          await tester.pumpAndSettle();
          await tester.tap(
            find.text('${l10n.qualityGrade}: ${l10n.gradeC}').last,
          );
          await tester.pumpAndSettle();
          await fill(l10n.description, 'Fresh harvest');
          await tester.tap(find.text(l10n.next));
          await tester.pumpAndSettle();
          await fill(l10n.priceWithCurrency, '300');
          await fill(l10n.quantity, '20');
          final directory = Platform.environment['FLOW_SCREENSHOTS'];
          if (editing && directory != null) {
            await tester.runAsync(() async {
              final boundary =
                  reviewKey.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary;
              final image = await boundary.toImage(pixelRatio: 1);
              final bytes = (await image.toByteData(
                format: ui.ImageByteFormat.png,
              ))!;
              await Directory(directory).create(recursive: true);
              await File(
                '$directory/farmer-edit-$language.png',
              ).writeAsBytes(bytes.buffer.asUint8List());
              image.dispose();
            });
          }
          await tester.tap(
            find.widgetWithText(
              AppButton,
              editing ? l10n.saveChanges : l10n.createListingTitle,
            ),
          );
          await tester.pumpAndSettle();
          expect(find.byType(CreateListingScreen), findsOneWidget);
          expect(editing ? repository.updates : repository.creates, 1);
          expect(find.text(l10n.listingPublishFailed), findsOneWidget);
          expect(find.text('300'), findsOneWidget);
          expect(editing ? repository.updates : repository.creates, 1);
          ScaffoldMessenger.of(
            tester.element(find.byType(CreateListingScreen)),
          ).hideCurrentSnackBar();
          await tester.pumpAndSettle();
          repository.fail = false;
          await tester.tap(
            find.widgetWithText(
              AppButton,
              editing ? l10n.saveChanges : l10n.createListingTitle,
            ),
          );
          await tester.pumpAndSettle();
          expect(find.byType(CreateListingScreen), findsNothing);
          expect(
            editing ? repository.updated!.id : repository.created!.id,
            editing ? 'p1' : 'server-id',
          );
          expect(repository.lastSubmitted!.qualityGrade, QualityGrade.c);
          expect(editing ? repository.updates : repository.creates, 2);
        },
      );
    }
  }
}
