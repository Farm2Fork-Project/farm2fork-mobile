import 'package:farm2fork_mobile/core/localization/generated/app_localizations.dart';
import 'package:farm2fork_mobile/features/farm_location/data/farm_location.dart';
import 'package:farm2fork_mobile/features/farm_location/presentation/city_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import '../support/harness.dart' show testLocationsOverride;

Future<ValueNotifier<CityChoice?>> _pump(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  String? city,
  PakistanProvince? province,
}) async {
  final picked = ValueNotifier<CityChoice?>(null);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [testLocationsOverride],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (_, _) => MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Form(
              child: CityPickerField(
                city: city,
                province: province,
                onChanged: (c) => picked.value = c,
              ),
            ),
          ),
        ),
      ),
    ),
  );
  return picked;
}

void main() {
  testWidgets('province -> city chain returns the city and its centre', (
    tester,
  ) async {
    final picked = await _pump(tester);
    expect(find.text('Choose province and city'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(CityPickerField),
        matching: find.byType(InkWell),
      ),
    );
    await tester.pumpAndSettle();

    // Step 1: provinces only, no cities yet.
    expect(find.text('Choose your province'), findsOneWidget);
    expect(find.text('Sindh'), findsOneWidget);
    expect(find.text('Karachi'), findsNothing);

    await tester.tap(find.text('Sindh'));
    await tester.pumpAndSettle();
    // Step 2: that province's cities, not Punjab's.
    expect(find.text('Adilpur'), findsOneWidget, reason: 'first Sindh city');
    expect(find.text('Lahore'), findsNothing);
    await tester.enterText(find.byType(TextField), 'karachi');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Karachi'));
    await tester.pumpAndSettle();
    expect(picked.value?.city, 'Karachi');
    expect(picked.value?.province, PakistanProvince.sindh);
    expect(picked.value?.centre?.isInPakistan, isTrue);
    expect(find.text('Karachi, Sindh'), findsOneWidget);
  });

  testWidgets('search filters cities and finds them across provinces', (
    tester,
  ) async {
    await _pump(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(CityPickerField),
        matching: find.byType(InkWell),
      ),
    );
    await tester.pumpAndSettle();

    // On the province step, a city name searches every province.
    await tester.enterText(find.byType(TextField), 'lahor');
    await tester.pumpAndSettle();
    expect(find.text('Lahore'), findsOneWidget);
    expect(find.text('Punjab'), findsOneWidget, reason: 'province subtitle');

    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pumpAndSettle();
    expect(find.textContaining('No city found'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Punjab'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'multan');
    await tester.pumpAndSettle();
    expect(find.text('Multan'), findsOneWidget);
    expect(find.text('Lahore'), findsNothing);
  });

  testWidgets('back arrow returns to the province list', (tester) async {
    await _pump(tester, province: PakistanProvince.punjab, city: 'Multan');
    await tester.tap(
      find.descendant(
        of: find.byType(CityPickerField),
        matching: find.byType(InkWell),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Ahmadpur Sial'), findsOneWidget, reason: 'opens on Punjab');
    await tester.tap(find.byTooltip('Change province'));
    await tester.pumpAndSettle();
    expect(find.text('Sindh'), findsOneWidget);
  });

  testWidgets('renders in Urdu (RTL) with large touch targets', (tester) async {
    await _pump(tester, locale: const Locale('ur'));
    await tester.tap(
      find.descendant(
        of: find.byType(CityPickerField),
        matching: find.byType(InkWell),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      Directionality.of(tester.element(find.byType(CityPickerSheet))),
      TextDirection.rtl,
    );
    final row = find.ancestor(
      of: find.text('سندھ'),
      matching: find.byType(InkWell),
    );
    expect(tester.getSize(row.first).height, greaterThanOrEqualTo(48));
  });

  testWidgets('required validator fires until a city is chosen', (
    tester,
  ) async {
    final key = GlobalKey<FormState>();
    await tester.pumpWidget(
      ProviderScope(
        child: ScreenUtilInit(
          designSize: const Size(360, 690),
          builder: (_, _) => MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Form(
                key: key,
                child: CityPickerField(onChanged: (_) {}),
              ),
            ),
          ),
        ),
      ),
    );
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Please choose your city.'), findsOneWidget);
  });
}
