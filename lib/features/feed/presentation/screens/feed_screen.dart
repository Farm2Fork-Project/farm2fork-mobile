import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/core/widgets/app_state_placeholder.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/community/data/community.dart';
import 'package:farm2fork_mobile/features/community/presentation/widgets.dart';

bool canTakePart(AppUserRole? role) =>
    role == AppUserRole.farmer ||
    role == AppUserRole.buyer ||
    role == AppUserRole.transporter;

/// Community feed (US-13): search, filter by kind or topic, sort, like and
/// open a post. Farmers, buyers and transporters take part.
class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _search = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearch(String words) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => ref.read(feedFilterProvider.notifier).search(words),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final feed = ref.watch(communityFeedProvider);
    final query = ref.watch(feedFilterProvider);
    final filter = ref.read(feedFilterProvider.notifier);
    final role = ref.watch(authControllerProvider).asData?.value.role;
    final member = canTakePart(role);
    final filtered =
        query.tag != null || query.kind != null || query.search.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(l10n.feedTitle, style: AppTextStyles.h2),
        elevation: 0,
        backgroundColor: AppColors.backgroundLight,
        centerTitle: true,
      ),
      floatingActionButton: member
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: AppColors.white,
              onPressed: () => context.push(AppNavConfig.newPostRoute),
              icon: const Icon(Icons.edit_rounded),
              label: Text(l10n.newPost),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePadding,
                0,
                AppSpacing.pagePadding,
                AppSpacing.sm,
              ),
              child: TextField(
                controller: _search,
                onChanged: _onSearch,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: l10n.feedSearchHint,
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.white,
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _search.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: l10n.cancel,
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () {
                            _search.clear();
                            _onSearch('');
                          },
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: const BorderSide(color: AppColors.surfaceStrong),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: const BorderSide(color: AppColors.surfaceStrong),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding,
                ),
                children: [
                  _FilterChip(
                    label: query.sort == FeedSort.top
                        ? l10n.feedSortTop
                        : l10n.feedSortLatest,
                    icon: query.sort == FeedSort.top
                        ? Icons.trending_up_rounded
                        : Icons.schedule_rounded,
                    selected: query.sort == FeedSort.top,
                    onTap: () => filter.sort(
                      query.sort == FeedSort.top
                          ? FeedSort.latest
                          : FeedSort.top,
                    ),
                  ),
                  _FilterChip(
                    label: l10n.postKindAll,
                    selected: query.kind == null,
                    onTap: () => filter.kind(null),
                  ),
                  for (final kind in const [
                    PostKind.question,
                    PostKind.tip,
                    PostKind.market,
                    PostKind.discussion,
                  ])
                    _FilterChip(
                      key: ValueKey('feed-kind-${kind.name}'),
                      label: postKindLabel(l10n, kind),
                      icon: postKindIcon(kind),
                      selected: query.kind == kind,
                      onTap: () =>
                          filter.kind(query.kind == kind ? null : kind),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryGreen,
                onRefresh: () {
                  ref.invalidate(trendingTagsProvider);
                  return ref.refresh(communityFeedProvider.future);
                },
                child: feed.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  error: (_, _) => AppErrorState(
                    icon: Icons.error_outline_rounded,
                    onRetry: () => ref.invalidate(communityFeedProvider),
                  ),
                  data: (posts) => ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pagePadding,
                      0,
                      AppSpacing.pagePadding,
                      96,
                    ),
                    children: [
                      _Topics(selected: query.tag),
                      if (posts.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 64),
                          child: AppEmptyState(
                            message: filtered
                                ? l10n.communityNoResults
                                : l10n.communityEmpty,
                            icon: filtered
                                ? Icons.search_off_rounded
                                : Icons.forum_rounded,
                          ),
                        ),
                      for (final post in posts)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _PostCard(
                            key: ValueKey(post.id),
                            post: post,
                            member: member,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.white : AppColors.textDark;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
      child: Semantics(
        button: true,
        selected: selected,
        child: Material(
          color: selected ? AppColors.primaryGreen : AppColors.white,
          shape: StadiumBorder(
            side: BorderSide(
              color: selected ? AppColors.primaryGreen : AppColors.surfaceStrong,
            ),
          ),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16, color: foreground),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: AppTextStyles.small.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w600,
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

/// Topics people are posting about; tapping one filters the feed.
class _Topics extends ConsumerWidget {
  const _Topics({required this.selected});

  final String? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(trendingTagsProvider).asData?.value ?? const [];
    final names = {?selected, for (final tag in tags) tag.tag}.take(8);
    if (names.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.xs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            context.l10n.feedTrending,
            style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
          ),
          for (final name in names)
            _TopicLink(
              tag: name,
              selected: name == selected,
              onTap: () => ref
                  .read(feedFilterProvider.notifier)
                  .tag(name == selected ? null : name),
            ),
        ],
      ),
    );
  }
}

class _TopicLink extends StatelessWidget {
  const _TopicLink({
    required this.tag,
    required this.selected,
    required this.onTap,
  });

  final String tag;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(AppRadius.pill),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? AppColors.secondaryBlue : AppColors.secondaryBlueSoft,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '#$tag',
            style: AppTextStyles.small.copyWith(
              color: selected ? AppColors.white : AppColors.secondaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (selected) ...[
            const SizedBox(width: 4),
            const Icon(Icons.close_rounded, size: 14, color: AppColors.white),
          ],
        ],
      ),
    ),
  );
}

class _PostCard extends ConsumerWidget {
  const _PostCard({super.key, required this.post, required this.member});

  final CommunityPost post;
  final bool member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    void open() => context.push(AppNavConfig.postRoute(post.id));
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: open,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthorHeader(author: post.author, createdAt: post.createdAt),
            const SizedBox(height: AppSpacing.md),
            PostKindBadge(kind: post.kind),
            const SizedBox(height: AppSpacing.sm),
            Text(
              post.title,
              style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              post.content,
              style: AppTextStyles.body.copyWith(height: 1.45),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            if (post.images.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              PostPhoto(url: post.images.first),
            ],
            if (post.tags.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                post.tags.map((tag) => '#$tag').join('  '),
                style: AppTextStyles.small.copyWith(
                  color: AppColors.secondaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xs),
            const Divider(height: 1, color: AppColors.surfaceMedium),
            Row(
              children: [
                LikeButton(
                  post: post,
                  enabled: member,
                  setLiked: (liked) => ref
                      .read(communityRepositoryProvider)
                      .setLiked(post.id, liked: liked),
                ),
                PostStat(
                  icon: Icons.mode_comment_outlined,
                  label: '${post.commentCount}',
                  semanticLabel: l10n.feedCommentCount(post.commentCount),
                  onTap: open,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
