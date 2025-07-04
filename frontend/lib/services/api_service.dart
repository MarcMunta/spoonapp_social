import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/post.dart';
import '../models/story.dart';
import '../models/notification.dart';
import '../models/comment.dart';
import '../models/chat.dart';
import '../models/user.dart';
import '../models/friend_request.dart';
import '../models/block.dart';
import '../models/story_block.dart';
import '../models/category.dart';
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

  Future<List<Post>> fetchPosts(
    String? user, {
    int offset = 0,
    int limit = 10,
    String? category,
  }) async {
    final params = 'offset=$offset&limit=$limit';
    final cat = category == null ? '' : '&category=$category';
    final url = user == null
        ? '$baseUrl/posts?$params$cat'
        : '$baseUrl/posts?user=$user&$params$cat';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body) as List;
      return data.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<Post> createPost(
      String user, String caption, List<String> categories,
      [String? imageUrl]) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user': user,
        'caption': caption,
        'image_url': imageUrl,
        'categories': categories,
      }),
    );
    if (response.statusCode == 200) {
      return Post.fromJson(json.decode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to create post');
    }
  }

  Future<List<Story>> fetchStories([String? user]) async {
    final url = user == null ? '$baseUrl/stories' : '$baseUrl/stories?user=$user';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body) as List;
      return data.map((e) => Story.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load stories');
    }
  }

  Future<Story> createStory(String user, String imageUrl) async {
    final response = await http.post(
      Uri.parse('$baseUrl/stories'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'user': user, 'image_url': imageUrl}),
    );
    if (response.statusCode == 200) {
      return Story.fromJson(json.decode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to create story');
    }
  }

  Future<void> deleteStory(int id, String user) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/stories/$id?user=$user'),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete story');
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

  Future<void> markNotificationRead(int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notifications/$id/read'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification read');
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

  Future<Post> likePost(int postId, String user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/likes'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'user': user}),
    );
    if (response.statusCode == 200) {
      return Post.fromJson(json.decode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to like post');
    }
  }

  Future<Post> unlikePost(int postId, String user) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/posts/$postId/likes'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'user': user}),
    );
    if (response.statusCode == 200) {
      return Post.fromJson(json.decode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to unlike post');
    }
  }

  Future<void> deletePost(int postId, String user) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/posts/$postId?user=$user'),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete post');
    }
  }

  Future<void> deleteComment(
      int postId, int commentId, String user) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/posts/$postId/comments/$commentId?user=$user'),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete comment');
    }
  }

  Future<List<Chat>> fetchChats([String? user]) async {
    final url = user == null ? '$baseUrl/chats' : '$baseUrl/chats?user=$user';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body) as List;
      return data.map((e) => Chat.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load chats');
    }
  }

  Future<List<Message>> fetchMessages(int chatId) async {
    final response = await http.get(Uri.parse('$baseUrl/chats/$chatId/messages'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body) as List;
      return data
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load messages');
    }
  }

  Future<Message> sendMessage(int chatId, String sender, String content) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chats/$chatId/messages'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'sender': sender, 'content': content}),
    );
    if (response.statusCode == 200) {
      return Message.fromJson(
          json.decode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to send message');
    }
  }

  Future<UserProfile> fetchUser(String username) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$username'));
    if (response.statusCode == 200) {
      return UserProfile.fromJson(
          json.decode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<UserProfile> updateUser(
      String username, String bio, String? avatarUrl, String? bubbleColor) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$username'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'bio': bio,
        'avatar_url': avatarUrl,
        'bubble_color': bubbleColor,
      }),
    );
    if (response.statusCode == 200) {
      return UserProfile.fromJson(
          json.decode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to update user');
    }
  }

  Future<List<FriendRequest>> fetchFriendRequests([String? user]) async {
    final url = user == null
        ? '$baseUrl/friend-requests'
        : '$baseUrl/friend-requests?user=$user';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body) as List;
      return data
          .map((e) => FriendRequest.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load requests');
    }
  }

  Future<void> sendFriendRequest(String from, String to) async {
    final response = await http.post(
      Uri.parse('$baseUrl/friend-requests'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'from_user': from, 'to_user': to}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to send request');
    }
  }

  Future<void> acceptFriendRequest(int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/friend-requests/$id/accept'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to accept request');
    }
  }

  Future<List<Block>> fetchBlocks(String blocker) async {
    final response = await http.get(Uri.parse('$baseUrl/blocks?blocker=$blocker'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body) as List;
      return data.map((e) => Block.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load blocks');
    }
  }

  Future<void> blockUser(String blocker, String blocked) async {
    final response = await http.post(
      Uri.parse('$baseUrl/blocks'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'blocker': blocker, 'blocked': blocked}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to block user');
    }
  }

  Future<void> unblockUser(String username, String blocker) async {
    final response = await http.post(
      Uri.parse('$baseUrl/blocks/$username/unblock?blocker=$blocker'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to unblock user');
    }
  }

  Future<List<StoryBlock>> fetchStoryBlocks(String owner) async {
    final response = await http.get(Uri.parse('$baseUrl/story-blocks?owner=$owner'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body) as List;
      return data
          .map((e) => StoryBlock.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load story blocks');
    }
  }

  Future<void> createStoryBlock(String owner, String hiddenUser) async {
    final response = await http.post(
      Uri.parse('$baseUrl/story-blocks'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'story_owner': owner, 'hidden_user': hiddenUser}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to hide stories');
    }
  }

  Future<void> unhideStory(String username, String owner) async {
    final response = await http.post(
      Uri.parse('$baseUrl/story-blocks/$username/unhide?owner=$owner'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to unhide stories');
    }
  }

  Future<List<UserProfile>> searchUsers(String? query) async {
    final url = query == null || query.isEmpty
        ? '$baseUrl/users'
        : '$baseUrl/users?q=$query';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body) as List;
      return data
          .map((e) => UserProfile.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to search users');
    }
  }

  Future<List<Category>> fetchCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body) as List;
      return data.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }
}

