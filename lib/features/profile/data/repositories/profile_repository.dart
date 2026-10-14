import 'package:farm2fork_mobile/features/profile/data/models/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> fetch();

  /// Sends only the changed fields and returns the refreshed profile.
  Future<UserProfile> update(ProfileUpdate update);

  Future<UserProfile> uploadAvatar(AvatarUpload upload);

  Future<UserProfile> removeAvatar();
}
