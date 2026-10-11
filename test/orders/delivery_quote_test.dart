import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farm2fork_mobile/features/orders/data/models/order.dart';
import 'package:farm2fork_mobile/features/orders/data/repositories/api_orders_repository.dart';
import 'package:farm2fork_mobile/features/orders/data/services/orders_api_service.dart';

class _Api extends OrdersApiService {
  _Api() : super(Dio());
  Map<String, dynamic>? sentAddress;
  @override
  Future<Map<String, dynamic>> quoteOrder({
    required List<({String productId, int quantity})> items,
    required Map<String, dynamic> shippingAddress,
  }) async {
    sentAddress = shippingAddress;
    return {
      'totalAmount': 200,
      'platformFeePercent': 5,
      'platformFeeAmount': 10,
      'deliveryFee': 180,
      'deliveryDistanceKm': 2.5,
      'grandTotal': 390,
    };
  }
}

void main() {
  test(
    'quotes real delivery coordinates and preserves every server amount',
    () async {
      final api = _Api();
      final quote = await ApiOrdersRepository(api).quoteOrder(
        items: [(productId: 'product', quantity: 2)],
        shippingAddress: const OrderAddress(
          street: '12 Mall Road',
          city: 'Lahore',
          province: 'Punjab',
          lat: 31.5204,
          lng: 74.3587,
        ),
      );
      expect(api.sentAddress?['lat'], 31.5204);
      expect(api.sentAddress?['lng'], 74.3587);
      expect(quote.deliveryFee, 180);
      expect(quote.deliveryDistanceKm, 2.5);
      expect(quote.grandTotal, 390);
    },
  );
}
