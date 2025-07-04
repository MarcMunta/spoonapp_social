import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/story.dart';
import 'api_provider.dart';

class StoriesNotifier extends StateNotifier<AsyncValue<List<Story>>> {
  StoriesNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetch();
  }

  final Ref ref;

  Future<void> fetch() async {
    final api = ref.read(apiServiceProvider);
    try {
      final stories = await api.fetchStories();
      state = AsyncValue.data(stories);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final storiesNotifierProvider =
    StateNotifierProvider<StoriesNotifier, AsyncValue<List<Story>>>((ref) {
  return StoriesNotifier(ref);
});

final addStoryProvider = Provider((ref) => (String user, String imageUrl) async {
      final api = ref.read(apiServiceProvider);
      await api.createStory(user, imageUrl);
      await ref.read(storiesNotifierProvider.notifier).fetch();
    });

final deleteStoryProvider =
    Provider((ref) => (int id, String user) async {
          final api = ref.read(apiServiceProvider);
          await api.deleteStory(id, user);
          await ref.read(storiesNotifierProvider.notifier).fetch();
        });
