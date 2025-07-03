class FriendRequest {
  final int id;
  final String fromUser;
  final String toUser;
  final DateTime createdAt;

  FriendRequest({
    required this.id,
    required this.fromUser,
    required this.toUser,
    required this.createdAt,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'] as int,
      fromUser: json['from_user'] as String,
      toUser: json['to_user'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
