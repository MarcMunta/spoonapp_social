class NotificationItem {
  final int id;
  final String message;
  final DateTime createdAt;
  final String? title;
  final String? type;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.message,
    required this.createdAt,
    this.title,
    this.type,
    this.isRead = false,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as int,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      title: json['title'] as String?,
      type: json['notification_type'] as String?,
      isRead: json['is_read'] as bool? ?? false,
    );
  }
}
