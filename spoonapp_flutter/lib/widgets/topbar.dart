import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../providers/post_provider.dart';
import '../providers/menu_provider.dart';
import '../screens/profile_page.dart';
import '../screens/feed_page.dart';
import 'story_viewer.dart';

class _GlassCircle extends StatelessWidget {
  final Widget child;
  final bool hover;
  const _GlassCircle({required this.child, this.hover = false});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: hover
                ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.6),
                      blurRadius: 6,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}

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
    final menu = context.watch<MenuProvider>();

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
              icon: menu.leftOpen ? Icons.cancel : Icons.menu,
              animate: true,
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
                        _NavButton(
                          icon: Icons.add,
                          onPressed: () {
                            Navigator.pushNamed(context, '/publish');
                          },
                        ),
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
              icon: Icons.people,
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final bool animate;
  const _MenuButton({required this.onPressed, required this.icon, this.animate = false});

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
              boxShadow: _hover
                  ? [
                      BoxShadow(
                        color: Colors.pinkAccent.withOpacity(0.6),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: widget.onPressed,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: widget.animate
                    ? AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale:
                                Tween<double>(begin: 0.8, end: 1.0).animate(animation),
                            child: child,
                          ),
                        ),
                        child: Icon(widget.icon, key: ValueKey(widget.icon), color: Colors.black),
                      )
                    : Icon(widget.icon, color: Colors.black),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _ProfileButton({required this.onPressed});

  @override
  State<_ProfileButton> createState() => _ProfileButtonState();
}

class _ProfileButtonState extends State<_ProfileButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;
    final provider = context.watch<PostProvider>();
    final hasStory = provider.userHasStory(user);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
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
            widget.onPressed();
          }
        },
        child: _GlassCircle(
          hover: _hover,
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
                  backgroundImage: user.profileImage.startsWith('http')
                      ? NetworkImage(user.profileImage)
                      : AssetImage(user.profileImage) as ImageProvider,
                  radius: 16,
                  backgroundColor: Colors.grey.shade200,
                ),
              ),
            ],
          ),
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
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        child: _GlassCircle(
          hover: _hover,
          child: IconButton(
            icon: Icon(widget.icon, color: Colors.white),
            onPressed: widget.onPressed,
            splashRadius: 20,
          ),
        ),
      ),
    );
  }
}
