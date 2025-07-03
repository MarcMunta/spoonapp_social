import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../models/post.dart';
import '../pages/post_detail_page.dart';

class PostCard extends StatelessWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/post/${post.id}', extra: post),
      child: Card(
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
              Hero(
                tag: 'post_${post.id}',
                child: CachedNetworkImage(
                  imageUrl: post.imageUrl!,
                  fit: BoxFit.cover,
                ),
              ),
            if (post.caption.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(post.caption),
              ),
          ],
        ),
      ),
    );
  }
}
