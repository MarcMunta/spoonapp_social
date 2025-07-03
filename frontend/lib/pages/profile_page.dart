import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/profile_provider.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final themeMode = ref.watch(themeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: auth == null
          ? const Center(child: Text('No autenticado'))
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
                    Text(profile.username,
                        style: Theme.of(context).textTheme.headlineSmall),
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
                      child: const Text('Solicitudes de amistad'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.push('/blocked-users'),
                      child: const Text('Usuarios bloqueados'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.push('/search'),
                      child: const Text('Buscar usuarios'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(authProvider.notifier).logout(),
                      child: const Text('Cerrar sesión'),
                    ),
                    SwitchListTile(
                      title: const Text('Tema oscuro'),
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
