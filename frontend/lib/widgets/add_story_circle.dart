import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/language_provider.dart';
import '../utils/l10n.dart';

class AddStoryCircle extends ConsumerWidget {
  const AddStoryCircle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageProvider);
    return GestureDetector(
      onTap: () => context.push('/stories/new'),
      child: Column(
        children: [
          const CircleAvatar(radius: 30, child: Icon(Icons.add)),
          const SizedBox(height: 4),
          Text(L10n.of(locale, 'add'), style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
