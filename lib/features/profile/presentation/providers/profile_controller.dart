import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/features/auth/data/models/auth_user.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/profile/data/models/user_profile.dart';
import 'package:farm2fork_mobile/features/profile/data/repositories/profile_repository_provider.dart';

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, UserProfile>(
      ProfileController.new,
    );

/// The signed-in user's full profile. Every successful edit also refreshes the
/// auth user so the avatar and name update everywhere they are shown.
class ProfileController extends AsyncNotifier<UserProfile> {
  @override
  Future<UserProfile> build() {
    // Re-fetch only when a different account signs in, not on every edit.
    ref.watch(authControllerProvider.select((a) => a.value?.user?.id));
    return ref.read(profileRepositoryProvider).fetch();
  }

  Future<UserProfile> save(ProfileUpdate update) =>
      _apply(() => ref.read(profileRepositoryProvider).update(update));

  Future<UserProfile> uploadAvatar(AvatarUpload upload) =>
      _apply(() => ref.read(profileRepositoryProvider).uploadAvatar(upload));

  Future<UserProfile> removeAvatar() =>
      _apply(() => ref.read(profileRepositoryProvider).removeAvatar());

  Future<UserProfile> reload() async {
    final profile = await ref.read(profileRepositoryProvider).fetch();
    _publish(profile);
    return profile;
  }

  Future<UserProfile> _apply(Future<UserProfile> Function() action) async {
    final profile = await action();
    _publish(profile);
    return profile;
  }

  void _publish(UserProfile profile) {
    state = AsyncData(profile);
    final auth = ref.read(authControllerProvider).value?.user;
    if (auth == null) return;
    ref
        .read(authControllerProvider.notifier)
        .updateCurrentUser(
          AuthUser(
            id: auth.id,
            email: auth.email,
            role: auth.role,
            isVerified: profile.user.isVerified,
            isActive: profile.user.isActive,
            fullName: profile.user.fullName,
            avatarUrl: profile.user.avatarUrl,
            phone: profile.user.phone,
          ),
        );
  }
}
