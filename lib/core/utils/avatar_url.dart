import 'package:farm2fork_mobile/core/config/app_config.dart';

/// The backend serves 256px square avatars through Cloudinary with
/// `w_256,h_256` in the transformation. For another size, swap those two
/// parameters (see the backend's profile-and-avatar contract).
String avatarUrlForSize(String url, int logicalSize, double devicePixelRatio) {
  final pixels = _bucket((logicalSize * devicePixelRatio).ceil());
  return url.replaceFirst('w_256,h_256', 'w_$pixels,h_$pixels');
}

// Few buckets keep the CDN cache warm instead of one variant per device.
int _bucket(int pixels) {
  for (final size in const [96, 192, 256, 384, 512]) {
    if (pixels <= size) return size;
  }
  return 512;
}

/// Local development serves a root-relative `/api/files/public/...` path. The
/// API base URL ends in `/api`, so only its origin is needed.
String resolveAvatarUrl(
  String url, {
  String apiBaseUrl = AppConfig.apiBaseUrl,
}) {
  if (!url.startsWith('/')) return url;
  final base = Uri.parse(apiBaseUrl);
  return Uri(
    scheme: base.scheme,
    host: base.host,
    port: base.hasPort ? base.port : null,
    path: url,
  ).toString();
}

/// Up to two initials for the fallback avatar, e.g. `Ayesha Khan` -> `AK`.
String initialsFor(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  String first(String s) => String.fromCharCode(s.runes.first).toUpperCase();
  if (parts.length == 1) return first(parts.first);
  return first(parts.first) + first(parts.last);
}
