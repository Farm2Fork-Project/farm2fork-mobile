import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

Uri? safepayCheckoutUri(String? value) {
  final uri = Uri.tryParse(value ?? '');
  if (uri == null ||
      uri.scheme != 'https' ||
      uri.userInfo.isNotEmpty ||
      (uri.hasPort && uri.port != 443) ||
      !{'sandbox.api.getsafepay.com', 'getsafepay.com'}.contains(uri.host)) {
    return null;
  }
  return uri;
}

typedef CheckoutLauncher = Future<bool> Function(Uri);
final checkoutLauncherProvider = Provider<CheckoutLauncher>(
  (ref) =>
      (uri) => launchUrl(uri, mode: LaunchMode.externalApplication),
);
