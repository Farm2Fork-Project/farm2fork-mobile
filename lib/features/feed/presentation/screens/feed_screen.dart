import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_badge.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/core/widgets/app_state_placeholder.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/community/data/community.dart';
import 'package:farm2fork_mobile/features/community/presentation/widgets.dart';

/// Community feed (US-13). Farmers and buyers can post; everyone signed in
/// can read.
class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(communityFeedProvider);
    final tag = ref.watch(communityTagFilterProvider);
    final role = ref.watch(authControllerProvider).asData?.value.role;
    final canPost = role == AppUserRole.farmer || role == AppUserRole.buyer;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(context.l10n.feedTitle, style: AppTextStyles.h2),
        elevation: 0,
        backgroundColor: AppColors.backgroundLight,
        centerTitle: true,
      ),
      floatingActionButton: canPost
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: AppColors.white,
              onPressed: () => context.push(AppNavConfig.newPostRoute),
              icon: const Icon(Icons.edit_rounded),
              label: Text(context.l10n.newPost),
            )
          : null,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryGreen,
          onRefresh: () => ref.refresh(communityFeedProvider.future),
          child: feed.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            ),
            error: (_, _) => AppErrorState(
              icon: Icons.error_outline_rounded,
              onRetry: () => ref.invalidate(communityFeedProvider),
            ),
            data: (posts) => ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePadding,
                AppSpacing.pagePadding,
                AppSpacing.pagePadding,
                96,
              ),
              children: [
                if (tag != null)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: InputChip(
                      label: Text('#$tag'),
                      onDeleted: () => ref
                          .read(communityTagFilterProvider.notifier)
                          .select(null),
                    ),
                  ),
                if (posts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: AppEmptyState(
                      message: context.l10n.communityEmpty,
                      icon: Icons.forum_rounded,
                    ),
                  ),
                for (final post in posts)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _PostCard(post: post),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PostCard extends ConsumerWidget {
  const _PostCard({required this.post});

  final CommunityPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: () => context.push(AppNavConfig.postRoute(post.id)),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthorHeader(author: post.author, createdAt: post.createdAt),
            const SizedBox(height: AppSpacing.md),
            Text(
              post.title,
              style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              post.content,
              style: AppTextStyles.body,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            if (post.images.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              PostPhoto(url: post.images.first),
            ],
            if (post.tags.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final tag in post.tags)
                    GestureDetector(
                      onTap: () => ref
                          .read(communityTagFilterProvider.notifier)
                          .select(tag),
                      child: AppBadge(
                        label: '#$tag',
                        backgroundColor: AppColors.secondaryBlueSoft,
                        foregroundColor: AppColors.secondaryBlue,
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(
                  Icons.forum_outlined,
                  size: 18,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(width: 6),
                Text(
                  context.l10n.feedCommentCount(post.commentCount),
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
