import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/config/app_config.dart';
import 'package:farm2fork_mobile/firebase_options.dart';

/// Must be a top-level function (FCM runs it in its own isolate). Messages
/// with a notification payload are displayed by the system; nothing else is
/// needed in the background.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

/// Data carried by a push (see backend NotificationService.push).
typedef PushData = Map<String, dynamic>;

abstract class PushService {
  /// Wires foreground display and tap handling. Call once.
  Future<void> start({
    required void Function(PushData data) onTap,
    required void Function(PushData data) onForegroundMessage,
  });

  /// Asks for permission (Android 13+/iOS) and returns this device's token.
  Future<String?> enable();

  Stream<String> get tokenRefresh;

  /// Forgets the device token (on sign-out).
  Future<void> disable();
}

class FirebasePushService implements PushService {
  final _local = FlutterLocalNotificationsPlugin();
  bool _started = false;

  /// Matches the backend's android.notification.channelId and the
  /// default_notification_channel_id in AndroidManifest.xml.
  static const channel = AndroidNotificationChannel(
    'farm2fork_default',
    'Farm2Fork',
    description: 'Orders, deliveries and loan updates',
    importance: Importance.high,
  );

  @override
  Future<void> start({
    required void Function(PushData data) onTap,
    required void Function(PushData data) onForegroundMessage,
  }) async {
    if (_started) return;
    _started = true;
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _local.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // FCM asks for permission; don't prompt twice.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null) return;
        try {
          onTap(Map<String, dynamic>.from(jsonDecode(payload) as Map));
        } on Object {
          // Malformed payload: nothing to open.
        }
      },
    );
    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // Android doesn't show FCM notifications while the app is in the
    // foreground, so show them locally.
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification != null &&
          defaultTargetPlatform == TargetPlatform.android) {
        _local.show(
          id: message.messageId.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          payload: jsonEncode(message.data),
        );
      }
      onForegroundMessage(message.data);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((m) => onTap(m.data));
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) onTap(initial.data);
  }

  @override
  Future<String?> enable() async {
    final settings = await FirebaseMessaging.instance.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) return null;
    return FirebaseMessaging.instance.getToken();
  }

  @override
  Stream<String> get tokenRefresh => FirebaseMessaging.instance.onTokenRefresh;

  @override
  Future<void> disable() => FirebaseMessaging.instance.deleteToken();
}

/// No push in mock mode (and in tests, which override this provider).
class NoopPushService implements PushService {
  @override
  Future<void> start({
    required void Function(PushData data) onTap,
    required void Function(PushData data) onForegroundMessage,
  }) async {}

  @override
  Future<String?> enable() async => null;

  @override
  Stream<String> get tokenRefresh => const Stream.empty();

  @override
  Future<void> disable() async {}
}

final pushServiceProvider = Provider<PushService>(
  (ref) => AppConfig.useMocks ? NoopPushService() : FirebasePushService(),
);
