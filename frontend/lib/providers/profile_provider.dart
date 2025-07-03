import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import 'post_provider.dart';
import 'auth_provider.dart';

final profileProvider = FutureProvider.family<UserProfile, String>((ref, username) async {
  final api = ref.watch(apiServiceProvider);
  return api.fetchUser(username);
});

final updateProfileProvider = Provider((ref) => (String username, String bio, String? avatarUrl) async {
  final api = ref.read(apiServiceProvider);
  await api.updateUser(username, bio, avatarUrl);
  ref.invalidate(profileProvider(username));
});
