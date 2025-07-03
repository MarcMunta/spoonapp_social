import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/story.dart';

class StoryPage extends StatelessWidget {
  final Story story;
  const StoryPage({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Hero(
          tag: 'story_${story.id}',
          child: CachedNetworkImage(imageUrl: story.imageUrl),
        ),
      ),
    );
  }
}
