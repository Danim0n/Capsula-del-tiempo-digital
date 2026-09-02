import 'dart:async';

import 'package:capsula_del_tiempo_digital/app/theme/app_theme.dart';
import 'package:capsula_del_tiempo_digital/features/creation/audio_recording_dialog.dart';
import 'package:capsula_del_tiempo_digital/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:record/record.dart';

void main() {
  late _FakeRecorder recorder;
  late DateTime now;
  late int factories;
  String? result;
  bool completed = false;

  setUp(() {
    recorder = _FakeRecorder();
    now = DateTime(2026, 9, 2, 12);
    factories = 0;
    result = null;
    completed = false;
  });

  Future<void> show(WidgetTester tester, {double textScale = 1}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showDialog<String>(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => AudioRecordingDialog(
                    recorderFactory: () {
                      factories++;
                      return recorder;
                    },
                    pathFactory: () async => 'test-only-recording.m4a',
                    now: () => now,
                  ),
                );
                completed = true;
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  IconButton button(WidgetTester tester, String name) =>
      tester.widget(find.byKey(ValueKey('recording-$name')));

  Future<void> tap(WidgetTester tester, String name) async {
    await tester.tap(find.byKey(ValueKey('recording-$name')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  RecordingWaveform waveform(WidgetTester tester) =>
      tester.widget(find.byType(RecordingWaveform));

  Future<void> remove(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
  }

  testWidgets(
    'starts idle without microphone permission; close saves nothing',
    (tester) async {
      await show(tester);
      expect(factories, 0);
      expect(recorder.calls, isEmpty);
      expect(find.text('Listo para empezar'), findsOneWidget);
      expect(find.text('00:00'), findsOneWidget);
      expect(button(tester, 'pause').onPressed, isNull);
      expect(button(tester, 'stop').onPressed, isNull);
      expect(button(tester, 'start').onPressed, isNotNull);
      expect(waveform(tester).samples, isEmpty);
      expect(waveform(tester).active, isFalse);
      await tester.tap(find.byTooltip('Cancelar'));
      await tester.pumpAndSettle();
      expect(completed, isTrue);
      expect(result, isNull);
      expect(factories, 0);
      await remove(tester);
    },
  );

  testWidgets(
    'real levels, pause and resume keep one file and exclude paused time',
    (tester) async {
      await show(tester);
      await tap(tester, 'start');
      expect(recorder.calls.where((c) => c == 'start'), hasLength(1));
      expect(find.text('Grabando…'), findsOneWidget);
      expect(button(tester, 'start').onPressed, isNull);
      expect(button(tester, 'pause').onPressed, isNotNull);
      expect(button(tester, 'stop').onPressed, isNotNull);
      recorder.level(-60);
      recorder.level(-30);
      recorder.level(0);
      await tester.pump();
      expect(waveform(tester).samples, [0.0, .5, 1.0]);
      now = now.add(const Duration(seconds: 5));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('00:05'), findsOneWidget);
      await tap(tester, 'pause');
      expect(find.text('Grabación en pausa'), findsOneWidget);
      expect(button(tester, 'pause').onPressed, isNull);
      expect(button(tester, 'start').tooltip, 'Continuar grabación');
      expect(waveform(tester).active, isFalse);
      now = now.add(const Duration(minutes: 2));
      recorder.level(-10);
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('00:05'), findsOneWidget);
      expect(waveform(tester).samples, [0.0, .5, 1.0]);
      await tap(tester, 'start');
      now = now.add(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('00:08'), findsOneWidget);
      expect(recorder.calls.where((c) => c == 'start'), hasLength(1));
      expect(recorder.calls.where((c) => c == 'resume'), hasLength(1));
      await tap(tester, 'stop');
      await tester.pumpAndSettle();
      expect(completed, isTrue);
      expect(result, 'test-only-recording.m4a');
      await remove(tester);
      expect(recorder.calls, contains('dispose'));
      expect(recorder.calls, isNot(contains('cancel')));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'waveform is bounded, clamps invalid levels and stops while paused',
    (tester) async {
      await show(tester);
      await tap(tester, 'start');
      for (var i = 0; i < 100; i++) {
        recorder.level(-20);
      }
      recorder.level(double.negativeInfinity);
      recorder.level(double.nan);
      recorder.level(-120);
      recorder.level(10);
      await tester.pump();
      final levels = waveform(tester).samples;
      expect(levels, hasLength(64));
      expect(levels.sublist(60), [0, 0, 0, 1]);
      expect(levels.every((n) => n.isFinite && n >= 0 && n <= 1), isTrue);
      await tap(tester, 'pause');
      await tap(tester, 'stop');
      await tester.pumpAndSettle();
      expect(result, 'test-only-recording.m4a');
      await remove(tester);
    },
  );

  testWidgets(
    'back pauses, confirms discard and does not silently save audio',
    (tester) async {
      await show(tester);
      await tap(tester, 'start');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('¿Descartar esta grabación?'), findsOneWidget);
      expect(recorder.calls, contains('pause'));
      await tester.tap(find.widgetWithText(TextButton, 'Cancelar'));
      await tester.pumpAndSettle();
      expect(completed, isFalse);
      expect(find.text('Grabación en pausa'), findsOneWidget);
      expect(recorder.calls, isNot(contains('resume')));
      await tester.tap(find.byTooltip('Cancelar'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
      await tester.pumpAndSettle();
      expect(completed, isTrue);
      expect(result, isNull);
      await remove(tester);
      expect(recorder.calls, containsAllInOrder(['cancel', 'dispose']));
      expect(recorder.calls, isNot(contains('stop')));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('denied permission is explained and can be retried', (
    tester,
  ) async {
    recorder.permitted = false;
    await show(tester);
    await tap(tester, 'start');
    expect(
      find.textContaining('Permite el acceso al micrófono'),
      findsOneWidget,
    );
    expect(recorder.calls, isNot(contains('start')));
    expect(button(tester, 'start').onPressed, isNotNull);
    recorder.permitted = true;
    await tap(tester, 'start');
    expect(find.text('Grabando…'), findsOneWidget);
    await tap(tester, 'stop');
    await tester.pumpAndSettle();
    await remove(tester);
  });

  testWidgets(
    'failed controls preserve usable state; failed stop does not save',
    (tester) async {
      await show(tester);
      recorder.failAction = 'start';
      await tap(tester, 'start');
      expect(find.textContaining('No se ha podido completar'), findsOneWidget);
      expect(button(tester, 'start').onPressed, isNotNull);
      recorder.failAction = null;
      await tap(tester, 'start');
      recorder.failAction = 'pause';
      await tap(tester, 'pause');
      expect(find.text('Grabando…'), findsOneWidget);
      expect(button(tester, 'stop').onPressed, isNotNull);
      recorder.failAction = null;
      await tap(tester, 'pause');
      recorder.failAction = 'resume';
      await tap(tester, 'start');
      expect(find.text('Grabación en pausa'), findsOneWidget);
      recorder.failAction = 'stop';
      await tap(tester, 'stop');
      expect(completed, isFalse);
      expect(button(tester, 'stop').onPressed, isNotNull);
      recorder.failAction = null;
      await tap(tester, 'stop');
      await tester.pumpAndSettle();
      expect(completed, isTrue);
      expect(result, isNotNull);
      await remove(tester);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'app background and native interruption pause without auto-resume',
    (tester) async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await show(tester);
      await tap(tester, 'start');
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(find.text('Grabación en pausa'), findsOneWidget);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(find.text('Grabación en pausa'), findsOneWidget);
      expect(recorder.calls, isNot(contains('resume')));
      await tap(tester, 'start');
      recorder.states.add(RecordState.pause);
      await tester.pump();
      expect(find.text('Grabación en pausa'), findsOneWidget);
      expect(button(tester, 'start').onPressed, isNotNull);
      await tap(tester, 'stop');
      await tester.pumpAndSettle();
      await remove(tester);
    },
  );

  testWidgets(
    'pending start blocks duplicate taps and disposes after completion',
    (tester) async {
      recorder.startGate = Completer<void>();
      await show(tester);
      await tap(tester, 'start');
      await tap(tester, 'start');
      expect(recorder.calls.where((c) => c == 'start'), hasLength(1));
      expect(button(tester, 'stop').onPressed, isNull);
      await tester.pumpWidget(const SizedBox());
      expect(recorder.calls, isNot(contains('dispose')));
      recorder.startGate!.complete();
      await tester.pump();
      await remove(tester);
      expect(
        recorder.calls,
        containsAllInOrder(['start', 'cancel', 'dispose']),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'small screen and large text have no overflow and all controls fit',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await show(tester, textScale: 1.6);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.byKey(const ValueKey('recording-start')));
      await tap(tester, 'start');
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.byKey(const ValueKey('recording-stop')));
      await tap(tester, 'stop');
      await tester.pumpAndSettle();
      await remove(tester);
    },
  );
}

class _FakeRecorder implements AudioRecorder {
  final calls = <String>[];
  final amplitudes = StreamController<Amplitude>.broadcast(sync: true);
  final states = StreamController<RecordState>.broadcast(sync: true);
  bool permitted = true;
  String? failAction;
  String? path;
  Completer<void>? startGate;

  void level(double current) =>
      amplitudes.add(Amplitude(current: current, max: 0));
  void check(String action) {
    calls.add(action);
    if (failAction == action) throw StateError('Test $action failure');
  }

  @override
  Future<bool> hasPermission({bool request = true}) async {
    check('permission');
    return permitted;
  }

  @override
  Future<void> start(RecordConfig config, {required String path}) async {
    check('start');
    this.path = path;
    await startGate?.future;
    states.add(RecordState.record);
  }

  @override
  Future<void> pause() async {
    check('pause');
    states.add(RecordState.pause);
  }

  @override
  Future<void> resume() async {
    check('resume');
    states.add(RecordState.record);
  }

  @override
  Future<String?> stop() async {
    check('stop');
    states.add(RecordState.stop);
    return path;
  }

  @override
  Future<void> cancel() async => check('cancel');

  @override
  Future<void> dispose() async {
    check('dispose');
    await amplitudes.close();
    await states.close();
  }

  @override
  Stream<Amplitude> onAmplitudeChanged(Duration interval) => amplitudes.stream;

  @override
  Stream<RecordState> onStateChanged() => states.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
