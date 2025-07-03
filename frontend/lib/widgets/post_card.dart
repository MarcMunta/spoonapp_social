import 'package:flutter/material.dart';

import '../models/post.dart';

class PostCard extends StatelessWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(child: Text(post.user[0].toUpperCase())),
            title: Text(post.user),
            subtitle: Text(post.createdAt.toLocal().toString()),
          ),
          if (post.imageUrl != null)
            Image.network(post.imageUrl!, fit: BoxFit.cover),
          if (post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(post.caption),
            ),
        ],
      ),
    );
  }
}
