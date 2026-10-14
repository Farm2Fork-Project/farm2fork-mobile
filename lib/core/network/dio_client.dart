import 'package:dio/dio.dart';
import 'package:farm2fork_mobile/core/config/app_config.dart';
import 'package:farm2fork_mobile/core/network/interceptors/auth_interceptor.dart';
import 'package:farm2fork_mobile/core/network/interceptors/error_interceptor.dart';
import 'package:farm2fork_mobile/core/network/interceptors/locale_interceptor.dart';
import 'package:farm2fork_mobile/core/storage/token_storage.dart';

/// Builds the single, centrally-configured [Dio] instance used by every API
/// service (master context 8.1 / ruleset 11). Widgets and services must never
/// construct their own Dio.
Dio buildDioClient({
  required TokenStorage tokenStorage,
  required LanguageCodeSupplier languageCode,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(milliseconds: AppConfig.connectTimeoutMs),
      receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeoutMs),
      contentType: 'application/json',
      // Let the ErrorInterceptor decide; don't throw on the raw status here.
      validateStatus: (status) =>
          status != null && status >= 200 && status < 300,
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(tokenStorage),
    LocaleInterceptor(languageCode),
    ErrorInterceptor(),
  ]);

  return dio;
}
