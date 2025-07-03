import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/category_provider.dart';
import '../providers/post_provider.dart';
import '../providers/language_provider.dart';
import '../utils/l10n.dart';
import 'package:go_router/go_router.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCategories = ref.watch(categoriesProvider);
    final locale = ref.watch(languageProvider);
    return Scaffold(
      appBar: AppBar(title: Text(L10n.of(locale, 'categories'))),
      body: asyncCategories.when(
        data: (cats) => ListView.builder(
          itemCount: cats.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return ListTile(
                title: Text(L10n.of(locale, 'all')),
                onTap: () {
                  ref.read(selectedCategoryProvider.notifier).state = null;
                  context.go('/');
                },
              );
            }
            final cat = cats[index - 1];
            return ListTile(
              title: Text(cat.name),
              onTap: () {
                ref.read(selectedCategoryProvider.notifier).state = cat.slug;
                context.go('/');
              },
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
