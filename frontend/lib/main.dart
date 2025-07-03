import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pages/feed_page.dart';

void main() {
  runApp(const ProviderScope(child: SpoonApp()));
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
      home: const FeedPage(),
    );
  }
}
