import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/features/profile/data/models/user_profile.dart';
import 'package:farm2fork_mobile/features/profile/data/repositories/api_profile_repository.dart';
import 'package:farm2fork_mobile/features/profile/data/services/profile_api_service.dart';

const _profileJson = {
  'user': {
    'id': 'u1',
    'email': 'a@b.com',
    'role': 'buyer',
    'fullName': 'Ayesha Khan',
    'isVerified': true,
    'isActive': true,
  },
  'displayName': 'Ayesha Khan',
  'profile': {'kind': 'buyer', 'cnicMasked': '*********5671'},
};

class _Recorder implements HttpClientAdapter {
  RequestOptions? last;
  List<int>? body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    if (requestStream != null) {
      body = [await for (final chunk in requestStream) ...chunk];
    }
    return ResponseBody.fromString(
      jsonEncode(_profileJson),
      200,
      headers: {
        'content-type': ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _Recorder adapter;
  late ApiProfileRepository repo;

  setUp(() {
    adapter = _Recorder();
    final dio = Dio(BaseOptions(contentType: 'application/json'))
      ..httpClientAdapter = adapter;
    repo = ApiProfileRepository(ProfileApiService(dio));
  });

  test('fetch reads GET /auth/me/profile', () async {
    final profile = await repo.fetch();
    expect(adapter.last!.method, 'GET');
    expect(adapter.last!.path, '/auth/me/profile');
    expect(profile.displayName, 'Ayesha Khan');
  });

  test('update PATCHes only the fields that are set', () async {
    await repo.update(const ProfileUpdate(fullName: 'New Name'));
    expect(adapter.last!.method, 'PATCH');
    expect(adapter.last!.path, '/auth/me/profile');
    expect(adapter.last!.data, {'fullName': 'New Name'});
  });

  test('uploadAvatar PUTs multipart field "file" as image/jpeg', () async {
    await repo.uploadAvatar(
      const AvatarUpload(bytes: [0xFF, 0xD8, 0xFF, 0xE0, 1, 2, 3]),
    );
    expect(adapter.last!.method, 'PUT');
    expect(adapter.last!.path, '/auth/me/avatar');
    expect(
      adapter.last!.headers['content-type'] ??
          adapter.last!.headers['Content-Type'],
      startsWith('multipart/form-data'),
    );
    final form = adapter.last!.data as FormData;
    expect(form.files.single.key, 'file');
    expect(form.files.single.value.contentType?.mimeType, 'image/jpeg');
    final raw = latin1.decode(adapter.body!);
    expect(raw, contains('name="file"'));
    expect(raw.toLowerCase(), contains('content-type: image/jpeg'));
  });

  test('removeAvatar DELETEs /auth/me/avatar', () async {
    await repo.removeAvatar();
    expect(adapter.last!.method, 'DELETE');
    expect(adapter.last!.path, '/auth/me/avatar');
  });
}
