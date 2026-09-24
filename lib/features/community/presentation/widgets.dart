import 'package:flutter/material.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/utils/number_formatters.dart';
import 'package:farm2fork_mobile/features/community/data/community.dart';

class AuthorHeader extends StatelessWidget {
  const AuthorHeader({
    super.key,
    required this.author,
    required this.createdAt,
  });

  final CommunityAuthor author;
  final DateTime createdAt;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final role = switch (author.role) {
      'farmer' => l10n.communityRoleFarmer,
      'buyer' => l10n.communityRoleBuyer,
      'admin' => l10n.communityRoleTeam,
      _ => '',
    };
    final meta = [
      role,
      ?author.city,
      formatShortDate(createdAt, Localizations.localeOf(context)),
    ].where((part) => part.isNotEmpty).join(' · ');
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.primaryGreenSoft,
          child: Text(
            author.name.isEmpty
                ? '?'
                : author.name.characters.first.toUpperCase(),
            style: AppTextStyles.body.copyWith(
              color: AppColors.primaryGreenDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(author.name, style: AppTextStyles.h3),
              Text(
                meta,
                style: AppTextStyles.small.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Network photo with a neutral placeholder while loading or on failure.
class PostPhoto extends StatelessWidget {
  const PostPhoto({super.key, required this.url, this.height = 180});

  final String url;
  final double height;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Image.network(
      url,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        height: height,
        color: AppColors.surfaceMedium,
        child: const Icon(
          Icons.broken_image_rounded,
          color: AppColors.textMuted,
        ),
      ),
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : Container(height: height, color: AppColors.surfaceMedium),
    ),
  );
}
