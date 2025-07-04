import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../widgets/post_card.dart';
import '../widgets/stories_carousel.dart';
import '../widgets/topbar.dart';
import '../widgets/sidebar_left.dart';
import '../widgets/sidebar_right.dart';
import 'create_post_page.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final posts = context.watch<PostProvider>().posts;
    final stories = context.watch<PostProvider>().stories;
    final width = MediaQuery.of(context).size.width;
    final showLeft = width > 1000;
    final showRight = width > 600;

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
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showLeft) const SidebarLeft(),
          Expanded(child: feed),
          if (showRight) const SidebarRight(),
        ],
      ),
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFB46DDD), Color(0xFFD9A7C7)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
        child: IconButton(
          icon: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const CreatePostPage()));
          },
        ),
      ),
    );
  }
}
