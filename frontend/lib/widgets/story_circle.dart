import 'package:flutter/material.dart';

import '../models/story.dart';

class StoryCircle extends StatelessWidget {
  final Story story;
  const StoryCircle({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(story.imageUrl),
        ),
        const SizedBox(height: 4),
        Text(story.user, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
