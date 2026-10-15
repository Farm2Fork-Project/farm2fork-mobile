import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/features/shipments/data/services/shipments_api_service.dart';

class _Recorder implements HttpClientAdapter {
  final calls = <RequestOptions>[];
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancel,
  ) async {
    calls.add(options);
    return ResponseBody.fromString(
      jsonEncode({'code': '123456', 'shipmentId': 's'}),
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
  test(
    'code reads, reissue, verified completion, reasoned issue and earnings use dedicated endpoints',
    () async {
      final recorder = _Recorder();
      final api = ShipmentsApiService(
        Dio(BaseOptions(baseUrl: 'https://example.test/api'))
          ..httpClientAdapter = recorder,
      );
      await api.getDeliveryCode('s');
      await api.getDeliveryCode('s', reissue: true);
      await api.complete('s', '123456', 'Handover');
      await api.reportIssue('s', 'vehicle_issue', 'Puncture');
      await api.getEarnings();
      expect(recorder.calls.map((r) => '${r.method} ${r.path}'), [
        'GET /delivery/shipments/s/code',
        'POST /delivery/shipments/s/code/reissue',
        'POST /delivery/shipments/s/complete',
        'POST /delivery/shipments/s/issue',
        'GET /delivery/earnings',
      ]);
      expect(recorder.calls[2].data, {'code': '123456', 'note': 'Handover'});
      expect(recorder.calls[3].data, {
        'reason': 'vehicle_issue',
        'note': 'Puncture',
      });
    },
  );
}
