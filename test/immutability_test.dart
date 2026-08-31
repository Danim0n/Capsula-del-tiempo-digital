import 'package:capsula_del_tiempo_digital/core/database/app_database.dart';
import 'package:capsula_del_tiempo_digital/features/capsules/data/capsule_repository.dart';
import 'package:capsula_del_tiempo_digital/features/capsules/domain/capsule_models.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late CapsuleRepository repository;
  late Capsule sealed;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = CapsuleRepository(database);
    final draft = await repository.createDraft(
      title: 'Locked',
      unlockAt: DateTime.now().add(const Duration(days: 20)),
    );
    await repository.addItem(
      CapsuleItem(
        id: 'item-1',
        capsuleId: draft.id,
        type: CapsuleItemType.text,
        encryptedText: 'encrypted',
        createdAt: DateTime.now(),
        orderIndex: 0,
      ),
    );
    await repository.seal(draft.id, DateTime.now());
    sealed = await repository.getCapsule(draft.id);
  });

  tearDown(() => database.close());

  test('adding content after sealing fails', () async {
    await expectLater(
      repository.addItem(
        CapsuleItem(
          id: 'item-2',
          capsuleId: sealed.id,
          type: CapsuleItemType.text,
          encryptedText: 'encrypted',
          createdAt: DateTime.now(),
          orderIndex: 1,
        ),
      ),
      throwsA(isA<CapsuleLockedException>()),
    );
  });

  test('removing content after sealing fails', () async {
    await expectLater(
      repository.removeItem(sealed.id, 'item-1'),
      throwsA(isA<CapsuleLockedException>()),
    );
  });

  test('changing opening date after sealing fails', () async {
    await expectLater(
      repository.updateDraft(
        sealed.copyWith(unlockAt: sealed.unlockAt.add(const Duration(days: 1))),
      ),
      throwsA(isA<CapsuleLockedException>()),
    );
  });

  test('changing title after sealing fails', () async {
    await expectLater(
      repository.updateDraft(sealed.copyWith(title: 'Changed')),
      throwsA(isA<CapsuleLockedException>()),
    );
  });
}
