import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/block_provider.dart';
import '../providers/language_provider.dart';
import '../utils/l10n.dart';

class BlockedUsersPage extends ConsumerWidget {
  const BlockedUsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocksAsync = ref.watch(blocksProvider);
    final locale = ref.watch(languageProvider);
    return Scaffold(
      appBar: AppBar(title: Text(L10n.of(locale, 'blocked_users'))),
      body: blocksAsync.when(
        data: (blocks) => ListView.builder(
          itemCount: blocks.length,
          itemBuilder: (context, index) {
            final b = blocks[index];
            return ListTile(
              leading: CircleAvatar(child: Text(b.blocked[0].toUpperCase())),
              title: Text(b.blocked),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => ref.read(unblockUserProvider)(b.blocked),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('${L10n.of(locale, 'error')} $e')),
      ),
    );
  }
}
