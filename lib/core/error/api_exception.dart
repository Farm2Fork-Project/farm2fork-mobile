/// Typed application-facing error raised by the network layer.
///
/// Repositories surface [ApiException] (never raw [DioException]) so the UI can
/// branch on [kind] to pick a localized message. The backend returns a
/// consistent `{ statusCode, message, error }` body which is mapped here.
class ApiException implements Exception {
  const ApiException(this.kind, {this.statusCode, this.serverMessage});

  final ApiErrorKind kind;
  final int? statusCode;

  /// Raw backend `message`, if any. Not for direct display — the UI should map
  /// [kind] to a localized string; this is for logging/debugging only.
  final String? serverMessage;

  bool get isUnauthorized => kind == ApiErrorKind.unauthorized;

  @override
  String toString() =>
      'ApiException(kind: $kind, statusCode: $statusCode, '
      'serverMessage: $serverMessage)';
}

/// High-level error categories the UI can map to localized messages.
enum ApiErrorKind {
  /// No connectivity / DNS / connection refused.
  network,

  /// Connect/receive timeout.
  timeout,

  /// 401 — token missing, expired, or invalid.
  unauthorized,

  /// 403 — authenticated but not allowed.
  forbidden,

  /// 404 — resource not found.
  notFound,

  /// 400 / 422 — validation failed.
  validation,

  /// 5xx — server error.
  server,

  /// Anything else (including malformed responses / cancellation).
  unknown,
}
