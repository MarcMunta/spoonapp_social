import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final themeMode = ref.watch(themeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (auth != null) ...[
              Text('Usuario: ${auth.username}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(authProvider.notifier).logout(),
                child: const Text('Cerrar sesión'),
              ),
              SwitchListTile(
                title: const Text('Tema oscuro'),
                value: themeMode == ThemeMode.dark,
                onChanged: (_) => ref.read(themeProvider.notifier).toggle(),
              ),
            ] else
              const Text('No autenticado'),
          ],
        ),
      ),
    );
  }
}
