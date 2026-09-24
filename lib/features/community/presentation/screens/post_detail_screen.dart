import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_state_placeholder.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/community/data/community.dart';
import 'package:farm2fork_mobile/features/community/presentation/widgets.dart';

/// One post with its photos and comments (US-14).
class PostDetailScreen extends ConsumerStatefulWidget {
  const PostDetailScreen({super.key, required this.postId});

  final String postId;

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _comment = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  void _snack(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _send() async {
    final text = _comment.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      await ref
          .read(communityRepositoryProvider)
          .addComment(widget.postId, text);
      _comment.clear();
      ref
        ..invalidate(communityCommentsProvider(widget.postId))
        ..invalidate(communityFeedProvider);
    } on Object {
      if (mounted) _snack(context.l10n.communityActionFailed);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<bool> _confirm(String message) async =>
      await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => dialogContext.pop(false),
              child: Text(dialogContext.l10n.cancel),
            ),
            TextButton(
              onPressed: () => dialogContext.pop(true),
              child: Text(dialogContext.l10n.remove),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _removePost() async {
    if (!await _confirm(context.l10n.removePostConfirm)) return;
    try {
      await ref.read(communityRepositoryProvider).remove(widget.postId);
      ref.invalidate(communityFeedProvider);
      if (mounted) context.pop();
    } on Object {
      if (mounted) _snack(context.l10n.communityActionFailed);
    }
  }

  Future<void> _removeComment(CommunityComment comment) async {
    if (!await _confirm(context.l10n.removeCommentConfirm)) return;
    try {
      await ref
          .read(communityRepositoryProvider)
          .removeComment(widget.postId, comment.id);
      ref
        ..invalidate(communityCommentsProvider(widget.postId))
        ..invalidate(communityFeedProvider);
    } on Object {
      if (mounted) _snack(context.l10n.communityActionFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final auth = ref.watch(authControllerProvider).asData?.value;
    final me = auth?.user?.id;
    final canComment =
        auth?.role == AppUserRole.farmer || auth?.role == AppUserRole.buyer;
    final post = ref.watch(communityPostProvider(widget.postId));
    final comments = ref.watch(communityCommentsProvider(widget.postId));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(l10n.feedTitle, style: AppTextStyles.h3),
        actions: [
          if (post.asData?.value.author.id == me && me != null)
            IconButton(
              tooltip: l10n.remove,
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _removePost,
            ),
        ],
      ),
      body: post.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
        error: (_, _) => AppErrorState(
          onRetry: () => ref.invalidate(communityPostProvider(widget.postId)),
        ),
        data: (post) => Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.pagePadding),
                children: [
                  AuthorHeader(author: post.author, createdAt: post.createdAt),
                  const SizedBox(height: AppSpacing.md),
                  Text(post.title, style: AppTextStyles.h2),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    post.content,
                    style: AppTextStyles.body.copyWith(height: 1.5),
                  ),
                  for (final url in post.images) ...[
                    const SizedBox(height: AppSpacing.md),
                    PostPhoto(url: url, height: 220),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Text(l10n.feedCommentsTitle, style: AppTextStyles.h3),
                  const Divider(color: AppColors.surfaceMedium),
                  ...comments.when(
                    loading: () => [
                      const Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                    error: (_, _) => [Text(l10n.communityActionFailed)],
                    data: (list) => list.isEmpty
                        ? [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                              child: Text(
                                l10n.feedNoCommentsYet,
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          ]
                        : [
                            for (final comment in list)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  comment.author.name,
                                  style: AppTextStyles.small.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  comment.content,
                                  style: AppTextStyles.body,
                                ),
                                trailing: comment.author.id == me
                                    ? IconButton(
                                        tooltip: l10n.remove,
                                        icon: const Icon(
                                          Icons.close_rounded,
                                          size: 18,
                                        ),
                                        onPressed: () =>
                                            _removeComment(comment),
                                      )
                                    : null,
                              ),
                          ],
                  ),
                ],
              ),
            ),
            if (canComment)
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _comment,
                          maxLength: 2000,
                          minLines: 1,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: l10n.feedAddCommentHint,
                            counterText: '',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      IconButton(
                        tooltip: l10n.send,
                        icon: _sending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.send_rounded,
                                color: AppColors.primaryGreen,
                              ),
                        onPressed: _sending ? null : _send,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
