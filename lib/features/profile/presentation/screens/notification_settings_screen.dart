import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm2fork_mobile/core/localization/l10n_extension.dart';
import 'package:farm2fork_mobile/core/network/network_providers.dart';
import 'package:farm2fork_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:farm2fork_mobile/features/notifications/push_controller.dart';

final notificationsInboxProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  if (ref.watch(authControllerProvider).value?.user == null) return [];
  final response = await ref
      .watch(dioProvider)
      .get<Map<String, dynamic>>(
        '/notifications',
        queryParameters: {'limit': 50},
      );
  return (response.data?['data'] as List? ?? []).cast<Map<String, dynamic>>();
});

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});
  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsState();
}

class _NotificationSettingsState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _busy = false;
  bool _error = false;
  bool _denied = false;
  Future<void> _toggle(bool enabled) async {
    setState(() {
      _busy = true;
      _error = false;
      _denied = false;
    });
    try {
      final controller = ref.read(pushControllerProvider.notifier);
      if (enabled) {
        await controller.disable();
      } else {
        final granted = await controller.enable();
        if (mounted) setState(() => _denied = !granted);
      }
    } catch (_) {
      if (mounted) setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _readAll() async {
    setState(() {
      _busy = true;
      _error = false;
    });
    try {
      await ref.read(dioProvider).post('/notifications/read-all');
      ref.invalidate(notificationsInboxProvider);
    } catch (_) {
      if (mounted) setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = ref.watch(authControllerProvider).value?.user;
    final push = ref.watch(pushControllerProvider);
    final inbox = ref.watch(notificationsInboxProvider);
    final enabled = push.value ?? false;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notificationsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(l10n.pushDescription),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _busy || push.isLoading || user == null
                ? null
                : () => _toggle(enabled),
            child: Text(enabled ? l10n.pushDisable : l10n.pushEnable),
          ),
          if (user == null) Text(l10n.pushSignIn),
          if (_denied) Text(l10n.pushDenied),
          if (_error || push.hasError) Text(l10n.errorOccurred),
          if (push.hasError)
            TextButton(
              onPressed: () => ref.invalidate(pushControllerProvider),
              child: Text(l10n.retry),
            ),
          const SizedBox(height: 20),
          Text(l10n.pushInbox, style: Theme.of(context).textTheme.titleLarge),
          Wrap(
            children: [
              TextButton(
                onPressed: () => ref.invalidate(notificationsInboxProvider),
                child: Text(l10n.dispatchRefresh),
              ),
              TextButton(
                onPressed: _busy || user == null ? null : _readAll,
                child: Text(l10n.pushReadAll),
              ),
            ],
          ),
          inbox.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Text(l10n.errorOccurred),
            data: (items) => Column(
              children: [
                if (items.isEmpty) Text(l10n.pushEmpty),
                for (final item in items)
                  ListTile(
                    title: Text(item['title'] as String? ?? ''),
                    subtitle: Text(item['message'] as String? ?? ''),
                    trailing: item['isRead'] == false
                        ? const Icon(Icons.circle, size: 10)
                        : null,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
