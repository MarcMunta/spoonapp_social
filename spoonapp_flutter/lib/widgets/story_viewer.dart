import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/story.dart';

class StoryViewer extends StatefulWidget {
  final List<Story> stories;
  final int initialIndex;
  const StoryViewer({super.key, required this.stories, required this.initialIndex});

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> {
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
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.zero,
      child: GestureDetector(
        onTap: _next,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(value: _progress, backgroundColor: Colors.grey[300], color: Colors.blueAccent),
            ),
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
                if (story.mediaBytes != null) {
                  return Center(
                    child: Image.memory(story.mediaBytes!, fit: BoxFit.contain),
                  );
                }
                return Center(
                  child: Image.network(story.mediaUrl ?? '', fit: BoxFit.contain),
                );
              },
            ),
            Positioned(
              top: 40,
              left: 16,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: widget
                            .stories[_current].user.profileImage
                            .startsWith('http')
                        ? NetworkImage(
                            widget.stories[_current].user.profileImage)
                        : AssetImage(
                            widget.stories[_current].user.profileImage)
                            as ImageProvider,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.stories[_current].user.name,
                    style:
                        const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: Text(
                DateFormat('HH:mm').format(
                    widget.stories[_current].expiresAt.subtract(const Duration(hours: 24))),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
            Positioned(
              top: 40,
              right: 48,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
