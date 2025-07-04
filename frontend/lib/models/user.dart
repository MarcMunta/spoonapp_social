class UserProfile {
  final String username;
  final String bio;
  final String? avatarUrl;
  final String? bubbleColor;

  UserProfile({
    required this.username,
    required this.bio,
    this.avatarUrl,
    this.bubbleColor,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        username: json['username'] as String,
        bio: json['bio'] as String? ?? '',
        avatarUrl: json['avatar_url'] as String?,
        bubbleColor: json['bubble_color'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'username': username,
        'bio': bio,
        'avatar_url': avatarUrl,
        'bubble_color': bubbleColor,
      };
}
