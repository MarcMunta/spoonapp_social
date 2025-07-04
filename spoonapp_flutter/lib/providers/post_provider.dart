import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../models/story.dart';

class PostProvider extends ChangeNotifier {
  final List<Post> _posts = [];
  final List<Story> _stories = [];

  List<Post> get posts => _posts;
  List<Story> get stories => _stories;

  PostProvider() {
    _stories.addAll([
      Story(
        id: '1',
        user: 'Alice',
        mediaUrl: 'https://picsum.photos/100/100?1',
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      ),
      Story(
        id: '2',
        user: 'Bob',
        mediaUrl: 'https://picsum.photos/100/100?2',
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      ),
    ]);

    _posts.addAll([
      Post(
        id: '1',
        user: User(name: 'Alice', profileImage: 'https://picsum.photos/50/50?1'),
        date: DateTime.now().subtract(const Duration(hours: 1)),
        text: 'Hello from Flutter!',
        mediaUrl: 'https://picsum.photos/400/200?1',
        likes: 4,
      ),
      Post(
        id: '2',
        user: User(name: 'Bob', profileImage: 'https://picsum.photos/50/50?2'),
        date: DateTime.now().subtract(const Duration(hours: 2)),
        text: 'Another post',
        mediaUrl: 'https://picsum.photos/400/200?2',
        likes: 2,
      ),
    ]);
  }

  void likePost(Post post) {
    post.likes++;
    notifyListeners();
  }
}
