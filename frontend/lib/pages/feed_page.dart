import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/post_provider.dart';
import '../providers/story_provider.dart';
import '../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/go_router.dart';
import '../widgets/story_circle.dart';
import '../widgets/post_card.dart';
import '../widgets/add_story_circle.dart';

class FeedPage extends ConsumerWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postsNotifierProvider);
    final notifier = ref.read(postsNotifierProvider.notifier);
    final storiesAsync = ref.watch(storiesNotifierProvider);
    final auth = ref.watch(authProvider);
    final category = ref.watch(selectedCategoryProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(category == null ? 'Feed' : 'Feed (${category})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => context.push('/categories'),
          )
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 110,
            child: storiesAsync.when(
              data: (stories) {
                final items = [
                  if (auth != null) const AddStoryCircle(),
                  ...stories.map((s) => StoryCircle(story: s))
                ];
                return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final widget = items[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: widget,
                  );
                },
              );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
          Expanded(
            child: postsAsync.when(
              data: (posts) => RefreshIndicator(
                onRefresh: () => notifier.fetch(refresh: true),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification.metrics.pixels >=
                            notification.metrics.maxScrollExtent -
                                200 &&
                        notifier.hasMore) {
                      notifier.fetch();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return PostCard(post: post);
                    },
                  ),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: auth == null
          ? null
          : FloatingActionButton(
              onPressed: () => context.push('/new'),
              child: const Icon(Icons.add),
            ),
    );
  }
}
