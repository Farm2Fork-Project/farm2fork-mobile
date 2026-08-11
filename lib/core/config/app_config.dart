/// Centralised runtime configuration.
///
/// Values are read from compile-time environment via `--dart-define` so the
/// same build can target a local backend, a staging host, or pure mock mode
/// without code changes. Sensible defaults assume an Android emulator talking
/// to a Nest.js backend on the host machine (10.0.2.2 maps to host localhost).
abstract final class AppConfig {
  /// Base URL of the Nest.js API. Override with:
  ///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  /// When true, repositories use in-memory mock data and never hit the network.
  /// Lets the app run end-to-end while the backend is unavailable.
  ///   flutter run --dart-define=USE_MOCKS=true
  static const bool useMocks = bool.fromEnvironment(
    'USE_MOCKS',
    defaultValue: true,
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
