import 'package:capsula_del_tiempo_digital/core/database/app_database.dart';
import 'package:capsula_del_tiempo_digital/features/capsules/data/capsule_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late CapsuleRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = CapsuleRepository(database);
  });

  tearDown(() => database.close());

  test('custom category is trimmed and reused ignoring case', () async {
    final created = await repository.findOrCreateCategory('  Universidad  ');
    final reused = await repository.findOrCreateCategory('universidad');

    expect(created.name, 'Universidad');
    expect(reused.id, created.id);
    expect((await repository.getCategories()), hasLength(9));
  });

  test('empty custom category is rejected', () async {
    await expectLater(
      repository.findOrCreateCategory('   '),
      throwsArgumentError,
    );
  });
}
