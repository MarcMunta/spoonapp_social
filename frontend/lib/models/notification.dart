class NotificationItem {
  final int id;
  final String message;
  final DateTime createdAt;

  NotificationItem({required this.id, required this.message, required this.createdAt});

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as int,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
