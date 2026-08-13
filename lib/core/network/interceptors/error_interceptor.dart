import 'package:dio/dio.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';

/// Translates low-level [DioException]s into typed [ApiException]s so
/// repositories and the UI never deal with transport details.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: _toApiException(err),
      ),
    );
  }

  ApiException _toApiException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(ApiErrorKind.timeout);
      case DioExceptionType.connectionError:
        return const ApiException(ApiErrorKind.network);
      case DioExceptionType.badCertificate:
        return const ApiException(ApiErrorKind.network);
      case DioExceptionType.cancel:
        return const ApiException(ApiErrorKind.unknown);
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        return _fromResponse(err);
    }
  }

  ApiException _fromResponse(DioException err) {
    final status = err.response?.statusCode;
    final serverMessage = _extractMessage(err.response?.data);
    final code = _extractCode(err.response?.data);

    final kind = switch (status) {
      400 || 422 => ApiErrorKind.validation,
      401 => ApiErrorKind.unauthorized,
      403 => ApiErrorKind.forbidden,
      404 => ApiErrorKind.notFound,
      _ when status != null && status >= 500 => ApiErrorKind.server,
      _ when status == null => ApiErrorKind.network,
      _ => ApiErrorKind.unknown,
    };

    return ApiException(
      kind,
      statusCode: status,
      code: code,
      serverMessage: serverMessage,
    );
  }

  /// Backend error shape: `{ statusCode, message, error }`. `message` may be a
  /// string or a list of validation strings.
  String? _extractMessage(Object? data) {
    if (data is Map) {
      final message = data['message'];
      if (message is String) return message;
      if (message is List && message.isNotEmpty) {
        return message.map((e) => e.toString()).join(', ');
      }
    }
    return null;
  }

  String? _extractCode(Object? data) {
    if (data is Map && data['code'] is String) {
      return data['code'] as String;
    }
    return null;
  }
}
