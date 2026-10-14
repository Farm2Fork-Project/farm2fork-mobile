import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/core/localization/generated/app_localizations.dart';
import 'package:farm2fork_mobile/features/auth/data/models/auth_user.dart';
import 'package:farm2fork_mobile/features/auth/data/models/onboarding_request.dart';
import 'package:farm2fork_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:farm2fork_mobile/features/auth/data/repositories/auth_repository_provider.dart';

/// Records what the screens ask of the auth layer and lets a test script the
/// answer. Legacy mock-era methods are unused.
class FakeAuthRepository implements AuthRepository {
  FirebaseSignInOutcome emailOutcome = const FirebaseSignedIn(
    AuthUser(
      id: 'u1',
      email: 'a@b.com',
      role: AppUserRole.buyer,
      isVerified: true,
      isActive: true,
    ),
  );
  FirebaseSignInOutcome? googleOutcome;
  Object? signInError;
  Object? resetError;
  Object? onboardingError;
  Object? resendError;

  final signIns = <({String email, String password})>[];
  final resets = <String>[];
  final onboarded = <OnboardingRequest>[];
  int resends = 0;
  int signOuts = 0;

  @override
  Future<AuthUser?> restoreSession() async => null;

  @override
  Future<FirebaseSignInOutcome> signInWithGoogle() async =>
      googleOutcome ?? emailOutcome;

  @override
  Future<FirebaseSignInOutcome> signInWithEmail({
    required String email,
    required String password,
  }) async {
    signIns.add((email: email, password: password));
    if (signInError != null) throw signInError!;
    return emailOutcome;
  }

  @override
  Future<FirebaseSignInOutcome> refreshVerifiedEmailSession() async =>
      emailOutcome;

  @override
  Future<void> sendPasswordReset({required String email}) async {
    if (resetError != null) throw resetError!;
    resets.add(email);
  }

  @override
  Future<void> resendEmailVerification() async {
    if (resendError != null) throw resendError!;
    resends++;
  }

  @override
  Future<AuthUser> completeOnboarding(OnboardingRequest request) async {
    if (onboardingError != null) throw onboardingError!;
    onboarded.add(request);
    return AuthUser(
      id: 'new',
      email: 'new@b.com',
      role: switch (request.role) {
        OnboardingRole.farmer => AppUserRole.farmer,
        OnboardingRole.buyer => AppUserRole.buyer,
        OnboardingRole.transporter => AppUserRole.transporter,
      },
      isVerified: true,
      isActive: true,
      fullName: request.fullName,
    );
  }

  @override
  Future<void> signOut() async {
    signOuts++;
  }

  @override
  Future<AuthUser> signIn({required String email, required String password}) =>
      throw UnimplementedError();

  @override
  Future<AuthUser> signUp({required SignUpRequest request}) =>
      throw UnimplementedError();
}

List<Override> authOverrides(FakeAuthRepository repo) => [
  authRepositoryProvider.overrideWithValue(repo),
];

/// Hosts [home] at [initial] next to stub pages for the routes auth screens
/// navigate to, so a test can assert where the user ended up.
GoRouter stubbedAuthRouter({
  required String initial,
  required Map<String, Widget> screens,
}) {
  return GoRouter(
    initialLocation: initial,
    routes: [
      for (final entry in screens.entries)
        GoRoute(path: entry.key, builder: (_, _) => entry.value),
      for (final path in const [
        '/auth/login',
        '/auth/onboarding',
        '/auth/verify',
        '/guest/marketplace',
      ])
        if (!screens.containsKey(path))
          GoRoute(
            path: path,
            builder: (_, _) => Scaffold(body: Text('stub:$path')),
          ),
    ],
  );
}

Widget authTestApp({
  required GoRouter router,
  Locale locale = const Locale('en'),
  double textScale = 1.0,
}) {
  return ScreenUtilInit(
    designSize: const Size(360, 690),
    builder: (_, _) => MaterialApp.router(
      routerConfig: router,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, c) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: c!,
      ),
    ),
  );
}
