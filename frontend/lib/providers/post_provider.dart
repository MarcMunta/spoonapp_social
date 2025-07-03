import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/post.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider((ref) => ApiService('http://localhost:8000'));

final postsProvider = FutureProvider<List<Post>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.fetchPosts();
});
