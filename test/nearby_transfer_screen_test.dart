import 'dart:convert';

import 'package:capsula_del_tiempo_digital/app/providers.dart';
import 'package:capsula_del_tiempo_digital/core/transfer/capsule_transfer_service.dart';
import 'package:capsula_del_tiempo_digital/core/transfer/nearby_transport.dart';
import 'package:capsula_del_tiempo_digital/features/transfer/nearby_transfer_screen.dart';
import 'package:capsula_del_tiempo_digital/l10n/generated/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <MethodCall>[];
  const methods = MethodChannel('ctd/nearby');
  const events = MethodChannel('ctd/nearby/events');

  setUp(() {
    calls.clear();
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(methods, (
      call,
    ) async {
      calls.add(call);
      return null;
    });
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      events,
      (_) async => null,
    );
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(methods, null);
    binding.defaultBinaryMessenger.setMockMethodCallHandler(events, null);
  });

  Future<void> showScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [capsulesProvider.overrideWith((ref) => Stream.value([]))],
        child: const MaterialApp(
          locale: Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: NearbyTransferScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> emit(WidgetTester tester, Map<String, dynamic> event) async {
    await binding.defaultBinaryMessenger.handlePlatformMessage(
      'ctd/nearby/events',
      const StandardMethodCodec().encodeSuccessEnvelope(event),
      (_) {},
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> startReceiver(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      find.text('Recibir cápsula'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Recibir cápsula'));
    await tester.pump();
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    debugDefaultTargetPlatformOverride = null;
  }

  testWidgets(
    'nearby is explained on unsupported platforms without invoking native methods',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await showScreen(tester);
      expect(NearbyTransport.supported, isFalse);
      expect(find.textContaining('Google Play'), findsOneWidget);
      expect(find.text('Exportación y copias actuales'), findsOneWidget);
      expect(calls, isEmpty);
      await finish(tester);
      expect(calls, isEmpty);
    },
  );

  testWidgets(
    'pairing requires explicit code confirmation and rejection never accepts',
    (tester) async {
      tester.view.physicalSize = const Size(320, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await showScreen(tester);
      await startReceiver(tester);
      await emit(tester, {
        'type': 'pairing',
        'name': 'Otro móvil',
        'code': '1234',
      });
      expect(find.text('1234'), findsOneWidget);
      expect(calls.where((c) => c.method == 'accept'), isEmpty);
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Cancelar'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(calls.where((c) => c.method == 'reject'), hasLength(1));
      expect(
        calls.where((c) => c.method == 'accept' || c.method == 'receiveStream'),
        isEmpty,
      );
      expect(tester.takeException(), isNull);
      await finish(tester);
    },
  );

  testWidgets(
    'receiver accepts content separately; disconnect removes the progress state',
    (tester) async {
      await showScreen(tester);
      await startReceiver(tester);
      await emit(tester, {'type': 'pairing', 'name': 'Amigo', 'code': '5678'});
      await tester.tap(find.text('El código coincide'));
      await tester.pump();
      expect(calls.where((c) => c.method == 'accept'), hasLength(1));
      await emit(tester, {'type': 'connected'});
      final offer = CapsuleTransferOffer(
        transferId: 'transfer1',
        title: 'Nuestra carta',
        size: 100,
        digest: 'a' * 64,
        key: base64Encode(List.filled(32, 1)),
        unlockAt: DateTime.utc(2035),
      );
      await emit(tester, {
        'type': 'message',
        'message': jsonEncode(offer.toJson()),
      });
      expect(find.text('Nuestra carta'), findsOneWidget);
      expect(calls.where((c) => c.method == 'receiveStream'), isEmpty);
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Recibir cápsula'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      final arm = calls.indexWhere((c) => c.method == 'receiveStream');
      final ready = calls.indexWhere(
        (c) =>
            c.method == 'message' &&
            (c.arguments['message'] as String).contains('ready'),
      );
      expect(arm, greaterThanOrEqualTo(0));
      expect(ready, greaterThan(arm));
      await emit(tester, {'type': 'disconnected'});
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(
        find.textContaining('La conexión se ha interrumpido'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await finish(tester);
    },
  );

  testWidgets('connection failure dismisses a pending pairing dialog', (
    tester,
  ) async {
    await showScreen(tester);
    await startReceiver(tester);
    await emit(tester, {'type': 'pairing', 'name': 'Amigo', 'code': '5678'});
    await emit(tester, {'type': 'error', 'code': 'CONNECTION'});
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
    await finish(tester);
  });
}
