class Post {
  final int id;
  final String user;
  final String caption;
  final DateTime createdAt;
  final String? imageUrl;
  final String? videoUrl;

  Post({
    required this.id,
    required this.user,
    required this.caption,
    required this.createdAt,
    this.imageUrl,
    this.videoUrl,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json['id'] as int,
        user: json['user'] as String,
        caption: json['caption'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        imageUrl: json['image_url'] as String?,
        videoUrl: json['video_url'] as String?,
      );
}
