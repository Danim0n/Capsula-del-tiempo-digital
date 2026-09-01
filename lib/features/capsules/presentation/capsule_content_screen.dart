import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/navigation/app_navigation.dart';
import '../../../l10n/l10n.dart';
import '../domain/capsule_models.dart';

class CapsuleContentScreen extends ConsumerStatefulWidget {
  const CapsuleContentScreen({super.key, required this.capsuleId});
  final String capsuleId;

  @override
  ConsumerState<CapsuleContentScreen> createState() =>
      _CapsuleContentScreenState();
}

class _CapsuleContentScreenState extends ConsumerState<CapsuleContentScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(ref.read(screenSecurityProvider).protect());
  }

  @override
  void dispose() {
    ref.read(screenSecurityProvider).unprotect();
    ref.read(storageProvider).clearTemporaryPreviews();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final capsule = ref.watch(capsuleProvider(widget.capsuleId));
    final items = ref.watch(capsuleItemsProvider(widget.capsuleId));
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: '/capsules'),
        title: Text(capsule.valueOrNull?.title ?? context.l10n.appName),
      ),
      body: items.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (_, __) => const Center(child: Icon(Icons.error_outline_rounded)),
        data:
            (values) => ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
              itemCount: values.length,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder:
                  (context, index) =>
                      _PrivateItem(item: values[index], index: index),
            ),
      ),
    );
  }
}

class _PrivateItem extends ConsumerStatefulWidget {
  const _PrivateItem({required this.item, required this.index});
  final CapsuleItem item;
  final int index;
  @override
  ConsumerState<_PrivateItem> createState() => _PrivateItemState();
}

class _PrivateItemState extends ConsumerState<_PrivateItem> {
  File? _file;
  String? _text;
  String? _textTitle;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final key = await ref.read(keyServiceProvider).getOrCreateMasterKey();
      if (widget.item.type == CapsuleItemType.text) {
        final clear = await ref
            .read(encryptionProvider)
            .decryptText(widget.item.encryptedText!, key);
        final title =
            widget.item.textTitle == null
                ? null
                : await ref
                    .read(encryptionProvider)
                    .decryptText(widget.item.textTitle!, key);
        if (mounted) {
          setState(() {
            _text = clear;
            _textTitle = title;
          });
        }
      } else {
        final extension = _extension(widget.item.mimeType);
        final file = await ref
            .read(storageProvider)
            .decryptToTemporary(
              widget.item.encryptedPath!,
              key,
              extension: extension,
            );
        if (mounted) setState(() => _file = file);
      }
    } catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Icon(Icons.broken_image_outlined),
        ),
      );
    }
    if (_text == null && _file == null) {
      return const Card(
        child: SizedBox(
          height: 180,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.item.type == CapsuleItemType.text)
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_textTitle != null) ...[
                  Text(_textTitle!, style: emotionalTitle(context, size: 27)),
                  const SizedBox(height: 16),
                ],
                SelectableText(
                  _text!,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 18,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          )
        else if (widget.item.type == CapsuleItemType.image)
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.file(_file!, fit: BoxFit.cover),
          )
        else if (widget.item.type == CapsuleItemType.video)
          _VideoMemory(file: _file!)
        else
          _AudioMemory(file: _file!),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: 6,
          children: [
            if (widget.item.type == CapsuleItemType.text)
              TextButton.icon(
                onPressed: () => Clipboard.setData(ClipboardData(text: _text!)),
                icon: const Icon(Icons.copy_outlined),
                label: Text(context.l10n.copy),
              ),
            if (widget.item.type == CapsuleItemType.image ||
                widget.item.type == CapsuleItemType.video)
              TextButton.icon(
                onPressed: _saveToGallery,
                icon: const Icon(Icons.download_outlined),
                label: Text(context.l10n.saveToDevice),
              ),
            TextButton.icon(
              onPressed: _share,
              icon: const Icon(Icons.ios_share_outlined),
              label: Text(context.l10n.share),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _saveToGallery() async {
    if (_file == null) return;
    final granted = await Gal.hasAccess() || await Gal.requestAccess();
    if (!granted) return;
    if (widget.item.type == CapsuleItemType.image) {
      await Gal.putImage(_file!.path, album: 'Cápsula del Tiempo');
    } else {
      await Gal.putVideo(_file!.path, album: 'Cápsula del Tiempo');
    }
  }

  Future<void> _share() async {
    if (_text != null) {
      await SharePlus.instance.share(
        ShareParams(text: _text!, subject: _textTitle),
      );
    } else if (_file != null) {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(_file!.path, mimeType: widget.item.mimeType)],
        ),
      );
    }
  }

  String _extension(String? mime) => switch (mime) {
    'image/png' => '.png',
    'image/webp' => '.webp',
    'image/heic' => '.heic',
    'video/quicktime' => '.mov',
    'video/x-matroska' => '.mkv',
    'audio/wav' => '.wav',
    'audio/mpeg' => '.mp3',
    'audio/ogg' => '.ogg',
    'audio/mp4' => '.m4a',
    _ => widget.item.type == CapsuleItemType.image ? '.jpg' : '.mp4',
  };
}

class _VideoMemory extends StatefulWidget {
  const _VideoMemory({required this.file});
  final File file;
  @override
  State<_VideoMemory> createState() => _VideoMemoryState();
}

class _VideoMemoryState extends State<_VideoMemory> {
  late final VideoPlayerController _controller;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_controller),
            IconButton.filledTonal(
              iconSize: 34,
              onPressed: () {
                setState(
                  () =>
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play(),
                );
              },
              icon: Icon(
                _controller.value.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
                padding: const EdgeInsets.all(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AudioMemory extends StatefulWidget {
  const _AudioMemory({required this.file});
  final File file;
  @override
  State<_AudioMemory> createState() => _AudioMemoryState();
}

class _AudioMemoryState extends State<_AudioMemory> {
  final _player = AudioPlayer();
  Duration _duration = Duration.zero;
  @override
  void initState() {
    super.initState();
    _player.setFilePath(widget.file.path).then((duration) {
      if (mounted) setState(() => _duration = duration ?? Duration.zero);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.paleSage,
      borderRadius: BorderRadius.circular(22),
    ),
    child: StreamBuilder<Duration>(
      stream: _player.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        return Row(
          children: [
            StreamBuilder<PlayerState>(
              stream: _player.playerStateStream,
              builder:
                  (context, state) => IconButton.filled(
                    onPressed:
                        () =>
                            state.data?.playing == true
                                ? _player.pause()
                                : _player.play(),
                    icon: Icon(
                      state.data?.playing == true
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),
                  ),
            ),
            Expanded(
              child: Slider(
                value:
                    position.inMilliseconds
                        .clamp(
                          0,
                          _duration.inMilliseconds == 0
                              ? 1
                              : _duration.inMilliseconds,
                        )
                        .toDouble(),
                max:
                    (_duration.inMilliseconds == 0
                            ? 1
                            : _duration.inMilliseconds)
                        .toDouble(),
                onChanged:
                    (value) =>
                        _player.seek(Duration(milliseconds: value.round())),
              ),
            ),
            Text(
              '${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')}',
            ),
          ],
        );
      },
    ),
  );
}
