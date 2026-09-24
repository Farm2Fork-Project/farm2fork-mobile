import 'package:dio/dio.dart';
import 'package:farm2fork_mobile/core/config/app_config.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/core/network/network_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wire values the backend accepts (PAKISTAN_PROVINCES).
enum PakistanProvince {
  punjab('Punjab'),
  sindh('Sindh'),
  khyberPakhtunkhwa('Khyber Pakhtunkhwa'),
  balochistan('Balochistan'),
  gilgitBaltistan('Gilgit-Baltistan'),
  azadJammuKashmir('Azad Jammu and Kashmir'),
  islamabad('Islamabad Capital Territory');

  const PakistanProvince(this.wire);
  final String wire;

  static PakistanProvince? fromWire(String? value) {
    for (final province in values) {
      if (province.wire == value) return province;
    }
    return null;
  }
}

/// A farm's pickup location. Transporters only see and claim orders from
/// farms whose street/village, city and province are all set.
class FarmLocation {
  const FarmLocation({this.address, this.city, this.province});

  final String? address;
  final String? city;
  final PakistanProvince? province;

  bool get complete =>
      (address?.trim().isNotEmpty ?? false) &&
      (city?.trim().isNotEmpty ?? false) &&
      province != null;

  Map<String, dynamic> toJson() => {
    'address': address?.trim(),
    'city': city?.trim(),
    'province': province?.wire,
  };

  static FarmLocation fromJson(Map<String, dynamic> json) => FarmLocation(
    address: json['address'] as String?,
    city: json['city'] as String?,
    province: PakistanProvince.fromWire(json['province'] as String?),
  );
}

abstract class FarmLocationRepository {
  Future<FarmLocation> get();
  Future<FarmLocation> update(FarmLocation location);
}

class ApiFarmLocationRepository implements FarmLocationRepository {
  ApiFarmLocationRepository(this._dio);

  final Dio _dio;
  static const _path = '/farmers/me/farm-location';

  @override
  Future<FarmLocation> get() async =>
      FarmLocation.fromJson(await _unwrap(() => _dio.get(_path)));

  @override
  Future<FarmLocation> update(FarmLocation location) async =>
      FarmLocation.fromJson(
        await _unwrap(() => _dio.patch(_path, data: location.toJson())),
      );

  Future<Map<String, dynamic>> _unwrap(
    Future<Response<dynamic>> Function() request,
  ) async {
    final data = (await request()).data;
    if (data is! Map) throw const ApiException(ApiErrorKind.unknown);
    return Map<String, dynamic>.from(data);
  }
}

/// Mock farmers already have a complete location, so no prompt shows.
class MockFarmLocationRepository implements FarmLocationRepository {
  FarmLocation _location = const FarmLocation(
    address: 'Chak 5, Canal Road',
    city: 'Multan',
    province: PakistanProvince.punjab,
  );

  @override
  Future<FarmLocation> get() async => _location;

  @override
  Future<FarmLocation> update(FarmLocation location) async =>
      _location = location;
}

final farmLocationRepositoryProvider = Provider<FarmLocationRepository>((ref) {
  if (AppConfig.useMocks) return MockFarmLocationRepository();
  return ApiFarmLocationRepository(ref.watch(dioProvider));
});

final farmLocationProvider = FutureProvider.autoDispose<FarmLocation>(
  (ref) => ref.watch(farmLocationRepositoryProvider).get(),
);
