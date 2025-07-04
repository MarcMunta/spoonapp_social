import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../models/story.dart';
import '../services/backend.dart';

class PostProvider extends ChangeNotifier {
  final BackendService _backend;
  final List<Post> _posts = [];
  final List<Story> _stories = [];
  final List<User> _activeUsers = [];

  List<Post> get posts => _posts;
  List<Story> get stories => _stories;
  List<User> get activeUsers => _activeUsers;

  PostProvider(this._backend) {
    final alice = User(
      name: 'Alice',
      profileImage: 'https://picsum.photos/50/50?1',
      email: 'alice@example.com',
    );
    final bob = User(
      name: 'Bob',
      profileImage: 'https://picsum.photos/50/50?2',
      email: 'bob@example.com',
    );

    _posts.addAll([
      Post(
        id: '1',
        user: alice,
        date: DateTime.now().subtract(const Duration(hours: 1)),
        text: 'Hello from Flutter!',
        mediaUrl: 'https://picsum.photos/400/200?1',
        likes: 4,
      ),
      Post(
        id: '2',
        user: bob,
        date: DateTime.now().subtract(const Duration(hours: 2)),
        text: 'Another post',
        mediaUrl: 'https://picsum.photos/400/200?2',
        likes: 2,
      ),
    ]);

    _activeUsers.addAll([
      alice,
      bob,
      User(
        name: 'Charlie',
        profileImage: 'https://picsum.photos/40/40?3',
        email: 'charlie@example.com',
      ),
    ]);

    Future.microtask(() => loadStories());
  }

  void likePost(Post post) {
    post.likes++;
    notifyListeners();
  }

  bool userHasStory(User user) {
    _cleanStories();
    return _stories.any((s) => s.user.email == user.email);
  }

  int indexOfFirstStory(User user) {
    _cleanStories();
    return _stories.indexWhere((s) => s.user.email == user.email);
  }

  Future<void> addStory(User user, Uint8List bytes) async {
    final ok = await _backend.uploadStory(bytes, 'story.webp');
    if (ok) {
      await loadStories();
    }
  }

  Future<void> loadStories() async {
    final fetched = await _backend.fetchStories();
    _stories
      ..clear()
      ..addAll(fetched);
    notifyListeners();
  }

  void _cleanStories() {
    _stories.removeWhere((s) => s.expiresAt.isBefore(DateTime.now()));
  }
}
