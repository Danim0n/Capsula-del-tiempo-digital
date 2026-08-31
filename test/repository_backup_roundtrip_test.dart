import 'package:capsula_del_tiempo_digital/core/database/app_database.dart';
import 'package:capsula_del_tiempo_digital/features/capsules/data/capsule_repository.dart';
import 'package:capsula_del_tiempo_digital/features/capsules/domain/capsule_models.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'database backup export restores capsules, categories and items',
    () async {
      final sourceDatabase = AppDatabase(NativeDatabase.memory());
      final source = CapsuleRepository(sourceDatabase);
      final draft = await source.createDraft(
        title: 'Para mi yo del futuro',
        unlockAt: DateTime.now().add(const Duration(days: 365)),
      );
      await source.addItem(
        CapsuleItem(
          id: 'text-item',
          capsuleId: draft.id,
          type: CapsuleItemType.text,
          encryptedText: 'authenticated-ciphertext',
          textTitle: 'Carta',
          createdAt: DateTime.now(),
          orderIndex: 0,
        ),
      );
      await source.seal(draft.id, DateTime.now());

      final manifest = await source.exportData();
      await sourceDatabase.close();
      final restoredDatabase = AppDatabase(NativeDatabase.memory());
      addTearDown(restoredDatabase.close);
      final restored = CapsuleRepository(restoredDatabase);
      await restored.replaceFromJson(manifest);

      final capsule = await restored.getCapsule(draft.id);
      final items = await restored.getItems(draft.id);
      final categories = await restored.getCategories();
      expect(capsule.title, 'Para mi yo del futuro');
      expect(capsule.persistedStatus, CapsuleStatus.sealed);
      expect(items.single.encryptedText, 'authenticated-ciphertext');
      expect(categories, hasLength(8));
    },
  );
}
