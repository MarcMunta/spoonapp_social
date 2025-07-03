import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/block.dart';
import 'auth_provider.dart';
import 'post_provider.dart';

final blocksProvider = FutureProvider<List<Block>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final auth = ref.read(authProvider);
  if (auth == null) return [];
  return api.fetchBlocks(auth.username);
});

final blockUserProvider = Provider(
  (ref) => (String username) async {
    final api = ref.read(apiServiceProvider);
    final auth = ref.read(authProvider);
    if (auth != null) {
      await api.blockUser(auth.username, username);
      ref.invalidate(blocksProvider);
    }
  },
);

final unblockUserProvider = Provider(
  (ref) => (String username) async {
    final api = ref.read(apiServiceProvider);
    final auth = ref.read(authProvider);
    if (auth != null) {
      await api.unblockUser(username, auth.username);
      ref.invalidate(blocksProvider);
    }
  },
);
