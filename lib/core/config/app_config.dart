import 'package:farm2fork_mobile/core/config/release_config.dart';

/// Centralised runtime configuration.
///
/// Values are read from compile-time environment via `--dart-define` so the
/// same build can target a local backend, a staging host, or pure mock mode
/// without code changes. Sensible defaults assume an Android emulator talking
/// to a Nest.js backend on the host machine (10.0.2.2 maps to host localhost).
abstract final class AppConfig {
  static void validateForRelease() {
    final errors = validateReleaseConfig(
      apiBaseUrl: apiBaseUrl,
      publicTraceOrigin: publicTraceOrigin,
      traceLinkHost: const String.fromEnvironment('TRACE_LINK_HOST'),
      apiExplicit: const bool.hasEnvironment('API_BASE_URL'),
      traceExplicit: const bool.hasEnvironment('PUBLIC_TRACE_ORIGIN'),
      useMocks: const String.fromEnvironment(
        'USE_MOCKS',
        defaultValue: 'false',
      ),
      paymentSimulator: const String.fromEnvironment(
        'PAYMENT_SIMULATOR_ENABLED',
        defaultValue: 'false',
      ),
    );
    if (errors.isNotEmpty) {
      throw StateError('Invalid release configuration: ${errors.join(' ')}');
    }
  }

  /// Canonical public QR origin; must match the website and native link host.
  static const String publicTraceOrigin = String.fromEnvironment(
    'PUBLIC_TRACE_ORIGIN',
    defaultValue: 'https://farm2fork.tech',
  );

  /// Base URL of the Nest.js API. Override with:
  ///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api',
  );

  /// When true, repositories use in-memory mock data and never hit the network.
  /// Lets the app run end-to-end while the backend is unavailable.
  ///   flutter run --dart-define=USE_MOCKS=true
  static const bool useMocks = bool.fromEnvironment(
    'USE_MOCKS',
    defaultValue: false,
  );

  /// Enables the authenticated backend payment simulator in a non-mock build.
  /// This must remain false for normal API builds.
  static const bool paymentSimulatorEnabled = bool.fromEnvironment(
    'PAYMENT_SIMULATOR_ENABLED',
    defaultValue: false,
  );

  /// Request/response timeout in milliseconds.
  static const int connectTimeoutMs = int.fromEnvironment(
    'CONNECT_TIMEOUT_MS',
    defaultValue: 15000,
  );
  static const int receiveTimeoutMs = int.fromEnvironment(
    'RECEIVE_TIMEOUT_MS',
    defaultValue: 15000,
  );
}
