import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/story.dart';
import 'post_provider.dart';

final storiesProvider = FutureProvider<List<Story>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.fetchStories();
});
