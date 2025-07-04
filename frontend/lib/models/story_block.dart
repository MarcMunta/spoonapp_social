class StoryBlock {
  final int id;
  final String owner;
  final String hiddenUser;
  final DateTime createdAt;

  StoryBlock({
    required this.id,
    required this.owner,
    required this.hiddenUser,
    required this.createdAt,
  });

  factory StoryBlock.fromJson(Map<String, dynamic> json) => StoryBlock(
        id: json['id'] as int,
        owner: json['story_owner'] as String,
        hiddenUser: json['hidden_user'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
