import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:flutter/material.dart' as material show Colors;
import 'package:palette_generator/palette_generator.dart';
import '../models/story.dart';

class StoryViewer extends StatefulWidget {
  final List<Story> stories;
  final int initialIndex;
  final String? heroTag;
  const StoryViewer({super.key, required this.stories, required this.initialIndex, this.heroTag});

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> {
  Color? _dominantColor;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateDominantColor();
  }

  Future<void> _updateDominantColor() async {
    final story = widget.stories[_current];
    ImageProvider imageProvider;
    if (story.mediaBytes != null) {
      imageProvider = MemoryImage(story.mediaBytes!);
    } else {
      imageProvider = NetworkImage(story.mediaUrl ?? '');
    }
    final PaletteGenerator palette = await PaletteGenerator.fromImageProvider(
      imageProvider,
      size: const Size(200, 200),
      maximumColorCount: 8,
    );
    setState(() {
      _dominantColor = palette.dominantColor?.color ?? material.Colors.black.withOpacity(0.2);
    });
  }
  late PageController _controller;
  late int _current;
  Timer? _timer;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _controller = PageController(initialPage: _current);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _progress = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      setState(() => _progress += 0.01);
      if (_progress >= 1) {
        t.cancel();
        _next();
      }
    });
  }

  void _next() {
    if (_current < widget.stories.length - 1) {
      _current++;
      _controller.animateToPage(_current,
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      _startTimer();
      _updateDominantColor();
      setState(() {});
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: GestureDetector(
        onTap: _next,
        child: Stack(
          children: [
            // Fondo reactivo al color dominante + AR glasses
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (_dominantColor ?? Colors.white.withOpacity(0.15)).withOpacity(0.35),
                      Colors.black.withOpacity(0.25),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
            // Eliminada la barra azul superior global, solo queda la interna sobre la historia
            PageView.builder(
              controller: _controller,
              onPageChanged: (i) {
                _current = i;
                _startTimer();
                setState(() {});
              },
              itemCount: widget.stories.length,
              itemBuilder: (context, index) {
                final story = widget.stories[index];
                final tag = widget.heroTag ?? 'story-avatar-${story.user.email}';
                // Tamaño historia y AR glass (Instagram web style)
                final Size screen = MediaQuery.of(context).size;
                final double aspectRatio = 9 / 16; // móvil vertical
                final double maxStoryWidth = screen.width * 0.7;
                final double maxStoryHeight = screen.height * 0.8;
                double storyWidth = maxStoryWidth;
                double storyHeight = storyWidth / aspectRatio;
                if (storyHeight > maxStoryHeight) {
                  storyHeight = maxStoryHeight;
                  storyWidth = storyHeight * aspectRatio;
                }
                // AR glass pegado a la historia, sin huecos, y solo una barra azul interna
                final double arGlassBorder = 8.0; // Borde fino estilo iPhone
                return Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.18),
                        width: arGlassBorder,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.10),
                          blurRadius: 32,
                          spreadRadius: 2,
                        ),
                      ],
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.10),
                          Colors.white.withOpacity(0.02),
                          Colors.transparent
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: SizedBox(
                        width: storyWidth,
                        height: storyHeight,
                        child: Stack(
                          children: [
                            story.mediaBytes != null
                                ? Image.memory(
                                    story.mediaBytes!,
                                    fit: BoxFit.cover,
                                    width: storyWidth,
                                    height: storyHeight,
                                    errorBuilder: (context, error, stack) => Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                          const SizedBox(height: 8),
                                          Text(
                                            'No se pudo cargar la historia',
                                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Image.network(
                                    story.mediaUrl ?? '',
                                    fit: BoxFit.cover,
                                    width: storyWidth,
                                    height: storyHeight,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                              : null,
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stack) => Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                          const SizedBox(height: 8),
                                          Text(
                                            'No se pudo cargar la historia',
                                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            // Barra de progreso sobre la imagen
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 6,
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300]?.withOpacity(0.7),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                ),
                                child: Stack(
                                  children: [
                                    FractionallySizedBox(
                                      widthFactor: _progress.clamp(0, 1),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.blueAccent,
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Info usuario y botón cerrar
                            Positioned(
                              top: 16,
                              left: 16,
                              right: 16,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundImage: widget.stories[_current].user.profileImage.startsWith('http')
                                        ? NetworkImage(widget.stories[_current].user.profileImage)
                                        : AssetImage(widget.stories[_current].user.profileImage) as ImageProvider,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      widget.stories[_current].user.name,
                                      style: const TextStyle(color: Colors.white, fontSize: 16, shadows: [Shadow(blurRadius: 2, color: Colors.black26)]),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('HH:mm').format(
                                        widget.stories[_current].expiresAt.subtract(const Duration(hours: 24))),
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.white),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            // Eliminado: overlays duplicados de usuario, hora y cerrar fuera de la historia
          ],
        ),
      ),
    );
  }
}
