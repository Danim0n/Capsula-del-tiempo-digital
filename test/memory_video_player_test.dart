import 'dart:async';

import 'package:capsula_del_tiempo_digital/features/capsules/domain/capsule_models.dart';
import 'package:capsula_del_tiempo_digital/features/capsules/presentation/capsule_sequence_viewer.dart';
import 'package:capsula_del_tiempo_digital/features/capsules/presentation/memory_video_player.dart';
import 'package:capsula_del_tiempo_digital/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

void main() {
  late _FakeVideoPlatform platform;
  late VideoPlayerPlatform previous;
  setUp(() {
    previous = VideoPlayerPlatform.instance;
    platform = _FakeVideoPlatform();
    VideoPlayerPlatform.instance = platform;
  });
  tearDown(() {
    VideoPlayerPlatform.instance = previous;
  });

  Future<void> show(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'video initializes paused, supports play, pause, seek and replay',
    (tester) async {
      await show(tester, const MemoryVideoPlayer(path: '/private/test.mp4'));
      expect(find.text('video-surface'), findsOneWidget);
      expect(platform.calls, isNot(contains('play')));
      await tester.tap(find.byTooltip('Reproducir'));
      await tester.pump();
      expect(platform.calls, contains('play'));
      await tester.tap(find.byTooltip('Pausar'));
      await tester.pump();
      expect(platform.calls.last, 'pause');
      await tester.tap(find.byType(VideoProgressIndicator));
      await tester.pump();
      expect(platform.position, greaterThan(Duration.zero));
      platform.streams[0]!.add(VideoEvent(eventType: VideoEventType.completed));
      await tester.pump();
      await tester.tap(find.byTooltip('Reproducir'));
      await tester.pump();
      expect(platform.position, Duration.zero);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pumpAndSettle();
      await tester.pump();
      await tester.pump();
      expect(platform.calls, contains('dispose-0'));
    },
  );

  testWidgets('unsupported video displays an error and can be retried', (
    tester,
  ) async {
    platform.fail = true;
    await show(tester, const MemoryVideoPlayer(path: '/private/test.mp4'));
    expect(find.textContaining('No se puede reproducir'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    platform.fail = false;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('video-surface'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });

  testWidgets('Continue disposes the playing video before the next memory', (
    tester,
  ) async {
    final items = [
      for (final type in [CapsuleItemType.video, CapsuleItemType.text])
        CapsuleItem(
          id: type.name,
          capsuleId: 'c',
          type: type,
          createdAt: DateTime(2026),
          orderIndex: 0,
        ),
    ];
    await show(
      tester,
      CapsuleSequenceViewer(
        items: items,
        onFinished: () {},
        itemBuilder: (item, _) => item.type == CapsuleItemType.video
            ? const MemoryVideoPlayer(path: '/private/test.mp4')
            : const Text('Carta final'),
      ),
    );
    await tester.ensureVisible(find.byTooltip('Reproducir'));
    await tester.tap(find.byTooltip('Reproducir'));
    await tester.pump();
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('Carta final'), findsOneWidget);
    expect(find.byType(VideoPlayer), findsNothing);
    expect(platform.calls, contains('dispose-0'));
    expect(tester.takeException(), isNull);
  });
}

class _FakeVideoPlatform extends VideoPlayerPlatform {
  final calls = <String>[];
  final streams = <int, StreamController<VideoEvent>>{};
  bool fail = false;
  Duration position = Duration.zero;
  int _next = 0;
  @override
  Future<void> init() async {}
  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async {
    final id = _next++;
    final stream = StreamController<VideoEvent>();
    streams[id] = stream;
    if (fail) {
      stream.addError(
        PlatformException(
          code: 'unsupported',
          message: 'Unsupported test codec',
        ),
      );
    } else {
      stream.add(
        VideoEvent(
          eventType: VideoEventType.initialized,
          size: const Size(640, 360),
          duration: const Duration(seconds: 10),
        ),
      );
    }
    return id;
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) => streams[playerId]!.stream;
  @override
  Future<void> dispose(int playerId) async {
    calls.add('dispose-$playerId');
    await streams[playerId]?.close();
  }

  @override
  Future<void> play(int playerId) async {
    calls.add('play');
  }

  @override
  Future<void> pause(int playerId) async {
    calls.add('pause');
  }

  @override
  Future<void> seekTo(int playerId, Duration value) async {
    position = value;
    calls.add('seek');
  }

  @override
  Future<Duration> getPosition(int playerId) async => position;
  @override
  Future<void> setLooping(int playerId, bool looping) async {}
  @override
  Future<void> setVolume(int playerId, double volume) async {}
  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {}
  @override
  Widget buildViewWithOptions(VideoViewOptions options) =>
      const Center(child: Text('video-surface'));
}
