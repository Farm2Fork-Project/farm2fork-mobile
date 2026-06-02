import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_badge.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/features/community/data/models/post.dart';
import 'package:farm2fork_mobile/features/community/presentation/providers/community_controller.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(communityControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(context.l10n.feedTitle, style: AppTextStyles.h2),
        elevation: 0,
        backgroundColor: AppColors.backgroundLight,
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(communityControllerProvider.notifier).fetchFeed(),
          color: AppColors.primaryGreen,
          child: feedAsync.when(
            data: (posts) {
              if (posts.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.forum_rounded,
                          size: 64,
                          color: AppColors.textMuted.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          context.l10n.noDataFound,
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.pagePadding),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _PostCard(post: post),
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            ),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.errorRed,
                    size: 48,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(context.l10n.errorOccurred, style: AppTextStyles.body),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () => ref
                        .read(communityControllerProvider.notifier)
                        .fetchFeed(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                    ),
                    child: Text(
                      context.l10n.retry,
                      style: const TextStyle(color: AppColors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PostCard extends ConsumerWidget {
  const _PostCard({required this.post});
  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryGreenSoft,
                child: Text(
                  post.authorName[0].toUpperCase(),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.primaryGreenDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.authorName, style: AppTextStyles.h3),
                    const SizedBox(height: 1),
                    Text(
                      _formatDate(post.createdAt),
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Title & Body
          Text(
            post.title,
            style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(post.content, style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.md),

          // Tags Row
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: post.tags
                .map(
                  (tag) => AppBadge(
                    label: '#$tag',
                    backgroundColor: AppColors.secondaryBlueSoft,
                    foregroundColor: AppColors.secondaryBlue,
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.surfaceMedium),
          const SizedBox(height: AppSpacing.xs),

          // Actions Row (Like & Comment)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.favorite_border_rounded,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () {}, // Upvote interaction (MVP visual)
                  ),
                  Text(
                    '12',
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                icon: const Icon(
                  Icons.forum_outlined,
                  size: 20,
                  color: AppColors.primaryGreen,
                ),
                label: Text(
                  '${post.commentCount} Comments',
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () => _showCommentsSheet(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCommentsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CommentsSheet(post: post, parentRef: ref),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _CommentsSheet extends StatefulWidget {
  const _CommentsSheet({required this.post, required this.parentRef});
  final Post post;
  final WidgetRef parentRef;

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    widget.parentRef
        .read(communityControllerProvider.notifier)
        .addComment(widget.post.id, text);

    _commentController.clear();
    Navigator.pop(context); // Close sheet on comment
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Comments', style: AppTextStyles.h3),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(color: AppColors.surfaceMedium),
            const SizedBox(height: AppSpacing.sm),

            // Comments list
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 250),
              child: widget.post.comments.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Text(
                          'No comments yet.',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.post.comments.length,
                      itemBuilder: (ctx, index) {
                        final comment = widget.post.comments[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    comment.authorName,
                                    style: AppTextStyles.small.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${comment.createdAt.hour}:${comment.createdAt.minute.toString().padLeft(2, '0')}',
                                    style: AppTextStyles.label.copyWith(
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(comment.content, style: AppTextStyles.body),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const Divider(color: AppColors.surfaceMedium),
            const SizedBox(height: AppSpacing.sm),

            // Submit comment input row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: AppTextStyles.body,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                IconButton(
                  icon: const Icon(
                    Icons.send_rounded,
                    color: AppColors.primaryGreen,
                  ),
                  onPressed: _submit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
