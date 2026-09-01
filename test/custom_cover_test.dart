import 'package:capsula_del_tiempo_digital/core/database/app_database.dart';
import 'package:capsula_del_tiempo_digital/core/storage/custom_cover_id.dart';
import 'package:capsula_del_tiempo_digital/features/capsules/data/capsule_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('custom cover ids preserve their encrypted path', () {
    const path = r'C:\private\vault\cover.ctdv';

    expect(customCoverPath(customCoverId(path)), path);
    expect(customCoverPath('cover_01'), isNull);
  });

  test(
    'discarding a draft also returns its custom cover for deletion',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = CapsuleRepository(database);
      const path = r'C:\private\vault\cover.ctdv';
      final draft = await repository.createDraft(coverId: customCoverId(path));

      final encryptedPaths = await repository.discardDraft(draft.id);

      expect(encryptedPaths, [path]);
    },
  );
}
