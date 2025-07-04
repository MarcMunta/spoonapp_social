import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
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
    final ref = this.ref;
    final locale = ref.watch(languageProvider);
    final themeMode = ref.watch(themeProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('🍴 SpoonApp'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              setState(() => _index = 0);
              context.go('/');
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              setState(() => _index = 1);
              context.go('/notifications');
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              setState(() => _index = 2);
              context.go('/chats');
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              setState(() => _index = 3);
              context.go('/profile');
            },
          ),
          IconButton(
            icon: Icon(themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => ref.read(themeProvider.notifier).toggle(),
          ),
        ],
      ),
      body: widget.child,
    );
  }
}
