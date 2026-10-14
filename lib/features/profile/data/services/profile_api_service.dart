import 'package:dio/dio.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/features/profile/data/models/user_profile.dart';

/// Transport for the self-service profile endpoints. Failures surface as
/// [ApiException] (mapped by the shared ErrorInterceptor).
class ProfileApiService {
  ProfileApiService(this._dio);

  final Dio _dio;

  /// GET /auth/me/profile
  Future<UserProfile> fetch() async {
    final response = await _dio.get<Map<String, dynamic>>('/auth/me/profile');
    return UserProfile.fromJson(_body(response.data));
  }

  /// PATCH /auth/me/profile — only the fields set on [update] are sent.
  Future<UserProfile> update(ProfileUpdate update) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/auth/me/profile',
      data: update.toJson(),
    );
    return UserProfile.fromJson(_body(response.data));
  }

  /// PUT /auth/me/avatar — multipart field `file` (JPEG, PNG or WebP, <= 5 MB).
  Future<UserProfile> uploadAvatar(AvatarUpload upload) async {
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        upload.bytes,
        filename: upload.fileName,
        contentType: DioMediaType('image', 'jpeg'),
      ),
    });
    final response = await _dio.put<Map<String, dynamic>>(
      '/auth/me/avatar',
      data: form,
    );
    return UserProfile.fromJson(_body(response.data));
  }

  /// DELETE /auth/me/avatar
  Future<UserProfile> removeAvatar() async {
    final response = await _dio.delete<Map<String, dynamic>>('/auth/me/avatar');
    return UserProfile.fromJson(_body(response.data));
  }

  Map<String, dynamic> _body(Map<String, dynamic>? data) {
    if (data == null) throw const ApiException(ApiErrorKind.unknown);
    return data;
  }
}
