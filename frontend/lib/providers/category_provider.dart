import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category.dart';
import 'api_provider.dart';

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.fetchCategories();
});
