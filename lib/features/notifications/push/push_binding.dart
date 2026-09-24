import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/features/auth/data/models/auth_user.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/notifications/data/notifications_repository.dart';
import 'package:farm2fork_mobile/features/notifications/presentation/notification_routes.dart';
import 'package:farm2fork_mobile/features/notifications/push/push_service.dart';
import 'package:farm2fork_mobile/features/shipments/presentation/providers/dispatch_controller.dart';

/// Connects FCM to the session: registers the device token for whoever is
/// signed in, refreshes badges and offers when a push arrives, and opens
/// the right screen when a notification is tapped.
class PushBinding extends ConsumerStatefulWidget {
  const PushBinding({super.key, required this.router, required this.child});

  final GoRouter router;
  final Widget child;

  @override
  ConsumerState<PushBinding> createState() => _PushBindingState();
}

class _PushBindingState extends ConsumerState<PushBinding> {
  StreamSubscription<String>? _tokenSub;
  PushData? _pendingTap;

  @override
  void initState() {
    super.initState();
    final push = ref.read(pushServiceProvider);
    unawaited(
      push
          .start(onTap: _handleTap, onForegroundMessage: _handleForeground)
          .catchError((_) {}),
    );
    ref.listenManual(authControllerProvider, (previous, next) {
      final wasIn = previous?.asData?.value.isAuthenticated ?? false;
      final isIn = next.asData?.value.isAuthenticated ?? false;
      if (isIn && !wasIn) _register();
      if (isIn && _pendingTap != null) {
        final tap = _pendingTap!;
        _pendingTap = null;
        _handleTap(tap);
      }
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _tokenSub?.cancel();
    super.dispose();
  }

  Future<void> _register() async {
    final push = ref.read(pushServiceProvider);
    final repo = ref.read(notificationsRepositoryProvider);
    try {
      final token = await push.enable();
      if (token != null) await repo.registerDeviceToken(token);
      _tokenSub ??= push.tokenRefresh.listen(
        (token) => repo.registerDeviceToken(token).catchError((_) {}),
      );
    } on Object {
      // Push is best-effort; the in-app inbox still works.
    }
  }

  void _handleForeground(PushData data) {
    ref
      ..invalidate(unreadNotificationsProvider)
      ..invalidate(notificationsProvider);
    if (data['type'] == 'delivery_offer') {
      ref.invalidate(dispatchControllerProvider);
    }
  }

  void _handleTap(PushData data) {
    final auth = ref.read(authControllerProvider).asData?.value;
    // A tap that launched the app arrives before the session is restored.
    if (auth == null || !auth.isAuthenticated || auth.role == null) {
      if (auth?.status != AuthStatus.guest) _pendingTap = data;
      return;
    }
    final notificationId = data['notificationId'];
    if (notificationId is String) {
      ref
          .read(notificationsRepositoryProvider)
          .markRead(notificationId)
          .then((_) => ref.invalidate(unreadNotificationsProvider))
          .catchError((_) {});
    }
    final route = routeForNotification(
      role: auth.role!,
      type: '${data['type']}',
      relatedEntityId: data['relatedEntityId'] as String?,
      relatedEntityModel: data['relatedEntityModel'] as String?,
    );
    if (route == null) return;
    if (route.startsWith('/shipments/')) {
      widget.router.push(route);
    } else {
      widget.router.go(route);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
