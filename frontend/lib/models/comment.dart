class Comment {
  final int id;
  final int postId;
  final String user;
  final String content;
  final DateTime createdAt;
  final String? bubbleColor;

  Comment({
    required this.id,
    required this.postId,
    required this.user,
    required this.content,
    required this.createdAt,
    this.bubbleColor,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json['id'] as int,
        postId: json['post_id'] as int,
        user: json['user'] as String,
        content: json['content'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        bubbleColor: json['bubble_color'] as String?,
      );
}
