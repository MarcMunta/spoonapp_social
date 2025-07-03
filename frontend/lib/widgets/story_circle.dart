import 'package:flutter/material.dart';

import '../models/story.dart';
import '../pages/story_page.dart';

class StoryCircle extends StatelessWidget {
  final Story story;
  const StoryCircle({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => StoryPage(story: story)),
      ),
      child: Column(
        children: [
          Hero(
            tag: 'story_${story.id}',
            child: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(story.imageUrl),
            ),
          ),
          const SizedBox(height: 4),
          Text(story.user, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
