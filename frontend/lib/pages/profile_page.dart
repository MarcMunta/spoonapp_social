import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/language_provider.dart';
import '../utils/l10n.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(languageProvider);
    return Scaffold(
      appBar: AppBar(title: Text(L10n.of(locale, 'profile'))),
      body: auth == null
          ? Center(child: Text(L10n.of(locale, 'not_authenticated')))
          : Consumer(builder: (context, ref, _) {
              final profileAsync = ref.watch(profileProvider(auth.username));
              return profileAsync.when(
                data: (profile) => ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    if (profile.avatarUrl != null)
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(profile.avatarUrl!),
                      ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: profile.bubbleColor != null
                            ? Color(int.parse(profile.bubbleColor!.substring(1), radix: 16) + 0xFF000000)
                            : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        profile.username,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(profile.bio),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.push('/profile/edit'),
                      child: const Text('Editar perfil'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.push('/friend-requests'),
                      child: Text(L10n.of(locale, 'friend_requests')),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.push('/blocked-users'),
                      child: Text(L10n.of(locale, 'blocked_users')),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.push('/hidden-stories'),
                      child: Text(L10n.of(locale, 'hidden_stories')),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.push('/categories'),
                      child: const Text('Categories'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.push('/search'),
                      child: Text(L10n.of(locale, 'search_users')),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.push('/settings'),
                      child: Text(L10n.of(locale, 'settings')),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(authProvider.notifier).logout(),
                      child: Text(L10n.of(locale, 'logout')),
                    ),
                    SwitchListTile(
                      title: Text(L10n.of(locale, 'dark_theme')),
                      value: themeMode == ThemeMode.dark,
                      onChanged: (_) =>
                          ref.read(themeProvider.notifier).toggle(),
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error: $e')),
              );
            }),
    );
  }
}
