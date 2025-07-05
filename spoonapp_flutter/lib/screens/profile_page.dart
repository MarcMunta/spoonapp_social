import 'package:flutter/material.dart';

import '../widgets/topbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;
    return Scaffold(
      appBar: const TopBar(title: 'Profile'),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(user.profileImage),
            ),
            const SizedBox(height: 12),
            Text(
              user.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              user.email,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Editar'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Cerrar sesión'),
                    content: const Text('¿Seguro que quieres cerrar sesión?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Cerrar sesión'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('auth_token');
                  context.read<UserProvider>().setToken('');
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                }
              },
              child: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
