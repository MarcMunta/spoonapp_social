import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/story_block_provider.dart';
import '../providers/language_provider.dart';
import '../utils/l10n.dart';

class HiddenStoriesPage extends ConsumerWidget {
  const HiddenStoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocksAsync = ref.watch(storyBlocksProvider);
    final locale = ref.watch(languageProvider);
    return Scaffold(
      appBar: AppBar(title: Text(L10n.of(locale, 'hidden_stories'))),
      body: blocksAsync.when(
        data: (blocks) => ListView.builder(
          itemCount: blocks.length,
          itemBuilder: (context, index) {
            final b = blocks[index];
            return ListTile(
              leading: CircleAvatar(child: Text(b.hiddenUser[0].toUpperCase())),
              title: Text(b.hiddenUser),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => ref.read(unhideStoriesProvider)(b.hiddenUser),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
