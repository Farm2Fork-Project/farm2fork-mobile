import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:farm2fork_mobile/core/config/app_config.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/core/network/media_url.dart';
import 'package:farm2fork_mobile/core/network/network_providers.dart';
import 'package:farm2fork_mobile/core/network/upload_file.dart';

const maxPostPhotos = 4;
const maxPostTags = 5;

/// What a post is, so the feed can be filtered by intent.
enum PostKind {
  discussion,
  question,
  tip,
  market;

  static PostKind parse(Object? value) => PostKind.values.firstWhere(
    (kind) => kind.name == value,
    orElse: () => PostKind.discussion,
  );
}

enum FeedSort { latest, top }

enum ReportReason { spam, abuse, misinformation, scam, other }

class TrendingTag {
  const TrendingTag(this.tag, this.count);

  final String tag;
  final int count;
}

class CommunityAuthor {
  const CommunityAuthor({
    required this.id,
    required this.name,
    required this.role,
    this.city,
  });

  final String id;

  /// Farm or business name, never an email.
  final String name;
  final String role;
  final String? city;

  static CommunityAuthor fromJson(Object? json) {
    final map = json is Map ? json : const {};
    return CommunityAuthor(
      id: (map['id'] as String?) ?? '',
      name: (map['name'] as String?) ?? '',
      role: (map['role'] as String?) ?? '',
      city: map['city'] as String?,
    );
  }
}

class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.author,
    required this.title,
    required this.content,
    required this.images,
    required this.tags,
    required this.commentCount,
    required this.createdAt,
    this.kind = PostKind.discussion,
    this.likeCount = 0,
    this.likedByMe = false,
    this.editedAt,
  });

  final String id;
  final CommunityAuthor author;
  final PostKind kind;
  final int likeCount;
  final bool likedByMe;
  final DateTime? editedAt;
  final String title;
  final String content;

  /// Already resolved to loadable URLs.
  final List<String> images;
  final List<String> tags;
  final int commentCount;
  final DateTime createdAt;

  static CommunityPost fromJson(Map<String, dynamic> json) => CommunityPost(
    id: json['id'] as String,
    author: CommunityAuthor.fromJson(json['author']),
    title: (json['title'] as String?) ?? '',
    content: (json['content'] as String?) ?? '',
    images: [
      for (final url in (json['images'] as List?) ?? const [])
        if (url is String) resolveMediaUrl(url),
    ],
    tags: [
      for (final tag in (json['tags'] as List?) ?? const [])
        if (tag is String) tag,
    ],
    commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    kind: PostKind.parse(json['kind']),
    likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
    likedByMe: json['likedByMe'] == true,
    editedAt: DateTime.tryParse(json['editedAt'] as String? ?? ''),
  );

  CommunityPost copyWith({
    String? title,
    String? content,
    List<String>? tags,
    PostKind? kind,
    int? likeCount,
    bool? likedByMe,
    int? commentCount,
    DateTime? editedAt,
  }) => CommunityPost(
    id: id,
    author: author,
    title: title ?? this.title,
    content: content ?? this.content,
    images: images,
    tags: tags ?? this.tags,
    commentCount: commentCount ?? this.commentCount,
    createdAt: createdAt,
    kind: kind ?? this.kind,
    likeCount: likeCount ?? this.likeCount,
    likedByMe: likedByMe ?? this.likedByMe,
    editedAt: editedAt ?? this.editedAt,
  );
}

class CommunityComment {
  const CommunityComment({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
    this.parentCommentId,
  });

  final String id;
  final CommunityAuthor author;
  final String content;
  final DateTime createdAt;

  /// Set on a reply; replies are one level deep.
  final String? parentCommentId;

  static CommunityComment fromJson(Map<String, dynamic> json) =>
      CommunityComment(
        id: json['id'] as String,
        author: CommunityAuthor.fromJson(json['author']),
        content: (json['content'] as String?) ?? '',
        createdAt:
            DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        parentCommentId: json['parentCommentId'] as String?,
      );
}

class FeedQuery {
  const FeedQuery({
    this.tag,
    this.kind,
    this.sort = FeedSort.latest,
    this.search = '',
  });

  final String? tag;
  final PostKind? kind;
  final FeedSort sort;
  final String search;

  @override
  bool operator ==(Object other) =>
      other is FeedQuery &&
      other.tag == tag &&
      other.kind == kind &&
      other.sort == sort &&
      other.search == search;

  @override
  int get hashCode => Object.hash(tag, kind, sort, search);
}

abstract class CommunityRepository {
  Future<List<CommunityPost>> feed([FeedQuery query = const FeedQuery()]);
  Future<List<TrendingTag>> trendingTags();
  Future<CommunityPost> post(String id);
  Future<CommunityPost> create({
    required String title,
    required String content,
    required List<String> tags,
    required List<XFile> photos,
    PostKind kind = PostKind.discussion,
  });
  Future<CommunityPost> update(
    String postId, {
    required String title,
    required String content,
    required List<String> tags,
    required PostKind kind,
  });
  Future<void> remove(String postId);

  /// Returns the post's new like count.
  Future<int> setLiked(String postId, {required bool liked});
  Future<void> reportPost(String postId, ReportReason reason, {String? note});
  Future<void> reportComment(
    String postId,
    String commentId,
    ReportReason reason, {
    String? note,
  });
  Future<List<CommunityComment>> comments(String postId);
  Future<CommunityComment> addComment(
    String postId,
    String content, {
    String? parentCommentId,
  });
  Future<void> removeComment(String postId, String commentId);
}

class ApiCommunityRepository implements CommunityRepository {
  ApiCommunityRepository(this._dio);

  final Dio _dio;
  static const _base = '/community/posts';

  @override
  Future<List<CommunityPost>> feed([
    FeedQuery query = const FeedQuery(),
  ]) async {
    final search = query.search.trim();
    final data = (await _dio.get<Map<String, dynamic>>(
      _base,
      queryParameters: {
        'limit': 50,
        'tag': ?query.tag,
        'kind': ?query.kind?.name,
        if (query.sort == FeedSort.top) 'sort': 'top',
        if (search.isNotEmpty) 'q': search,
      },
    )).data;
    final items = data?['data'];
    if (items is! List) throw const ApiException(ApiErrorKind.unknown);
    return items
        .whereType<Map>()
        .map((m) => CommunityPost.fromJson(Map<String, dynamic>.from(m)))
        .toList(growable: false);
  }

  @override
  Future<List<TrendingTag>> trendingTags() async {
    final data = (await _dio.get<List<dynamic>>('$_base/tags/trending')).data;
    return [
      for (final row in data ?? const [])
        if (row is Map && row['tag'] is String)
          TrendingTag(row['tag'] as String, (row['count'] as num?)?.toInt() ?? 0),
    ];
  }

  @override
  Future<CommunityPost> post(String id) async =>
      CommunityPost.fromJson(await _map(() => _dio.get('$_base/$id')));

  @override
  Future<CommunityPost> update(
    String postId, {
    required String title,
    required String content,
    required List<String> tags,
    required PostKind kind,
  }) async => CommunityPost.fromJson(
    await _map(
      () => _dio.patch(
        '$_base/$postId',
        data: {
          'title': title,
          'content': content,
          'tags': tags,
          'kind': kind.name,
        },
      ),
    ),
  );

  @override
  Future<int> setLiked(String postId, {required bool liked}) async {
    final path = '$_base/$postId/like';
    final data = await _map(() => liked ? _dio.put(path) : _dio.delete(path));
    return (data['likeCount'] as num?)?.toInt() ?? 0;
  }

  @override
  Future<void> reportPost(
    String postId,
    ReportReason reason, {
    String? note,
  }) => _dio.post<void>(
    '$_base/$postId/report',
    data: {'reason': reason.name, 'note': ?note},
  );

  @override
  Future<void> reportComment(
    String postId,
    String commentId,
    ReportReason reason, {
    String? note,
  }) => _dio.post<void>(
    '$_base/$postId/comments/$commentId/report',
    data: {'reason': reason.name, 'note': ?note},
  );

  @override
  Future<CommunityPost> create({
    required String title,
    required String content,
    required List<String> tags,
    required List<XFile> photos,
    PostKind kind = PostKind.discussion,
  }) async {
    final form = FormData.fromMap({
      'title': title,
      'content': content,
      'kind': kind.name,
      if (tags.isNotEmpty) 'tags': tags.join(','),
    });
    for (final photo in photos) {
      form.files.add(MapEntry('images', await multipartFromXFile(photo)));
    }
    return CommunityPost.fromJson(
      await _map(() => _dio.post(_base, data: form)),
    );
  }

  @override
  Future<void> remove(String postId) => _dio.delete<void>('$_base/$postId');

  @override
  Future<List<CommunityComment>> comments(String postId) async {
    final data = (await _dio.get<List<dynamic>>(
      '$_base/$postId/comments',
    )).data;
    if (data == null) throw const ApiException(ApiErrorKind.unknown);
    return data
        .whereType<Map>()
        .map((m) => CommunityComment.fromJson(Map<String, dynamic>.from(m)))
        .toList(growable: false);
  }

  @override
  Future<CommunityComment> addComment(
    String postId,
    String content, {
    String? parentCommentId,
  }) async => CommunityComment.fromJson(
    await _map(
      () => _dio.post(
        '$_base/$postId/comments',
        data: {'content': content, 'parentCommentId': ?parentCommentId},
      ),
    ),
  );

  @override
  Future<void> removeComment(String postId, String commentId) =>
      _dio.delete<void>('$_base/$postId/comments/$commentId');

  Future<Map<String, dynamic>> _map(
    Future<Response<dynamic>> Function() request,
  ) async {
    final data = (await request()).data;
    if (data is! Map) throw const ApiException(ApiErrorKind.unknown);
    return Map<String, dynamic>.from(data);
  }
}

class MockCommunityRepository implements CommunityRepository {
  static const _farm = CommunityAuthor(
    id: 'mock_farmer_001',
    name: 'Green Valley Farm',
    role: 'farmer',
    city: 'Multan',
  );
  static const _buyer = CommunityAuthor(
    id: 'b1',
    name: 'Fresh Mart',
    role: 'buyer',
    city: 'Lahore',
  );
  static const _otherFarm = CommunityAuthor(
    id: 'f2',
    name: 'Sunrise Orchards',
    role: 'farmer',
    city: 'Sahiwal',
  );

  final List<CommunityPost> _posts = [
    CommunityPost(
      id: 'post_1',
      author: _farm,
      kind: PostKind.question,
      title: 'Best time to sow wheat in South Punjab?',
      content:
          'Planning to sow right after cotton picking. What has worked for you?',
      images: const [],
      tags: const ['wheat', 'sowing'],
      commentCount: 2,
      likeCount: 4,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    CommunityPost(
      id: 'post_2',
      author: _otherFarm,
      kind: PostKind.tip,
      title: 'Cool mangoes in shade before packing',
      content:
          'Two hours in shade after picking and our Chaunsa arrived firm in Lahore. Do not pack them warm.',
      images: const [],
      tags: const ['mango', 'packing'],
      commentCount: 0,
      likeCount: 12,
      likedByMe: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    CommunityPost(
      id: 'post_3',
      author: _buyer,
      kind: PostKind.market,
      title: 'Looking for 2 tons of basmati this week',
      content: 'Grade A or B, delivered to Lahore. Message through an order.',
      images: const [],
      tags: const ['rice', 'buying'],
      commentCount: 0,
      likeCount: 1,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];
  final Map<String, List<CommunityComment>> _comments = {
    'post_1': [
      CommunityComment(
        id: 'c1',
        author: _buyer,
        content: 'Early November worked well for our suppliers.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      CommunityComment(
        id: 'c2',
        author: _farm,
        content: 'Thank you, that matches what my neighbours say.',
        parentCommentId: 'c1',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ],
  };

  int _index(String id) => _posts.indexWhere((p) => p.id == id);

  @override
  Future<List<CommunityPost>> feed([
    FeedQuery query = const FeedQuery(),
  ]) async {
    final words = query.search.trim().toLowerCase();
    final posts = _posts
        .where(
          (p) =>
              (query.tag == null || p.tags.contains(query.tag)) &&
              (query.kind == null || p.kind == query.kind) &&
              (words.isEmpty ||
                  p.title.toLowerCase().contains(words) ||
                  p.content.toLowerCase().contains(words)),
        )
        .toList();
    if (query.sort == FeedSort.top) {
      posts.sort((a, b) => b.likeCount.compareTo(a.likeCount));
    }
    return posts;
  }

  @override
  Future<List<TrendingTag>> trendingTags() async {
    final counts = <String, int>{};
    for (final post in _posts) {
      for (final tag in post.tags) {
        counts[tag] = (counts[tag] ?? 0) + 1;
      }
    }
    return [for (final e in counts.entries) TrendingTag(e.key, e.value)];
  }

  @override
  Future<CommunityPost> post(String id) async =>
      _posts.firstWhere((p) => p.id == id);

  @override
  Future<CommunityPost> create({
    required String title,
    required String content,
    required List<String> tags,
    required List<XFile> photos,
    PostKind kind = PostKind.discussion,
  }) async {
    final post = CommunityPost(
      id: 'post_${DateTime.now().microsecondsSinceEpoch}',
      author: _farm,
      kind: kind,
      title: title,
      content: content,
      images: const [],
      tags: tags,
      commentCount: 0,
      createdAt: DateTime.now(),
    );
    _posts.insert(0, post);
    return post;
  }

  @override
  Future<CommunityPost> update(
    String postId, {
    required String title,
    required String content,
    required List<String> tags,
    required PostKind kind,
  }) async {
    final i = _index(postId);
    return _posts[i] = _posts[i].copyWith(
      title: title,
      content: content,
      tags: tags,
      kind: kind,
      editedAt: DateTime.now(),
    );
  }

  @override
  Future<void> remove(String postId) async =>
      _posts.removeWhere((p) => p.id == postId);

  @override
  Future<int> setLiked(String postId, {required bool liked}) async {
    final i = _index(postId);
    final post = _posts[i];
    if (post.likedByMe != liked) {
      _posts[i] = post.copyWith(
        likedByMe: liked,
        likeCount: post.likeCount + (liked ? 1 : -1),
      );
    }
    return _posts[i].likeCount;
  }

  final List<String> reported = [];

  @override
  Future<void> reportPost(
    String postId,
    ReportReason reason, {
    String? note,
  }) async => reported.add('post:$postId:${reason.name}');

  @override
  Future<void> reportComment(
    String postId,
    String commentId,
    ReportReason reason, {
    String? note,
  }) async => reported.add('comment:$commentId:${reason.name}');

  @override
  Future<List<CommunityComment>> comments(String postId) async =>
      List.unmodifiable(_comments[postId] ?? const []);

  @override
  Future<CommunityComment> addComment(
    String postId,
    String content, {
    String? parentCommentId,
  }) async {
    final comment = CommunityComment(
      id: 'c_${DateTime.now().microsecondsSinceEpoch}',
      author: _farm,
      content: content,
      parentCommentId: parentCommentId,
      createdAt: DateTime.now(),
    );
    (_comments[postId] ??= []).add(comment);
    final i = _index(postId);
    if (i >= 0) {
      _posts[i] = _posts[i].copyWith(commentCount: _posts[i].commentCount + 1);
    }
    return comment;
  }

  @override
  Future<void> removeComment(String postId, String commentId) async =>
      _comments[postId]?.removeWhere((c) => c.id == commentId);
}

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  if (AppConfig.useMocks) return MockCommunityRepository();
  return ApiCommunityRepository(ref.watch(dioProvider));
});

class FeedFilter extends Notifier<FeedQuery> {
  @override
  FeedQuery build() => const FeedQuery();

  void tag(String? tag) => state = FeedQuery(
    tag: tag,
    kind: state.kind,
    sort: state.sort,
    search: state.search,
  );

  void kind(PostKind? kind) => state = FeedQuery(
    tag: state.tag,
    kind: kind,
    sort: state.sort,
    search: state.search,
  );

  void sort(FeedSort sort) => state = FeedQuery(
    tag: state.tag,
    kind: state.kind,
    sort: sort,
    search: state.search,
  );

  void search(String words) => state = FeedQuery(
    tag: state.tag,
    kind: state.kind,
    sort: state.sort,
    search: words,
  );
}

final feedFilterProvider = NotifierProvider<FeedFilter, FeedQuery>(
  FeedFilter.new,
);

final communityFeedProvider = FutureProvider.autoDispose<List<CommunityPost>>(
  (ref) =>
      ref.watch(communityRepositoryProvider).feed(ref.watch(feedFilterProvider)),
);

final trendingTagsProvider = FutureProvider.autoDispose<List<TrendingTag>>(
  (ref) => ref.watch(communityRepositoryProvider).trendingTags(),
);

final communityPostProvider = FutureProvider.autoDispose
    .family<CommunityPost, String>(
      (ref, id) => ref.watch(communityRepositoryProvider).post(id),
    );

final communityCommentsProvider = FutureProvider.autoDispose
    .family<List<CommunityComment>, String>(
      (ref, id) => ref.watch(communityRepositoryProvider).comments(id),
    );
