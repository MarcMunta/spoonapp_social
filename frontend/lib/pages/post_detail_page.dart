import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/post.dart';
import '../providers/comment_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';
import '../providers/language_provider.dart';
import '../utils/l10n.dart';

class PostDetailPage extends ConsumerStatefulWidget {
  final Post post;
  const PostDetailPage({super.key, required this.post});

  @override
  ConsumerState<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<PostDetailPage> {
  final _controller = TextEditingController();
  bool _sending = false;

  Future<void> _send() async {
    final auth = ref.read(authProvider);
    if (auth == null) return;
    setState(() => _sending = true);
    await ref
        .read(addCommentProvider)(widget.post.id, auth.username, _controller.text);
    _controller.clear();
    ref.invalidate(commentsProvider(widget.post.id));
    setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final commentsAsync = ref.watch(commentsProvider(widget.post.id));
    final auth = ref.watch(authProvider);
    final locale = ref.watch(languageProvider);
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: widget.post.bubbleColor != null
                ? Color(int.parse(widget.post.bubbleColor!.substring(1), radix: 16) + 0xFF000000)
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            widget.post.user,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          if (auth != null && auth.username == widget.post.user)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(L10n.of(locale, 'delete_post_question')),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(L10n.of(locale, 'cancel'))),
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(L10n.of(locale, 'delete'))),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await ref
                      .read(deletePostProvider)(widget.post.id, auth.username);
                  if (mounted) Navigator.of(context).pop();
                }
              },
            )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          if (widget.post.imageUrl != null)
            Hero(
              tag: 'post_${widget.post.id}',
              child: CachedNetworkImage(
                  imageUrl: widget.post.imageUrl!, fit: BoxFit.cover),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(widget.post.caption, style: const TextStyle(fontSize: 18)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              widget.post.createdAt.toLocal().toString(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const Divider(),
          commentsAsync.when(
            data: (comments) => Column(
              children: comments
                  .map((c) => ListTile(
                        title: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: c.bubbleColor != null
                                ? Color(int.parse(c.bubbleColor!.substring(1),
                                        radix: 16) +
                                    0xFF000000)
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            c.user,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        subtitle: Text(c.content),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              c.createdAt.toLocal().toString(),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (auth != null && auth.username == c.user)
                              IconButton(
                                icon: const Icon(Icons.delete, size: 16),
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(L10n.of(locale, 'delete_comment_question')),
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
                                    await ref.read(deleteCommentProvider)(
                                        widget.post.id, c.id, auth.username);
                                  }
                                },
                              ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('${L10n.of(locale, 'error')} $e')),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                        hintText: L10n.of(locale, 'comment_hint')),
                  ),
                ),
                IconButton(
                  onPressed: _sending ? null : _send,
                  icon: _sending
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.send),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
