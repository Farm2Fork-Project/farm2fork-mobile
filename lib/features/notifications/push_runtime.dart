import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/app/navigation/app_nav_config.dart';
import 'package:farm2fork_mobile/app/router.dart';
import 'package:farm2fork_mobile/core/config/app_config.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'push_controller.dart';

class PushRuntime extends ConsumerStatefulWidget {
  const PushRuntime({super.key, required this.child});
  final Widget child;
  @override
  ConsumerState<PushRuntime> createState() => _PushRuntimeState();
}

class _PushRuntimeState extends ConsumerState<PushRuntime> {
  RemoteMessage? _pending;
  StreamSubscription<RemoteMessage>? _opened;
  StreamSubscription<RemoteMessage>? _foreground;
  @override
  void initState() {
    super.initState();
    if (AppConfig.useMocks || Firebase.apps.isEmpty) return;
    _opened = FirebaseMessaging.onMessageOpenedApp.listen(_open);
    _foreground = FirebaseMessaging.onMessage.listen((message) {
      if (!mounted || ref.read(authControllerProvider).value?.user == null) {
        return;
      }
      final notice = message.notification;
      if (notice != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${notice.title ?? ''}\n${notice.body ?? ''}'),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () => _open(message),
            ),
          ),
        );
      }
    });
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((message) {
          if (message != null && mounted) _open(message);
        })
        .catchError((Object _) {});
  }

  void _open(RemoteMessage message) {
    final user = ref.read(authControllerProvider).value?.user;
    if (user == null) {
      _pending = message;
      return;
    }
    _pending = null;
    final model = message.data['relatedEntityModel'];
    final id = message.data['relatedEntityId'];
    final route =
        model == 'Shipment' &&
            id is String &&
            RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(id)
        ? '/shipments/$id'
        : AppNavConfig.routeFor(
            user.role,
            model == 'Order'
                ? AppNavDestination.orders
                : AppNavDestination.profile,
          );
    ref.read(goRouterProvider).go(route);
  }

  @override
  void dispose() {
    _opened?.cancel();
    _foreground?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(pushControllerProvider);
    ref.listen(authControllerProvider, (_, next) {
      if (next.value?.user != null && _pending != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _pending != null) _open(_pending!);
        });
      }
    });
    return widget.child;
  }
}
