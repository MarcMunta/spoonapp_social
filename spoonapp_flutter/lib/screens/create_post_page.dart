import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:dotted_border/dotted_border.dart';

import '../providers/post_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/topbar.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  Uint8List? _fileBytes;
  String? _fileName;
  final _descController = TextEditingController();
  String? _category;
  bool _loading = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'mp4'],
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _fileBytes = result.files.single.bytes;
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _publish() async {
    if (_loading || _fileBytes == null || _category == null) return;
    final userProv = context.read<UserProvider>();
    setState(() => _loading = true);
    try {
      await context.read<PostProvider>().addPost(
            userProv.currentUser,
            _fileBytes!,
            _fileName ?? 'media',
            _descController.text,
            _category!,
            userProv.token,
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Error al publicar')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final boxWidth = width > 800 ? 800.0 : width * 0.9;
    return Scaffold(
      appBar: const TopBar(title: 'Crear publicación'),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB46DDD), Color(0xFFD9A7C7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: boxWidth,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xB3E6E6FA),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: _pickFile,
                    child: DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                        color: Colors.white70,
                        strokeWidth: 2,
                        dashPattern: const [6, 4],
                        radius: const Radius.circular(8),
                      ),
                      child: Container(
                        height: 150,
                        alignment: Alignment.center,
                        color: _fileBytes == null
                            ? Colors.transparent
                            : Colors.white24,
                        child: _fileBytes == null
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.attach_file, color: Colors.grey),
                                  SizedBox(width: 8),
                                  Text(
                                    '🖱️ Arrastra una imagen o video aquí o haz clic',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              )
                            : Image.memory(_fileBytes!, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descController,
                    minLines: 3,
                    maxLines: null,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFEFE3F6),
                      hintText: '🧑‍🍳 ¿Qué tienes en tu cuchara?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _category,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFEFE3F6),
                      hintText: 'Selecciona la categoría de tu plato 🍲',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Entrantes', child: Text('Entrantes')),
                      DropdownMenuItem(value: 'Primer plato', child: Text('Primer plato')),
                      DropdownMenuItem(value: 'Segundo plato', child: Text('Segundo plato')),
                      DropdownMenuItem(value: 'Postres', child: Text('Postres')),
                    ],
                    onChanged: (v) => setState(() => _category = v),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: (_fileBytes == null || _category == null || _loading)
                          ? null
                          : _publish,
                      icon: _loading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('🚀'),
                      label: const Text('Publicar'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        backgroundColor: const Color(0xFFB46DDD),
                      ).copyWith(
                        elevation: MaterialStateProperty.resolveWith(
                          (states) => states.contains(MaterialState.hovered) ? 6 : 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
