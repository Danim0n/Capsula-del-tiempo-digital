import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:capsula_del_tiempo_digital/app/providers.dart';
import 'package:capsula_del_tiempo_digital/app/theme/app_theme.dart';
import 'package:capsula_del_tiempo_digital/core/database/app_database.dart';
import 'package:capsula_del_tiempo_digital/core/encryption/encryption_service.dart';
import 'package:capsula_del_tiempo_digital/core/encryption/key_service.dart';
import 'package:capsula_del_tiempo_digital/core/storage/private_storage_service.dart';
import 'package:capsula_del_tiempo_digital/features/capsules/data/capsule_repository.dart';
import 'package:capsula_del_tiempo_digital/features/capsules/domain/capsule_models.dart';
import 'package:capsula_del_tiempo_digital/features/creation/draft_memory_preview_screen.dart';
import 'package:capsula_del_tiempo_digital/l10n/generated/app_localizations.dart';
import 'package:cryptography/cryptography.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Repository repository;
  late _Storage storage;
  late _Keys keys;
  late Directory temp;
  late _VideoPlatform video;
  late VideoPlayerPlatform previousVideo;
  late _AudioChannels audio;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('ctd_draft_preview_test_');
    final original = File('${temp.path}/original.ctdv');
    await original.writeAsString('encrypted original stays unchanged');
    final preview = File('${temp.path}/preview.png');
    await preview.writeAsBytes(
      base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jKlkAAAAASUVORK5CYII=',
      ),
    );
    repository = _Repository(original.path);
    storage = _Storage(preview);
    keys = _Keys();
    previousVideo = VideoPlayerPlatform.instance;
    video = _VideoPlatform();
    VideoPlayerPlatform.instance = video;
    audio = _AudioChannels()..install();
  });

  tearDown(() async {
    VideoPlayerPlatform.instance = previousVideo;
    audio.uninstall();
    await repository.db.close();
    // Only files in this test's freshly generated directory are removed.
    for (final entry in temp.listSync()) {
      await entry.delete();
    }
    await temp.delete();
  });

  Future<void> settleUntil(
    WidgetTester tester,
    bool Function() condition,
  ) async {
    for (var attempt = 0; attempt < 100; attempt++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump(const Duration(milliseconds: 50));
      if (condition()) return;
    }
    expect(
      condition(),
      isTrue,
      reason: 'Preview did not reach the expected state.',
    );
  }

  Future<void> show(WidgetTester tester, CapsuleItemType type) async {
    repository.type = type;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          capsuleRepositoryProvider.overrideWithValue(repository),
          storageProvider.overrideWithValue(storage),
          keyServiceProvider.overrideWithValue(keys),
          encryptionProvider.overrideWithValue(_ReadableEncryption()),
        ],
        child: MaterialApp(
          theme: buildAppTheme(),
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => const DraftMemoryPreviewScreen(
                      capsuleId: 'draft',
                      itemId: 'item',
                    ),
                  ),
                ),
                child: const Text('Editor'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editor'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
  }

  Future<void> close(WidgetTester tester) async {
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Editor'), findsOneWidget);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 40)),
    );
    await tester.pump();
  }

  testWidgets(
    'text preview displays the full body and title without changing the draft',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await show(tester, CapsuleItemType.text);
      await settleUntil(
        tester,
        () => find.byType(SelectableText).evaluate().isNotEmpty,
      );
      expect(find.text('Título privado'), findsOneWidget);
      final text = tester.widget<SelectableText>(find.byType(SelectableText));
      expect(text.data, contains('Final del texto completo.'));
      expect(text.maxLines, isNull);
      expect(find.text('Compartir'), findsNothing);
      expect(find.text('Guardar en el dispositivo'), findsNothing);
      expect(tester.takeException(), isNull);
      await close(tester);
      expect(repository.status, CapsuleStatus.draft);
      expect(repository.writes, 0);
      expect(storage.loads, 0);
    },
  );

  testWidgets(
    'photo preview supports zoom and removes only the temporary file on close',
    (tester) async {
      await show(tester, CapsuleItemType.image);
      await settleUntil(
        tester,
        () => find.byType(InteractiveViewer).evaluate().isNotEmpty,
      );
      final viewer = tester.widget<InteractiveViewer>(
        find.byType(InteractiveViewer),
      );
      expect(viewer.maxScale, greaterThan(1));
      expect(find.byType(Image), findsOneWidget);
      await close(tester);
      await settleUntil(tester, () => !storage.preview.existsSync());
      expect(
        File(repository.original).readAsStringSync(),
        'encrypted original stays unchanged',
      );
      expect(repository.writes, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'video starts paused, plays and is disposed when preview closes',
    (tester) async {
      await show(tester, CapsuleItemType.video);
      await settleUntil(
        tester,
        () => find.text('Video de prueba').evaluate().isNotEmpty,
      );
      expect(video.calls, isNot(contains('play')));
      await tester.ensureVisible(find.byTooltip('Reproducir'));
      await tester.tap(find.byTooltip('Reproducir'));
      await tester.pump();
      expect(video.calls, contains('play'));
      await tester.tap(find.byTooltip('Pausar'));
      await tester.pump();
      await tester.tap(find.byTooltip('Reproducir'));
      await tester.pump();
      await close(tester);
      await settleUntil(
        tester,
        () => video.calls.contains('dispose') && !storage.preview.existsSync(),
      );
      expect(video.calls.last, 'dispose');
      expect(repository.writes, 0);
    },
  );

  testWidgets('audio can play, pause and seek; closing releases the player', (
    tester,
  ) async {
    await show(tester, CapsuleItemType.audio);
    await settleUntil(
      tester,
      () => find.byTooltip('Reproducir').evaluate().isNotEmpty,
    );
    expect(audio.calls, contains('load'));
    expect(audio.calls, isNot(contains('play')));
    await tester.tap(find.byTooltip('Reproducir'));
    await settleUntil(tester, () => audio.calls.contains('play'));
    expect(find.byTooltip('Pausar'), findsOneWidget);
    await tester.tap(find.byTooltip('Pausar'));
    await settleUntil(tester, () => audio.calls.contains('pause'));
    await tester.tap(find.byType(Slider));
    await tester.pump();
    expect(audio.calls, contains('seek'));
    await tester.tap(find.byTooltip('Reproducir'));
    await tester.pump();
    await close(tester);
    await settleUntil(
      tester,
      () =>
          audio.calls.contains('disposePlayer') &&
          !storage.preview.existsSync(),
    );
    expect(tester.takeException(), isNull);
  });

  for (final status in [
    CapsuleStatus.sealed,
    CapsuleStatus.trashed,
    CapsuleStatus.opened,
  ]) {
    testWidgets('preview rejects $status before decrypting any content', (
      tester,
    ) async {
      repository.status = status;
      await show(tester, CapsuleItemType.text);
      await tester.pumpAndSettle();
      expect(
        find.text(
          'La vista previa solo está disponible antes de sellar la cápsula.',
        ),
        findsOneWidget,
      );
      expect(keys.calls, 0);
      expect(storage.loads, 0);
      expect(find.byType(SelectableText), findsNothing);
      await close(tester);
    });
  }

  testWidgets(
    'missing memory and decryption failure show errors instead of endless loading',
    (tester) async {
      repository.hasItem = false;
      await show(tester, CapsuleItemType.image);
      await tester.pumpAndSettle();
      expect(find.text('Reintentar'), findsOneWidget);
      expect(storage.loads, 0);
      repository.hasItem = true;
      storage.fail = true;
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();
      expect(find.text('Reintentar'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      storage.fail = false;
      await tester.tap(find.text('Reintentar'));
      await settleUntil(
        tester,
        () => find.byType(InteractiveViewer).evaluate().isNotEmpty,
      );
      await close(tester);
      await settleUntil(tester, () => !storage.preview.existsSync());
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('closing while decrypting cleans a late preview file', (
    tester,
  ) async {
    storage.gate = Completer<File>();
    await show(tester, CapsuleItemType.video);
    await settleUntil(tester, () => storage.loads == 1);
    await close(tester);
    storage.gate!.complete(storage.preview);
    await settleUntil(tester, () => !storage.preview.existsSync());
    expect(video.calls, isEmpty);
    expect(tester.takeException(), isNull);
  });
}

class _Keys extends KeyService {
  int calls = 0;
  @override
  Future<SecretKey> getOrCreateMasterKey() async {
    calls++;
    return SecretKey(List.filled(32, 1));
  }
}

class _ReadableEncryption extends EncryptionService {
  @override
  Future<String> decryptText(String encoded, SecretKey key) async =>
      encoded.substring(7);
}

class _Storage extends PrivateStorageService {
  _Storage(this.preview) : super(EncryptionService());
  final File preview;
  int loads = 0;
  bool fail = false;
  Completer<File>? gate;
  @override
  Future<File> decryptToTemporary(
    String encryptedPath,
    SecretKey key, {
    String extension = '',
  }) async {
    loads++;
    if (fail) throw StateError('Unreadable test file');
    return gate == null ? preview : await gate!.future;
  }
}

class _Repository extends CapsuleRepository {
  _Repository(this.original) : super(AppDatabase(NativeDatabase.memory()));
  final String original;
  CapsuleStatus status = CapsuleStatus.draft;
  CapsuleItemType type = CapsuleItemType.text;
  bool hasItem = true;
  int writes = 0;
  @override
  Future<Capsule> getCapsule(String id) async => Capsule(
    id: id,
    title: 'Mi borrador',
    categoryId: 'personal',
    coverId: 'cover_01',
    createdAt: DateTime(2026),
    unlockAt: DateTime(2040),
    unlockIncludesTime: true,
    persistedStatus: status,
  );
  @override
  Future<List<CapsuleItem>> getItems(String capsuleId) async => hasItem
      ? [
          CapsuleItem(
            id: 'item',
            capsuleId: capsuleId,
            type: type,
            encryptedText:
                'cipher:${'Texto largo del recuerdo. ' * 40}Final del texto completo.',
            textTitle: 'cipher:Título privado',
            encryptedPath: original,
            mimeType: type == CapsuleItemType.image
                ? 'image/png'
                : type == CapsuleItemType.audio
                ? 'audio/mp4'
                : 'video/mp4',
            createdAt: DateTime(2026),
            orderIndex: 0,
          ),
        ]
      : [];
  @override
  Future<void> updateDraft(Capsule capsule) async {
    writes++;
  }

  @override
  Future<void> seal(String id, DateTime now) async {
    writes++;
  }

  @override
  Future<void> markOpened(String id, DateTime now) async {
    writes++;
  }
}

class _VideoPlatform extends VideoPlayerPlatform {
  final calls = <String>[];
  final events = StreamController<VideoEvent>();
  @override
  Future<void> init() async {}
  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async {
    events.add(
      VideoEvent(
        eventType: VideoEventType.initialized,
        size: const Size(640, 360),
        duration: const Duration(seconds: 10),
      ),
    );
    return 1;
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) => events.stream;
  @override
  Future<void> dispose(int playerId) async {
    calls.add('dispose');
    await events.close();
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
  Future<void> seekTo(int playerId, Duration value) async {}
  @override
  Future<Duration> getPosition(int playerId) async => Duration.zero;
  @override
  Future<void> setLooping(int playerId, bool looping) async {}
  @override
  Future<void> setVolume(int playerId, double volume) async {}
  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {}
  @override
  Widget buildViewWithOptions(VideoViewOptions options) =>
      const Text('Video de prueba');
}

class _AudioChannels {
  final calls = <String>[];
  final channels = <MethodChannel>[];
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  void handle(String name, Future<Object?> Function(MethodCall) callback) {
    final channel = MethodChannel(name);
    channels.add(channel);
    messenger.setMockMethodCallHandler(channel, callback);
  }

  void install() {
    handle(
      'com.ryanheise.audio_session',
      (call) async => call.method == 'setActive' ? true : null,
    );
    handle('com.ryanheise.just_audio.methods', (call) async {
      calls.add(call.method);
      if (call.method == 'init') {
        final id = (call.arguments as Map)['id'] as String;
        handle('com.ryanheise.just_audio.events.$id', (call) async => null);
        handle('com.ryanheise.just_audio.data.$id', (call) async => null);
        handle('com.ryanheise.just_audio.methods.$id', (call) async {
          calls.add(call.method);
          if (call.method == 'load') {
            messenger.handlePlatformMessage(
              'com.ryanheise.just_audio.events.$id',
              const StandardMethodCodec().encodeSuccessEnvelope({
                'processingState': 3,
                'updateTime': DateTime.now().millisecondsSinceEpoch,
                'updatePosition': 0,
                'bufferedPosition': 10000000,
                'duration': 10000000,
                'currentIndex': 0,
              }),
              (_) {},
            );
            return {'duration': 10000000};
          }
          return <String, Object?>{};
        });
      }
      return <String, Object?>{};
    });
  }

  void uninstall() {
    for (final channel in channels) {
      messenger.setMockMethodCallHandler(channel, null);
    }
  }
}
