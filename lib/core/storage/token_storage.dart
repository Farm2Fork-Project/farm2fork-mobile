import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Securely persists the JWT access token (master context 15.3: sensitive data
/// must never be stored in plain local storage).
///
/// Backed by the platform keystore/keychain via flutter_secure_storage.
class TokenStorage {
  TokenStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'auth.access_token';

  final FlutterSecureStorage _storage;

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  Future<void> writeAccessToken(String token) =>
      _storage.write(key: _accessTokenKey, value: token);

  Future<void> clear() => _storage.delete(key: _accessTokenKey);
}
