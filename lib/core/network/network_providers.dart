import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/localization/locale_controller.dart';
import 'package:farm2fork_mobile/core/network/dio_client.dart';
import 'package:farm2fork_mobile/core/storage/token_storage.dart';

/// Secure JWT storage, shared across the app.
final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

/// The single shared Dio client. Reads the current locale from
/// [localeControllerProvider] at request time via a supplier closure, so the
/// Accept-Language header always reflects the active language without rebuilding
/// the client on every toggle.
final dioProvider = Provider<Dio>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return buildDioClient(
    tokenStorage: tokenStorage,
    languageCode: () =>
        ref.read(localeControllerProvider).value?.languageCode ?? 'en',
  );
});
