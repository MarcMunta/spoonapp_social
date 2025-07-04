import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import 'api_provider.dart';

final searchUsersProvider = FutureProvider.family<List<UserProfile>, String?>((ref, query) async {
  final api = ref.watch(apiServiceProvider);
  return api.searchUsers(query);
});
