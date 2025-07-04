import 'package:flutter/material.dart';
import '../widgets/topbar.dart';

class CreatePostPage extends StatelessWidget {
  const CreatePostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: TopBar(title: 'Create Post'),
      body: Center(child: Text('Create Post')),
    );
  }
}
