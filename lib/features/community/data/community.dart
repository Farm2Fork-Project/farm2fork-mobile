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
  });

  final String id;
  final CommunityAuthor author;
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
  );
}

class CommunityComment {
  const CommunityComment({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final CommunityAuthor author;
  final String content;
  final DateTime createdAt;

  static CommunityComment fromJson(Map<String, dynamic> json) =>
      CommunityComment(
        id: json['id'] as String,
        author: CommunityAuthor.fromJson(json['author']),
        content: (json['content'] as String?) ?? '',
        createdAt:
            DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

abstract class CommunityRepository {
  Future<List<CommunityPost>> feed({String? tag});
  Future<CommunityPost> post(String id);
  Future<CommunityPost> create({
    required String title,
    required String content,
    required List<String> tags,
    required List<XFile> photos,
  });
  Future<void> remove(String postId);
  Future<List<CommunityComment>> comments(String postId);
  Future<CommunityComment> addComment(String postId, String content);
  Future<void> removeComment(String postId, String commentId);
}

class ApiCommunityRepository implements CommunityRepository {
  ApiCommunityRepository(this._dio);

  final Dio _dio;
  static const _base = '/community/posts';

  @override
  Future<List<CommunityPost>> feed({String? tag}) async {
    final data = (await _dio.get<Map<String, dynamic>>(
      _base,
      queryParameters: {'limit': 50, 'tag': ?tag},
    )).data;
    final items = data?['data'];
    if (items is! List) throw const ApiException(ApiErrorKind.unknown);
    return items
        .whereType<Map>()
        .map((m) => CommunityPost.fromJson(Map<String, dynamic>.from(m)))
        .toList(growable: false);
  }

  @override
  Future<CommunityPost> post(String id) async =>
      CommunityPost.fromJson(await _map(() => _dio.get('$_base/$id')));

  @override
  Future<CommunityPost> create({
    required String title,
    required String content,
    required List<String> tags,
    required List<XFile> photos,
  }) async {
    final form = FormData.fromMap({
      'title': title,
      'content': content,
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
  Future<CommunityComment> addComment(String postId, String content) async =>
      CommunityComment.fromJson(
        await _map(
          () =>
              _dio.post('$_base/$postId/comments', data: {'content': content}),
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

  final List<CommunityPost> _posts = [
    CommunityPost(
      id: 'post_1',
      author: _farm,
      title: 'Best time to sow wheat in South Punjab?',
      content:
          'Planning to sow right after cotton picking. What has worked for you?',
      images: const [],
      tags: const ['wheat', 'sowing'],
      commentCount: 1,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];
  final Map<String, List<CommunityComment>> _comments = {
    'post_1': [
      CommunityComment(
        id: 'c1',
        author: const CommunityAuthor(
          id: 'b1',
          name: 'Fresh Mart',
          role: 'buyer',
        ),
        content: 'Early November worked well for our suppliers.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ],
  };

  @override
  Future<List<CommunityPost>> feed({String? tag}) async => _posts
      .where((p) => tag == null || p.tags.contains(tag))
      .toList(growable: false);

  @override
  Future<CommunityPost> post(String id) async =>
      _posts.firstWhere((p) => p.id == id);

  @override
  Future<CommunityPost> create({
    required String title,
    required String content,
    required List<String> tags,
    required List<XFile> photos,
  }) async {
    final post = CommunityPost(
      id: 'post_${DateTime.now().microsecondsSinceEpoch}',
      author: _farm,
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
  Future<void> remove(String postId) async =>
      _posts.removeWhere((p) => p.id == postId);

  @override
  Future<List<CommunityComment>> comments(String postId) async =>
      List.unmodifiable(_comments[postId] ?? const []);

  @override
  Future<CommunityComment> addComment(String postId, String content) async {
    final comment = CommunityComment(
      id: 'c_${DateTime.now().microsecondsSinceEpoch}',
      author: _farm,
      content: content,
      createdAt: DateTime.now(),
    );
    (_comments[postId] ??= []).add(comment);
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

class CommunityTagFilter extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? tag) => state = tag;
}

final communityTagFilterProvider =
    NotifierProvider<CommunityTagFilter, String?>(CommunityTagFilter.new);

final communityFeedProvider = FutureProvider.autoDispose<List<CommunityPost>>(
  (ref) => ref
      .watch(communityRepositoryProvider)
      .feed(tag: ref.watch(communityTagFilterProvider)),
);

final communityPostProvider = FutureProvider.autoDispose
    .family<CommunityPost, String>(
      (ref, id) => ref.watch(communityRepositoryProvider).post(id),
    );

final communityCommentsProvider = FutureProvider.autoDispose
    .family<List<CommunityComment>, String>(
      (ref, id) => ref.watch(communityRepositoryProvider).comments(id),
    );
