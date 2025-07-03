import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/post.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

final apiServiceProvider = Provider((ref) => ApiService('http://localhost:8000'));

class PostsNotifier extends StateNotifier<AsyncValue<List<Post>>> {
  PostsNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetch();
  }

  final Ref ref;
  int _offset = 0;
  final int _limit = 10;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  Future<void> fetch({bool refresh = false}) async {
    if (refresh) {
      _offset = 0;
      _hasMore = true;
      state = const AsyncValue.loading();
    }
    if (!_hasMore) return;
    final api = ref.read(apiServiceProvider);
    final auth = ref.read(authProvider);
    try {
      final posts = await api.fetchPosts(
        auth?.username,
        offset: _offset,
        limit: _limit,
      );
      if (refresh) {
        state = AsyncValue.data(posts);
      } else {
        final current = state.value ?? [];
        state = AsyncValue.data([...current, ...posts]);
      }
      if (posts.length < _limit) {
        _hasMore = false;
      } else {
        _offset += _limit;
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final postsNotifierProvider =
    StateNotifierProvider<PostsNotifier, AsyncValue<List<Post>>>((ref) {
  return PostsNotifier(ref);
});

final toggleLikeProvider = Provider(
  (ref) => (Post post, String user) async {
    final api = ref.read(apiServiceProvider);
    if (post.liked) {
      await api.unlikePost(post.id, user);
    } else {
      await api.likePost(post.id, user);
    }
    await ref.read(postsNotifierProvider.notifier).fetch(refresh: true);
  },
);

final addPostProvider = Provider((ref) => (
      String user,
      String caption,
      List<String> categories,
      [String? imageUrl],
    ) async {
      final api = ref.read(apiServiceProvider);
      await api.createPost(user, caption, categories, imageUrl);
      await ref.read(postsNotifierProvider.notifier).fetch(refresh: true);
    });

final deletePostProvider = Provider(
  (ref) => (int postId, String user) async {
    final api = ref.read(apiServiceProvider);
    await api.deletePost(postId, user);
    await ref.read(postsNotifierProvider.notifier).fetch(refresh: true);
  },
);
