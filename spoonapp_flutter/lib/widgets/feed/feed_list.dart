import 'package:flutter/material.dart';

class FeedList extends StatelessWidget {
  final List<Post> posts;
  const FeedList({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: CircleAvatar(child: Text(post.user[0])),
                title: Text(post.user),
                subtitle: Text(post.date.toString()),
              ),
              if (post.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(post.text),
                ),
              if (post.mediaUrl != null)
                Image.network(post.mediaUrl!, fit: BoxFit.cover),
              ButtonBar(
                alignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.thumb_up),
                    onPressed: () {},
                  ),
                  Text('${post.likes}'),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}

class Post {
  final String id;
  final String user;
  final DateTime date;
  final String text;
  final String? mediaUrl;
  final int likes;

  Post({
    required this.id,
    required this.user,
    required this.date,
    required this.text,
    this.mediaUrl,
    this.likes = 0,
  });
}
