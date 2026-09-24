import 'package:farm2fork_mobile/core/config/app_config.dart';

/// Uploaded files come back either as absolute (Cloudinary) URLs or, in
/// local development, as API-root-relative paths such as
/// "/api/files/public/abc.jpg"; the latter resolve against the API origin.
String resolveMediaUrl(String url) {
  if (!url.startsWith('/')) return url;
  return Uri.parse(AppConfig.apiBaseUrl).resolve(url).toString();
}
