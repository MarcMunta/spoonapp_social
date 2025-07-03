import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/post.dart';
import '../pages/post_detail_page.dart';
import '../providers/post_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../utils/l10n.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final locale = ref.watch(languageProvider);
    return GestureDetector(
      onTap: () => context.push('/post/${post.id}', extra: post),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(child: Text(post.user[0].toUpperCase())),
              title: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: post.bubbleColor != null
                      ? Color(int.parse(post.bubbleColor!.substring(1), radix: 16) + 0xFF000000)
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  post.user,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              subtitle: Text(post.createdAt.toLocal().toString()),
              trailing: auth != null && auth.username == post.user
                  ? PopupMenuButton(
                      onSelected: (value) async {
                        if (value == 'delete') {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(L10n.of(locale, 'delete_post_question')),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: Text(L10n.of(locale, 'cancel'))),
                                TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: Text(L10n.of(locale, 'delete'))),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            await ref
                                .read(deletePostProvider)(post.id, auth.username);
                          }
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                            value: 'delete',
                            child: Text(L10n.of(locale, 'delete'))),
                      ],
                    )
                  : null,
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
            if (post.categories.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Wrap(
                  spacing: 4,
                  children: [
                    for (final c in post.categories)
                      Chip(label: Text(c), visualDensity: VisualDensity.compact),
                  ],
                ),
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
