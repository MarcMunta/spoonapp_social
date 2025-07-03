import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/post.dart';

class ApiService {
  final String baseUrl;
  ApiService(this.baseUrl);

  Future<List<Post>> fetchPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/posts'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body) as List;
      return data.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }
}
