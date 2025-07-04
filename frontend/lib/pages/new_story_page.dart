import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/story_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../utils/l10n.dart';

class NewStoryPage extends ConsumerStatefulWidget {
  const NewStoryPage({super.key});

  @override
  ConsumerState<NewStoryPage> createState() => _NewStoryPageState();
}

class _NewStoryPageState extends ConsumerState<NewStoryPage> {
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
      await ref.read(addStoryProvider)(auth.username, _imageController.text);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = L10n.of(ref.read(languageProvider), 'story_error'));
    } finally {
      setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final locale = ref.watch(languageProvider);
    return Scaffold(
      appBar: AppBar(title: Text(L10n.of(locale, 'new_story'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _imageController,
              decoration:
                  InputDecoration(labelText: L10n.of(locale, 'image_url')),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _sending ? null : _submit,
              child: _sending
                  ? const CircularProgressIndicator()
                  : Text(L10n.of(locale, 'publish')),
            ),
          ],
        ),
      ),
    );
  }
}
