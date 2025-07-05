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
    final user = context.read<UserProvider>().currentUser;
    final postProv = context.read<PostProvider>();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECF5),
        borderRadius: BorderRadius.circular(12),
      ),
      height: 76, // Más compacto
      child: RefreshIndicator(
        onRefresh: () async {
          await postProv.loadStories();
        },
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: stories.where((s) => s.user.email != user.email).length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              // ...avatar propio y botón + (igual que antes)...
              final borderColor = postProv.userHasStory(user)
                  ? Colors.blueAccent
                  : Colors.grey;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Hero(
                          tag: 'story-avatar-${user.email}',
                          child: GestureDetector(
                            onTap: () {
                              final idx = postProv.indexOfFirstStory(user);
                              if (idx >= 0) {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    opaque: false,
                                    transitionDuration: const Duration(milliseconds: 400),
                                    pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
                                      opacity: animation,
                                      child: StoryViewer(
                                        stories: stories,
                                        initialIndex: idx,
                                        heroTag: 'story-avatar-${user.email}',
                                      ),
                                    ),
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
                                backgroundImage: user.profileImage.startsWith('http')
                                    ? NetworkImage(user.profileImage)
                                    : AssetImage(user.profileImage) as ImageProvider,
                                radius: 26,
                                backgroundColor: Colors.grey.shade200,
                              ),
                            ),
                          ),
                        ),
                        // Botón + SOLO en el avatar del usuario actual
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () async {
                              final res = await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'mp4', 'mov', 'avi', 'webm'],
                              );
                              if (res != null && res.files.single.bytes != null) {
                                final filename = res.files.single.name;
                                final bytes = res.files.single.bytes!;
                                final userProvider = context.read<UserProvider>();
                                final token = userProvider.token;
                                final scaffold = ScaffoldMessenger.of(context);
                                final nav = Navigator.of(context);
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (ctx) => const Center(child: CircularProgressIndicator()),
                                );
                                try {
                                  await postProv.addStory(user, bytes, filename, token);
                                  nav.pop(); // Cierra el loading
                                  scaffold.showSnackBar(
                                    const SnackBar(content: Text('Historia subida correctamente')),
                                  );
                                } catch (e) {
                                  nav.pop();
                                  scaffold.showSnackBar(
                                    SnackBar(content: Text('Error al subir la historia: $e')),
                                  );
                                }
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
                    const SizedBox(height: 2),
                    SizedBox(
                      width: 52,
                      height: 16,
                      child: Center(
                        child: Text(
                          user.name,
                          style: const TextStyle(fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // Solo historias de otros usuarios
              final filteredStories = stories.where((s) => s.user.email != user.email).toList();
              final story = filteredStories[index - 1];
              final hasStory = postProv.userHasStory(story.user);
              final isNew = story.expiresAt.difference(DateTime.now()).inHours < 1;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => StoryViewer(
                        stories: stories,
                        initialIndex: stories.indexOf(story),
                      ),
                    );
                  },
                  child: SizedBox(
                    width: 60,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Hero(
                              tag: 'story-avatar-${story.user.email}',
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: hasStory
                                      ? Border.all(color: Colors.blueAccent, width: 2)
                                      : null,
                                  color: !hasStory ? Colors.grey.shade300 : null,
                                ),
                                child: CircleAvatar(
                                  backgroundImage: story.user.profileImage.startsWith('http')
                                      ? NetworkImage(story.user.profileImage)
                                      : AssetImage(story.user.profileImage) as ImageProvider,
                                  radius: 26,
                                  backgroundColor: Colors.grey.shade200,
                                ),
                              ),
                            ),
                            if (isNew)
                              Positioned(
                                top: 2,
                                right: 2,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 1.5),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        SizedBox(
                          width: 52,
                          height: 16,
                          child: Center(
                            child: Text(
                              story.user.name,
                              style: const TextStyle(fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
