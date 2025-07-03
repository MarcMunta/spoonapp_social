import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/search_provider.dart';
import '../providers/friend_request_provider.dart';
import '../providers/block_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../utils/l10n.dart';

class UserSearchPage extends ConsumerStatefulWidget {
  const UserSearchPage({super.key});

  @override
  ConsumerState<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends ConsumerState<UserSearchPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final usersAsync =
        ref.watch(searchUsersProvider(_query.isEmpty ? null : _query));
    final blocksAsync = ref.watch(blocksProvider);
    final locale = ref.watch(languageProvider);
    final auth = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration:
              InputDecoration(hintText: L10n.of(locale, 'search_users')),
          onChanged: (v) => setState(() => _query = v),
        ),
      ),
      body: usersAsync.when(
        data: (users) => ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final u = users[index];
            final canRequest = auth != null && auth.username != u.username;
            final blocks = blocksAsync.value ?? [];
            final isBlocked = blocks.any((b) => b.blocked == u.username);
            return ListTile(
              leading: CircleAvatar(child: Text(u.username[0].toUpperCase())),
              title: Text(u.username),
              trailing: auth != null && auth.username != u.username
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.person_add),
                          tooltip: L10n.of(locale, 'send_request'),
                          onPressed: () async {
                            await ref.read(sendFriendRequestProvider)(u.username);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${L10n.of(locale, 'send_request')}: ${u.username}'),
                                  ),
                                );
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.block, color: isBlocked ? Colors.red : null),
                          tooltip: L10n.of(locale, isBlocked ? 'unblock' : 'block'),
                          onPressed: () async {
                            if (isBlocked) {
                              await ref.read(unblockUserProvider)(u.username);
                            } else {
                              await ref.read(blockUserProvider)(u.username);
                            }
                          },
                        ),
                      ],
                    )
                  : null,
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
