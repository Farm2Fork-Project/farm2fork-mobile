import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/core/localization/generated/app_localizations.dart';
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
      'transporter' => l10n.communityRoleTransporter,
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

String postKindLabel(AppLocalizations l10n, PostKind kind) => switch (kind) {
  PostKind.discussion => l10n.postKindDiscussion,
  PostKind.question => l10n.postKindQuestion,
  PostKind.tip => l10n.postKindTip,
  PostKind.market => l10n.postKindMarket,
};

IconData postKindIcon(PostKind kind) => switch (kind) {
  PostKind.discussion => Icons.forum_outlined,
  PostKind.question => Icons.help_outline_rounded,
  PostKind.tip => Icons.lightbulb_outline_rounded,
  PostKind.market => Icons.storefront_outlined,
};

/// Small coloured label saying what a post is.
class PostKindBadge extends StatelessWidget {
  const PostKindBadge({super.key, required this.kind});

  final PostKind kind;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (kind) {
      PostKind.question => (
        AppColors.secondaryBlueSoft,
        AppColors.secondaryBlue,
      ),
      PostKind.tip => (AppColors.accentYellowSoft, const Color(0xFF7A5600)),
      PostKind.market => (
        AppColors.primaryGreenSoft,
        AppColors.primaryGreenDark,
      ),
      PostKind.discussion => (AppColors.surfaceMedium, AppColors.textDark),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(postKindIcon(kind), size: 13, color: foreground),
          const SizedBox(width: AppSpacing.xs),
          Text(
            postKindLabel(context.l10n, kind),
            style: AppTextStyles.label.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tappable count with an icon: likes and comments under a post.
class PostStat extends StatelessWidget {
  const PostStat({
    super.key,
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
    this.semanticLabel,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primaryGreen : AppColors.textMuted;
    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40, minWidth: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 6),
                ExcludeSemantics(
                  excluding: semanticLabel != null,
                  child: Text(
                    label,
                    style: AppTextStyles.small.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Like control that answers instantly and settles on the server's count.
class LikeButton extends StatefulWidget {
  const LikeButton({
    super.key,
    required this.post,
    required this.enabled,
    required this.setLiked,
    this.onChanged,
  });

  final CommunityPost post;
  final bool enabled;
  final Future<int> Function(bool liked) setLiked;
  final VoidCallback? onChanged;

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  late bool _liked = widget.post.likedByMe;
  late int _count = widget.post.likeCount;
  bool _busy = false;

  @override
  void didUpdateWidget(LikeButton old) {
    super.didUpdateWidget(old);
    if (!_busy &&
        (old.post.likedByMe != widget.post.likedByMe ||
            old.post.likeCount != widget.post.likeCount)) {
      _liked = widget.post.likedByMe;
      _count = widget.post.likeCount;
    }
  }

  Future<void> _toggle() async {
    if (_busy) return;
    final before = (_liked, _count);
    setState(() {
      _busy = true;
      _liked = !_liked;
      _count += _liked ? 1 : -1;
    });
    HapticFeedback.selectionClick();
    try {
      final count = await widget.setLiked(_liked);
      if (mounted) setState(() => _count = count);
      widget.onChanged?.call();
    } on Object {
      if (mounted) {
        setState(() {
          _liked = before.$1;
          _count = before.$2;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.communityActionFailed)),
        );
      }
    } finally {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) => PostStat(
    icon: _liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
    label: '$_count',
    active: _liked,
    semanticLabel: context.l10n.feedLikeCount(_count),
    onTap: widget.enabled ? _toggle : null,
  );
}

String _reasonLabel(AppLocalizations l10n, ReportReason reason) =>
    switch (reason) {
      ReportReason.spam => l10n.reportReasonSpam,
      ReportReason.abuse => l10n.reportReasonAbuse,
      ReportReason.misinformation => l10n.reportReasonMisinformation,
      ReportReason.scam => l10n.reportReasonScam,
      ReportReason.other => l10n.reportReasonOther,
    };

/// Asks why, sends the report, and tells the member what happened.
Future<void> showReportSheet(
  BuildContext context,
  Future<void> Function(ReportReason reason, String? note) send,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final sent = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.white,
    builder: (_) => _ReportSheet(send: send),
  );
  if (sent == null) return;
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        switch (sent) {
          'sent' => l10n.reportSent,
          'duplicate' => l10n.reportAlreadySent,
          _ => l10n.communityActionFailed,
        },
      ),
    ),
  );
}

class _ReportSheet extends StatefulWidget {
  const _ReportSheet({required this.send});

  final Future<void> Function(ReportReason reason, String? note) send;

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  final _note = TextEditingController();
  ReportReason? _reason;
  bool _sending = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final reason = _reason;
    if (reason == null) return;
    setState(() => _sending = true);
    final navigator = Navigator.of(context);
    try {
      final note = _note.text.trim();
      await widget.send(reason, note.isEmpty ? null : note);
      navigator.pop('sent');
    } on ApiException catch (error) {
      navigator.pop(error.statusCode == 409 ? 'duplicate' : 'failed');
    } on Object {
      navigator.pop('failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        0,
        AppSpacing.pagePadding,
        AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.reportTitle, style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.reportSubtitle,
              style: AppTextStyles.small.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.sm),
            RadioGroup<ReportReason>(
              groupValue: _reason,
              onChanged: (value) => setState(() => _reason = value),
              child: Column(
                children: [
                  for (final reason in ReportReason.values)
                    RadioListTile<ReportReason>(
                      value: reason,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.primaryGreen,
                      title: Text(
                        _reasonLabel(l10n, reason),
                        style: AppTextStyles.body,
                      ),
                    ),
                ],
              ),
            ),
            TextField(
              controller: _note,
              maxLength: 500,
              minLines: 1,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.reportNoteHint,
                counterText: '',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: l10n.reportSubmit,
              expand: true,
              isLoading: _sending,
              onPressed: _reason == null || _sending ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
