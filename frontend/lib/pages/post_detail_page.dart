import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/post.dart';

class PostDetailPage extends StatelessWidget {
  final Post post;
  const PostDetailPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(post.user)),
      body: ListView(
          children: [
            if (post.imageUrl != null)
              Hero(
                tag: 'post_${post.id}',
                child: CachedNetworkImage(imageUrl: post.imageUrl!, fit: BoxFit.cover),
              ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(post.caption, style: const TextStyle(fontSize: 18)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              post.createdAt.toLocal().toString(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
