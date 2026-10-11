import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/config/app_config.dart';
import 'package:farm2fork_mobile/core/network/network_providers.dart';

class TransporterStatus {
  const TransporterStatus({
    required this.online,
    required this.locationFresh,
    required this.radiusKm,
    this.lastLocationAt,
    this.activeShipmentId,
  });
  final bool online, locationFresh;
  final double radiusKm;
  final DateTime? lastLocationAt;
  final String? activeShipmentId;
  factory TransporterStatus.fromJson(Map<String, dynamic> json) {
    if (json['online'] is! bool ||
        json['locationFresh'] is! bool ||
        json['radiusKm'] is! num) {
      throw const FormatException('Invalid transporter status');
    }
    return TransporterStatus(
      online: json['online'] as bool,
      locationFresh: json['locationFresh'] as bool,
      radiusKm: (json['radiusKm'] as num).toDouble(),
      lastLocationAt: DateTime.tryParse(
        json['lastLocationAt'] as String? ?? '',
      ),
      activeShipmentId: json['activeShipmentId'] as String?,
    );
  }
}

class TransporterDispatchService {
  TransporterDispatchService(this._dio, {this.useMocks = false});
  final Dio _dio;
  final bool useMocks;
  bool _mockOnline = false;
  DateTime? _mockLocationAt;
  TransporterStatus _mockStatus() => TransporterStatus(
    online: _mockOnline,
    locationFresh: _mockLocationAt != null,
    radiusKm: 20,
    lastLocationAt: _mockLocationAt,
  );
  Future<TransporterStatus> getStatus() async => useMocks
      ? _mockStatus()
      : TransporterStatus.fromJson(
          (await _dio.get<Map<String, dynamic>>(
            '/shipments/transporter/status',
          )).data!,
        );
  Future<TransporterStatus> setAvailability(
    bool online, {
    double? lat,
    double? lng,
  }) async {
    if (useMocks) {
      _mockOnline = online;
      if (online) _mockLocationAt = DateTime.now();
      return _mockStatus();
    }
    return TransporterStatus.fromJson(
      (await _dio.put<Map<String, dynamic>>(
        '/shipments/transporter/availability',
        data: {
          'online': online,
          if (online) 'location': {'lat': lat, 'lng': lng},
        },
      )).data!,
    );
  }

  Future<void> updateLocation(double lat, double lng) async {
    if (useMocks) {
      _mockLocationAt = DateTime.now();
      return;
    }
    await _dio.put<void>(
      '/shipments/transporter/location',
      data: {'lat': lat, 'lng': lng},
    );
  }
}

final transporterDispatchServiceProvider = Provider(
  (ref) => TransporterDispatchService(
    ref.watch(dioProvider),
    useMocks: AppConfig.useMocks,
  ),
);
