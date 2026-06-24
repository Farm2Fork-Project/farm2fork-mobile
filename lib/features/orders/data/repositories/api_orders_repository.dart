import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/features/orders/data/models/order.dart';
import 'package:farm2fork_mobile/features/orders/data/services/orders_api_service.dart';
import 'orders_repository.dart';

/// Real [OrdersRepository] backed by the backend `/orders` API.
///
/// The backend response uses `id` (not `_id`) and lowercase status strings, so
/// responses are adapted into the client [Order] model here rather than via
/// raw `Order.fromJson`.
class ApiOrdersRepository implements OrdersRepository {
  ApiOrdersRepository(this._api);

  final OrdersApiService _api;

  @override
  Future<Order> createOrder({
    required List<OrderLine> items,
    required OrderAddress shippingAddress,
  }) async {
    final json = await _api.createOrder(
      items: items,
      shippingAddress: {
        'street': shippingAddress.street,
        'city': shippingAddress.city,
        'province': shippingAddress.province,
        if (shippingAddress.zip != null) 'zip': shippingAddress.zip,
      },
    );
    return _orderFromDto(json);
  }

  @override
  Future<List<Order>> getOrdersByUser({
    required String userId,
    required AppUserRole role,
  }) async {
    // The backend scopes orders by the authenticated caller's role/id, so the
    // userId/role args are not sent — they're satisfied by the JWT.
    final body = await _api.fetchOrders();
    final data = body['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(_orderFromDto)
        .toList(growable: false);
  }

  @override
  Future<Order> updateOrderStatus(String orderId, OrderStatus status) async {
    // Only cancellation is buyer-driven today; other transitions are
    // server-side (payment, shipment). Map cancel to the cancel endpoint.
    if (status == OrderStatus.cancelled) {
      return _orderFromDto(await _api.cancelOrder(orderId));
    }
    throw UnsupportedError('Only cancellation is supported from the client');
  }

  Order _orderFromDto(Map<String, dynamic> dto) {
    return Order(
      id: (dto['id'] as String?) ?? (dto['_id'] as String?) ?? '',
      buyerId: (dto['buyerId'] as String?) ?? '',
      farmerId: (dto['farmerId'] as String?) ?? '',
      items: _items(dto['items']),
      totalAmount: _toDouble(dto['totalAmount']),
      platformFeePercent: _toDouble(dto['platformFeePercent']),
      platformFeeAmount: _toDouble(dto['platformFeeAmount']),
      grandTotal: _toDouble(dto['grandTotal']),
      shippingAddress: _address(dto['shippingAddress']),
      status: _statusFromString(dto['status'] as String?),
      paymentId: dto['paymentId'] as String?,
      shipmentId: dto['shipmentId'] as String?,
      createdAt: _toDate(dto['createdAt']),
      updatedAt: _toDate(dto['updatedAt']),
    );
  }

  List<OrderItem> _items(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map((i) {
          return OrderItem(
            productId: (i['productId'] as String?) ?? '',
            farmerId: (i['farmerId'] as String?) ?? '',
            productName: (i['productName'] as String?) ?? '',
            quantity: _toDouble(i['quantity']),
            // Backend OrderItem has no unit; default to empty (display handles it).
            unit: (i['unit'] as String?) ?? '',
            unitPrice: _toDouble(i['unitPrice']),
            subtotal: _toDouble(i['subtotal']),
          );
        })
        .toList(growable: false);
  }

  OrderAddress _address(Object? value) {
    final map = value is Map<String, dynamic>
        ? value
        : const <String, dynamic>{};
    return OrderAddress(
      street: (map['street'] as String?) ?? '',
      city: (map['city'] as String?) ?? '',
      province: (map['province'] as String?) ?? '',
      zip: map['zip'] as String?,
    );
  }

  OrderStatus _statusFromString(String? value) {
    switch (value) {
      case 'paid':
        return OrderStatus.paid;
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'pending':
      default:
        return OrderStatus.pending;
    }
  }

  double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  DateTime _toDate(Object? value) {
    if (value is String) return DateTime.tryParse(value) ?? DateTime(1970);
    return DateTime(1970);
  }
}
