import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../models/story.dart';

class PostProvider extends ChangeNotifier {
  final List<Post> _posts = [];
  final List<Story> _stories = [];
  final List<User> _activeUsers = [];

  List<Post> get posts => _posts;
  List<Story> get stories => _stories;
  List<User> get activeUsers => _activeUsers;

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
        user: User(
          name: 'Alice',
          profileImage: 'https://picsum.photos/50/50?1',
          email: 'alice@example.com',
        ),
        date: DateTime.now().subtract(const Duration(hours: 1)),
        text: 'Hello from Flutter!',
        mediaUrl: 'https://picsum.photos/400/200?1',
        likes: 4,
      ),
      Post(
        id: '2',
        user: User(
          name: 'Bob',
          profileImage: 'https://picsum.photos/50/50?2',
          email: 'bob@example.com',
        ),
        date: DateTime.now().subtract(const Duration(hours: 2)),
        text: 'Another post',
        mediaUrl: 'https://picsum.photos/400/200?2',
        likes: 2,
      ),
    ]);

    _activeUsers.addAll([
      User(
        name: 'Alice',
        profileImage: 'https://picsum.photos/40/40?1',
        email: 'alice@example.com',
      ),
      User(
        name: 'Bob',
        profileImage: 'https://picsum.photos/40/40?2',
        email: 'bob@example.com',
      ),
      User(
        name: 'Charlie',
        profileImage: 'https://picsum.photos/40/40?3',
        email: 'charlie@example.com',
      ),
    ]);
  }

  void likePost(Post post) {
    post.likes++;
    notifyListeners();
  }
}
