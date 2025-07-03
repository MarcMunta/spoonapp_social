import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/friend_request_provider.dart';

class FriendRequestsPage extends ConsumerWidget {
  const FriendRequestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(friendRequestsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitudes de amistad')),
      body: requestsAsync.when(
        data: (reqs) => ListView.builder(
          itemCount: reqs.length,
          itemBuilder: (context, index) {
            final r = reqs[index];
            return ListTile(
              leading: CircleAvatar(child: Text(r.fromUser[0].toUpperCase())),
              title: Text(r.fromUser),
              subtitle: Text(r.createdAt.toLocal().toString()),
              trailing: IconButton(
                icon: const Icon(Icons.check),
                onPressed: () =>
                    ref.read(acceptFriendRequestProvider)(r.id),
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
