import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/comment.dart';
import 'post_provider.dart';

final commentsProvider = FutureProvider.family<List<Comment>, int>((ref, postId) async {
  final api = ref.watch(apiServiceProvider);
  return api.fetchComments(postId);
});

final addCommentProvider = Provider((ref) => (int postId, String user, String content) {
  final api = ref.read(apiServiceProvider);
  return api.addComment(postId, user, content);
});
