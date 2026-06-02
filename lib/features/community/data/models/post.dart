import 'package:freezed_annotation/freezed_annotation.dart';

part 'post.freezed.dart';
part 'post.g.dart';

@freezed
abstract class CommunityComment with _$CommunityComment {
  const factory CommunityComment({
    @JsonKey(name: '_id') required String id,
    required String postId,
    required String authorId,
    required String authorName,
    required String content,
    required DateTime createdAt,
  }) = _CommunityComment;

  factory CommunityComment.fromJson(Map<String, dynamic> json) =>
      _$CommunityCommentFromJson(json);
}

@freezed
abstract class Post with _$Post {
  const factory Post({
    @JsonKey(name: '_id') required String id,
    required String authorId,
    required String authorName,
    required String title,
    required String content,
    @Default([]) List<String> tags,
    @Default(0) int commentCount,
    required List<CommunityComment> comments,
    required DateTime createdAt,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}
