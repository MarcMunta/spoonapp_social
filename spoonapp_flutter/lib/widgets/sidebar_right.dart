import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';

class SidebarRight extends StatelessWidget {
  const SidebarRight({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: 200,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4CC).withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: DefaultTextStyle(
            style: const TextStyle(color: Colors.black),
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                const Text('Usuarios activos',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...context.watch<PostProvider>().activeUsers.map(
                  (u) => ListTile(
                    leading: CircleAvatar(
                        backgroundImage: NetworkImage(u.profileImage)),
                    title: Text(u.name),
                    subtitle: const Text('Activo'),
                  ),
                ),
                const Divider(),
                const Text('Comunidades',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const ListTile(title: Text('Cocina')),
                const ListTile(title: Text('Viajes')),
                const Divider(),
                const Text('Patrocinados',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const ListTile(title: Text('Anuncio 1')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
