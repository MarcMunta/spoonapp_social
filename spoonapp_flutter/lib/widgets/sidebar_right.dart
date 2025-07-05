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
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          width: 200,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4FA).withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.pinkAccent.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
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
                    hoverColor: const Color(0xFFFF80AB).withOpacity(0.1),
                  ),
                ),
                const Divider(),
                const Text('Comunidades',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ListTile(
                  title: const Text('Cocina'),
                  hoverColor: const Color(0xFFFF80AB).withOpacity(0.1),
                ),
                ListTile(
                  title: const Text('Viajes'),
                  hoverColor: const Color(0xFFFF80AB).withOpacity(0.1),
                ),
                const Divider(),
                const Text('Patrocinados',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ListTile(
                  title: const Text('Anuncio 1'),
                  hoverColor: const Color(0xFFFF80AB).withOpacity(0.1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
