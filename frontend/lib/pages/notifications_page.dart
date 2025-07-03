import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/notification_provider.dart';
import '../utils/l10n.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = Localizations.localeOf(context);
    final notificationsAsync = ref.watch(notificationsProvider);
    final markRead = ref.read(markNotificationReadProvider);
    return Scaffold(
      appBar: AppBar(title: Text(L10n.of(locale, 'notifications'))),
      body: notificationsAsync.when(
        data: (items) => ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              title: Text(item.title ?? item.message),
              subtitle: Text(item.message),
              trailing: item.isRead
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () => markRead(item.id),
                    ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
