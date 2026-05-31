import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:farm2fork_mobile/core/localization/generated/app_localizations.dart';
import 'package:farm2fork_mobile/app/router.dart';
import 'package:farm2fork_mobile/core/localization/locale_controller.dart';
import 'package:farm2fork_mobile/core/theme/app_theme.dart';

class Farm2ForkApp extends ConsumerWidget {
  const Farm2ForkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(localeControllerProvider);

    return ScreenUtilInit(
      designSize: const Size(360, 690), // Base design size for responsiveness
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Farm2Fork',
          theme: AppTheme.lightTheme,
          routerConfig: goRouter,
          locale: localeAsync.value ?? const Locale('en'),
          supportedLocales: const [Locale('en'), Locale('ur')],
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
