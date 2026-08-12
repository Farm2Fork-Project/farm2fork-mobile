import 'package:dio/dio.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';

/// Thin transport layer over the backend Firebase-auth endpoints. Returns raw
/// decoded JSON (`{ accessToken, user }`); mapping to models happens in the
/// repository. Throws [ApiException] (already mapped by ErrorInterceptor).
class AuthApiService {
  AuthApiService(this._dio);

  final Dio _dio;

  /// POST /auth/firebase — exchange a Firebase ID token for a backend session.
  /// A 409 response means the identity has no account yet (onboarding needed).
  Future<Map<String, dynamic>> signInWithFirebase(String idToken) {
    return _post('/auth/firebase', {'idToken': idToken});
  }

  /// POST /auth/firebase/onboard/{role} — create the account + role profile.
  Future<Map<String, dynamic>> onboard(
    String rolePath,
    Map<String, dynamic> body,
  ) {
    return _post('/auth/firebase/onboard/$rolePath', body);
  }

  /// GET /auth/me — the current authenticated user (used to restore a session).
  Future<Map<String, dynamic>> me() async {
    final response = await _dio.get<Map<String, dynamic>>('/auth/me');
    return _requireBody(response.data);
  }

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    final response = await _dio.post<Map<String, dynamic>>(path, data: body);
    return _requireBody(response.data);
  }

  Map<String, dynamic> _requireBody(Map<String, dynamic>? data) {
    if (data == null) {
      throw const ApiException(ApiErrorKind.unknown);
    }
    return data;
  }
}
