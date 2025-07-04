import 'package:flutter/material.dart';

class StoryList extends StatelessWidget {
  final List<Story> stories;
  const StoryList({super.key, required this.stories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(story.mediaUrl),
                  radius: 30,
                ),
                const SizedBox(height: 4),
                Text(
                  story.user,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class Story {
  final String id;
  final String user;
  final String mediaUrl;
  final DateTime expiresAt;
  Story({required this.id, required this.user, required this.mediaUrl, required this.expiresAt});
}
