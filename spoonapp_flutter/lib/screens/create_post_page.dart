import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:dotted_border/dotted_border.dart';

import '../providers/post_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/topbar.dart';
import '../widgets/sidebar_left.dart';
import '../widgets/sidebar_right.dart';
import '../providers/menu_provider.dart';

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

  void _toggleLeft() => context.read<MenuProvider>().toggleLeft();
  void _toggleRight() => context.read<MenuProvider>().toggleRight();

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error al publicar')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final boxWidth = width > 800 ? 800.0 : width * 0.9;
    final menu = context.watch<MenuProvider>();

    final card = ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: boxWidth,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFF00FF).withOpacity(0.25),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.white54,
                blurRadius: 20,
                spreadRadius: 1,
                offset: const Offset(0, 10),
              ),
            ],
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.05),
                Colors.white.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: DefaultTextStyle(
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: _pickFile,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: DottedBorder(
                      color: Colors.black45,
                      strokeWidth: 1.5,
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(12),
                      dashPattern: const [6, 3],
                      child: Container(
                        height: 150,
                        alignment: Alignment.center,
                        color: const Color(0xFFFF00FF).withOpacity(0.2),
                        child: _fileBytes == null
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.attach_file, color: Colors.black54),
                                  SizedBox(width: 8),
                                  Text(
                                    '🖱️ Arrastra una imagen o video aquí o haz clic',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ],
                              )
                            : Image.memory(_fileBytes!, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descController,
                  minLines: 3,
                  maxLines: null,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFFF00FF).withOpacity(0.3),
                    hintText: '🧑‍🍳 ¿Qué tienes en tu cuchara?',
                    hintStyle: const TextStyle(color: Colors.black54),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFFF00FF).withOpacity(0.3),
                    hintText: 'Selecciona la categoría de tu plato 🍲',
                    hintStyle: const TextStyle(color: Colors.black54),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  iconEnabledColor: Colors.black,
                  items: const [
                    DropdownMenuItem(
                      value: 'Entrantes',
                      child: Text('Entrantes', style: TextStyle(color: Colors.black)),
                    ),
                    DropdownMenuItem(
                      value: 'Primer plato',
                      child: Text('Primer plato', style: TextStyle(color: Colors.black)),
                    ),
                    DropdownMenuItem(
                      value: 'Segundo plato',
                      child: Text('Segundo plato', style: TextStyle(color: Colors.black)),
                    ),
                    DropdownMenuItem(
                      value: 'Postres',
                      child: Text('Postres', style: TextStyle(color: Colors.black)),
                    ),
                  ],
                  onChanged: (v) => setState(() => _category = v),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed:
                        (_fileBytes == null || _category == null || _loading)
                        ? null
                        : _publish,
                    icon: _loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Icon(Icons.rocket_launch, color: Colors.black),
                    label: const Text('Publicar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFFF00FF).withOpacity(0.3),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: TopBar(
        title: 'Crear publicación',
        onLeftMenu: _toggleLeft,
        onRightMenu: _toggleRight,
      ),
      backgroundColor: const Color(
        0xFFFFFDF4,
      ), // blanco ligeramente amarillento
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: card,
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            top: 0,
            bottom: 0,
            left: menu.leftOpen ? 0 : -216,
            child: const SidebarLeft(),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            top: 0,
            bottom: 0,
            right: menu.rightOpen ? 0 : -216,
            child: const SidebarRight(),
          ),
        ],
      ),
    );
  }
}
