import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/community/data/models/post.dart';
import 'package:farm2fork_mobile/features/community/data/repositories/mock_community_repository.dart';

final communityControllerProvider =
    AsyncNotifierProvider<CommunityController, List<Post>>(
      CommunityController.new,
    );

class CommunityController extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    final repository = ref.watch(communityRepositoryProvider);
    return repository.getFeed();
  }

  Future<void> fetchFeed() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return ref.read(communityRepositoryProvider).getFeed();
    });
  }

  Future<void> addComment(String postId, String content) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final authState = ref.read(authControllerProvider).asData?.value;
      final authorName = authState?.user?.email.split('@').first ?? 'Guest';
      final repository = ref.read(communityRepositoryProvider);
      await repository.addComment(postId, authorName, content);
      return repository.getFeed();
    });
  }
}
