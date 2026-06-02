import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/features/community/data/models/post.dart';
import 'community_repository.dart';

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return MockCommunityRepository();
});

class MockCommunityRepository implements CommunityRepository {
  final List<Post> _feed = [
    Post(
      id: 'post_001',
      authorId: 'farmer_002',
      authorName: 'Fatima Bibi',
      title: 'Sindh Mango Crop Advice',
      content:
          'Due to early heatwaves in Sindh, ensure light watering every 3 days. Focus on organic pest repellents for grade A quality exports!',
      tags: const ['Mangoes', 'FarmingTips', 'Organic'],
      commentCount: 2,
      comments: [
        CommunityComment(
          id: 'comm_101',
          postId: 'post_001',
          authorId: 'farmer_001',
          authorName: 'Ali Hassan',
          content:
              'Very helpful advice, Fatima! Applying this in Multan today.',
          createdAt: DateTime.now().subtract(const Duration(hours: 10)),
        ),
        CommunityComment(
          id: 'comm_102',
          postId: 'post_001',
          authorId: 'buyer_001',
          authorName: 'Muhammad Junaid',
          content:
              'Looking forward to buying your mango harvest on the platform!',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Post(
      id: 'post_002',
      authorId: 'farmer_003',
      authorName: 'Tariq Mehmood',
      title: 'Basmati Rice Price Trends',
      content:
          'Expect price stabilization for Basmati Rice (1121) this season. Direct listings here are cutting out middleman cuts by 20%!',
      tags: const ['MarketTrends', 'Rice', 'DirectMarket'],
      commentCount: 1,
      comments: [
        CommunityComment(
          id: 'comm_103',
          postId: 'post_002',
          authorId: 'farmer_004',
          authorName: 'Saima Noor',
          content: 'Direct payment confirmed by JazzCash has been a lifesaver.',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  @override
  Future<List<Post>> getFeed() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _feed;
  }

  @override
  Future<Post> addComment(
    String postId,
    String authorName,
    String content,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final index = _feed.indexWhere((p) => p.id == postId);
    if (index == -1) throw Exception('Post not found');

    final post = _feed[index];
    final updatedComments = List<CommunityComment>.from(post.comments)
      ..add(
        CommunityComment(
          id: 'comm_${DateTime.now().millisecondsSinceEpoch}',
          postId: postId,
          authorId: 'current_user',
          authorName: authorName,
          content: content,
          createdAt: DateTime.now(),
        ),
      );

    final updated = post.copyWith(
      comments: updatedComments,
      commentCount: updatedComments.length,
    );

    _feed[index] = updated;
    return updated;
  }
}
