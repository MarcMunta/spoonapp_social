import 'package:flutter/material.dart';
import 'widgets/feed/feed_list.dart';
import 'widgets/stories/story_list.dart';
import 'widgets/topbar/top_bar.dart';

void main() {
  runApp(const SpoonApp());
}

class SpoonApp extends StatelessWidget {
  const SpoonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpoonApp Social',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const FeedPage(),
    );
  }
}

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final stories = [
      Story(id: '1', user: 'Alice', mediaUrl: 'https://via.placeholder.com/150', expiresAt: DateTime.now().add(const Duration(hours: 24))),
      Story(id: '2', user: 'Bob', mediaUrl: 'https://via.placeholder.com/150', expiresAt: DateTime.now().add(const Duration(hours: 24))),
    ];

    final posts = [
      Post(
        id: '1',
        user: 'Alice',
        date: DateTime.now().subtract(const Duration(hours: 1)),
        text: 'Hello from Flutter!',
        mediaUrl: 'https://via.placeholder.com/400x200',
        likes: 4,
      ),
      Post(
        id: '2',
        user: 'Bob',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        text: 'Another post',
        mediaUrl: null,
        likes: 2,
      ),
    ];

    return Scaffold(
      appBar: const TopBar(title: 'SpoonApp Social'),
      body: Column(
        children: [
          StoryList(stories: stories),
          Expanded(child: FeedList(posts: posts)),
        ],
      ),
    );
  }
}
