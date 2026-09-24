import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/config/app_config.dart';
import 'package:farm2fork_mobile/core/error/api_exception.dart';
import 'package:farm2fork_mobile/core/network/network_providers.dart';

enum NotificationKind {
  orderPlaced('order_placed'),
  paymentConfirmed('payment_confirmed'),
  shipmentAssigned('shipment_assigned'),
  deliveryUpdate('delivery_update'),
  loanUpdate('loan_update'),
  adminAction('admin_action'),
  deliveryOffer('delivery_offer');

  const NotificationKind(this.wire);
  final String wire;

  static NotificationKind fromWire(String? value) => values.firstWhere(
    (kind) => kind.wire == value,
    orElse: () => NotificationKind.adminAction,
  );
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.relatedEntityId,
    this.relatedEntityModel,
  });

  final String id;
  final NotificationKind kind;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final String? relatedEntityId;

  /// 'Order' | 'Shipment' | 'LoanApplication'
  final String? relatedEntityModel;

  AppNotification read() => AppNotification(
    id: id,
    kind: kind,
    title: title,
    message: message,
    isRead: true,
    createdAt: createdAt,
    relatedEntityId: relatedEntityId,
    relatedEntityModel: relatedEntityModel,
  );

  static AppNotification fromJson(Map<String, dynamic> json) => AppNotification(
    id: json['id'] as String,
    kind: NotificationKind.fromWire(json['type'] as String?),
    title: (json['title'] as String?) ?? '',
    message: (json['message'] as String?) ?? '',
    isRead: json['isRead'] == true,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    relatedEntityId: json['relatedEntityId'] as String?,
    relatedEntityModel: json['relatedEntityModel'] as String?,
  );
}

abstract class NotificationsRepository {
  Future<List<AppNotification>> list();
  Future<int> unreadCount();
  Future<void> markRead(String id);
  Future<void> markAllRead();

  /// Registers this device's FCM token for the signed-in account.
  Future<void> registerDeviceToken(String token);
  Future<void> clearDeviceToken();
}

class ApiNotificationsRepository implements NotificationsRepository {
  ApiNotificationsRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<AppNotification>> list() async {
    final data = (await _dio.get<Map<String, dynamic>>(
      '/notifications',
      queryParameters: {'limit': 50},
    )).data;
    final items = data?['data'];
    if (items is! List) throw const ApiException(ApiErrorKind.unknown);
    return items
        .whereType<Map>()
        .map(
          (item) => AppNotification.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
  }

  @override
  Future<int> unreadCount() async {
    final data = (await _dio.get<Map<String, dynamic>>(
      '/notifications/unread-count',
    )).data;
    return (data?['unread'] as num?)?.toInt() ?? 0;
  }

  @override
  Future<void> markRead(String id) =>
      _dio.patch<void>('/notifications/$id/read');

  @override
  Future<void> markAllRead() => _dio.post<void>('/notifications/read-all');

  @override
  Future<void> registerDeviceToken(String token) =>
      _dio.put<void>('/notifications/device-token', data: {'token': token});

  @override
  Future<void> clearDeviceToken() =>
      _dio.delete<void>('/notifications/device-token');
}

class MockNotificationsRepository implements NotificationsRepository {
  final List<AppNotification> _items = [
    AppNotification(
      id: 'n1',
      kind: NotificationKind.paymentConfirmed,
      title: 'Payment confirmed',
      message:
          "We received Rs 2,725 for order #A1B2C3. We're finding a transporter near the farm.",
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
  ];

  @override
  Future<List<AppNotification>> list() async => List.unmodifiable(_items);

  @override
  Future<int> unreadCount() async => _items.where((n) => !n.isRead).length;

  @override
  Future<void> markRead(String id) async {
    final i = _items.indexWhere((n) => n.id == id);
    if (i >= 0) _items[i] = _items[i].read();
  }

  @override
  Future<void> markAllRead() async {
    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].read();
    }
  }

  @override
  Future<void> registerDeviceToken(String token) async {}

  @override
  Future<void> clearDeviceToken() async {}
}

final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  if (AppConfig.useMocks) return MockNotificationsRepository();
  return ApiNotificationsRepository(ref.watch(dioProvider));
});

final notificationsProvider = FutureProvider.autoDispose<List<AppNotification>>(
  (ref) => ref.watch(notificationsRepositoryProvider).list(),
);

final unreadNotificationsProvider = FutureProvider.autoDispose<int>(
  (ref) => ref.watch(notificationsRepositoryProvider).unreadCount(),
);
