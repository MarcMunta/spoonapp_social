import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';
import 'post_provider.dart';

final chatsProvider = FutureProvider<List<Chat>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final auth = ref.read(authProvider);
  return api.fetchChats(auth?.username);
});

final messagesProvider = FutureProvider.family<List<Message>, int>((ref, chatId) async {
  final api = ref.watch(apiServiceProvider);
  return api.fetchMessages(chatId);
});

final sendMessageProvider = Provider(
  (ref) => (int chatId, String sender, String content) async {
    final api = ref.read(apiServiceProvider);
    await api.sendMessage(chatId, sender, content);
    ref.invalidate(messagesProvider(chatId));
  },
);
