import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/story.dart';
import '../models/user.dart';
import '../models/post.dart';

class BackendService {
  final String baseUrl;
  BackendService(this.baseUrl);

  Future<List<Story>> fetchStories() async {
    final resp = await http.get(Uri.parse('$baseUrl/api/stories/'));
    if (resp.statusCode != 200) return [];
    final json = jsonDecode(resp.body)['stories'] as List<dynamic>;
    return json.map((s) {
      return Story(
        id: s['id'].toString(),
        user: User(
          name: s['user'],
          profileImage: s['avatar'] ?? '',
          email: '',
        ),
        mediaUrl: s['url'],
        expiresAt: DateTime.parse(s['created_at']).add(const Duration(hours: 24)),
      );
    }).toList();
  }

  Future<bool> uploadStory(Uint8List bytes, String filename, String token, {String? mimeType}) async {
    final uri = Uri.parse('$baseUrl/api/stories/upload/');
    final request = http.MultipartRequest('POST', uri);
    final ext = filename.split('.').last.toLowerCase();
    final isVideo = ['mp4', 'mov', 'avi', 'webm'].contains(ext);
    request.headers['Authorization'] = 'Token $token';
    if (isVideo) {
      request.files.add(
        http.MultipartFile.fromBytes('video', bytes, filename: filename),
      );
    } else {
      request.files.add(
        http.MultipartFile.fromBytes('image', bytes, filename: filename),
      );
    }
    final response = await request.send();
    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>?> uploadPost(Uint8List bytes, String filename,
      String description, String category, String token) async {
    final uri = Uri.parse('$baseUrl/api/posts/upload/');
    final request = http.MultipartRequest('POST', uri);
    final ext = filename.split('.').last.toLowerCase();
    final isVideo = ['mp4', 'mov', 'avi', 'webm'].contains(ext);
    request.fields['description'] = description;
    request.fields['category'] = category;
    request.fields['token'] = token;
    if (isVideo) {
      request.files.add(
        http.MultipartFile.fromBytes('video', bytes, filename: filename),
      );
    } else {
      request.files.add(
        http.MultipartFile.fromBytes('image', bytes, filename: filename),
      );
    }
    final response = await request.send();
    if (response.statusCode != 200) return null;
    final body = await response.stream.bytesToString();
    return jsonDecode(body) as Map<String, dynamic>;
  }

  Future<List<Post>> fetchPosts() async {
    final resp = await http.get(Uri.parse('$baseUrl/api/posts/'));
    if (resp.statusCode != 200) return [];
    final jsonList = jsonDecode(resp.body)['posts'] as List<dynamic>;
    return jsonList.map((p) {
      return Post(
        id: p['id'],
        user: User(
          name: p['user_name'],
          profileImage: p['avatar'] ?? '',
          email: p['email'] ?? '',
        ),
        date: DateTime.parse(p['created_at']),
        text: p['description'] ?? '',
        mediaUrl: p['url'],
      );
    }).toList();
  }
}
