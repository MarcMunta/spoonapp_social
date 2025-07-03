import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/block_provider.dart';

class BlockedUsersPage extends ConsumerWidget {
  const BlockedUsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocksAsync = ref.watch(blocksProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Blocked users')),
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
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
