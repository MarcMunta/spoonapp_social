class Story {
  final int id;
  final String user;
  final String imageUrl;
  final DateTime createdAt;

  Story({
    required this.id,
    required this.user,
    required this.imageUrl,
    required this.createdAt,
  });

  factory Story.fromJson(Map<String, dynamic> json) => Story(
        id: json['id'] as int,
        user: json['user'] as String,
        imageUrl: json['image_url'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
