import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';

class SidebarRight extends StatelessWidget {
  const SidebarRight({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          const Text('Usuarios activos', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...context.watch<PostProvider>().activeUsers.map(
            (u) => ListTile(
              leading: CircleAvatar(backgroundImage: NetworkImage(u.profileImage)),
              title: Text(u.name),
              subtitle: const Text('Activo'),
            ),
          ),
          const Divider(),
          const Text('Comunidades', style: TextStyle(fontWeight: FontWeight.bold)),
          const ListTile(title: Text('Cocina')),
          const ListTile(title: Text('Viajes')),
          const Divider(),
          const Text('Patrocinados', style: TextStyle(fontWeight: FontWeight.bold)),
          const ListTile(title: Text('Anuncio 1')),
        ],
      ),
    );
  }
}
