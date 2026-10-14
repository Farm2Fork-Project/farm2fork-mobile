abstract interface class PushGateway {
  Future<bool> requestPermission();
  Future<String?> getToken();
  Future<void> deleteToken();
}

class PushRegistration {
  PushRegistration(this.gateway, this.registerToken, this.clearToken);
  final PushGateway gateway;
  final Future<void> Function(String token) registerToken;
  final Future<void> Function() clearToken;
  Future<bool> enable() async {
    if (!await gateway.requestPermission()) return false;
    final token = await gateway.getToken();
    if (token == null || token.isEmpty) return false;
    await registerToken(token);
    return true;
  }

  Future<void> disable() async {
    await clearToken();
    await gateway.deleteToken();
  }
}

/// Serializes token writes and lets revocation invalidate pending SDK work.
class PushOperations {
  Future<void> _tail = Future.value();
  int _revision = 0;
  bool _accepting = true;
  String? _session;
  void beginSession(String? userId) {
    if (_session == userId) return;
    _session = userId;
    _revision++;
    _accepting = userId != null;
  }

  void enable() {
    _revision++;
    _accepting = true;
  }

  Future<bool> register(Future<bool> Function(bool Function()) operation) {
    final revision = _revision;
    final result = _tail.then(
      (_) => operation(() => revision == _revision && _accepting),
    );
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<void> revoke(Future<void> Function() cleanup) {
    _revision++;
    _accepting = false;
    final result = _tail.then((_) => cleanup());
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<void> cancelAndDrain() {
    _revision++;
    _accepting = false;
    return _tail;
  }
}
