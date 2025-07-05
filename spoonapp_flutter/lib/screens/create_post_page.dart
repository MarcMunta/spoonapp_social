import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../assets/base64_images.dart';

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
  String? _category;
  bool _loading = false;
  final _descController = TextEditingController();

  final _categories = const [
    'Entrantes',
    'Primer plato',
    'Segundo plato',
    'Postres',
  ];

  Future<void> _pickFile() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4'],
    );
    if (res != null && res.files.single.bytes != null) {
      setState(() {
        _fileBytes = res.files.single.bytes;
        _fileName = res.files.single.name;
      });
    }
  }

  Future<void> _publish() async {
    if (_fileBytes == null || _category == null) return;
    setState(() => _loading = true);
    final userProv = context.read<UserProvider>();
    final postProv = context.read<PostProvider>();
    final ok = await postProv.addPost(
      user: userProv.currentUser,
      bytes: _fileBytes!,
      filename: _fileName ?? const Uuid().v4(),
      description: _descController.text,
      category: _category!,
      token: userProv.token,
    );
    setState(() => _loading = false);
    final snackBar = SnackBar(
      content: Text(ok ? 'Publicación creada' : 'Error al publicar'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxWidth = size.width > 820 ? 800.0 : size.width * 0.9;

    final dropArea = DottedBorder(
      color: Colors.white70,
      dashPattern: const [6, 4],
      strokeWidth: 2,
      borderType: BorderType.RRect,
      radius: const Radius.circular(12),
      child: GestureDetector(
        onTap: _pickFile,
        child: Container(
          height: 150,
          alignment: Alignment.center,
          child: _fileBytes == null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.attach_file, color: Colors.white70),
                    SizedBox(width: 8),
                    Text(
                      '🖱️ Arrastra una imagen o video aquí o haz clic',
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : _preview(),
        ),
      ),
    );

    final description = TextField(
      controller: _descController,
      minLines: 4,
      maxLines: null,
      decoration: const InputDecoration(
        hintText: '🧑‍🍳 ¿Qué tienes en tu cuchara?',
        filled: true,
        fillColor: Color(0xFFF3E8FD),
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
      ),
    );

    final category = DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        hintText: 'Selecciona la categoría de tu plato 🍲',
        filled: true,
        fillColor: Color(0xFFF3E8FD),
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
      ),
      value: _category,
      items: _categories
          .map((c) => DropdownMenuItem(value: c, child: Center(child: Text(c))))
          .toList(),
      onChanged: (v) => setState(() => _category = v),
    );

    final publishBtn = ElevatedButton.icon(
      onPressed: _loading ? null : _publish,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        backgroundColor: const Color(0xFFB46DDD),
        foregroundColor: Colors.white,
      ).copyWith(
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.purple.shade200;
          }
          return null;
        }),
      ),
      icon: _loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.rocket_launch),
      label: const Text('Publicar', style: TextStyle(fontWeight: FontWeight.bold)),
    );

    final card = Container(
      width: maxWidth,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xCCF3E8FD),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          dropArea,
          const SizedBox(height: 16),
          description,
          const SizedBox(height: 16),
          category,
          const SizedBox(height: 16),
          Align(alignment: Alignment.centerRight, child: publishBtn),
        ],
      ),
    );

    return Scaffold(
      appBar: const TopBar(title: 'Publicar'),
      body: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFB46DDD), Color(0xFFD9A7C7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          image: DecorationImage(
            image: MemoryImage(dotsBytes),
            repeat: ImageRepeat.repeat,
            opacity: 0.2,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(child: card),
        ),
      ),
    );
  }

  Widget _preview() {
    final ext = _fileName?.split('.').last.toLowerCase();
    final isVideo = ext == 'mp4';
    if (isVideo) {
      return const Icon(Icons.videocam, color: Colors.white70, size: 48);
    }
    return Image.memory(_fileBytes!, fit: BoxFit.cover, height: 140);
  }
}
