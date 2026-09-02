import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../l10n/l10n.dart';

class MemoryVideoPlayer extends StatefulWidget {
  const MemoryVideoPlayer({super.key, required this.path});
  final String path;

  @override
  State<MemoryVideoPlayer> createState() => _MemoryVideoPlayerState();
}

class _MemoryVideoPlayerState extends State<MemoryVideoPlayer>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _error = false;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_initialize());
  }

  @override
  void didUpdateWidget(covariant MemoryVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.path != oldWidget.path) unawaited(_initialize());
  }

  Future<void> _initialize() async {
    final generation = ++_generation;
    _release();
    if (mounted) setState(() => _error = false);
    try {
      // Web media must use a browser blob URL, never VideoPlayerController.file.
      if (kIsWeb && Uri.tryParse(widget.path)?.scheme != 'blob') {
        throw UnsupportedError('Local file unavailable in browser.');
      }
      final controller = kIsWeb
          ? VideoPlayerController.networkUrl(Uri.parse(widget.path))
          : VideoPlayerController.file(File(widget.path));
      _controller = controller;
      controller.addListener(_changed);
      await controller.initialize().timeout(const Duration(seconds: 30));
      if (mounted && generation == _generation) setState(() {});
    } catch (_) {
      if (mounted && generation == _generation) {
        _release();
        setState(() => _error = true);
      }
    }
  }

  void _changed() {
    if (mounted) setState(() => _error = _controller?.value.hasError ?? false);
  }

  void _release() {
    final controller = _controller;
    _controller = null;
    if (controller != null) {
      controller.removeListener(_changed);
      unawaited(controller.pause().catchError((Object _) {}));
      unawaited(controller.dispose().catchError((Object _) {}));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      unawaited(
        _controller?.pause().catchError((Object _) {}) ?? Future<void>.value(),
      );
    }
  }

  @override
  void dispose() {
    _generation++;
    WidgetsBinding.instance.removeObserver(this);
    _release();
    super.dispose();
  }

  Future<void> _toggle() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    try {
      if (controller.value.isPlaying) {
        await controller.pause();
      } else {
        if (controller.value.position >= controller.value.duration) {
          await controller.seekTo(Duration.zero);
        }
        await controller.play();
      }
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.videocam_off_outlined, size: 40),
              const SizedBox(height: 12),
              Text(
                context.l10n.videoPlaybackError,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _initialize,
                child: Text(context.l10n.memoryRetry),
              ),
            ],
          ),
        ),
      );
    }
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final value = controller.value;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: ColoredBox(
            color: Colors.black,
            child: AspectRatio(
              aspectRatio: value.aspectRatio > 0 ? value.aspectRatio : 16 / 9,
              child: VideoPlayer(controller),
            ),
          ),
        ),
        const SizedBox(height: 8),
        VideoProgressIndicator(
          controller,
          allowScrubbing: true,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        Row(
          children: [
            IconButton.filledTonal(
              tooltip: value.isPlaying
                  ? context.l10n.mediaPause
                  : context.l10n.mediaPlay,
              onPressed: _toggle,
              icon: Icon(
                value.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${_time(value.position)} / ${_time(value.duration)}',
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _time(Duration duration) {
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '${duration.inMinutes}:$seconds';
  }
}
