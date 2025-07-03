import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/post.dart';
import '../models/story.dart';
import '../models/notification.dart';

import '../models/comment.dart';
class ApiService {
  final String baseUrl;
  ApiService(this.baseUrl);

  Future<String> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          json.decode(response.body) as Map<String, dynamic>;
      return data['token'] as String;
    } else {
      throw Exception('Invalid credentials');
    }
  }

  Future<String> signup(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          json.decode(response.body) as Map<String, dynamic>;
      return data['token'] as String;
    } else {
      throw Exception('Signup failed');
    }
  }

  Future<List<Post>> fetchPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/posts'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body) as List;
      return data.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<List<Story>> fetchStories() async {
    final response = await http.get(Uri.parse('$baseUrl/stories'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body) as List;
      return data.map((e) => Story.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load stories');
    }
  }

  Future<List<NotificationItem>> fetchNotifications() async {
    final response = await http.get(Uri.parse('$baseUrl/notifications'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body) as List;
      return data
          .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  Future<List<Comment>> fetchComments(int postId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/posts/$postId/comments'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body) as List;
      return data
          .map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<Comment> addComment(int postId, String user, String content) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/comments'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'user': user, 'content': content}),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          json.decode(response.body) as Map<String, dynamic>;
      return Comment.fromJson(data);
    } else {
      throw Exception('Failed to add comment');
    }
  }
}

