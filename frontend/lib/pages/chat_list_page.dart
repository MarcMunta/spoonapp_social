import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/chat_provider.dart';
import '../providers/language_provider.dart';
import '../utils/l10n.dart';

class ChatListPage extends ConsumerWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(chatsProvider);
    final locale = ref.watch(languageProvider);
    return Scaffold(
      appBar: AppBar(title: Text(L10n.of(locale, 'chats'))),
      body: chatsAsync.when(
        data: (chats) => ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            final title = chat.participants.join(', ');
            return ListTile(
              title: Text(title),
              onTap: () => context.push('/chat/${chat.id}'),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
