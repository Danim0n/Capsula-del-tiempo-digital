import 'package:capsula_del_tiempo_digital/app/providers.dart';
import 'package:capsula_del_tiempo_digital/app/router.dart';
import 'package:capsula_del_tiempo_digital/app/theme/app_theme.dart';
import 'package:capsula_del_tiempo_digital/core/database/app_database.dart';
import 'package:capsula_del_tiempo_digital/core/encryption/key_service.dart';
import 'package:capsula_del_tiempo_digital/core/settings/app_preferences.dart';
import 'package:capsula_del_tiempo_digital/features/capsules/data/capsule_repository.dart';
import 'package:capsula_del_tiempo_digital/features/capsules/domain/capsule_models.dart';
import 'package:capsula_del_tiempo_digital/features/creation/creation_mode_screen.dart';
import 'package:capsula_del_tiempo_digital/features/creation/creation_screen.dart';
import 'package:capsula_del_tiempo_digital/features/creation/draft_memory_preview_screen.dart';
import 'package:capsula_del_tiempo_digital/l10n/generated/app_localizations.dart';
import 'package:cryptography/cryptography.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late _MemoryRepository repository;
  late AppPreferencesController preferences;
  GoRouter? router;
  setUp(() async {
    SharedPreferences.setMockInitialValues({'tutorialComplete': true});
    preferences = await AppPreferencesController.load();
    repository = _MemoryRepository();
  });
  tearDown(() async {
    router?.dispose();
    router = null;
    await repository.db.close();
  });

  Future<void> show(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          capsuleRepositoryProvider.overrideWithValue(repository),
          keyServiceProvider.overrideWithValue(_FixedKeyService()),
          appPreferencesProvider.overrideWith((ref) => preferences),
          capsulesProvider.overrideWith((ref) => Stream.value([])),
          categoriesProvider.overrideWith(
            (ref) => Stream.value(const [
              CapsuleCategory(
                id: 'personal',
                name: 'Personal',
                isDefault: true,
              ),
            ]),
          ),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            router ??= buildRouter(ref);
            return MaterialApp.router(
              routerConfig: router,
              theme: buildAppTheme(),
              locale: const Locale('es'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    router!.go('/create');
    await tester.pumpAndSettle();
  }

  Future<void> addText(WidgetTester tester, String text) async {
    final expectedCount = repository.items.length + 1;
    if (repository.draft!.kind == CapsuleKind.standard) {
      await tester.tap(find.text('Añadir texto'));
    } else {
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('sequence-add')),
        180,
        scrollable: find
            .descendant(
              of: find.byKey(const ValueKey('sequence-builder')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(find.byKey(const ValueKey('sequence-add')));
      await tester.pumpAndSettle();
      for (final label in ['Foto', 'Audio', 'Texto', 'Vídeo']) {
        expect(find.text(label), findsWidgets);
      }
      await tester.tap(find.widgetWithText(ListTile, 'Texto'));
    }
    await tester.pumpAndSettle();
    final fields = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(fields.at(0), 'Título $text');
    await tester.enterText(fields.at(1), text);
    await tester.pump();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Guardar'),
      ),
    );
    await tester.pump();
    await tester.runAsync(() async {
      for (
        var attempt = 0;
        attempt < 100 && repository.items.length < expectedCount;
        attempt++
      ) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
    });
    await tester.pumpAndSettle();
    expect(repository.items.length, expectedCount);
  }

  testWidgets(
    'create offers both kinds; standard and quick actions retain the original editor',
    (tester) async {
      await show(tester);
      expect(find.byType(CreationModeScreen), findsOneWidget);
      expect(find.text('Cápsula del tiempo'), findsOneWidget);
      expect(find.text('Cápsula del tiempo personalizada'), findsOneWidget);
      expect(repository.draft, isNull);
      await tester.tap(find.byKey(const ValueKey('create-standard')));
      await tester.pumpAndSettle();
      expect(
        tester.widget<CreationScreen>(find.byType(CreationScreen)).kind,
        CapsuleKind.standard,
      );
      expect(find.byKey(const ValueKey('sequence-add')), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'personalized plus appends text, deletion never changes the order of later additions',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await show(tester);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('create-personalized')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const ValueKey('create-personalized')));
      await tester.pumpAndSettle();
      expect(repository.draft!.kind, CapsuleKind.personalized);
      expect(find.byKey(const ValueKey('sequence-add')), findsOneWidget);
      await addText(tester, 'Primero');
      await addText(tester, 'Segundo');
      await addText(tester, 'Tercero');
      expect(repository.items.map((item) => item.orderIndex), [0, 1, 2]);
      final second = repository.items[1];
      final card = find.byKey(ValueKey(second.id));
      await tester.scrollUntilVisible(
        card,
        -200,
        scrollable: find
            .descendant(
              of: find.byKey(const ValueKey('sequence-builder')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(
        find.descendant(of: card, matching: find.byType(IconButton)),
      );
      await tester.pumpAndSettle();
      await addText(tester, 'Cuarto');
      expect(repository.items.map((item) => item.orderIndex), [0, 2, 3]);
      await tester.tap(find.text('Continuar con los detalles'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsWidgets);
      final title = find.widgetWithText(TextField, 'Título');
      await tester.enterText(title, 'Mi historia');
      await tester.enterText(
        find.widgetWithText(TextField, 'Descripción (opcional)'),
        'Una cápsula en capítulos',
      );
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
      expect(repository.draft!.title, 'Mi historia');
      expect(repository.draft!.description, 'Una cápsula en capítulos');
      expect(repository.draft!.kind, CapsuleKind.personalized);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sellar cápsula'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sellar para el futuro'));
      await tester.pumpAndSettle();
      expect(repository.draft!.persistedStatus, CapsuleStatus.sealed);
      expect(repository.draft!.kind, CapsuleKind.personalized);
      expect(find.byType(CreationScreen), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );

  for (final kind in CapsuleKind.values) {
    testWidgets(
      '$kind previews from content and final review preserve the editor',
      (tester) async {
        await show(tester);
        router!.go('/create?mode=${kind.name}');
        await tester.pumpAndSettle();
        await addText(tester, 'El contenido completo de mi recuerdo');
        final item = repository.items.single;
        final contentCard = find.byKey(
          ValueKey(
            kind == CapsuleKind.personalized
                ? item.id
                : 'draft-item-${item.id}',
          ),
        );
        if (kind == CapsuleKind.standard) {
          await tester.scrollUntilVisible(
            contentCard,
            180,
            scrollable: find
                .descendant(
                  of: find.byKey(const ValueKey('standard-content')),
                  matching: find.byType(Scrollable),
                )
                .first,
          );
        }
        final contentTap = find.descendant(
          of: contentCard,
          matching: kind == CapsuleKind.personalized
              ? find.byType(TextButton)
              : find.byType(ListTile),
        );
        await tester.ensureVisible(contentTap);
        await tester.tap(contentTap);
        await tester.pump();
        for (
          var attempt = 0;
          attempt < 100 && find.byType(SelectableText).evaluate().isEmpty;
          attempt++
        ) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 20)),
          );
          await tester.pump(const Duration(milliseconds: 50));
        }
        expect(find.byType(DraftMemoryPreviewScreen), findsOneWidget);
        expect(find.byType(SelectableText), findsOneWidget);
        expect(
          tester.widget<SelectableText>(find.byType(SelectableText)).data,
          'El contenido completo de mi recuerdo',
        );
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        expect(find.byType(CreationScreen), findsOneWidget);
        expect(repository.items.single.id, item.id);
        await tester.tap(
          find.text(
            kind == CapsuleKind.personalized
                ? 'Continuar con los detalles'
                : 'Siguiente',
          ),
        );
        await tester.pumpAndSettle();
        await tester.enterText(
          find.widgetWithText(TextField, 'Título'),
          'Título que se conserva',
        );
        await tester.tap(find.text('Siguiente'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Siguiente'));
        await tester.pumpAndSettle();
        final reviewCard = find.byKey(ValueKey('review-item-${item.id}'));
        await tester.scrollUntilVisible(
          reviewCard,
          200,
          scrollable: find.byType(Scrollable).last,
        );
        await tester.tap(
          find.descendant(of: reviewCard, matching: find.byType(ListTile)),
        );
        await tester.pump();
        for (
          var attempt = 0;
          attempt < 100 && find.byType(SelectableText).evaluate().isEmpty;
          attempt++
        ) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 20)),
          );
          await tester.pump(const Duration(milliseconds: 50));
        }
        expect(find.byType(SelectableText), findsOneWidget);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.text('Sellar cápsula'), findsOneWidget);
        expect(repository.draft!.title, 'Título que se conserva');
        expect(repository.draft!.persistedStatus, CapsuleStatus.draft);
        expect(repository.items.single.id, item.id);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      },
    );
  }
}

class _FixedKeyService extends KeyService {
  @override
  Future<SecretKey> getOrCreateMasterKey() async =>
      SecretKey(List.filled(32, 1));
}

class _MemoryRepository extends CapsuleRepository {
  _MemoryRepository() : super(AppDatabase(NativeDatabase.memory()));
  Capsule? draft;
  final items = <CapsuleItem>[];
  @override
  Future<List<CapsuleItem>> getItems(String capsuleId) async => List.of(items);
  @override
  Future<Capsule> createDraft({
    CapsuleKind kind = CapsuleKind.standard,
    String title = '',
    String categoryId = 'personal',
    String coverId = 'cover_01',
    DateTime? unlockAt,
  }) async {
    return draft = Capsule(
      id: 'draft',
      kind: kind,
      title: title,
      categoryId: categoryId,
      coverId: coverId,
      createdAt: DateTime.now(),
      unlockAt: unlockAt ?? DateTime(2030),
      unlockIncludesTime: false,
      persistedStatus: CapsuleStatus.draft,
    );
  }

  @override
  Future<void> addItem(CapsuleItem item) async {
    items.add(item);
  }

  @override
  Future<void> removeItem(String capsuleId, String itemId) async {
    items.removeWhere((item) => item.id == itemId);
  }

  @override
  Future<void> updateDraft(Capsule capsule) async {
    draft = capsule;
  }

  @override
  Future<void> seal(String id, DateTime now) async {
    draft = draft!.copyWith(
      persistedStatus: CapsuleStatus.sealed,
      sealedAt: now,
    );
  }

  @override
  Future<Capsule> getCapsule(String id) async =>
      draft!.copyWith(itemCount: items.length);
}
