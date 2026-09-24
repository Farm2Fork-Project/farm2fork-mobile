import 'dart:typed_data';

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
  _Repo({this.quality, this.priceError});

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
    return const PriceSuggestion(
      minPrice: 154,
      maxPrice: 352,
      confidence: 0.45,
      ruleBased: true,
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
    return quality!;
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
    'price card labels the rule-based range and applies the midpoint',
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
      expect(find.textContaining('not live market data'), findsOneWidget);
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
    expect(find.textContaining('No price rule'), findsOneWidget);
  });

  testWidgets('quality card guesses the crop, labels previews and applies', (
    tester,
  ) async {
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

    expect(repo.gradedCrop, GradableCrop.mango);
    expect(find.text('Grade B · 26% confidence'), findsOneWidget);
    expect(find.textContaining('Preview only'), findsOneWidget);
    await tester.tap(find.text('Use grade B'));
    expect(applied, QualityGrade.b);
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
}
