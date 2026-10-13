import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/core/localization/generated/app_localizations.dart';
import 'package:farm2fork_mobile/features/auth/data/models/auth_user.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/profile/data/models/user_profile.dart';
import 'package:farm2fork_mobile/features/profile/data/repositories/profile_repository.dart';
import 'package:farm2fork_mobile/features/profile/data/repositories/profile_repository_provider.dart';
import 'package:farm2fork_mobile/features/profile/data/services/avatar_photo_source.dart';

const buyerUser = AuthUser(
  id: 'u1',
  email: 'ayesha@example.test',
  role: AppUserRole.buyer,
  isVerified: true,
  isActive: true,
  fullName: 'Ayesha Khan',
);

UserProfile buyerProfile({String? avatarUrl, String? fullName}) => UserProfile(
  user: ProfileUser(
    id: 'u1',
    email: 'ayesha@example.test',
    role: 'buyer',
    phone: '+923001234567',
    fullName: fullName ?? 'Ayesha Khan',
    avatarUrl: avatarUrl,
    isVerified: true,
  ),
  displayName: fullName ?? 'Ayesha Khan',
  profile: const ProfileDetails.buyer(
    cnicMasked: '*********5671',
    businessName: 'Khan Traders',
    businessType: 'retailer',
  ),
);

class TestAuth extends AuthController {
  TestAuth([this.user = buyerUser]);
  final AuthUser user;
  int signOuts = 0;

  @override
  Future<AuthState> build() async =>
      AuthState(status: AuthStatus.authenticated, user: user);

  @override
  Future<void> signOut() async {
    signOuts++;
  }
}

class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository(this.profile);

  UserProfile profile;
  final updates = <ProfileUpdate>[];
  final uploads = <AvatarUpload>[];
  int removes = 0;
  Object? updateError;
  Object? uploadError;

  @override
  Future<UserProfile> fetch() async => profile;

  @override
  Future<UserProfile> update(ProfileUpdate update) async {
    if (updateError != null) throw updateError!;
    updates.add(update);
    final user = profile.user.copyWith(
      fullName: update.fullName ?? profile.user.fullName,
      phone: update.phone ?? profile.user.phone,
    );
    final details = profile.profile;
    return profile = UserProfile(
      user: user,
      displayName: user.fullName ?? profile.displayName,
      profile: details is BuyerProfileDetails
          ? details.copyWith(
              businessName: update.businessName ?? details.businessName,
              businessType: update.businessType ?? details.businessType,
            )
          : details,
    );
  }

  @override
  Future<UserProfile> uploadAvatar(AvatarUpload upload) async {
    if (uploadError != null) throw uploadError!;
    uploads.add(upload);
    return profile = UserProfile(
      user: profile.user.copyWith(
        avatarUrl: 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQ',
      ),
      displayName: profile.displayName,
      profile: profile.profile,
    );
  }

  @override
  Future<UserProfile> removeAvatar() async {
    removes++;
    return profile = UserProfile(
      user: profile.user.copyWith(avatarUrl: null),
      displayName: profile.displayName,
      profile: profile.profile,
    );
  }
}

class FakeAvatarSource implements AvatarPhotoSource {
  AvatarUpload? result = const AvatarUpload(bytes: [0xFF, 0xD8, 0xFF, 0xD9]);
  Object? error;
  AvatarSource? lastSource;

  @override
  Future<AvatarUpload?> pick(
    AvatarSource source, {
    required String cropTitle,
  }) async {
    lastSource = source;
    if (error != null) throw error!;
    return result;
  }
}

/// App shell with the app's localizations, ScreenUtil and optional text scale.
Widget testApp({
  required Widget child,
  Locale locale = const Locale('en'),
  double textScale = 1.0,
}) {
  return ScreenUtilInit(
    designSize: const Size(360, 690),
    builder: (_, _) => MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, c) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: c!,
      ),
      home: child,
    ),
  );
}

List<Override> profileOverrides({
  required FakeProfileRepository repo,
  FakeAvatarSource? avatar,
  TestAuth? auth,
}) => [
  authControllerProvider.overrideWith(() => auth ?? TestAuth()),
  profileRepositoryProvider.overrideWithValue(repo),
  if (avatar != null) avatarPhotoSourceProvider.overrideWithValue(avatar),
];

UserProfile farmerProfile() => const UserProfile(
  user: ProfileUser(
    id: 'f1',
    email: 'farmer@example.test',
    role: 'farmer',
    phone: '+923001234567',
    fullName: 'محمد اسلم',
    isVerified: true,
  ),
  displayName: 'محمد اسلم',
  profile: ProfileDetails.farmer(
    cnicMasked: '*********5671',
    farmName: 'سبز وادی فارم',
    cropTypes: ['گندم', 'ٹماٹر'],
    landSizeAcres: 12.5,
    farmLocation: FarmLocationSummary(
      address: 'Chak 5',
      city: 'Multan',
      province: 'Punjab',
      complete: true,
    ),
  ),
);

UserProfile transporterProfile() => const UserProfile(
  user: ProfileUser(
    id: 't1',
    email: 'driver@example.test',
    role: 'transporter',
    fullName: 'Bilal Ahmed',
    isVerified: true,
  ),
  displayName: 'Bilal Ahmed',
  profile: ProfileDetails.transporter(
    cnicMasked: '*********5671',
    vehicleType: 'van',
    vehicleNumber: 'LEA-1234',
    serviceAreas: ['Lahore', 'Faisalabad'],
  ),
);

/// Hosts [child] at `/edit` behind a home page, with a real GoRouter so
/// `context.push`/`context.pop` and back handling behave as in the app.
Widget testRouterApp({
  required Widget child,
  Locale locale = const Locale('en'),
  double textScale = 1.0,
}) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, _) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => context.push('/edit'),
              child: const Text('open'),
            ),
          ),
        ),
      ),
      GoRoute(path: '/edit', builder: (_, _) => child),
      GoRoute(
        path: '/settings/farm-location',
        builder: (_, _) => const Scaffold(body: Text('farm location page')),
      ),
    ],
  );
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
