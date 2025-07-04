import 'package:flutter/material.dart';

class SidebarLeft extends StatelessWidget {
  const SidebarLeft({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECF5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          const Text('Men\u00fa', style: TextStyle(fontWeight: FontWeight.bold)),
          const ListTile(
            leading: Icon(Icons.videocam),
            title: Text('Transmisiones'),
          ),
          const ListTile(
            leading: Icon(Icons.event),
            title: Text('Eventos'),
          ),
          const ListTile(
            leading: Icon(Icons.people),
            title: Text('Usuarios'),
          ),
          const ListTile(
            leading: Icon(Icons.memory),
            title: Text('Recuerdos'),
          ),
          const ListTile(
            leading: Icon(Icons.videogame_asset),
            title: Text('Juegos'),
          ),
          const Divider(),
          const Text('Restaurantes',
              style: TextStyle(fontWeight: FontWeight.bold)),
          ListTile(
            leading: const Icon(Icons.restaurant),
            title: const Text("Luigi's Kitchen"),
            trailing:
                const Text('Ir al sitio', style: TextStyle(color: Colors.blue)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.restaurant),
            title: const Text('Restaurant 2'),
            trailing:
                const Text('Ir al sitio', style: TextStyle(color: Colors.blue)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.restaurant),
            title: const Text('Restaurant 3'),
            trailing:
                const Text('Ir al sitio', style: TextStyle(color: Colors.blue)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.restaurant),
            title: const Text('Restaurant 4'),
            trailing:
                const Text('Ir al sitio', style: TextStyle(color: Colors.blue)),
            onTap: () {},
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFD699C7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Ver m\u00e1s'),
          ),
        ],
      ),
    );
  }
}
