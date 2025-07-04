import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/story.dart';
import 'package:go_router/go_router.dart';

class StoryCircle extends StatelessWidget {
  final Story story;
  const StoryCircle({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/story/${story.id}'),
      child: Column(
        children: [
          Hero(
            tag: 'story_${story.id}',
            child: CircleAvatar(
              radius: 30,
              backgroundImage: CachedNetworkImageProvider(story.imageUrl),
            ),
          ),
          const SizedBox(height: 4),
          Text(story.user, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
