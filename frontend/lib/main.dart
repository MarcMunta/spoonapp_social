import 'package:flutter/material.dart';

void main() {
  runApp(const SpoonApp());
}

class SpoonApp extends StatelessWidget {
  const SpoonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpoonApp',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: const PlaceholderPage(),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('SpoonApp Flutter'),
      ),
    );
  }
}
