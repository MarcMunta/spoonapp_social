import 'dart:ui';
import 'package:flutter/material.dart';

class SidebarLeft extends StatelessWidget {
  const SidebarLeft({super.key});

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
                const Text('Men\u00fa',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ListTile(
                  leading: const Icon(Icons.videocam, color: Colors.black),
                  title: const Text('Transmisiones'),
                  hoverColor: const Color(0xFFFF80AB).withOpacity(0.1),
                ),
                ListTile(
                  leading: const Icon(Icons.event, color: Colors.black),
                  title: const Text('Eventos'),
                  hoverColor: const Color(0xFFFF80AB).withOpacity(0.1),
                ),
                ListTile(
                  leading: const Icon(Icons.people, color: Colors.black),
                  title: const Text('Usuarios'),
                  hoverColor: const Color(0xFFFF80AB).withOpacity(0.1),
                ),
                ListTile(
                  leading: const Icon(Icons.memory, color: Colors.black),
                  title: const Text('Recuerdos'),
                  hoverColor: const Color(0xFFFF80AB).withOpacity(0.1),
                ),
                ListTile(
                  leading: const Icon(Icons.videogame_asset, color: Colors.black),
                  title: const Text('Juegos'),
                  hoverColor: const Color(0xFFFF80AB).withOpacity(0.1),
                ),
                const Divider(),
                const Text('Restaurantes',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ListTile(
                  leading: const Icon(Icons.restaurant, color: Colors.black),
                  title: const Text("Luigi's Kitchen"),
                  trailing: const Text('Ir al sitio',
                      style: TextStyle(color: Colors.blue)),
                  hoverColor: const Color(0xFFFF80AB).withOpacity(0.1),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.restaurant, color: Colors.black),
                  title: const Text('Restaurant 2'),
                  trailing: const Text('Ir al sitio',
                      style: TextStyle(color: Colors.blue)),
                  hoverColor: const Color(0xFFFF80AB).withOpacity(0.1),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.restaurant, color: Colors.black),
                  title: const Text('Restaurant 3'),
                  trailing: const Text('Ir al sitio',
                      style: TextStyle(color: Colors.blue)),
                  hoverColor: const Color(0xFFFF80AB).withOpacity(0.1),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.restaurant, color: Colors.black),
                  title: const Text('Restaurant 4'),
                  trailing: const Text('Ir al sitio',
                      style: TextStyle(color: Colors.blue)),
                  hoverColor: const Color(0xFFFF80AB).withOpacity(0.1),
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
