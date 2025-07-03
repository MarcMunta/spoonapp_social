import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/post.dart';
import '../providers/comment_provider.dart';
import '../providers/auth_provider.dart';

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
    final commentsAsync = ref.watch(commentsProvider(widget.post.id));
    return Scaffold(
      appBar: AppBar(title: Text(widget.post.user)),
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
                        title: Text(c.user),
                        subtitle: Text(c.content),
                        trailing: Text(
                          c.createdAt.toLocal().toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ))
                  .toList(),
            ),
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error: $e')),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                        hintText: 'Escribe un comentario'),
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
