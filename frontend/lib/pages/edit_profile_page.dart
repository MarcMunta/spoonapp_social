import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _bioController = TextEditingController();
  bool _saving = false;
  String? _bubbleColor;

  @override
  void initState() {
    super.initState();
    final auth = ref.read(authProvider);
    if (auth != null) {
      ref.read(profileProvider(auth.username)).whenData((profile) {
        _bioController.text = profile.bio;
        _bubbleColor = profile.bubbleColor;
      });
    }
  }

  Future<void> _save() async {
    final auth = ref.read(authProvider);
    if (auth == null) return;
    setState(() => _saving = true);
    await ref
        .read(updateProfileProvider)(auth.username, _bioController.text, null, _bubbleColor);
    setState(() => _saving = false);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    if (auth == null) return const SizedBox.shrink();
    final profileAsync = ref.watch(profileProvider(auth.username));
    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: profileAsync.when(
        data: (profile) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: 'Biografía'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _bubbleColor,
                decoration: const InputDecoration(labelText: 'Bubble Color'),
                items: const [
                  '#ff0000',
                  '#ffa500',
                  '#ffff00',
                  '#008000',
                  '#00ffff',
                  '#0000ff',
                  '#800080',
                  '#ff00ff',
                  '#ffc0cb',
                  '#a52a2a',
                ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (value) => setState(() => _bubbleColor = value),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const CircularProgressIndicator()
                    : const Text('Guardar'),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
