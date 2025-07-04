import 'package:flutter/material.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const TopBar({super.key, this.title = ''});

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
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (showNav)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _NavButton(icon: Icons.home, onPressed: () {}),
                  _NavButton(icon: Icons.add, onPressed: () {}),
                  _NavButton(icon: Icons.notifications, onPressed: () {}),
                  _NavButton(icon: Icons.restaurant, onPressed: () {}),
                ],
              ),
            Positioned(
              left: 8,
              child: _MenuButton(
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              ),
            ),
            if (showLogo)
              Positioned(
                right: 8,
                child: Image.asset(
                  'assets/images/spoonapp.png',
                  height: 45,
                  fit: BoxFit.contain,
                ),
              ),
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
