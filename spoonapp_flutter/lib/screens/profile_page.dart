import 'package:flutter/material.dart';

import '../widgets/topbar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: TopBar(title: 'Profile'),
      body: Center(child: Text('User Profile')),
    );
  }
}
