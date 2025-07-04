import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/language_provider.dart';
import '../utils/l10n.dart';

class HomePage extends ConsumerStatefulWidget {
  final Widget child;
  const HomePage({super.key, required this.child});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(languageProvider);
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) {
          setState(() => _index = i);
          switch (i) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/notifications');
              break;
            case 2:
              context.go('/chats');
              break;
            default:
              context.go('/profile');
          }
        },
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: L10n.of(locale, 'feed')),
          BottomNavigationBarItem(icon: const Icon(Icons.notifications), label: L10n.of(locale, 'notifications')),
          BottomNavigationBarItem(icon: const Icon(Icons.chat), label: L10n.of(locale, 'chats')),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: L10n.of(locale, 'profile')),
        ],
      ),
    );
  }
}
