import 'package:farm2fork_mobile/features/community/data/models/post.dart';

abstract class CommunityRepository {
  Future<List<Post>> getFeed();
  Future<Post> addComment(String postId, String authorName, String content);
}
