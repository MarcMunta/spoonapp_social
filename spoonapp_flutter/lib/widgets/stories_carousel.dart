import 'package:flutter/material.dart';
import '../models/story.dart';
import 'story_viewer.dart';

class StoriesCarousel extends StatelessWidget {
  final List<Story> stories;
  const StoriesCarousel({super.key, required this.stories});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECF5),
        borderRadius: BorderRadius.circular(12),
      ),
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => StoryViewer(
                    stories: stories,
                    initialIndex: index,
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blueAccent, width: 2),
                    ),
                    child: CircleAvatar(
                      backgroundImage: story.user.profileImage.startsWith('http')
                          ? NetworkImage(story.user.profileImage)
                              as ImageProvider
                          : AssetImage(story.user.profileImage),
                      radius: 30,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    story.user.name,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
