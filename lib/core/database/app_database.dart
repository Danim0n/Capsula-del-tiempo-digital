import 'package:drift/drift.dart';

import 'connection/database_connection.dart';

part 'app_database.g.dart';

@DataClassName('CategoryRow')
class CategoryRows extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('CapsuleRow')
class CapsuleRows extends Table {
  TextColumn get id => text()();
  TextColumn get kind => text().withDefault(const Constant('standard'))();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get categoryId => text().references(CategoryRows, #id)();
  TextColumn get coverId => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get sealedAt => dateTime().nullable()();
  DateTimeColumn get unlockAt => dateTime()();
  BoolColumn get unlockIncludesTime => boolean()();
  DateTimeColumn get openedAt => dateTime().nullable()();
  DateTimeColumn get emergencyAccessedAt => dateTime().nullable()();
  TextColumn get status => text()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('CapsuleItemRow')
class CapsuleItemRows extends Table {
  TextColumn get id => text()();
  TextColumn get capsuleId =>
      text().references(CapsuleRows, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => text()();
  TextColumn get encryptedPath => text().nullable()();
  TextColumn get encryptedText => text().nullable()();
  TextColumn get textTitle => text().nullable()();
  TextColumn get mimeType => text().nullable()();
  IntColumn get byteSize => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get orderIndex => integer()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('AppSettingRow')
class AppSettingRows extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DataClassName('BackupMetadataRow')
class BackupMetadataRows extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get destinationName => text()();
  IntColumn get byteSize => integer()();
}

@DriftDatabase(
  tables: [
    CategoryRows,
    CapsuleRows,
    CapsuleItemRows,
    AppSettingRows,
    BackupMetadataRows,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      final now = DateTime.now();
      await batch((batch) {
        batch.insertAll(categoryRows, [
          for (final entry in _defaultCategories.entries)
            CategoryRowsCompanion.insert(
              id: entry.key,
              name: entry.value,
              isDefault: const Value(true),
              createdAt: now,
            ),
        ]);
      });
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.addColumn(capsuleRows, capsuleRows.kind);
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  static const _defaultCategories = <String, String>{
    'personal': 'Personal',
    'family': 'Familia',
    'couple': 'Pareja',
    'friends': 'Amigos',
    'travel': 'Viajes',
    'goals': 'Metas',
    'celebrations': 'Celebraciones',
    'other': 'Personalizada',
  };
}
