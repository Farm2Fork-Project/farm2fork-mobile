// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CommunityComment {

@JsonKey(name: '_id') String get id; String get postId; String get authorId; String get authorName; String get content; DateTime get createdAt;
/// Create a copy of CommunityComment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommunityCommentCopyWith<CommunityComment> get copyWith => _$CommunityCommentCopyWithImpl<CommunityComment>(this as CommunityComment, _$identity);

  /// Serializes this CommunityComment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommunityComment&&(identical(other.id, id) || other.id == id)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.content, content) || other.content == content)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,postId,authorId,authorName,content,createdAt);

@override
String toString() {
  return 'CommunityComment(id: $id, postId: $postId, authorId: $authorId, authorName: $authorName, content: $content, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $CommunityCommentCopyWith<$Res>  {
  factory $CommunityCommentCopyWith(CommunityComment value, $Res Function(CommunityComment) _then) = _$CommunityCommentCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '_id') String id, String postId, String authorId, String authorName, String content, DateTime createdAt
});




}
/// @nodoc
class _$CommunityCommentCopyWithImpl<$Res>
    implements $CommunityCommentCopyWith<$Res> {
  _$CommunityCommentCopyWithImpl(this._self, this._then);

  final CommunityComment _self;
  final $Res Function(CommunityComment) _then;

/// Create a copy of CommunityComment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? postId = null,Object? authorId = null,Object? authorName = null,Object? content = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,authorName: null == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CommunityComment].
extension CommunityCommentPatterns on CommunityComment {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommunityComment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommunityComment() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommunityComment value)  $default,){
final _that = this;
switch (_that) {
case _CommunityComment():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommunityComment value)?  $default,){
final _that = this;
switch (_that) {
case _CommunityComment() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  String postId,  String authorId,  String authorName,  String content,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommunityComment() when $default != null:
return $default(_that.id,_that.postId,_that.authorId,_that.authorName,_that.content,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  String postId,  String authorId,  String authorName,  String content,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _CommunityComment():
return $default(_that.id,_that.postId,_that.authorId,_that.authorName,_that.content,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '_id')  String id,  String postId,  String authorId,  String authorName,  String content,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _CommunityComment() when $default != null:
return $default(_that.id,_that.postId,_that.authorId,_that.authorName,_that.content,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CommunityComment implements CommunityComment {
  const _CommunityComment({@JsonKey(name: '_id') required this.id, required this.postId, required this.authorId, required this.authorName, required this.content, required this.createdAt});
  factory _CommunityComment.fromJson(Map<String, dynamic> json) => _$CommunityCommentFromJson(json);

@override@JsonKey(name: '_id') final  String id;
@override final  String postId;
@override final  String authorId;
@override final  String authorName;
@override final  String content;
@override final  DateTime createdAt;

/// Create a copy of CommunityComment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommunityCommentCopyWith<_CommunityComment> get copyWith => __$CommunityCommentCopyWithImpl<_CommunityComment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommunityCommentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommunityComment&&(identical(other.id, id) || other.id == id)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.content, content) || other.content == content)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,postId,authorId,authorName,content,createdAt);

@override
String toString() {
  return 'CommunityComment(id: $id, postId: $postId, authorId: $authorId, authorName: $authorName, content: $content, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CommunityCommentCopyWith<$Res> implements $CommunityCommentCopyWith<$Res> {
  factory _$CommunityCommentCopyWith(_CommunityComment value, $Res Function(_CommunityComment) _then) = __$CommunityCommentCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '_id') String id, String postId, String authorId, String authorName, String content, DateTime createdAt
});




}
/// @nodoc
class __$CommunityCommentCopyWithImpl<$Res>
    implements _$CommunityCommentCopyWith<$Res> {
  __$CommunityCommentCopyWithImpl(this._self, this._then);

  final _CommunityComment _self;
  final $Res Function(_CommunityComment) _then;

/// Create a copy of CommunityComment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? postId = null,Object? authorId = null,Object? authorName = null,Object? content = null,Object? createdAt = null,}) {
  return _then(_CommunityComment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,authorName: null == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$Post {

@JsonKey(name: '_id') String get id; String get authorId; String get authorName; String get title; String get content; List<String> get tags; int get commentCount; List<CommunityComment> get comments; DateTime get createdAt;
/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostCopyWith<Post> get copyWith => _$PostCopyWithImpl<Post>(this as Post, _$identity);

  /// Serializes this Post to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Post&&(identical(other.id, id) || other.id == id)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&const DeepCollectionEquality().equals(other.comments, comments)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,authorId,authorName,title,content,const DeepCollectionEquality().hash(tags),commentCount,const DeepCollectionEquality().hash(comments),createdAt);

@override
String toString() {
  return 'Post(id: $id, authorId: $authorId, authorName: $authorName, title: $title, content: $content, tags: $tags, commentCount: $commentCount, comments: $comments, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PostCopyWith<$Res>  {
  factory $PostCopyWith(Post value, $Res Function(Post) _then) = _$PostCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '_id') String id, String authorId, String authorName, String title, String content, List<String> tags, int commentCount, List<CommunityComment> comments, DateTime createdAt
});




}
/// @nodoc
class _$PostCopyWithImpl<$Res>
    implements $PostCopyWith<$Res> {
  _$PostCopyWithImpl(this._self, this._then);

  final Post _self;
  final $Res Function(Post) _then;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? authorId = null,Object? authorName = null,Object? title = null,Object? content = null,Object? tags = null,Object? commentCount = null,Object? comments = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,authorName: null == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as List<CommunityComment>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Post].
extension PostPatterns on Post {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Post value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Post value)  $default,){
final _that = this;
switch (_that) {
case _Post():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Post value)?  $default,){
final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  String authorId,  String authorName,  String title,  String content,  List<String> tags,  int commentCount,  List<CommunityComment> comments,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that.id,_that.authorId,_that.authorName,_that.title,_that.content,_that.tags,_that.commentCount,_that.comments,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  String authorId,  String authorName,  String title,  String content,  List<String> tags,  int commentCount,  List<CommunityComment> comments,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Post():
return $default(_that.id,_that.authorId,_that.authorName,_that.title,_that.content,_that.tags,_that.commentCount,_that.comments,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '_id')  String id,  String authorId,  String authorName,  String title,  String content,  List<String> tags,  int commentCount,  List<CommunityComment> comments,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that.id,_that.authorId,_that.authorName,_that.title,_that.content,_that.tags,_that.commentCount,_that.comments,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Post implements Post {
  const _Post({@JsonKey(name: '_id') required this.id, required this.authorId, required this.authorName, required this.title, required this.content, final  List<String> tags = const [], this.commentCount = 0, required final  List<CommunityComment> comments, required this.createdAt}): _tags = tags,_comments = comments;
  factory _Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

@override@JsonKey(name: '_id') final  String id;
@override final  String authorId;
@override final  String authorName;
@override final  String title;
@override final  String content;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@JsonKey() final  int commentCount;
 final  List<CommunityComment> _comments;
@override List<CommunityComment> get comments {
  if (_comments is EqualUnmodifiableListView) return _comments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_comments);
}

@override final  DateTime createdAt;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostCopyWith<_Post> get copyWith => __$PostCopyWithImpl<_Post>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Post&&(identical(other.id, id) || other.id == id)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&const DeepCollectionEquality().equals(other._comments, _comments)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,authorId,authorName,title,content,const DeepCollectionEquality().hash(_tags),commentCount,const DeepCollectionEquality().hash(_comments),createdAt);

@override
String toString() {
  return 'Post(id: $id, authorId: $authorId, authorName: $authorName, title: $title, content: $content, tags: $tags, commentCount: $commentCount, comments: $comments, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PostCopyWith<$Res> implements $PostCopyWith<$Res> {
  factory _$PostCopyWith(_Post value, $Res Function(_Post) _then) = __$PostCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '_id') String id, String authorId, String authorName, String title, String content, List<String> tags, int commentCount, List<CommunityComment> comments, DateTime createdAt
});




}
/// @nodoc
class __$PostCopyWithImpl<$Res>
    implements _$PostCopyWith<$Res> {
  __$PostCopyWithImpl(this._self, this._then);

  final _Post _self;
  final $Res Function(_Post) _then;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? authorId = null,Object? authorName = null,Object? title = null,Object? content = null,Object? tags = null,Object? commentCount = null,Object? comments = null,Object? createdAt = null,}) {
  return _then(_Post(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,authorName: null == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,comments: null == comments ? _self._comments : comments // ignore: cast_nullable_to_non_nullable
as List<CommunityComment>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
