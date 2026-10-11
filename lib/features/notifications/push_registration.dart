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
