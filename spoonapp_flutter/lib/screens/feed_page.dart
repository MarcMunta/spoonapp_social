import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../widgets/post_card.dart';
import '../widgets/stories_carousel.dart';
import '../widgets/topbar.dart';
import '../widgets/sidebar_left.dart';
import '../widgets/sidebar_right.dart';
import '../providers/menu_provider.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  void _toggleLeft() => context.read<MenuProvider>().toggleLeft();
  void _toggleRight() => context.read<MenuProvider>().toggleRight();

  @override
  Widget build(BuildContext context) {
    final posts = context.watch<PostProvider>().posts;
    final stories = context.watch<PostProvider>().stories;
    final menu = context.watch<MenuProvider>();

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
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            top: 0,
            bottom: 0,
            left: menu.leftOpen ? 0 : -216,
            child: const SidebarLeft(),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            top: 0,
            bottom: 0,
            right: menu.rightOpen ? 0 : -216,
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
            Navigator.pushNamed(context, '/publish');
          },
        ),
      ),
    );
  }
}
