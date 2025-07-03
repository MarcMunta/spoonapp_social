import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification.dart';
import 'post_provider.dart';

final notificationsProvider = FutureProvider<List<NotificationItem>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.fetchNotifications();
});
