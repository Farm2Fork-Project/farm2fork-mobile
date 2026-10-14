import 'package:farm2fork_mobile/features/profile/data/models/user_profile.dart';
import 'package:farm2fork_mobile/features/profile/data/repositories/profile_repository.dart';
import 'package:farm2fork_mobile/features/profile/data/services/profile_api_service.dart';

class ApiProfileRepository implements ProfileRepository {
  ApiProfileRepository(this._api);

  final ProfileApiService _api;

  @override
  Future<UserProfile> fetch() => _api.fetch();

  @override
  Future<UserProfile> update(ProfileUpdate update) => _api.update(update);

  @override
  Future<UserProfile> uploadAvatar(AvatarUpload upload) =>
      _api.uploadAvatar(upload);

  @override
  Future<UserProfile> removeAvatar() => _api.removeAvatar();
}
