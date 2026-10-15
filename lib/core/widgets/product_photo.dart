import 'package:flutter/material.dart';
import 'package:farm2fork_mobile/core/config/app_config.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';

/// Public listing media with an honest fallback on broken URLs. Data images
/// are used only by the explicit mock repository; API images resolve normally.
class ProductPhoto extends StatelessWidget {
  const ProductPhoto({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.label,
  });
  final String url;
  final double? width;
  final double? height;
  final String? label;
  Widget _fallback() => SizedBox(
    width: width,
    height: height,
    child: const Center(
      child: Icon(Icons.spa_rounded, color: AppColors.primaryGreenDark),
    ),
  );
  @override
  Widget build(BuildContext context) {
    try {
      final uri = Uri.parse(url);
      if (uri.scheme == 'data') {
        return Image.memory(
          uri.data!.contentAsBytes(),
          width: width,
          height: height,
          fit: BoxFit.cover,
          semanticLabel: label,
          errorBuilder: (_, _, _) => _fallback(),
        );
      }
      final resolved = uri.hasScheme
          ? uri
          : Uri.parse(AppConfig.apiBaseUrl).resolveUri(uri);
      return Image.network(
        resolved.toString(),
        width: width,
        height: height,
        fit: BoxFit.cover,
        semanticLabel: label,
        errorBuilder: (_, _, _) => _fallback(),
      );
    } catch (_) {
      return _fallback();
    }
  }
}
