import 'package:farm2fork_mobile/core/config/app_config.dart';

final RegExp _objectId = RegExp(r'^[a-fA-F0-9]{24}$');

enum TraceLinkKind { product, order }

class TraceLink {
  const TraceLink(this.kind, this.id);
  final TraceLinkKind kind;
  final String id;
  String get path =>
      kind == TraceLinkKind.order ? '/trace/orders/$id' : '/trace/products/$id';
}

/// Recognizes only Farm2Fork trace destinations. A foreign QR is never opened.
TraceLink? parseTraceLink(String input) {
  final value = input.trim();
  if (_objectId.hasMatch(value)) {
    return TraceLink(TraceLinkKind.product, value.toLowerCase());
  }
  final uri = Uri.tryParse(value);
  if (uri == null || uri.userInfo.isNotEmpty) return null;
  final configured = Uri.parse(AppConfig.publicTraceOrigin);
  final isWeb =
      uri.scheme == configured.scheme &&
      uri.host == configured.host &&
      uri.port == configured.port;
  final isLegacy =
      uri.scheme == 'https' && uri.host == 'farm2fork.com' && !uri.hasPort;
  final isScheme =
      uri.scheme == 'farm2fork' && uri.host == 'app' && !uri.hasPort;
  if (!isWeb && !isLegacy && !isScheme) return null;
  final parts = uri.pathSegments.toList();
  if (parts.isNotEmpty && parts.last.isEmpty) parts.removeLast();
  if (parts.isEmpty || parts.first != 'trace') return null;
  if (parts.length == 2 && _objectId.hasMatch(parts[1])) {
    return TraceLink(TraceLinkKind.product, parts[1].toLowerCase());
  }
  if (parts.length == 3 && _objectId.hasMatch(parts[2])) {
    if (parts[1] == 'products') {
      return TraceLink(TraceLinkKind.product, parts[2].toLowerCase());
    }
    if (parts[1] == 'orders') {
      return TraceLink(TraceLinkKind.order, parts[2].toLowerCase());
    }
  }
  return null;
}

String? parseTraceProductId(String input) {
  final link = parseTraceLink(input);
  return link?.kind == TraceLinkKind.product ? link!.id : null;
}

String shortenTxHash(String txHash) => txHash.length <= 20
    ? txHash
    : '${txHash.substring(0, 10)}…${txHash.substring(txHash.length - 8)}';
