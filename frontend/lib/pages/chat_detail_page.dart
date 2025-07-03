import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';

class ChatDetailPage extends ConsumerStatefulWidget {
  final int chatId;
  const ChatDetailPage({super.key, required this.chatId});

  @override
  ConsumerState<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends ConsumerState<ChatDetailPage> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.chatId));
    final sendMessage = ref.read(sendMessageProvider);
    final auth = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Chat ${widget.chatId}')),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) => ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final m = messages[index];
                  return ListTile(
                    title: Text(m.sender),
                    subtitle: Text(m.content),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
          if (auth != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Escribe un mensaje',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () async {
                      final text = _controller.text.trim();
                      if (text.isEmpty) return;
                      await sendMessage(widget.chatId, auth.username, text);
                      _controller.clear();
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
