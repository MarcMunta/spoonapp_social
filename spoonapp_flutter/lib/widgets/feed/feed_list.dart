import 'package:flutter/material.dart';
import '../../models/post.dart';
import '../post_card.dart';

class FeedList extends StatelessWidget {
  final List<Post> posts;
  const FeedList({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return PostCard(post: posts[index]);
      },
    );
  }
}
