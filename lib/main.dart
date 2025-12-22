import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      splitScreenMode: true,
      designSize: const Size(393, 852),
      builder: (context, child) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        themeAnimationStyle: const AnimationStyle(
          curve: Curves.easeInOut,
          duration: Duration(milliseconds: 300),
          reverseCurve: Curves.easeInOut,
        ),
        title: 'Farm2Fork',
      ),
    );
  }
}
