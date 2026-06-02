// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CommunityComment _$CommunityCommentFromJson(Map<String, dynamic> json) =>
    _CommunityComment(
      id: json['_id'] as String,
      postId: json['postId'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$CommunityCommentToJson(_CommunityComment instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'postId': instance.postId,
      'authorId': instance.authorId,
      'authorName': instance.authorName,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_Post _$PostFromJson(Map<String, dynamic> json) => _Post(
  id: json['_id'] as String,
  authorId: json['authorId'] as String,
  authorName: json['authorName'] as String,
  title: json['title'] as String,
  content: json['content'] as String,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
  comments: (json['comments'] as List<dynamic>)
      .map((e) => CommunityComment.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$PostToJson(_Post instance) => <String, dynamic>{
  '_id': instance.id,
  'authorId': instance.authorId,
  'authorName': instance.authorName,
  'title': instance.title,
  'content': instance.content,
  'tags': instance.tags,
  'commentCount': instance.commentCount,
  'comments': instance.comments,
  'createdAt': instance.createdAt.toIso8601String(),
};
