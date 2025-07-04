import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../widgets/post_card.dart';
import '../widgets/stories_carousel.dart';
import '../widgets/topbar.dart';
import '../widgets/sidebar_left.dart';
import '../widgets/sidebar_right.dart';
import 'create_post_page.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  bool _leftOpen = false;
  bool _rightOpen = false;

  void _toggleLeft() => setState(() => _leftOpen = !_leftOpen);
  void _toggleRight() => setState(() => _rightOpen = !_rightOpen);

  @override
  Widget build(BuildContext context) {
    final posts = context.watch<PostProvider>().posts;
    final stories = context.watch<PostProvider>().stories;
    final width = MediaQuery.of(context).size.width;
    final showLeft = width > 1000;

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

    final body = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLeft) const SidebarLeft(),
        Expanded(child: feed),
      ],
    );

    return Scaffold(
      appBar: TopBar(
        title: 'SpoonApp Social',
        onLeftMenu: _toggleLeft,
        onRightMenu: _toggleRight,
      ),
      body: Stack(
        children: [
          body,
          if (!showLeft)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              top: 0,
              bottom: 0,
              left: _leftOpen ? 0 : -216,
              child: const SidebarLeft(),
            ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            top: 0,
            bottom: 0,
            right: _rightOpen ? 0 : -216,
            child: const SidebarRight(),
          ),
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
