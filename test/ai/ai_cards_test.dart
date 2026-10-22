import 'dart:typed_data';
import 'dart:async';

import 'package:farm2fork_mobile/core/localization/generated/app_localizations.dart';
import 'package:farm2fork_mobile/features/ai/data/models/ai_models.dart';
import 'package:farm2fork_mobile/features/ai/data/repositories/ai_repository.dart';
import 'package:farm2fork_mobile/features/ai/data/repositories/ai_repository_provider.dart';
import 'package:farm2fork_mobile/features/ai/presentation/widgets/price_suggestion_card.dart';
import 'package:farm2fork_mobile/features/ai/presentation/widgets/quality_check_card.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product.dart';
import 'package:farm2fork_mobile/features/marketplace/data/models/product_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

class _Repo implements AiRepository {
  _Repo({this.quality, this.priceError, this.pending});

  final Completer<QualityCheck>? pending;

  final QualityCheck? quality;
  final AiErrorKind? priceError;
  GradableCrop? gradedCrop;

  @override
  Future<AiStatus> status() async =>
      const AiStatus(available: true, qualityModel: AiModelStatus.untrained);

  @override
  Future<PriceSuggestion> suggestPrice({
    required String productName,
    required ProductCategory category,
    required ProductUnit unit,
    required QualityGrade grade,
  }) async {
    if (priceError != null) throw AiException(priceError!);
    return PriceSuggestion(
      minPrice: 154,
      maxPrice: 352,
      commodity: 'Mango(Chounsa)',
      observedOn: DateTime(2026, 8, 15),
      marketScope: 'Punjab',
      marketCount: 39,
    );
  }

  @override
  Future<QualityCheck> checkQuality({
    required List<int> bytes,
    required String filename,
    required String mimeType,
    required GradableCrop crop,
  }) async {
    gradedCrop = crop;
    return pending == null ? quality! : await pending!.future;
  }
}

Future<void> _pump(WidgetTester tester, _Repo repo, Widget child) async {
  tester.view.physicalSize = const Size(360, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [aiRepositoryProvider.overrideWithValue(repo)],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (_, _) => MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<XFile?> _fakePhoto(ImageSource _) async =>
    XFile.fromData(Uint8List.fromList([1, 2, 3]), name: 'mango.jpg');

void main() {
  testWidgets(
    'price card shows the dated official source and applies the midpoint',
    (tester) async {
      double? applied;
      await _pump(
        tester,
        _Repo(),
        PriceSuggestionCard(
          productName: 'Chaunsa Mangoes',
          category: ProductCategory.fruits,
          unit: ProductUnit.kg,
          grade: QualityGrade.a,
          unitLabel: 'kg',
          onApply: (price) => applied = price,
        ),
      );

      await tester.tap(find.text('Suggest a price'));
      await tester.pumpAndSettle();

      expect(find.text('Rs 154 – 352 per kg'), findsOneWidget);
      expect(
        find.textContaining('across 39 Punjab markets on Aug 15, 2026'),
        findsOneWidget,
      );
      expect(find.textContaining('Source: AMIS Punjab'), findsOneWidget);
      await tester.tap(find.text('Use Rs 253'));
      expect(applied, 253);
    },
  );

  testWidgets('price card explains a missing rule', (tester) async {
    await _pump(
      tester,
      _Repo(priceError: AiErrorKind.noPriceRule),
      PriceSuggestionCard(
        productName: 'Eggs',
        category: ProductCategory.dairy,
        unit: ProductUnit.dozen,
        grade: QualityGrade.a,
        unitLabel: 'dozen',
        onApply: (_) {},
      ),
    );
    await tester.tap(find.text('Suggest a price'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No official mandi price'), findsOneWidget);
  });

  testWidgets(
    'quality card requires explicit crop, labels previews and applies',
    (tester) async {
      QualityGrade? applied;
      final repo = _Repo(
        quality: const QualityCheck(
          modelGrade: 'B',
          suggestedListingGrade: QualityGrade.b,
          confidence: 0.26,
          cropSupported: true,
          lowConfidence: true,
          modelStatus: AiModelStatus.untrained,
        ),
      );
      await _pump(
        tester,
        repo,
        QualityCheckCard(
          productName: 'Chaunsa Mango',
          onApplyGrade: (grade) => applied = grade,
          pickPhoto: _fakePhoto,
        ),
      );

      expect(find.textContaining("isn't trained yet"), findsOneWidget);
      await tester.tap(find.text('Choose from gallery'));
      await tester.pumpAndSettle();
      expect(repo.gradedCrop, isNull);
      await tester.tap(find.byType(DropdownButtonFormField<GradableCrop>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mango').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose from gallery'));
      await tester.pumpAndSettle();

      expect(repo.gradedCrop, GradableCrop.mango);
      expect(find.text('Grade B · 26% confidence'), findsOneWidget);
      expect(find.textContaining('Preview only'), findsOneWidget);
      await tester.tap(find.text('Use grade B'));
      expect(applied, QualityGrade.b);
    },
  );

  testWidgets('a referred photo shows no grade and offers a retake', (
    tester,
  ) async {
    var grades = 0;
    final repo = _Repo(
      quality: const QualityCheck(
        modelGrade: null,
        suggestedListingGrade: null,
        confidence: 0.97,
        cropSupported: true,
        lowConfidence: true,
        modelStatus: AiModelStatus.trained,
        reviewReason: QualityReviewReason.unfamiliarPhoto,
      ),
    );
    await _pump(
      tester,
      repo,
      QualityCheckCard(
        productName: 'Chaunsa Mango',
        onApplyGrade: (_) => grades++,
        pickPhoto: _fakePhoto,
      ),
    );
    await tester.tap(find.byType(DropdownButtonFormField<GradableCrop>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mango').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose from gallery'));
    await tester.pumpAndSettle();

    expect(find.text('No grade from this photo'), findsOneWidget);
    expect(find.textContaining('looks different from the photos'), findsOneWidget);
    expect(find.textContaining('choose the listing grade yourself'), findsOneWidget);
    expect(find.textContaining('Grade A'), findsNothing);
    expect(find.textContaining('Use grade'), findsNothing);
    repo.gradedCrop = null;
    await tester.tap(find.text('Retake photo'));
    await tester.pumpAndSettle();
    expect(repo.gradedCrop, GradableCrop.mango);
    expect(grades, 0);
  });

  testWidgets('quality card asks for the crop and offers no grade for a D', (
    tester,
  ) async {
    final repo = _Repo(
      quality: const QualityCheck(
        modelGrade: 'D',
        suggestedListingGrade: null,
        confidence: 0.8,
        cropSupported: true,
        lowConfidence: false,
        modelStatus: AiModelStatus.trained,
      ),
    );
    await _pump(
      tester,
      repo,
      QualityCheckCard(
        productName: 'Fresh produce',
        onApplyGrade: (_) {},
        pickPhoto: _fakePhoto,
      ),
    );

    await tester.tap(find.text('Take a photo'));
    await tester.pumpAndSettle();
    expect(find.text('Select the crop in the photo.'), findsOneWidget);
    expect(repo.gradedCrop, isNull);

    await tester.tap(find.byType(DropdownButtonFormField<GradableCrop>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rice').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Take a photo'));
    await tester.pumpAndSettle();

    expect(repo.gradedCrop, GradableCrop.rice);
    expect(find.textContaining('Below listing grades'), findsOneWidget);
    expect(find.textContaining('Use grade'), findsNothing);
  });
  testWidgets('Other never picks a photo or calls grading', (tester) async {
    final repo = _Repo();
    var picks = 0;
    await _pump(
      tester,
      repo,
      QualityCheckCard(
        productName: 'Cotton',
        onApplyGrade: (_) {},
        pickPhoto: (_) async {
          picks++;
          return _fakePhoto(ImageSource.gallery);
        },
      ),
    );
    await tester.tap(find.byType(DropdownButtonFormField<GradableCrop>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Other').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('AI grading is not available'), findsOneWidget);
    expect(find.text('Choose from gallery'), findsNothing);
    expect(picks, 0);
    expect(repo.gradedCrop, isNull);
  });

  testWidgets('crop change ignores an in-flight grade', (tester) async {
    final pending = Completer<QualityCheck>();
    final repo = _Repo(pending: pending);
    await _pump(
      tester,
      repo,
      QualityCheckCard(
        productName: 'Wheat',
        onApplyGrade: (_) {},
        pickPhoto: _fakePhoto,
      ),
    );
    await tester.tap(find.byType(DropdownButtonFormField<GradableCrop>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wheat').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose from gallery'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(repo.gradedCrop, GradableCrop.wheat);
    await tester.tap(find.byType(DropdownButtonFormField<GradableCrop>));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Other').last);
    await tester.pumpAndSettle();
    pending.complete(
      const QualityCheck(
        modelGrade: 'A',
        suggestedListingGrade: QualityGrade.a,
        confidence: .9,
        cropSupported: true,
        lowConfidence: false,
        modelStatus: AiModelStatus.trained,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Grade A'), findsNothing);
    expect(find.text('Use grade A'), findsNothing);
  });
  testWidgets(
    'renaming the product clears a result and ignores pending grading',
    (tester) async {
      final pending = Completer<QualityCheck>();
      final repo = _Repo(pending: pending);
      final name = ValueNotifier('Wheat');
      addTearDown(name.dispose);
      await _pump(
        tester,
        repo,
        ValueListenableBuilder<String>(
          valueListenable: name,
          builder: (_, value, _) => QualityCheckCard(
            productName: value,
            onApplyGrade: (_) {},
            pickPhoto: _fakePhoto,
          ),
        ),
      );
      await tester.tap(find.byType(DropdownButtonFormField<GradableCrop>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Wheat').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose from gallery'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      name.value = 'Mango';
      await tester.pumpAndSettle();
      pending.complete(
        const QualityCheck(
          modelGrade: 'A',
          suggestedListingGrade: QualityGrade.a,
          confidence: .9,
          cropSupported: true,
          lowConfidence: false,
          modelStatus: AiModelStatus.trained,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Use grade A'), findsNothing);
      expect(find.textContaining('Grade A'), findsNothing);
    },
  );

  testWidgets('choosing a replacement photo clears the prior suggestion', (
    tester,
  ) async {
    final repo = _Repo(
      quality: const QualityCheck(
        modelGrade: 'B',
        suggestedListingGrade: QualityGrade.b,
        confidence: .9,
        cropSupported: true,
        lowConfidence: false,
        modelStatus: AiModelStatus.trained,
      ),
    );
    final replacement = Completer<XFile?>();
    var picks = 0;
    var invalidations = 0;
    await _pump(
      tester,
      repo,
      QualityCheckCard(
        productName: 'Wheat',
        onApplyGrade: (_) {},
        onInvalidateGrade: () => invalidations++,
        pickPhoto: (source) =>
            ++picks == 1 ? _fakePhoto(source) : replacement.future,
      ),
    );
    await tester.tap(find.byType(DropdownButtonFormField<GradableCrop>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wheat').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose from gallery'));
    await tester.pumpAndSettle();
    expect(find.text('Use grade B'), findsOneWidget);
    final before = invalidations;
    await tester.tap(find.text('Choose from gallery'));
    await tester.pump();
    expect(find.text('Use grade B'), findsNothing);
    expect(invalidations, before + 1);
    replacement.complete(null);
    await tester.pumpAndSettle();
  });
}
