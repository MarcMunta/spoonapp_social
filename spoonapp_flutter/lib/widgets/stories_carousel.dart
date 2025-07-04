import 'package:flutter/material.dart';
import '../models/story.dart';

class StoriesCarousel extends StatelessWidget {
  final List<Story> stories;
  const StoriesCarousel({super.key, required this.stories});

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
