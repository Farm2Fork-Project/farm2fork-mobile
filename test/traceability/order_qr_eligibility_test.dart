import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:farm2fork_mobile/features/orders/data/repositories/api_orders_repository.dart';
import 'package:farm2fork_mobile/features/orders/data/services/orders_api_service.dart';

void main() {
  final repository = ApiOrdersRepository(OrdersApiService(Dio()));
  test('QR eligibility comes exclusively from settled-payment server flag', () {
    for (final status in ['pending', 'paid', 'delivered', 'cancelled']) {
      final dto = <String, dynamic>{
        'id': 'abc',
        'status': status,
        'paymentId': 'old-payment',
      };
      expect(repository.orderFromDto(dto).canViewQr, isFalse);
      expect(
        repository.orderFromDto({...dto, 'canViewQr': true}).canViewQr,
        isTrue,
      );
      expect(
        repository.orderFromDto({...dto, 'canViewQr': false}).canViewQr,
        isFalse,
      );
    }
  });
}
