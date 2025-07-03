import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/search_provider.dart';
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
    final locale = ref.watch(languageProvider);
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
            return ListTile(
              leading: CircleAvatar(child: Text(u.username[0].toUpperCase())),
              title: Text(u.username),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
