import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/config/app_config.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/network/network_providers.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/core/theme/app_sizes.dart';
import 'package:farm2fork_mobile/core/theme/app_typography.dart';
import 'package:farm2fork_mobile/core/utils/number_formatters.dart';
import 'package:farm2fork_mobile/core/widgets/app_button.dart';
import 'package:farm2fork_mobile/core/widgets/app_card.dart';
import 'package:farm2fork_mobile/core/widgets/app_state_placeholder.dart';
import 'package:farm2fork_mobile/core/widgets/section_header.dart';

// --- data ---------------------------------------------------------------------

class Review {
  const Review({
    required this.id,
    required this.orderId,
    required this.farmerId,
    required this.buyerName,
    required this.productNames,
    required this.rating,
    required this.createdAt,
    this.comment,
    this.farmerReply,
  });

  final String id;
  final String orderId;
  final String farmerId;
  final String buyerName;
  final List<String> productNames;
  final int rating;
  final String? comment;
  final String? farmerReply;
  final DateTime createdAt;

  static Review fromJson(Map<String, dynamic> json) => Review(
    id: json['id'] as String,
    orderId: (json['orderId'] as String?) ?? '',
    farmerId: (json['farmerId'] as String?) ?? '',
    buyerName: (json['buyerName'] as String?) ?? '',
    productNames: [
      for (final name in (json['productNames'] as List?) ?? const [])
        if (name is String) name,
    ],
    rating: ((json['rating'] as num?)?.toInt() ?? 0).clamp(0, 5),
    comment: json['comment'] as String?,
    farmerReply: json['farmerReply'] as String?,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );
}

class FarmerReviews {
  const FarmerReviews({
    required this.average,
    required this.count,
    required this.reviews,
  });

  final double average;
  final int count;
  final List<Review> reviews;
}

abstract class ReviewsRepository {
  /// Reviews the signed-in buyer has written.
  Future<List<Review>> mine();
  Future<FarmerReviews> forFarmer(String farmerId);
  Future<Review> create({
    required String orderId,
    required int rating,
    String? comment,
  });
  Future<Review> reply(String reviewId, String reply);
}

class ApiReviewsRepository implements ReviewsRepository {
  ApiReviewsRepository(this._dio);

  final Dio _dio;

  Map<String, dynamic> _map(Object? data) {
    if (data is! Map) throw const ApiException(ApiErrorKind.unknown);
    return Map<String, dynamic>.from(data);
  }

  List<Review> _list(Object? data) => [
    for (final row in data is List ? data : const [])
      if (row is Map) Review.fromJson(Map<String, dynamic>.from(row)),
  ];

  @override
  Future<List<Review>> mine() async =>
      _list((await _dio.get<dynamic>('/reviews/mine')).data);

  @override
  Future<FarmerReviews> forFarmer(String farmerId) async {
    final data = _map(
      (await _dio.get<dynamic>(
        '/reviews/farmers/$farmerId',
        queryParameters: {'limit': 20},
      )).data,
    );
    final summary = data['summary'] is Map ? data['summary'] as Map : const {};
    return FarmerReviews(
      average: (summary['average'] as num?)?.toDouble() ?? 0,
      count: (summary['count'] as num?)?.toInt() ?? 0,
      reviews: _list(data['data']),
    );
  }

  @override
  Future<Review> create({
    required String orderId,
    required int rating,
    String? comment,
  }) async => Review.fromJson(
    _map(
      (await _dio.post<dynamic>(
        '/reviews',
        data: {'orderId': orderId, 'rating': rating, 'comment': ?comment},
      )).data,
    ),
  );

  @override
  Future<Review> reply(String reviewId, String reply) async => Review.fromJson(
    _map(
      (await _dio.post<dynamic>(
        '/reviews/$reviewId/reply',
        data: {'reply': reply},
      )).data,
    ),
  );
}

class MockReviewsRepository implements ReviewsRepository {
  final List<Review> _reviews = [
    Review(
      id: 'r1',
      orderId: 'order_old_1',
      farmerId: 'mock_farmer_001',
      buyerName: 'Fresh Mart',
      productNames: const ['Chaunsa Mangoes'],
      rating: 5,
      comment: 'Fresh, well packed and on time.',
      farmerReply: 'Thank you, see you next season.',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
    Review(
      id: 'r2',
      orderId: 'order_old_2',
      farmerId: 'mock_farmer_001',
      buyerName: 'City Grocers',
      productNames: const ['Basmati Rice'],
      rating: 4,
      comment: 'Good grain. One bag was a little short.',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];
  final Set<String> _mine = {};

  @override
  Future<List<Review>> mine() async =>
      _reviews.where((r) => _mine.contains(r.id)).toList();

  @override
  Future<FarmerReviews> forFarmer(String farmerId) async {
    final count = _reviews.length;
    return FarmerReviews(
      average: count == 0
          ? 0
          : _reviews.fold<int>(0, (sum, r) => sum + r.rating) / count,
      count: count,
      reviews: List.unmodifiable(_reviews),
    );
  }

  @override
  Future<Review> create({
    required String orderId,
    required int rating,
    String? comment,
  }) async {
    final review = Review(
      id: 'r_${DateTime.now().microsecondsSinceEpoch}',
      orderId: orderId,
      farmerId: 'mock_farmer_001',
      buyerName: 'You',
      productNames: const [],
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );
    _reviews.insert(0, review);
    _mine.add(review.id);
    return review;
  }

  @override
  Future<Review> reply(String reviewId, String reply) async {
    final i = _reviews.indexWhere((r) => r.id == reviewId);
    final old = _reviews[i];
    return _reviews[i] = Review(
      id: old.id,
      orderId: old.orderId,
      farmerId: old.farmerId,
      buyerName: old.buyerName,
      productNames: old.productNames,
      rating: old.rating,
      comment: old.comment,
      farmerReply: reply,
      createdAt: old.createdAt,
    );
  }
}

final reviewsRepositoryProvider = Provider<ReviewsRepository>((ref) {
  if (AppConfig.useMocks) return MockReviewsRepository();
  return ApiReviewsRepository(ref.watch(dioProvider));
});

/// The buyer's own reviews keyed by order id.
final myReviewsProvider = FutureProvider.autoDispose<Map<String, Review>>(
  (ref) async => {
    for (final review in await ref.watch(reviewsRepositoryProvider).mine())
      review.orderId: review,
  },
);

final farmerReviewsProvider = FutureProvider.autoDispose
    .family<FarmerReviews, String>(
      (ref, farmerId) =>
          ref.watch(reviewsRepositoryProvider).forFarmer(farmerId),
    );

// --- widgets ------------------------------------------------------------------

class Stars extends StatelessWidget {
  const Stars({super.key, required this.rating, this.size = 16});

  final num rating;
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    label: context.l10n.ratingOutOfFive(rating.toStringAsFixed(1)),
    child: ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= 5; i++)
            Icon(
              rating >= i
                  ? Icons.star_rounded
                  : rating >= i - 0.5
                  ? Icons.star_half_rounded
                  : Icons.star_outline_rounded,
              size: size,
              color: AppColors.accentYellow,
            ),
        ],
      ),
    ),
  );
}

/// Under a delivered order: asks the buyer to rate it, or shows their rating.
class OrderReviewAction extends ConsumerWidget {
  const OrderReviewAction({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final mine = ref.watch(myReviewsProvider);
    final review = mine.asData?.value[orderId];
    if (mine.isLoading && !mine.hasValue) return const SizedBox.shrink();
    if (review != null) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.md),
        child: Row(
          children: [
            Text(
              l10n.yourRating,
              style: AppTextStyles.small.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(width: AppSpacing.sm),
            Stars(rating: review.rating),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.star_outline_rounded),
          label: Text(l10n.rateOrder),
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            final done = await showModalBottomSheet<bool>(
              context: context,
              isScrollControlled: true,
              showDragHandle: true,
              backgroundColor: AppColors.white,
              builder: (_) => _RateSheet(orderId: orderId),
            );
            if (done == true) {
              ref.invalidate(myReviewsProvider);
              messenger.showSnackBar(SnackBar(content: Text(l10n.reviewThanks)));
            }
          },
        ),
      ),
    );
  }
}

class _RateSheet extends ConsumerStatefulWidget {
  const _RateSheet({required this.orderId});

  final String orderId;

  @override
  ConsumerState<_RateSheet> createState() => _RateSheetState();
}

class _RateSheetState extends ConsumerState<_RateSheet> {
  final _comment = TextEditingController();
  int _rating = 0;
  bool _sending = false;
  bool _failed = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _sending = true;
      _failed = false;
    });
    final navigator = Navigator.of(context);
    try {
      final comment = _comment.text.trim();
      await ref
          .read(reviewsRepositoryProvider)
          .create(
            orderId: widget.orderId,
            rating: _rating,
            comment: comment.isEmpty ? null : comment,
          );
      navigator.pop(true);
    } on Object {
      if (mounted) {
        setState(() {
          _sending = false;
          _failed = true;
        });
      }
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.rateOrderTitle, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.rateOrderHint,
            style: AppTextStyles.small.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  tooltip: l10n.ratingOutOfFive('$i'),
                  iconSize: 40,
                  onPressed: () => setState(() => _rating = i),
                  icon: Icon(
                    _rating >= i
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: AppColors.accentYellow,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _comment,
            maxLength: 1000,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: l10n.reviewCommentHint,
              counterText: '',
              border: const OutlineInputBorder(),
            ),
          ),
          if (_failed) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.communityActionFailed,
              style: AppTextStyles.small.copyWith(color: AppColors.errorRed),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: l10n.submitReview,
            expand: true,
            isLoading: _sending,
            onPressed: _rating == 0 || _sending ? null : _submit,
          ),
        ],
      ),
    );
  }
}

class ReviewTile extends StatelessWidget {
  const ReviewTile({super.key, required this.review, this.onReply});

  final Review review;

  /// Offered to the reviewed farmer while there is no reply yet.
  final VoidCallback? onReply;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Stars(rating: review.rating),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                '${review.buyerName} · ${formatShortDate(review.createdAt, locale)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.small.copyWith(color: AppColors.textMuted),
              ),
            ),
          ],
        ),
        if (review.productNames.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              review.productNames.join(', '),
              style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
            ),
          ),
        if ((review.comment ?? '').isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              review.comment!,
              style: AppTextStyles.body.copyWith(height: 1.45),
            ),
          ),
        if ((review.farmerReply ?? '').isNotEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primaryGreenSoft,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.farmerReplyLabel,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primaryGreenDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(review.farmerReply!, style: AppTextStyles.small),
              ],
            ),
          )
        else if (onReply != null)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: onReply,
              icon: const Icon(Icons.reply_rounded, size: 18),
              label: Text(l10n.replyAction),
            ),
          ),
      ],
    );
  }
}

/// Rating summary and recent reviews of a farmer, for the product page.
class FarmerReviewsCard extends ConsumerWidget {
  const FarmerReviewsCard({super.key, required this.farmerId});

  final String farmerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final data = ref.watch(farmerReviewsProvider(farmerId)).asData?.value;
    // Nothing to show while loading, on failure, or before the first review.
    if (data == null || data.count == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: l10n.buyerReviews),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Text(
                  data.average.toStringAsFixed(1),
                  style: AppTextStyles.h1.copyWith(height: 1),
                ),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stars(rating: data.average, size: 18),
                    Text(
                      l10n.reviewCount(data.count),
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            for (final review in data.reviews.take(3)) ...[
              const Divider(height: AppSpacing.xxl, color: AppColors.surfaceMedium),
              ReviewTile(review: review),
            ],
          ],
        ),
      ),
    );
  }
}

/// A farmer's own reviews, with a single reply to each.
class MyFarmReviewsScreen extends ConsumerWidget {
  const MyFarmReviewsScreen({super.key, required this.farmerId});

  static const route = '/farmer/reviews';

  final String farmerId;

  Future<void> _reply(BuildContext context, WidgetRef ref, Review review) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.replyToReview),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 1000,
          minLines: 2,
          maxLines: 5,
          decoration: InputDecoration(hintText: l10n.replyOnceHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: Text(l10n.send),
          ),
        ],
      ),
    );
    if (text == null || text.isEmpty) return;
    try {
      await ref.read(reviewsRepositoryProvider).reply(review.id, text);
      ref.invalidate(farmerReviewsProvider(farmerId));
    } on Object {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.communityActionFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final reviews = ref.watch(farmerReviewsProvider(farmerId));
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: Text(l10n.buyerReviews, style: AppTextStyles.h3)),
      body: reviews.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
        error: (_, _) => AppErrorState(
          onRetry: () => ref.invalidate(farmerReviewsProvider(farmerId)),
        ),
        data: (data) => data.count == 0
            ? AppEmptyState(
                message: l10n.noReviewsYet,
                icon: Icons.star_outline_rounded,
              )
            : ListView(
                padding: const EdgeInsets.all(AppSpacing.pagePadding),
                children: [
                  AppCard(
                    child: Row(
                      children: [
                        Text(
                          data.average.toStringAsFixed(1),
                          style: AppTextStyles.h1.copyWith(height: 1),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stars(rating: data.average, size: 20),
                            Text(
                              l10n.reviewCount(data.count),
                              style: AppTextStyles.small.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  for (final review in data.reviews)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: AppCard(
                        child: ReviewTile(
                          review: review,
                          onReply: () => _reply(context, ref, review),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
