import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/storage/custom_cover_id.dart';
import '../domain/capsule_models.dart';

class CapsuleRepository {
  CapsuleRepository(this.db, {Uuid uuid = const Uuid()}) : _uuid = uuid;

  final AppDatabase db;
  final Uuid _uuid;

  Stream<List<Capsule>> watchCapsules({bool trashed = false}) {
    final query =
        db.select(db.capsuleRows)
          ..where(
            (row) =>
                trashed
                    ? row.status.equals('trashed')
                    : row.status.isNotValue('trashed'),
          )
          ..orderBy([(row) => OrderingTerm(expression: row.unlockAt)]);
    return query.watch().asyncMap(
      (rows) async => Future.wait(rows.map(_withCount)),
    );
  }

  Future<Capsule> getCapsule(String id) async {
    final row =
        await (db.select(db.capsuleRows)
          ..where((r) => r.id.equals(id))).getSingle();
    return _withCount(row);
  }

  Future<List<CapsuleItem>> getItems(String capsuleId) async {
    final rows =
        await (db.select(db.capsuleItemRows)
              ..where((r) => r.capsuleId.equals(capsuleId))
              ..orderBy([(r) => OrderingTerm.asc(r.orderIndex)]))
            .get();
    return rows.map(_mapItem).toList(growable: false);
  }

  Future<List<CapsuleCategory>> getCategories() async {
    final rows =
        await (db.select(db.categoryRows)
          ..orderBy([(r) => OrderingTerm.asc(r.createdAt)])).get();
    return rows
        .map(
          (r) =>
              CapsuleCategory(id: r.id, name: r.name, isDefault: r.isDefault),
        )
        .toList();
  }

  Stream<List<CapsuleCategory>> watchCategories() =>
      (db.select(db.categoryRows)
        ..orderBy([(r) => OrderingTerm.asc(r.createdAt)])).watch().map(
        (rows) =>
            rows
                .map(
                  (r) => CapsuleCategory(
                    id: r.id,
                    name: r.name,
                    isDefault: r.isDefault,
                  ),
                )
                .toList(),
      );

  Future<CapsuleCategory> createCategory(String name) async {
    final category = CapsuleCategory(
      id: _uuid.v4(),
      name: name.trim(),
      isDefault: false,
    );
    await db
        .into(db.categoryRows)
        .insert(
          CategoryRowsCompanion.insert(
            id: category.id,
            name: category.name,
            createdAt: DateTime.now(),
          ),
        );
    return category;
  }

  Future<CapsuleCategory> findOrCreateCategory(String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Category name cannot be empty.');
    }

    final normalizedName = trimmedName.toLowerCase();
    final categories = await getCategories();
    for (final category in categories) {
      if (category.name.trim().toLowerCase() == normalizedName) {
        return category;
      }
    }
    return createCategory(trimmedName);
  }

  Future<void> renameCategory(String id, String name) async {
    final row =
        await (db.select(db.categoryRows)
          ..where((r) => r.id.equals(id))).getSingle();
    if (row.isDefault) {
      throw StateError('Default categories cannot be renamed.');
    }
    await (db.update(db.categoryRows)..where(
      (r) => r.id.equals(id),
    )).write(CategoryRowsCompanion(name: Value(name.trim())));
  }

  Future<void> deleteCategory(String id) async {
    final row =
        await (db.select(db.categoryRows)
          ..where((r) => r.id.equals(id))).getSingle();
    if (row.isDefault) {
      throw StateError('Default categories cannot be deleted.');
    }
    final count =
        await (db.selectOnly(db.capsuleRows)
              ..addColumns([db.capsuleRows.id.count()])
              ..where(db.capsuleRows.categoryId.equals(id)))
            .map((r) => r.read(db.capsuleRows.id.count()) ?? 0)
            .getSingle();
    if (count > 0) throw StateError('Category is in use.');
    await (db.delete(db.categoryRows)..where((r) => r.id.equals(id))).go();
  }

  Future<Capsule> createDraft({
    String title = '',
    String categoryId = 'personal',
    String coverId = 'cover_01',
    DateTime? unlockAt,
  }) async {
    final now = DateTime.now();
    final capsule = Capsule(
      id: _uuid.v4(),
      title: title,
      categoryId: categoryId,
      coverId: coverId,
      createdAt: now,
      unlockAt: unlockAt ?? now.add(const Duration(days: 365)),
      unlockIncludesTime: false,
      persistedStatus: CapsuleStatus.draft,
    );
    await db.into(db.capsuleRows).insert(_capsuleCompanion(capsule));
    return capsule;
  }

  Future<void> updateDraft(Capsule capsule) async {
    await _requireDraft(capsule.id);
    await (db.update(db.capsuleRows)
      ..where((r) => r.id.equals(capsule.id))).write(
      CapsuleRowsCompanion(
        title: Value(capsule.title),
        description: Value(capsule.description),
        categoryId: Value(capsule.categoryId),
        coverId: Value(capsule.coverId),
        unlockAt: Value(capsule.unlockAt),
        unlockIncludesTime: Value(capsule.unlockIncludesTime),
      ),
    );
  }

  Future<void> addItem(CapsuleItem item) async {
    await _requireDraft(item.capsuleId);
    await db
        .into(db.capsuleItemRows)
        .insert(
          CapsuleItemRowsCompanion.insert(
            id: item.id,
            capsuleId: item.capsuleId,
            type: item.type.name,
            encryptedPath: Value(item.encryptedPath),
            encryptedText: Value(item.encryptedText),
            textTitle: Value(item.textTitle),
            mimeType: Value(item.mimeType),
            byteSize: Value(item.byteSize),
            createdAt: item.createdAt,
            orderIndex: item.orderIndex,
          ),
        );
  }

  Future<void> removeItem(String capsuleId, String itemId) async {
    await _requireDraft(capsuleId);
    await (db.delete(db.capsuleItemRows)
      ..where((r) => r.id.equals(itemId) & r.capsuleId.equals(capsuleId))).go();
  }

  Future<List<String>> discardDraft(String id) async {
    await _requireDraft(id);
    final capsule = await getCapsule(id);
    final items = await getItems(id);
    await (db.delete(db.capsuleRows)..where((r) => r.id.equals(id))).go();
    return _encryptedPaths(capsule, items);
  }

  Future<void> seal(String id, DateTime now) async {
    await _requireDraft(id);
    final capsule = await getCapsule(id);
    if (capsule.itemCount == 0 ||
        capsule.title.trim().isEmpty ||
        !capsule.unlockAt.isAfter(now)) {
      throw StateError('Capsule is incomplete.');
    }
    await (db.update(db.capsuleRows)..where((r) => r.id.equals(id))).write(
      CapsuleRowsCompanion(sealedAt: Value(now), status: const Value('sealed')),
    );
  }

  Future<void> markOpened(String id, DateTime now) async {
    final capsule = await getCapsule(id);
    if (capsule.statusAt(now) != CapsuleStatus.readyToOpen) {
      throw StateError('Capsule is still locked.');
    }
    await (db.update(db.capsuleRows)..where((r) => r.id.equals(id))).write(
      CapsuleRowsCompanion(openedAt: Value(now), status: const Value('opened')),
    );
  }

  Future<void> moveToTrash(String id, DateTime now) async {
    final capsule = await getCapsule(id);
    if (capsule.statusAt(now) != CapsuleStatus.opened) {
      throw StateError('Only opened capsules can be deleted.');
    }
    await (db.update(db.capsuleRows)..where((r) => r.id.equals(id))).write(
      CapsuleRowsCompanion(
        status: const Value('trashed'),
        deletedAt: Value(now),
      ),
    );
  }

  Future<void> restore(String id) async {
    final capsule = await getCapsule(id);
    if (capsule.persistedStatus != CapsuleStatus.trashed) return;
    await (db.update(db.capsuleRows)..where((r) => r.id.equals(id))).write(
      const CapsuleRowsCompanion(
        status: Value('opened'),
        deletedAt: Value(null),
      ),
    );
  }

  Future<List<String>> deleteForever(String id) async {
    final capsule = await getCapsule(id);
    if (capsule.persistedStatus != CapsuleStatus.trashed) {
      throw StateError('Capsule is not in trash.');
    }
    final items = await getItems(id);
    await (db.delete(db.capsuleRows)..where((r) => r.id.equals(id))).go();
    return _encryptedPaths(capsule, items);
  }

  Future<List<String>> purgeExpiredTrash(DateTime now) async {
    final threshold = now.subtract(const Duration(days: 30));
    final rows =
        await (db.select(db.capsuleRows)..where(
          (r) =>
              r.status.equals('trashed') &
              r.deletedAt.isSmallerThanValue(threshold),
        )).get();
    final paths = <String>[];
    for (final row in rows) {
      paths.addAll(await deleteForever(row.id));
    }
    return paths;
  }

  Future<void> _requireDraft(String id) async {
    final status =
        await (db.selectOnly(db.capsuleRows)
              ..addColumns([db.capsuleRows.status])
              ..where(db.capsuleRows.id.equals(id)))
            .map((r) => r.read(db.capsuleRows.status))
            .getSingle();
    if (status != 'draft') throw const CapsuleLockedException();
  }

  List<String> _encryptedPaths(Capsule capsule, List<CapsuleItem> items) => [
    ...items.map((item) => item.encryptedPath).whereType<String>(),
    if (customCoverPath(capsule.coverId) case final path?) path,
  ];

  Future<Capsule> _withCount(CapsuleRow row) async {
    final count =
        await (db.selectOnly(db.capsuleItemRows)
              ..addColumns([db.capsuleItemRows.id.count()])
              ..where(db.capsuleItemRows.capsuleId.equals(row.id)))
            .map((r) => r.read(db.capsuleItemRows.id.count()) ?? 0)
            .getSingle();
    return _mapCapsule(row, count);
  }

  Capsule _mapCapsule(CapsuleRow r, int count) => Capsule(
    id: r.id,
    title: r.title,
    description: r.description,
    categoryId: r.categoryId,
    coverId: r.coverId,
    createdAt: r.createdAt,
    sealedAt: r.sealedAt,
    unlockAt: r.unlockAt,
    unlockIncludesTime: r.unlockIncludesTime,
    openedAt: r.openedAt,
    emergencyAccessedAt: r.emergencyAccessedAt,
    persistedStatus: CapsuleStatus.values.firstWhere((s) => s.name == r.status),
    deletedAt: r.deletedAt,
    itemCount: count,
  );

  CapsuleItem _mapItem(CapsuleItemRow r) => CapsuleItem(
    id: r.id,
    capsuleId: r.capsuleId,
    type: CapsuleItemType.values.firstWhere((t) => t.name == r.type),
    encryptedPath: r.encryptedPath,
    encryptedText: r.encryptedText,
    textTitle: r.textTitle,
    mimeType: r.mimeType,
    byteSize: r.byteSize,
    createdAt: r.createdAt,
    orderIndex: r.orderIndex,
  );

  CapsuleRowsCompanion _capsuleCompanion(Capsule c) =>
      CapsuleRowsCompanion.insert(
        id: c.id,
        title: c.title,
        description: Value(c.description),
        categoryId: c.categoryId,
        coverId: c.coverId,
        createdAt: c.createdAt,
        sealedAt: Value(c.sealedAt),
        unlockAt: c.unlockAt,
        unlockIncludesTime: c.unlockIncludesTime,
        openedAt: Value(c.openedAt),
        emergencyAccessedAt: Value(c.emergencyAccessedAt),
        status: c.persistedStatus.name,
        deletedAt: Value(c.deletedAt),
      );

  Future<Map<String, dynamic>> exportData() async => {
    'version': 1,
    'categories': [
      for (final r in await db.select(db.categoryRows).get()) _categoryJson(r),
    ],
    'capsules': [
      for (final r in await db.select(db.capsuleRows).get()) _capsuleJson(r),
    ],
    'items': [
      for (final r in await db.select(db.capsuleItemRows).get()) _itemJson(r),
    ],
    'settings': [
      for (final r in await db.select(db.appSettingRows).get())
        {'key': r.key, 'value': r.value},
    ],
  };

  Future<void> replaceFromJson(Map<String, dynamic> data) async {
    if (data['version'] != 1) {
      throw const FormatException('Unsupported backup version.');
    }
    await db.transaction(() async {
      await db.delete(db.capsuleItemRows).go();
      await db.delete(db.capsuleRows).go();
      await db.delete(db.categoryRows).go();
      await db.delete(db.appSettingRows).go();
      for (final raw in (data['categories'] as List)) {
        final m = raw as Map<String, dynamic>;
        await db
            .into(db.categoryRows)
            .insert(
              CategoryRowsCompanion.insert(
                id: m['id'] as String,
                name: m['name'] as String,
                isDefault: Value(m['isDefault'] as bool),
                createdAt: DateTime.parse(m['createdAt'] as String),
              ),
            );
      }
      for (final raw in (data['capsules'] as List)) {
        final m = raw as Map<String, dynamic>;
        await db
            .into(db.capsuleRows)
            .insert(
              CapsuleRowsCompanion.insert(
                id: m['id'] as String,
                title: m['title'] as String,
                description: Value(m['description'] as String?),
                categoryId: m['categoryId'] as String,
                coverId: m['coverId'] as String,
                createdAt: DateTime.parse(m['createdAt'] as String),
                sealedAt: Value(_date(m['sealedAt'])),
                unlockAt: DateTime.parse(m['unlockAt'] as String),
                unlockIncludesTime: m['unlockIncludesTime'] as bool,
                openedAt: Value(_date(m['openedAt'])),
                emergencyAccessedAt: Value(_date(m['emergencyAccessedAt'])),
                status: m['status'] as String,
                deletedAt: Value(_date(m['deletedAt'])),
              ),
            );
      }
      for (final raw in (data['items'] as List)) {
        final m = raw as Map<String, dynamic>;
        await db
            .into(db.capsuleItemRows)
            .insert(
              CapsuleItemRowsCompanion.insert(
                id: m['id'] as String,
                capsuleId: m['capsuleId'] as String,
                type: m['type'] as String,
                encryptedPath: Value(m['encryptedPath'] as String?),
                encryptedText: Value(m['encryptedText'] as String?),
                textTitle: Value(m['textTitle'] as String?),
                mimeType: Value(m['mimeType'] as String?),
                byteSize: Value(m['byteSize'] as int),
                createdAt: DateTime.parse(m['createdAt'] as String),
                orderIndex: m['orderIndex'] as int,
              ),
            );
      }
      for (final raw in (data['settings'] as List)) {
        final m = raw as Map<String, dynamic>;
        await db
            .into(db.appSettingRows)
            .insert(
              AppSettingRowsCompanion.insert(
                key: m['key'] as String,
                value: m['value'] as String,
              ),
            );
      }
    });
  }

  String encodeExport(Map<String, dynamic> value) => jsonEncode(value);
}

DateTime? _date(Object? value) =>
    value == null ? null : DateTime.parse(value as String);

Map<String, dynamic> _categoryJson(CategoryRow r) => {
  'id': r.id,
  'name': r.name,
  'isDefault': r.isDefault,
  'createdAt': r.createdAt.toIso8601String(),
};

Map<String, dynamic> _capsuleJson(CapsuleRow r) => {
  'id': r.id,
  'title': r.title,
  'description': r.description,
  'categoryId': r.categoryId,
  'coverId': r.coverId,
  'createdAt': r.createdAt.toIso8601String(),
  'sealedAt': r.sealedAt?.toIso8601String(),
  'unlockAt': r.unlockAt.toIso8601String(),
  'unlockIncludesTime': r.unlockIncludesTime,
  'openedAt': r.openedAt?.toIso8601String(),
  'emergencyAccessedAt': r.emergencyAccessedAt?.toIso8601String(),
  'status': r.status,
  'deletedAt': r.deletedAt?.toIso8601String(),
};

Map<String, dynamic> _itemJson(CapsuleItemRow r) => {
  'id': r.id,
  'capsuleId': r.capsuleId,
  'type': r.type,
  'encryptedPath': r.encryptedPath,
  'encryptedText': r.encryptedText,
  'textTitle': r.textTitle,
  'mimeType': r.mimeType,
  'byteSize': r.byteSize,
  'createdAt': r.createdAt.toIso8601String(),
  'orderIndex': r.orderIndex,
};
