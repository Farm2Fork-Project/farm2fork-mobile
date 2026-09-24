final RegExp _objectId = RegExp(r'^[a-fA-F0-9]{24}$');

/// Accepts what a person can actually paste or scan: a bare product id, or a
/// full QR trace URL (`https://…/trace/<id>`, with or without a trailing
/// slash, query or fragment). Returns null when the input can't be a product
/// id, so the UI can say so without a network round trip.
String? parseTraceProductId(String input) {
  final value = input.trim();
  if (value.isEmpty) return null;
  if (_objectId.hasMatch(value)) return value.toLowerCase();

  final path = value
      .split(RegExp(r'[?#]'))
      .first
      .replaceAll(RegExp(r'/+$'), '');
  final candidate = path.split('/').last;
  return _objectId.hasMatch(candidate) ? candidate.toLowerCase() : null;
}

/// First and last characters of a Fabric tx id: readable, still checkable.
String shortenTxHash(String txHash) => txHash.length <= 20
    ? txHash
    : '${txHash.substring(0, 10)}…${txHash.substring(txHash.length - 8)}';
