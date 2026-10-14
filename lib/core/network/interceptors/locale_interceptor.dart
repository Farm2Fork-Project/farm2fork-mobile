import 'package:dio/dio.dart';

/// Supplies the current language code ('en' | 'ur') at request time.
typedef LanguageCodeSupplier = String Function();

/// Attaches `Accept-Language` to every request so the backend can return
/// localized error messages (master context 7.4 / 11.x). The frontend never
/// depends on the backend for basic UI strings — this is for server messages.
class LocaleInterceptor extends Interceptor {
  LocaleInterceptor(this._languageCode);

  final LanguageCodeSupplier _languageCode;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept-Language'] = _languageCode();
    handler.next(options);
  }
}
