import 'package:flutter/material.dart';
import '../models/story.dart';
import 'story_viewer.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../providers/user_provider.dart';
import 'package:file_picker/file_picker.dart';

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
        itemCount: stories.length + 1,
        itemBuilder: (context, index) {
          final user = context.read<UserProvider>().currentUser;
          final postProv = context.read<PostProvider>();
          if (index == 0) {
            final borderColor = postProv.userHasStory(user)
                ? Colors.blueAccent
                : Colors.grey;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          final idx = postProv.indexOfFirstStory(user);
                          if (idx >= 0) {
                            showDialog(
                              context: context,
                              builder: (_) => StoryViewer(
                                stories: stories,
                                initialIndex: idx,
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: borderColor, width: 2),
                          ),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(user.profileImage),
                            radius: 30,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () async {
                            final res = await FilePicker.platform.pickFiles(type: FileType.image);
                            if (res != null && res.files.single.bytes != null) {
                              await postProv.addStory(user, res.files.single.bytes!);
                            }
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFFB46DDD), Color(0xFFD9A7C7)],
                              ),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: const Icon(Icons.add, size: 16, color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 60,
                    child: Text(
                      user.name,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            );
          }
          final story = stories[index - 1];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => StoryViewer(
                    stories: stories,
                    initialIndex: index - 1,
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
                  SizedBox(
                    width: 60,
                    child: Text(
                      story.user.name,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
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
