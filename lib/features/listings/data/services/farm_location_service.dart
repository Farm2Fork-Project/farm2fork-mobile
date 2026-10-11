import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/config/app_config.dart';
import 'package:farm2fork_mobile/core/network/network_providers.dart';

class FarmLocationService {
  FarmLocationService(this._dio, {this.useMocks = false});
  final Dio _dio;
  final bool useMocks;
  Map<String, dynamic> _mock = {'complete': false};
  Future<Map<String, dynamic>> get() async => useMocks
      ? _mock
      : (await _dio.get<Map<String, dynamic>>(
          '/farmers/me/farm-location',
        )).data!;
  Future<Map<String, dynamic>> save(Map<String, dynamic> input) async {
    if (useMocks) return _mock = {...input, 'complete': true};
    return (await _dio.patch<Map<String, dynamic>>(
      '/farmers/me/farm-location',
      data: input,
    )).data!;
  }
}

final farmLocationServiceProvider = Provider(
  (ref) =>
      FarmLocationService(ref.watch(dioProvider), useMocks: AppConfig.useMocks),
);
