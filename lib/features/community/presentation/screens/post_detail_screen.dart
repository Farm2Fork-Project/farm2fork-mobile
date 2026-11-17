import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/utils/number_formatters.dart';
import 'package:farm2fork_mobile/core/widgets/app_state_placeholder.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/community/data/community.dart';
import 'package:farm2fork_mobile/features/community/presentation/widgets.dart';
import 'package:farm2fork_mobile/features/feed/presentation/screens/feed_screen.dart'
    show canTakePart;

/// One post with its photos and comments (US-14).
class PostDetailScreen extends ConsumerStatefulWidget {
  const PostDetailScreen({super.key, required this.postId});

  final String postId;

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _comment = TextEditingController();
  final _commentFocus = FocusNode();
  CommunityComment? _replyTo;
  bool _sending = false;

  @override
  void dispose() {
    _comment.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  void _reply(CommunityComment comment) {
    setState(() => _replyTo = comment);
    _commentFocus.requestFocus();
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
          .addComment(
            widget.postId,
            text,
            parentCommentId: _replyTo?.id,
          );
      _comment.clear();
      if (mounted) setState(() => _replyTo = null);
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
    final canComment = canTakePart(auth?.role);
    final post = ref.watch(communityPostProvider(widget.postId));
    final comments = ref.watch(communityCommentsProvider(widget.postId));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(l10n.feedTitle, style: AppTextStyles.h3),
        actions: [
          if (post.asData?.value case final loaded? when me != null)
            PopupMenuButton<String>(
              tooltip: l10n.moreOptions,
              onSelected: (action) {
                switch (action) {
                  case 'edit':
                    context.push(AppNavConfig.newPostRoute, extra: loaded);
                  case 'remove':
                    _removePost();
                  case 'report':
                    showReportSheet(
                      context,
                      (reason, note) => ref
                          .read(communityRepositoryProvider)
                          .reportPost(widget.postId, reason, note: note),
                    );
                }
              },
              itemBuilder: (_) => loaded.author.id == me
                  ? [
                      PopupMenuItem(value: 'edit', child: Text(l10n.editPost)),
                      PopupMenuItem(value: 'remove', child: Text(l10n.remove)),
                    ]
                  : [
                      if (canComment)
                        PopupMenuItem(
                          value: 'report',
                          child: Text(l10n.reportAction),
                        ),
                    ],
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
                  Row(
                    children: [
                      PostKindBadge(kind: post.kind),
                      if (post.editedAt != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          l10n.postEdited,
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
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
                  if (post.tags.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      post.tags.map((tag) => '#$tag').join('  '),
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.secondaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: LikeButton(
                      post: post,
                      enabled: canComment,
                      setLiked: (liked) => ref
                          .read(communityRepositoryProvider)
                          .setLiked(post.id, liked: liked),
                      onChanged: () => ref.invalidate(communityFeedProvider),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(l10n.feedCommentsTitle, style: AppTextStyles.h3),
                  const Divider(color: AppColors.surfaceMedium),
                  ...comments.when(
                    loading: () => [
                      const Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                    error: (_, _) => [
                      Text(l10n.communityActionFailed),
                      TextButton(
                        onPressed: () => ref.invalidate(
                          communityCommentsProvider(widget.postId),
                        ),
                        child: Text(l10n.retry),
                      ),
                    ],
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
                            for (final comment in _threaded(list))
                              _CommentTile(
                                comment: comment,
                                mine: comment.author.id == me,
                                canAct: canComment,
                                onReply: () => _reply(comment),
                                onRemove: () => _removeComment(comment),
                                onReport: () => showReportSheet(
                                  context,
                                  (reason, note) => ref
                                      .read(communityRepositoryProvider)
                                      .reportComment(
                                        widget.postId,
                                        comment.id,
                                        reason,
                                        note: note,
                                      ),
                                ),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_replyTo case final target?)
                        Row(
                          children: [
                            const Icon(
                              Icons.reply_rounded,
                              size: 16,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                l10n.replyingTo(target.author.name),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.small.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: l10n.cancel,
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () => setState(() => _replyTo = null),
                            ),
                          ],
                        ),
                      Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _comment,
                          focusNode: _commentFocus,
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

/// Top-level comments in order, each followed by its replies.
List<CommunityComment> _threaded(List<CommunityComment> comments) {
  final ids = {for (final c in comments) c.id};
  bool isReply(CommunityComment c) =>
      c.parentCommentId != null && ids.contains(c.parentCommentId);
  return [
    for (final top in comments.where((c) => !isReply(c))) ...[
      top,
      ...comments.where((c) => c.parentCommentId == top.id),
    ],
  ];
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    required this.mine,
    required this.canAct,
    required this.onReply,
    required this.onRemove,
    required this.onReport,
  });

  final CommunityComment comment;
  final bool mine;
  final bool canAct;
  final VoidCallback onReply;
  final VoidCallback onRemove;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reply = comment.parentCommentId != null;
    TextButton action(String label, VoidCallback onTap) => TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textMuted,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        minimumSize: const Size(44, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: AppTextStyles.label.copyWith(fontWeight: FontWeight.w600),
      ),
      child: Text(label),
    );
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: reply ? AppSpacing.xxl : 0,
        top: AppSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.xs,
          0,
        ),
        decoration: BoxDecoration(
          color: reply ? AppColors.surfaceLight : AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.surfaceMedium),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              [
                comment.author.name,
                formatShortDate(
                  comment.createdAt,
                  Localizations.localeOf(context),
                ),
              ].join(' · '),
              style: AppTextStyles.small.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(comment.content, style: AppTextStyles.body),
            Row(
              children: [
                if (canAct) action(l10n.replyAction, onReply),
                if (mine)
                  action(l10n.remove, onRemove)
                else if (canAct)
                  action(l10n.reportAction, onReport),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
