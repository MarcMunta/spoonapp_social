import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/post.dart';
import '../pages/post_detail_page.dart';
import '../providers/post_provider.dart';
import '../providers/auth_provider.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      post.liked ? Icons.favorite : Icons.favorite_border,
                      color: post.liked ? Colors.red : null,
                    ),
                    onPressed: auth == null
                        ? null
                        : () => ref
                            .read(toggleLikeProvider)(post, auth.username),
                  ),
                  Text('${post.likes}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
