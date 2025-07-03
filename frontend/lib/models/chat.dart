class Chat {
  final int id;
  final List<String> participants;

  Chat({required this.id, required this.participants});

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
        id: json['id'] as int,
        participants: List<String>.from(json['participants'] as List),
      );
}

class Message {
  final int id;
  final int chatId;
  final String sender;
  final String content;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.chatId,
    required this.sender,
    required this.content,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'] as int,
        chatId: json['chat_id'] as int,
        sender: json['sender'] as String,
        content: json['content'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

class MessageRequest {
  final String sender;
  final String content;

  MessageRequest({required this.sender, required this.content});

  Map<String, dynamic> toJson() => {
        'sender': sender,
        'content': content,
      };
}
