/// Keeps one validated private order destination across the multi-screen auth
/// flow. It lives as long as the router and is consumed once after sign-in.
class OrderAuthRecovery {
  String? _pending;
  static String? validate(String? value) =>
      value != null && RegExp(r'^/orders/[a-fA-F0-9]{24}$').hasMatch(value)
      ? value
      : null;

  void observe(Uri uri, {required bool authenticated}) {
    if (authenticated) return;
    if (uri.path.startsWith('/auth/')) {
      _pending = validate(uri.queryParameters['next']) ?? _pending;
    } else if (validate(uri.path) case final String order) {
      _pending = order;
    } else {
      _pending = null;
    }
  }

  String? consume() {
    final next = _pending;
    _pending = null;
    return next;
  }
}
