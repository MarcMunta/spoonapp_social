class Block {
  final int id;
  final String blocker;
  final String blocked;
  final DateTime createdAt;

  Block({
    required this.id,
    required this.blocker,
    required this.blocked,
    required this.createdAt,
  });

  factory Block.fromJson(Map<String, dynamic> json) => Block(
        id: json['id'] as int,
        blocker: json['blocker'] as String,
        blocked: json['blocked'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
