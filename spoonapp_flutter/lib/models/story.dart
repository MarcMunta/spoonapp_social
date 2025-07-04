import 'dart:typed_data';

import 'user.dart';

class Story {
  final String id;
  final User user;
  final String? mediaUrl;
  final Uint8List? mediaBytes;
  final DateTime expiresAt;

  Story({
    required this.id,
    required this.user,
    this.mediaUrl,
    this.mediaBytes,
    required this.expiresAt,
  });
}
