import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddStoryCircle extends StatelessWidget {
  const AddStoryCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/stories/new'),
      child: Column(
        children: const [
          CircleAvatar(radius: 30, child: Icon(Icons.add)),
          SizedBox(height: 4),
          Text('Añadir', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
