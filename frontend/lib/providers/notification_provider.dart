import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification.dart';
import 'api_provider.dart';

final notificationsProvider = FutureProvider<List<NotificationItem>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.fetchNotifications();
});

final markNotificationReadProvider = Provider(
  (ref) => (int id) async {
    final api = ref.read(apiServiceProvider);
    await api.markNotificationRead(id);
    ref.invalidate(notificationsProvider);
  },
);
