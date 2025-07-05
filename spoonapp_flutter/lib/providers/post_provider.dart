import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:uuid/uuid.dart';
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
    Future.microtask(() async {
      await loadStories();
      await loadPosts();
    });
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

  Future<void> addStory(User user, Uint8List bytes, String filename, String token) async {
    final ok = await _backend.uploadStory(bytes, filename, token);
    if (ok) {
      await loadStories();
    }
  }

  Future<void> addPost(User user, Uint8List bytes, String filename,
      String description, String category, String token) async {
    final data = await _backend.uploadPost(
        bytes, filename, description, category, token);
    if (data != null) {
      final post = Post(
        id: data['id'] as String,
        user: user,
        date: DateTime.now(),
        text: description,
        mediaUrl: data['url'] as String,
      );
      _posts.insert(0, post);
      notifyListeners();
    }
  }

  Future<void> loadPosts() async {
    final fetched = await _backend.fetchPosts();
    _posts
      ..clear()
      ..addAll(fetched);
    notifyListeners();
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
