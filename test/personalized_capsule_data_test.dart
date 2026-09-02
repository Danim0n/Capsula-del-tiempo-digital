import 'dart:io';

import 'package:capsula_del_tiempo_digital/core/database/app_database.dart';
import 'package:capsula_del_tiempo_digital/features/capsules/data/capsule_repository.dart';
import 'package:capsula_del_tiempo_digital/features/capsules/domain/capsule_models.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('v1 migration keeps capsules and assigns the standard kind', () async {
    final directory = await Directory.systemTemp.createTemp(
      'ctd_migration_test_',
    );
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/library.sqlite');
    final original = AppDatabase(NativeDatabase(file));
    final repository = CapsuleRepository(original);
    final capsule = await repository.createDraft(title: 'Mi cápsula existente');
    await repository.addItem(
      CapsuleItem(
        id: 'old-text',
        capsuleId: capsule.id,
        type: CapsuleItemType.text,
        encryptedText: 'old-ciphertext',
        createdAt: DateTime.now(),
        orderIndex: 0,
      ),
    );
    // v1 is exactly the current schema without capsule_rows.kind.
    await original.customStatement('ALTER TABLE capsule_rows DROP COLUMN kind');
    await original.customStatement('PRAGMA user_version = 1');
    await original.close();

    final upgraded = AppDatabase(NativeDatabase(file));
    addTearDown(upgraded.close);
    final after = CapsuleRepository(upgraded);
    expect((await after.getCapsule(capsule.id)).kind, CapsuleKind.standard);
    expect((await after.getCapsule(capsule.id)).title, 'Mi cápsula existente');
    expect(
      (await after.getItems(capsule.id)).single.encryptedText,
      'old-ciphertext',
    );
    final custom = await after.createDraft(kind: CapsuleKind.personalized);
    expect((await after.getCapsule(custom.id)).kind, CapsuleKind.personalized);
  });

  test(
    'backup restores personalized type and ordered items, legacy backups remain standard',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      final repository = CapsuleRepository(database);
      final draft = await repository.createDraft(
        title: 'Nuestra historia',
        kind: CapsuleKind.personalized,
      );
      for (final index in [2, 0, 4]) {
        await repository.addItem(
          CapsuleItem(
            id: 'item-$index',
            capsuleId: draft.id,
            type: CapsuleItemType.text,
            encryptedText: 'cipher-$index',
            createdAt: DateTime.now(),
            orderIndex: index,
          ),
        );
      }
      await repository.seal(draft.id, DateTime.now());
      final backup = await repository.exportData();
      await database.close();
      final restoredDb = AppDatabase(NativeDatabase.memory());
      addTearDown(restoredDb.close);
      final restored = CapsuleRepository(restoredDb);
      await restored.replaceFromJson(backup);
      final capsule = await restored.getCapsule(draft.id);
      expect(capsule.kind, CapsuleKind.personalized);
      expect(
        capsule.copyWith(title: 'anything').kind,
        CapsuleKind.personalized,
      );
      expect((await restored.getItems(draft.id)).map((item) => item.id), [
        'item-0',
        'item-2',
        'item-4',
      ]);
      await expectLater(
        restored.updateDraft(capsule),
        throwsA(isA<CapsuleLockedException>()),
      );
      for (final raw in backup['capsules'] as List) {
        (raw as Map).remove('kind');
      }
      await restored.replaceFromJson(backup);
      expect((await restored.getCapsule(draft.id)).kind, CapsuleKind.standard);
    },
  );
}
