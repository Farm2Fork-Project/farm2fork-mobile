import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/utils/avatar_url.dart';

/// Round profile picture. Shows [imageUrl] (the backend's Cloudinary URL,
/// re-sized for [size]) and falls back to the person's initials while it loads,
/// when there is no photo, or when the image cannot be fetched.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 48,
    this.semanticLabel,
  });

  final String name;
  final String? imageUrl;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    final initials = _Initials(name: name, size: size);
    Widget content = initials;
    if (url != null && url.isNotEmpty) {
      if (url.startsWith('data:')) {
        content = Image.memory(
          UriData.parse(url).contentAsBytes(),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => initials,
        );
      } else {
        final dpr = MediaQuery.devicePixelRatioOf(context);
        content = CachedNetworkImage(
          imageUrl: resolveAvatarUrl(avatarUrlForSize(url, size.round(), dpr)),
          width: size,
          height: size,
          fit: BoxFit.cover,
          fadeInDuration: const Duration(milliseconds: 150),
          placeholder: (_, _) => initials,
          errorWidget: (_, _, _) => initials,
        );
      }
    }
    return Semantics(
      label: semanticLabel,
      image: true,
      excludeSemantics: semanticLabel != null,
      child: ClipOval(
        child: SizedBox.square(dimension: size, child: content),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.name, required this.size});
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryGreenSoft,
      alignment: Alignment.center,
      child: Text(
        initialsFor(name),
        style: AppTextStyles.h3.copyWith(
          color: AppColors.primaryGreenDark,
          fontSize: size * 0.38,
        ),
      ),
    );
  }
}
