import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_theme.dart';
import '../../../l10n/l10n.dart';
import '../domain/capsule_models.dart';
import 'memory_video_player.dart';

class CapsuleMemoryView extends ConsumerStatefulWidget {
  const CapsuleMemoryView({
    super.key,
    required this.item,
    required this.index,
    this.preview = false,
  });
  final CapsuleItem item;
  final int index;
  final bool preview;
  @override
  ConsumerState<CapsuleMemoryView> createState() => _CapsuleMemoryViewState();
}

class _CapsuleMemoryViewState extends ConsumerState<CapsuleMemoryView> {
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
      final encryption = ref.read(encryptionProvider);
      final storage = ref.read(storageProvider);
      final key = await ref.read(keyServiceProvider).getOrCreateMasterKey();
      if (widget.item.type == CapsuleItemType.text) {
        final clear = await encryption.decryptText(
          widget.item.encryptedText!,
          key,
        );
        String? title;
        try {
          if (widget.item.textTitle != null) {
            title = await encryption.decryptText(widget.item.textTitle!, key);
          }
        } catch (_) {
          // Older transferred titles may use the sender's key. The body is still readable.
        }
        if (mounted) {
          setState(() {
            _text = clear;
            _textTitle = title;
          });
        }
      } else {
        final extension = _extension(widget.item.mimeType);
        final file = await storage.decryptToTemporary(
          widget.item.encryptedPath!,
          key,
          extension: extension,
        );
        if (mounted) {
          setState(() => _file = file);
        } else {
          await _deletePreview(file);
        }
      }
    } catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  @override
  void dispose() {
    final file = _file;
    if (file != null) unawaited(_deletePreview(file));
    super.dispose();
  }

  Future<void> _deletePreview(File file) async {
    // Native media players close asynchronously and can briefly hold a file
    // lock. Retry only this decrypted preview, never the encrypted original.
    for (var attempt = 0; attempt < 4; attempt++) {
      try {
        if (await file.exists()) await file.delete();
        return;
      } catch (_) {
        if (attempt < 3) {
          await Future<void>.delayed(
            Duration(milliseconds: 150 * (attempt + 1)),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Text(context.l10n.memoryLoadError),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  setState(() => _error = null);
                  unawaited(_load());
                },
                child: Text(context.l10n.memoryRetry),
              ),
            ],
          ),
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
          _image(context)
        else if (widget.item.type == CapsuleItemType.video)
          MemoryVideoPlayer(path: _file!.path)
        else
          _AudioMemory(file: _file!),
        if (!widget.preview) ...[
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 6,
            children: [
              if (widget.item.type == CapsuleItemType.text)
                TextButton.icon(
                  onPressed: () =>
                      Clipboard.setData(ClipboardData(text: _text!)),
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
      ],
    );
  }

  Widget _image(BuildContext context) {
    final image = Image.file(
      _file!,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Padding(
        padding: const EdgeInsets.all(24),
        child: Text(context.l10n.memoryLoadError),
      ),
    );
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: widget.preview
              ? SizedBox(
                  height: (MediaQuery.sizeOf(context).height * .6).clamp(
                    200,
                    640,
                  ),
                  width: double.infinity,
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 5,
                    child: Center(child: image),
                  ),
                )
              : image,
        ),
        if (widget.preview) ...[
          const SizedBox(height: 12),
          Text(context.l10n.previewImageHint, textAlign: TextAlign.center),
        ],
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

class _AudioMemory extends StatefulWidget {
  const _AudioMemory({required this.file});
  final File file;
  @override
  State<_AudioMemory> createState() => _AudioMemoryState();
}

class _AudioMemoryState extends State<_AudioMemory>
    with WidgetsBindingObserver {
  final _player = AudioPlayer();
  Duration _duration = Duration.zero;
  bool _ready = false;
  bool _error = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _player
        .setFilePath(widget.file.path)
        .timeout(const Duration(seconds: 30))
        .then((duration) {
          if (mounted) {
            setState(() {
              _duration = duration ?? Duration.zero;
              _ready = true;
            });
          }
        })
        .catchError((Object _) {
          if (mounted) setState(() => _error = true);
        });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_player.pause().catchError((Object _) {}));
    unawaited(_player.dispose().catchError((Object _) {}));
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      unawaited(_player.pause().catchError((Object _) {}));
    }
  }

  @override
  Widget build(BuildContext context) => _error
      ? Padding(
          padding: const EdgeInsets.all(24),
          child: Text(context.l10n.memoryLoadError),
        )
      : !_ready
      ? const SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        )
      : Container(
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
                    builder: (context, state) => IconButton.filled(
                      tooltip:
                          state.data?.playing == true &&
                              state.data?.processingState !=
                                  ProcessingState.completed
                          ? context.l10n.mediaPause
                          : context.l10n.mediaPlay,
                      onPressed: () async {
                        try {
                          if (state.data?.playing == true &&
                              state.data?.processingState !=
                                  ProcessingState.completed) {
                            await _player.pause();
                          } else {
                            if (_player.processingState ==
                                ProcessingState.completed) {
                              await _player.seek(Duration.zero);
                            }
                            unawaited(
                              _player.play().catchError((Object _) {
                                if (mounted) setState(() => _error = true);
                              }),
                            );
                          }
                        } catch (_) {
                          if (mounted) setState(() => _error = true);
                        }
                      },
                      icon: Icon(
                        state.data?.playing == true &&
                                state.data?.processingState !=
                                    ProcessingState.completed
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: position.inMilliseconds
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
                      onChanged: (value) async {
                        try {
                          await _player.seek(
                            Duration(milliseconds: value.round()),
                          );
                        } catch (_) {
                          if (mounted) setState(() => _error = true);
                        }
                      },
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
