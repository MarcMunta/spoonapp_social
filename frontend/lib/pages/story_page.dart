import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/story.dart';
import '../providers/story_provider.dart';

class StoryPage extends ConsumerStatefulWidget {
  final int storyId;
  const StoryPage({super.key, required this.storyId});

  @override
  ConsumerState<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends ConsumerState<StoryPage> {
  late final PageController _controller;
  late List<Story> _stories;
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final data = ref.read(storiesNotifierProvider).value ?? [];
    _stories = data;
    _index = data.indexWhere((s) => s.id == widget.storyId);
    if (_index < 0) _index = 0;
    _controller = PageController(initialPage: _index);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 5), _next);
  }

  void _next() {
    if (_index < _stories.length - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.of(context).pop();
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapUp: (_) => _next(),
        onLongPressStart: (_) => _timer?.cancel(),
        onLongPressEnd: (_) => _startTimer(),
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: _stories.length,
              onPageChanged: (i) {
                _index = i;
                _startTimer();
              },
              itemBuilder: (context, i) {
                final story = _stories[i];
                return Center(
                  child: Hero(
                    tag: 'story_${story.id}',
                    child: CachedNetworkImage(imageUrl: story.imageUrl),
                  ),
                );
              },
            ),
            const Positioned(
              top: 40,
              left: 8,
              child: BackButton(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
