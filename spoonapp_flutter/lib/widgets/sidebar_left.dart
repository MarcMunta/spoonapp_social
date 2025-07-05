import 'dart:ui';
import 'package:flutter/material.dart';

class SidebarLeft extends StatelessWidget {
  const SidebarLeft({super.key});

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
                const Text('Men\u00fa',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const ListTile(
                  leading: Icon(Icons.videocam, color: Colors.black),
                  title: Text('Transmisiones'),
                ),
                const ListTile(
                  leading: Icon(Icons.event, color: Colors.black),
                  title: Text('Eventos'),
                ),
                const ListTile(
                  leading: Icon(Icons.people, color: Colors.black),
                  title: Text('Usuarios'),
                ),
                const ListTile(
                  leading: Icon(Icons.memory, color: Colors.black),
                  title: Text('Recuerdos'),
                ),
                const ListTile(
                  leading: Icon(Icons.videogame_asset, color: Colors.black),
                  title: Text('Juegos'),
                ),
                const Divider(),
                const Text('Restaurantes',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ListTile(
                  leading: const Icon(Icons.restaurant, color: Colors.black),
                  title: const Text("Luigi's Kitchen"),
                  trailing: const Text('Ir al sitio',
                      style: TextStyle(color: Colors.blue)),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.restaurant, color: Colors.black),
                  title: const Text('Restaurant 2'),
                  trailing: const Text('Ir al sitio',
                      style: TextStyle(color: Colors.blue)),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.restaurant, color: Colors.black),
                  title: const Text('Restaurant 3'),
                  trailing: const Text('Ir al sitio',
                      style: TextStyle(color: Colors.blue)),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.restaurant, color: Colors.black),
                  title: const Text('Restaurant 4'),
                  trailing: const Text('Ir al sitio',
                      style: TextStyle(color: Colors.blue)),
                  onTap: () {},
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Ver m\u00e1s'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
