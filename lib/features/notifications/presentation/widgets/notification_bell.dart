import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/theme/app_colors.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/notifications/data/notifications_repository.dart';

/// App-bar bell with the unread count; opens the inbox.
class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key});

  static const route = '/notifications';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedIn =
        ref.watch(authControllerProvider).asData?.value.isAuthenticated ??
        false;
    if (!signedIn) return const SizedBox.shrink();
    final unread = ref.watch(unreadNotificationsProvider).asData?.value ?? 0;
    return IconButton(
      tooltip: context.l10n.notificationsTitle,
      onPressed: () => context.push(route),
      icon: Badge(
        isLabelVisible: unread > 0,
        backgroundColor: AppColors.errorRed,
        label: Text(unread > 99 ? '99+' : '$unread'),
        child: const Icon(Icons.notifications_rounded),
      ),
    );
  }
}
