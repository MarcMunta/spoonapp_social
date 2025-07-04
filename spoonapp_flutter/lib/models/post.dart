import 'user.dart';

class Post {
  final String id;
  final User user;
  final DateTime date;
  final String text;
  final String? mediaUrl;
  int likes;

  Post({
    required this.id,
    required this.user,
    required this.date,
    required this.text,
    this.mediaUrl,
    this.likes = 0,
  });
}
