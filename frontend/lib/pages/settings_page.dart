import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/language_provider.dart';
import '../utils/l10n.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageProvider);
    return Scaffold(
      appBar: AppBar(title: Text(L10n.of(locale, 'settings'))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(L10n.of(locale, 'language'), style: Theme.of(context).textTheme.headline6),
            const SizedBox(height: 8),
            DropdownButton<Locale>(
              value: locale,
              onChanged: (loc) {
                if (loc != null) {
                  ref.read(languageProvider.notifier).setLocale(loc);
                }
              },
              items: L10n.supportedLocales
                  .map((loc) => DropdownMenuItem(
                        value: loc,
                        child: Text(loc.languageCode),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
