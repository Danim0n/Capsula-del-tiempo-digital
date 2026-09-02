import 'package:capsula_del_tiempo_digital/features/capsules/domain/capsule_models.dart';
import 'package:capsula_del_tiempo_digital/features/capsules/presentation/capsule_sequence_viewer.dart';
import 'package:capsula_del_tiempo_digital/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'sequence shows one memory in insertion order and disposes it on Continue',
    (tester) async {
      final disposed = <String>[];
      var finished = false;
      final items = [
        for (final type in [
          CapsuleItemType.video,
          CapsuleItemType.text,
          CapsuleItemType.image,
          CapsuleItemType.audio,
        ])
          CapsuleItem(
            id: type.name,
            capsuleId: 'capsule',
            type: type,
            createdAt: DateTime(2026),
            orderIndex: type.index,
          ),
      ];
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: CapsuleSequenceViewer(
              items: items,
              description: 'Nuestra historia',
              onFinished: () => finished = true,
              itemBuilder: (item, index) =>
                  _TrackedMemory(id: item.id, onDispose: disposed.add),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('memory-video'), findsOneWidget);
      expect(find.text('memory-text'), findsNothing);
      expect(find.text('Nuestra historia'), findsOneWidget);
      expect(
        tester
            .widget<IconButton>(find.byKey(const ValueKey('sequence-previous')))
            .onPressed,
        isNull,
      );
      for (var index = 1; index < items.length; index++) {
        await tester.tap(find.byKey(const ValueKey('sequence-continue')));
        await tester.pumpAndSettle();
        expect(find.text('memory-${items[index].id}'), findsOneWidget);
        expect(disposed, contains(items[index - 1].id));
        expect(find.text('${index + 1} de 4'), findsOneWidget);
      }
      await tester.tap(find.byKey(const ValueKey('sequence-previous')));
      await tester.pumpAndSettle();
      expect(find.text('memory-image'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('sequence-continue')));
      await tester.pumpAndSettle();
      expect(find.text('Finalizar'), findsOneWidget);
      await tester.tap(find.text('Finalizar'));
      expect(finished, isTrue);
    },
  );

  testWidgets(
    'empty sequence and large text on a small screen do not overflow',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
              child: CapsuleSequenceViewer(
                items: [
                  CapsuleItem(
                    id: '1',
                    capsuleId: 'c',
                    type: CapsuleItemType.text,
                    createdAt: DateTime(2026),
                    orderIndex: 0,
                  ),
                ],
                onFinished: () {},
                itemBuilder: (_, __) => Text('Un recuerdo largo. ' * 200),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Finalizar'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

class _TrackedMemory extends StatefulWidget {
  const _TrackedMemory({required this.id, required this.onDispose});
  final String id;
  final ValueChanged<String> onDispose;
  @override
  State<_TrackedMemory> createState() => _TrackedMemoryState();
}

class _TrackedMemoryState extends State<_TrackedMemory> {
  @override
  void dispose() {
    widget.onDispose(widget.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Text('memory-${widget.id}');
}
