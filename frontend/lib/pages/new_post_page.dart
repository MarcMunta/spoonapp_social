import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/post_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/category_provider.dart';
import '../providers/language_provider.dart';
import '../utils/l10n.dart';

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
  final List<String> _selectedCategories = [];

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
        _selectedCategories,
        _imageController.text.isEmpty ? null : _imageController.text,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = L10n.of(ref.read(languageProvider), 'post_error'));
    } finally {
      setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageProvider);
    return Scaffold(
      appBar: AppBar(title: Text(L10n.of(locale, 'new_post'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer(
          builder: (context, ref, _) {
            final catsAsync = ref.watch(categoriesProvider);
            return catsAsync.when(
              data: (cats) => ListView(
                children: [
                  TextField(
                    controller: _captionController,
                    decoration:
                        InputDecoration(labelText: L10n.of(locale, 'title')),
                  ),
                  TextField(
                    controller: _imageController,
                    decoration: InputDecoration(
                        labelText: L10n.of(locale, 'image_url_optional')),
                  ),
                  const SizedBox(height: 16),
                  Text(L10n.of(locale, 'categories'),
                      style: Theme.of(context).textTheme.titleMedium),
                  ...cats.map((c) => CheckboxListTile(
                        title: Text(c.name),
                        value: _selectedCategories.contains(c.name),
                        onChanged: (v) {
                          setState(() {
                            if (v == true) {
                              _selectedCategories.add(c.name);
                            } else {
                              _selectedCategories.remove(c.name);
                            }
                          });
                        },
                      )),
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
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('${L10n.of(locale, 'error')} $e')),
            );
          },
        ),
      ),
    );
  }
}
