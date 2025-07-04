import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../widgets/post_card.dart';
import '../widgets/stories_carousel.dart';
import '../widgets/topbar.dart';
import '../widgets/sidebar.dart';
import 'create_post_page.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final posts = context.watch<PostProvider>().posts;
    final stories = context.watch<PostProvider>().stories;
    final isWide = MediaQuery.of(context).size.width > 800;

    final feedContent = ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        StoriesCarousel(stories: stories),
        ...posts.map((p) => PostCard(post: p)),
      ],
    );

    final feed = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: feedContent,
      ),
    );

    return Scaffold(
      appBar: const TopBar(title: 'SpoonApp Social'),
      body: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: feed),
                const Sidebar(),
              ],
            )
          : feed,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD9A7C7),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const CreatePostPage()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
