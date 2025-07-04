import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import '../providers/user_provider.dart';
import '../providers/post_provider.dart';
import '../screens/profile_page.dart';
import '../screens/feed_page.dart';
import 'story_viewer.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onLeftMenu;
  final VoidCallback? onRightMenu;
  const TopBar({super.key, this.title = '', this.onLeftMenu, this.onRightMenu});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final showNav = width > 600;
    final showLogo = width > 350;

    return Material(
      color: Colors.transparent,
      child: Container(
        height: preferredSize.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB46DDD), Color(0xFFD9A7C7)],
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            _MenuButton(
              onPressed: onLeftMenu ?? () {
                Scaffold.maybeOf(context)?.openDrawer();
              },
            ),
            if (showLogo)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FeedPage(),
                      ),
                    );
                  },
                  child: Image.asset(
                    'assets/images/spoonapp.png',
                    height: 45,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            Expanded(
              child: showNav
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _NavButton(
                          icon: Icons.home,
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const FeedPage(),
                              ),
                            );
                          },
                        ),
                        _NavButton(icon: Icons.add, onPressed: () {}),
                        _NavButton(
                            icon: Icons.notifications, onPressed: () {}),
                        _NavButton(icon: Icons.restaurant, onPressed: () {}),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
            _ProfileButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
            ),
            const SizedBox(width: 8),
            _MenuButton(
              onPressed: onRightMenu ?? () {
                Scaffold.maybeOf(context)?.openEndDrawer();
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _MenuButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFF0B3),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(Icons.menu, color: Color(0xFF5D1049)),
        ),
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _ProfileButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;
    final provider = context.watch<PostProvider>();
    final hasStory = provider.userHasStory(user);

    Future<void> addStory() async {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'mp4'],
      );
      if (result != null && result.files.single.bytes != null) {
        context.read<PostProvider>().addStory(user, result.files.single.bytes!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Historia subida')),
        );
      }
    }

    return Material(
      color: const Color(0xFFFFF0B3),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          final index = provider.indexOfFirstStory(user);
          if (index >= 0) {
            showDialog(
              context: context,
              builder: (_) => StoryViewer(
                stories: provider.stories,
                initialIndex: index,
              ),
            );
          } else {
            onPressed();
          }
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasStory ? null : Colors.grey.shade300,
                border: hasStory
                    ? Border.all(color: Colors.blueAccent, width: 2)
                    : null,
              ),
              child: CircleAvatar(
                backgroundImage: NetworkImage(user.profileImage),
                radius: 16,
              ),
            ),
            Positioned(
              bottom: -2,
              right: -2,
              child: GestureDetector(
                onTap: addStory,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: const Icon(Icons.add, size: 12, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const _NavButton({required this.icon, required this.onPressed});

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0B3),
          shape: BoxShape.circle,
          boxShadow: _hover
              ? const [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2))
                ]
              : null,
        ),
        child: IconButton(
          icon: Icon(widget.icon, color: const Color(0xFF5D1049)),
          onPressed: widget.onPressed,
          splashRadius: 20,
        ),
      ),
    );
  }
}
