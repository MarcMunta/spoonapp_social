import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../utils/l10n.dart';

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
    final ref = this.ref;
    final messagesAsync = ref.watch(messagesProvider(widget.chatId));
    final sendMessage = ref.read(sendMessageProvider);
    final auth = ref.watch(authProvider);
    final locale = ref.watch(languageProvider);
    return Scaffold(
      appBar: AppBar(title: Text('${L10n.of(locale, 'chat')} ${widget.chatId}')),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) => ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final m = messages[index];
                  final color = m.bubbleColor != null
                      ? Color(int.parse(m.bubbleColor!.substring(1), radix: 16) +
                          0xFF000000)
                      : Colors.grey.shade300;
                  return ListTile(
                    title: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        m.sender,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    subtitle: Text(m.content),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('${L10n.of(locale, 'error')} $e')),
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
                      decoration: InputDecoration(
                        hintText: L10n.of(locale, 'message_hint'),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    tooltip: L10n.of(locale, 'send'),
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
