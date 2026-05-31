import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final localeRepositoryProvider = Provider<LocaleRepository>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return LocaleRepository(storage);
});

class LocaleRepository {
  final FlutterSecureStorage _storage;

  LocaleRepository(this._storage);

  static const _localeKey = 'selected_locale';

  Future<String?> getLocale() async {
    try {
      return await _storage.read(key: _localeKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveLocale(String languageCode) async {
    try {
      await _storage.write(key: _localeKey, value: languageCode);
    } catch (_) {
      // Swallowing storage write errors in repository as per guidelines, or logging
    }
  }
}
