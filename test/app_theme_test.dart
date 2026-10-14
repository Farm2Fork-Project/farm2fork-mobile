import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/core/theme/app_theme.dart';

void main() {
  testWidgets(
    'lightTheme falls back to Noto Nastaliq Urdu for scripts the default font lacks',
    (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 690),
          builder: (context, child) => MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(body: Text('نمونہ')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final style = DefaultTextStyle.of(
        tester.element(find.text('نمونہ')),
      ).style;
      expect(style.fontFamilyFallback, contains('NotoNastaliqUrdu'));
    },
  );
}
