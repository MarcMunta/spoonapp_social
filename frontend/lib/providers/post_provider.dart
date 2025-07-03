import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/post.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

final apiServiceProvider = Provider((ref) => ApiService('http://localhost:8000'));

final postsProvider = FutureProvider<List<Post>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final auth = ref.read(authProvider);
  return api.fetchPosts(auth?.username);
});

final toggleLikeProvider = Provider(
  (ref) => (Post post, String user) async {
    final api = ref.read(apiServiceProvider);
    if (post.liked) {
      await api.unlikePost(post.id, user);
    } else {
      await api.likePost(post.id, user);
    }
    ref.invalidate(postsProvider);
  },
);

final addPostProvider = Provider((ref) => (
      String user,
      String caption,
      [String? imageUrl],
    ) async {
      final api = ref.read(apiServiceProvider);
      await api.createPost(user, caption, imageUrl);
      ref.invalidate(postsProvider);
    });
