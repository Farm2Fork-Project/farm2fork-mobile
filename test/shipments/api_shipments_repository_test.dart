import 'package:dio/dio.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/features/shipments/data/models/shipment.dart';
import 'package:farm2fork_mobile/features/shipments/data/repositories/api_shipments_repository.dart';
import 'package:farm2fork_mobile/features/shipments/data/services/shipments_api_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubApi extends ShipmentsApiService {
  _StubApi({
    this.available = const [],
    this.shipments = const [],
    this.shipment,
  }) : super(Dio());

  final List<Map<String, dynamic>> available;
  final List<Map<String, dynamic>> shipments;
  final Map<String, dynamic>? shipment;
  String? claimedOrderId;
  String? updatedShipmentId;
  Map<String, dynamic>? statusBody;

  @override
  Future<List<Map<String, dynamic>>> getAvailableDeliveries() async => available;

  @override
  Future<List<Map<String, dynamic>>> getMyShipments() async => shipments;

  @override
  Future<Map<String, dynamic>> getShipment(String shipmentId) async {
    return shipment ?? <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> claimShipment(String orderId) async {
    claimedOrderId = orderId;
    return shipment ?? <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> updateShipmentStatus({
    required String shipmentId,
    required String status,
    required String note,
  }) async {
    updatedShipmentId = shipmentId;
    statusBody = {'status': status, 'note': note};
    return shipment ?? <String, dynamic>{};
  }
}

const _shipmentDto = <String, dynamic>{
  'id': 'shipment-1',
  'orderId': 'order-1',
  'transporterId': 'transporter-1',
  'status': 'assigned',
  'pickupAddress': {
    'street': 'Green Farm, Canal Road',
    'city': 'Faisalabad',
    'province': 'Punjab',
  },
  'deliveryAddress': {
    'street': '21 Market Road',
    'city': 'Lahore',
    'province': 'Punjab',
    'zip': '54000',
  },
  'statusHistory': [
    {
      'status': 'assigned',
      'timestamp': '2026-08-11T00:00:00.000Z',
      'note': 'Shipment claimed by transporter',
      'updatedBy': 'transporter-1',
    },
  ],
  'estimatedDelivery': '2026-08-13T00:00:00.000Z',
  'createdAt': '2026-08-11T00:00:00.000Z',
  'updatedAt': '2026-08-11T00:00:00.000Z',
};

void main() {
  test('maps a redacted available delivery from the backend', () async {
    final api = _StubApi(
      available: const [
        {
          'orderId': 'order-1',
          'pickupCity': 'Faisalabad',
          'pickupProvince': 'Punjab',
          'deliveryCity': 'Lahore',
          'deliveryProvince': 'Punjab',
          'itemCount': 2,
          'createdAt': '2026-08-11T00:00:00.000Z',
        },
      ],
    );

    final deliveries = await ApiShipmentsRepository(api).getAvailable();

    expect(deliveries, hasLength(1));
    expect(deliveries.single.orderId, 'order-1');
    expect(deliveries.single.itemCount, 2);
  });

  test('claims only the selected order and maps the assigned shipment', () async {
    final api = _StubApi(shipment: _shipmentDto);

    final shipment = await ApiShipmentsRepository(api).claim('order-1');

    expect(api.claimedOrderId, 'order-1');
    expect(shipment.id, 'shipment-1');
    expect(shipment.status, ShipmentStatus.assigned);
  });

  test('rejects a shipment response without a backend id', () async {
    final malformed = Map<String, dynamic>.from(_shipmentDto)..remove('id');
    final api = _StubApi(shipments: [malformed]);

    await expectLater(
      ApiShipmentsRepository(api).getMine(),
      throwsA(isA<ApiException>()),
    );
  });
}
