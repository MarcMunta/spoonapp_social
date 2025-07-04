import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: const [
          ListTile(title: Text('Usuarios')),
          ListTile(title: Text('Comunidades')),
          ListTile(title: Text('Patrocinados')),
        ],
      ),
    );
  }
}
