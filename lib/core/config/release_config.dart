/// Pure release preflight; error messages contain field names, never values.
List<String> validateReleaseConfig({
  required String apiBaseUrl,
  required String publicTraceOrigin,
  required String traceLinkHost,
  required bool apiExplicit,
  required bool traceExplicit,
  required String useMocks,
  required String paymentSimulator,
}) {
  final errors = <String>[];
  bool https(Uri? uri) =>
      uri != null &&
      uri.scheme == 'https' &&
      uri.host.isNotEmpty &&
      uri.userInfo.isEmpty &&
      !uri.hasQuery &&
      !uri.hasFragment &&
      !const ['localhost', '10.0.2.2', '127.0.0.1', '::1'].contains(uri.host) &&
      !uri.host.endsWith('.localhost') &&
      !uri.host.endsWith('.local');
  final api = Uri.tryParse(apiBaseUrl);
  final trace = Uri.tryParse(publicTraceOrigin);
  if (!apiExplicit || !https(api)) {
    errors.add(
      'API_BASE_URL must be explicit HTTPS with a non-local host and no credentials/query/fragment.',
    );
  }
  if (!traceExplicit ||
      !https(trace) ||
      (trace!.path.isNotEmpty && trace.path != '/')) {
    errors.add('PUBLIC_TRACE_ORIGIN must be an explicit HTTPS origin.');
  }
  if (traceLinkHost.isEmpty || trace?.host != traceLinkHost) {
    errors.add('TRACE_LINK_HOST must match PUBLIC_TRACE_ORIGIN host.');
  }
  if (useMocks != 'false') errors.add('USE_MOCKS must be false for release.');
  if (paymentSimulator != 'false') {
    errors.add('PAYMENT_SIMULATOR_ENABLED must be false for release.');
  }
  return errors;
}
