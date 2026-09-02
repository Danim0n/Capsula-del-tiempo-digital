import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

import '../../l10n/l10n.dart';

/// Returns a temporary audio path only when the user explicitly stops to save.
/// The caller owns (and must remove) the returned temporary file.
class AudioRecordingDialog extends StatefulWidget {
  const AudioRecordingDialog({
    super.key,
    this.recorderFactory,
    this.pathFactory,
    this.now,
  });

  final AudioRecorder Function()? recorderFactory;
  final Future<String> Function()? pathFactory;
  final DateTime Function()? now;

  @override
  State<AudioRecordingDialog> createState() => _AudioRecordingDialogState();
}

class _AudioRecordingDialogState extends State<AudioRecordingDialog>
    with WidgetsBindingObserver {
  AudioRecorder? _recorder;
  StreamSubscription<Amplitude>? _amplitudeSub;
  StreamSubscription<RecordState>? _stateSub;
  Timer? _timer;
  Future<void>? _pendingAction;
  RecordState _state = RecordState.stop;
  final _samples = <double>[];
  Duration _elapsed = Duration.zero;
  DateTime? _segmentStart;
  String? _temporaryPath;
  String? _error;
  bool _started = false;
  bool _busy = false;
  bool _confirming = false;
  bool _closing = false;
  bool _accepted = false;
  bool _foreground = true;

  bool get _recording => _started && _state == RecordState.record;
  bool get _blocked => _busy || _confirming || _closing;
  DateTime get _now => (widget.now ?? DateTime.now)();
  Duration get _duration =>
      _elapsed +
      (_segmentStart == null ? Duration.zero : _now.difference(_segmentStart!));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _foreground = lifecycle == null || lifecycle == AppLifecycleState.resumed;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (!_foreground && _recording && !_blocked) {
      unawaited(_run(_pause));
    }
  }

  Future<String> _createPath() async {
    if (kIsWeb) return '';
    final temp = await getTemporaryDirectory();
    return p.join(temp.path, '${const Uuid().v4()}.m4a');
  }

  Future<void> _run(Future<void> Function() action) {
    if (_blocked) return Future.value();
    final pending = _perform(action);
    _pendingAction = pending;
    return pending;
  }

  Future<void> _perform(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      // A permission prompt or app switch can occur while start/resume awaits.
      // Never resume recording automatically when returning to the app.
      if (mounted && !_closing && !_foreground && _recording) {
        await _pause();
      }
    } catch (_) {
      if (mounted && !_closing) _error = context.l10n.recordingError;
    } finally {
      if (mounted && !_closing) setState(() => _busy = false);
    }
  }

  Future<void> _startOrResume() async {
    if (_started) {
      await _recorder!.resume();
      if (mounted && !_closing) _changeState(RecordState.record);
      return;
    }
    final recorder = _recorder ??=
        (widget.recorderFactory ?? AudioRecorder.new)();
    if (!await recorder.hasPermission()) {
      if (mounted && !_closing) _error = context.l10n.recordingPermission;
      return;
    }
    if (!mounted || _closing) return;
    _temporaryPath ??= await (widget.pathFactory ?? _createPath)();
    if (!mounted || _closing) return;
    _stateSub ??= recorder.onStateChanged().listen(
      (state) {
        if (!mounted || _closing || !_started) return;
        _changeState(state);
      },
      onError: (Object error) {
        if (mounted && !_closing) {
          setState(() => _error = context.l10n.recordingError);
        }
      },
    );
    try {
      await recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: _temporaryPath!,
      );
    } catch (_) {
      // A failed native start may still have acquired the microphone.
      try {
        await recorder.cancel();
      } catch (_) {
        // Closing the dialog will also dispose the native recorder.
      }
      rethrow;
    }
    if (!mounted || _closing) return;
    _started = true;
    _changeState(RecordState.record);
    _amplitudeSub ??= recorder
        .onAmplitudeChanged(const Duration(milliseconds: 100))
        .listen(
          (amplitude) {
            if (!mounted || _closing || !_recording) return;
            final db = amplitude.current;
            final level = db.isFinite ? ((db + 60) / 60).clamp(0.0, 1.0) : 0.0;
            setState(() {
              _samples.add(level);
              if (_samples.length > 64) _samples.removeAt(0);
            });
          },
          onError: (Object error) {
            // Metering is optional: don't discard a working recording if a
            // device stops reporting volume. Show that the meter is unavailable.
            if (mounted && !_closing) {
              setState(() => _error = context.l10n.recordingMeterError);
            }
          },
        );
  }

  void _changeState(RecordState state) {
    if (_state == state) return;
    if (_segmentStart != null) {
      _elapsed = _duration;
      _segmentStart = null;
    }
    _timer?.cancel();
    _state = state;
    if (state == RecordState.record) {
      _segmentStart = _now;
      _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
        if (mounted && !_closing) setState(() {});
      });
    }
    setState(() {});
  }

  Future<void> _pause() async {
    await _recorder!.pause();
    if (mounted && !_closing) _changeState(RecordState.pause);
  }

  Future<void> _stop() async {
    final path = await _recorder!.stop();
    if (!mounted || _closing) return;
    _changeState(RecordState.stop);
    if (path == null || path.isEmpty) {
      _error = context.l10n.recordingError;
      return;
    }
    _accepted = true;
    _closing = true;
    Navigator.of(context).pop(path);
  }

  Future<void> _requestClose() async {
    if (_blocked) return;
    if (_recording) await _run(_pause);
    if (!mounted || _closing) return;
    if (_started) {
      setState(() => _confirming = true);
      final discard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.recordingDiscardQuestion),
          content: Text(context.l10n.recordingDiscardHint),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.delete_outline_rounded),
              label: Text(context.l10n.delete),
            ),
          ],
        ),
      );
      if (!mounted || _closing) return;
      setState(() => _confirming = false);
      if (discard != true) return;
    }
    _closing = true;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _closing = true;
    _timer?.cancel();
    unawaited(_release());
    super.dispose();
  }

  Future<void> _release() async {
    // In-flight permission/start/stop calls must finish before native disposal.
    await _pendingAction;
    for (final subscription in <StreamSubscription<dynamic>?>[
      _amplitudeSub,
      _stateSub,
    ]) {
      try {
        await subscription?.cancel();
      } catch (_) {
        // A failed event channel must not prevent releasing the microphone.
      }
    }
    try {
      if (!_accepted) await _recorder?.cancel();
    } catch (_) {
      // Always release the microphone, even when cancelling failed.
    }
    try {
      await _recorder?.dispose();
    } catch (_) {
      // Disposal must not escape into Flutter's asynchronous error handler.
    }
    if (!_accepted && !kIsWeb && _temporaryPath != null) {
      try {
        final file = File(_temporaryPath!);
        if (await file.exists()) await file.delete();
      } catch (_) {
        // Best-effort cleanup of only this dialog's temporary recording.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final status = !_started
        ? l10n.recordingReady
        : switch (_state) {
            RecordState.record => l10n.recordingActive,
            RecordState.pause => l10n.recordingPaused,
            RecordState.stop => l10n.recordingInterrupted,
          };
    final duration = _duration;
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return PopScope<String>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) unawaited(_requestClose());
      },
      child: AlertDialog(
        scrollable: true,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        title: Row(
          children: [
            Expanded(child: Text(l10n.recordingTitle)),
            IconButton(
              tooltip: l10n.cancel,
              onPressed: _blocked ? null : _requestClose,
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
        content: SizedBox(
          width: 340,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(liveRegion: true, child: Text(status)),
              const SizedBox(height: 12),
              Text(
                '$minutes:$seconds',
                key: const ValueKey('recording-duration'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 16),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: .07),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: RecordingWaveform(
                    samples: List.unmodifiable(_samples),
                    active: _recording,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 12,
                children: [
                  IconButton.outlined(
                    key: const ValueKey('recording-pause'),
                    tooltip: l10n.recordingPause,
                    onPressed: !_blocked && _recording
                        ? () => _run(_pause)
                        : null,
                    icon: const Icon(Icons.pause_rounded),
                    iconSize: 28,
                    style: IconButton.styleFrom(
                      minimumSize: const Size(52, 52),
                    ),
                  ),
                  IconButton.filled(
                    key: const ValueKey('recording-start'),
                    tooltip: _started
                        ? l10n.recordingResume
                        : l10n.recordingStart,
                    onPressed:
                        !_blocked && (!_started || _state == RecordState.pause)
                        ? () => _run(_startOrResume)
                        : null,
                    icon: Icon(
                      _started ? Icons.play_arrow_rounded : Icons.mic_rounded,
                    ),
                    iconSize: 32,
                    style: IconButton.styleFrom(
                      minimumSize: const Size(60, 60),
                    ),
                  ),
                  IconButton.outlined(
                    key: const ValueKey('recording-stop'),
                    tooltip: l10n.recordingStop,
                    onPressed: !_blocked && _started ? () => _run(_stop) : null,
                    icon: const Icon(Icons.stop_rounded),
                    iconSize: 28,
                    style: IconButton.styleFrom(
                      minimumSize: const Size(52, 52),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                l10n.recordingHint,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (_busy) ...[
                const SizedBox(height: 12),
                const LinearProgressIndicator(),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _error!,
                    style: TextStyle(color: colors.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A rolling, bounded volume history; silence remains a flat dotted line.
class RecordingWaveform extends StatelessWidget {
  const RecordingWaveform({
    super.key,
    required this.samples,
    required this.active,
  });

  final List<double> samples;
  final bool active;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      height: 72,
      width: double.infinity,
      child: CustomPaint(
        painter: _WaveformPainter(
          samples,
          Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: active ? 1 : .45),
        ),
      ),
    ),
  );
}

class _WaveformPainter extends CustomPainter {
  const _WaveformPainter(this.samples, this.color);
  final List<double> samples;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final bars = math.max(1, (size.width / 6).floor());
    final visible = samples.skip(math.max(0, samples.length - bars)).toList();
    final empty = bars - visible.length;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < bars; i++) {
      final level = i < empty ? 0.0 : visible[i - empty];
      final height = 2 + level * (size.height - 6);
      final x = (i + .5) * size.width / bars;
      canvas.drawLine(
        Offset(x, (size.height - height) / 2),
        Offset(x, (size.height + height) / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) =>
      color != oldDelegate.color || !listEquals(samples, oldDelegate.samples);
}
