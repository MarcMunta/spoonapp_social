import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/friend_request.dart';
import 'auth_provider.dart';
import 'api_provider.dart';

final friendRequestsProvider = FutureProvider<List<FriendRequest>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final auth = ref.read(authProvider);
  return api.fetchFriendRequests(auth?.username);
});

final sendFriendRequestProvider = Provider(
  (ref) => (String toUser) async {
    final api = ref.read(apiServiceProvider);
    final auth = ref.read(authProvider);
    if (auth != null) {
      await api.sendFriendRequest(auth.username, toUser);
      ref.invalidate(friendRequestsProvider);
    }
  },
);

final acceptFriendRequestProvider = Provider(
  (ref) => (int id) async {
    final api = ref.read(apiServiceProvider);
    await api.acceptFriendRequest(id);
    ref.invalidate(friendRequestsProvider);
  },
);
