import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/story_block.dart';
import 'auth_provider.dart';
import 'post_provider.dart';

final storyBlocksProvider = FutureProvider<List<StoryBlock>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final auth = ref.read(authProvider);
  if (auth == null) return [];
  return api.fetchStoryBlocks(auth.username);
});

final hideStoriesProvider = Provider(
  (ref) => (String username) async {
    final api = ref.read(apiServiceProvider);
    final auth = ref.read(authProvider);
    if (auth != null) {
      await api.createStoryBlock(auth.username, username);
      ref.invalidate(storyBlocksProvider);
    }
  },
);

final unhideStoriesProvider = Provider(
  (ref) => (String username) async {
    final api = ref.read(apiServiceProvider);
    final auth = ref.read(authProvider);
    if (auth != null) {
      await api.unhideStory(username, auth.username);
      ref.invalidate(storyBlocksProvider);
    }
  },
);
