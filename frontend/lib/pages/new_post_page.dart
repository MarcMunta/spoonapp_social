import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/post_provider.dart';
import '../providers/auth_provider.dart';

class NewPostPage extends ConsumerStatefulWidget {
  const NewPostPage({super.key});

  @override
  ConsumerState<NewPostPage> createState() => _NewPostPageState();
}

class _NewPostPageState extends ConsumerState<NewPostPage> {
  final _captionController = TextEditingController();
  final _imageController = TextEditingController();
  bool _sending = false;
  String? _error;

  Future<void> _submit() async {
    final auth = ref.read(authProvider);
    if (auth == null) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref.read(addPostProvider)(
        auth.username,
        _captionController.text,
        _imageController.text.isEmpty ? null : _imageController.text,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = 'Error al crear el post');
    } finally {
      setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: _imageController,
              decoration: const InputDecoration(labelText: 'URL de la imagen (opcional)'),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _sending ? null : _submit,
              child: _sending
                  ? const CircularProgressIndicator()
                  : const Text('Publicar'),
            ),
          ],
        ),
      ),
    );
  }
}
