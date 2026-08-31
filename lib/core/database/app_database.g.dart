// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoryRowsTable extends CategoryRows
    with TableInfo<$CategoryRowsTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, isDefault, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      isDefault:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_default'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $CategoryRowsTable createAlias(String alias) {
    return $CategoryRowsTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final String id;
  final String name;
  final bool isDefault;
  final DateTime createdAt;
  const CategoryRow({
    required this.id,
    required this.name,
    required this.isDefault,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['is_default'] = Variable<bool>(isDefault);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CategoryRowsCompanion toCompanion(bool nullToAbsent) {
    return CategoryRowsCompanion(
      id: Value(id),
      name: Value(name),
      isDefault: Value(isDefault),
      createdAt: Value(createdAt),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'isDefault': serializer.toJson<bool>(isDefault),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CategoryRow copyWith({
    String? id,
    String? name,
    bool? isDefault,
    DateTime? createdAt,
  }) => CategoryRow(
    id: id ?? this.id,
    name: name ?? this.name,
    isDefault: isDefault ?? this.isDefault,
    createdAt: createdAt ?? this.createdAt,
  );
  CategoryRow copyWithCompanion(CategoryRowsCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, isDefault, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.isDefault == this.isDefault &&
          other.createdAt == this.createdAt);
}

class CategoryRowsCompanion extends UpdateCompanion<CategoryRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<bool> isDefault;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CategoryRowsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoryRowsCompanion.insert({
    required String id,
    required String name,
    this.isDefault = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<CategoryRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<bool>? isDefault,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isDefault != null) 'is_default': isDefault,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoryRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<bool>? isDefault,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CategoryRowsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRowsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CapsuleRowsTable extends CapsuleRows
    with TableInfo<$CapsuleRowsTable, CapsuleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CapsuleRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES category_rows (id)',
    ),
  );
  static const VerificationMeta _coverIdMeta = const VerificationMeta(
    'coverId',
  );
  @override
  late final GeneratedColumn<String> coverId = GeneratedColumn<String>(
    'cover_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sealedAtMeta = const VerificationMeta(
    'sealedAt',
  );
  @override
  late final GeneratedColumn<DateTime> sealedAt = GeneratedColumn<DateTime>(
    'sealed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unlockAtMeta = const VerificationMeta(
    'unlockAt',
  );
  @override
  late final GeneratedColumn<DateTime> unlockAt = GeneratedColumn<DateTime>(
    'unlock_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unlockIncludesTimeMeta =
      const VerificationMeta('unlockIncludesTime');
  @override
  late final GeneratedColumn<bool> unlockIncludesTime = GeneratedColumn<bool>(
    'unlock_includes_time',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("unlock_includes_time" IN (0, 1))',
    ),
  );
  static const VerificationMeta _openedAtMeta = const VerificationMeta(
    'openedAt',
  );
  @override
  late final GeneratedColumn<DateTime> openedAt = GeneratedColumn<DateTime>(
    'opened_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emergencyAccessedAtMeta =
      const VerificationMeta('emergencyAccessedAt');
  @override
  late final GeneratedColumn<DateTime> emergencyAccessedAt =
      GeneratedColumn<DateTime>(
        'emergency_accessed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    categoryId,
    coverId,
    createdAt,
    sealedAt,
    unlockAt,
    unlockIncludesTime,
    openedAt,
    emergencyAccessedAt,
    status,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'capsule_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<CapsuleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('cover_id')) {
      context.handle(
        _coverIdMeta,
        coverId.isAcceptableOrUnknown(data['cover_id']!, _coverIdMeta),
      );
    } else if (isInserting) {
      context.missing(_coverIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('sealed_at')) {
      context.handle(
        _sealedAtMeta,
        sealedAt.isAcceptableOrUnknown(data['sealed_at']!, _sealedAtMeta),
      );
    }
    if (data.containsKey('unlock_at')) {
      context.handle(
        _unlockAtMeta,
        unlockAt.isAcceptableOrUnknown(data['unlock_at']!, _unlockAtMeta),
      );
    } else if (isInserting) {
      context.missing(_unlockAtMeta);
    }
    if (data.containsKey('unlock_includes_time')) {
      context.handle(
        _unlockIncludesTimeMeta,
        unlockIncludesTime.isAcceptableOrUnknown(
          data['unlock_includes_time']!,
          _unlockIncludesTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unlockIncludesTimeMeta);
    }
    if (data.containsKey('opened_at')) {
      context.handle(
        _openedAtMeta,
        openedAt.isAcceptableOrUnknown(data['opened_at']!, _openedAtMeta),
      );
    }
    if (data.containsKey('emergency_accessed_at')) {
      context.handle(
        _emergencyAccessedAtMeta,
        emergencyAccessedAt.isAcceptableOrUnknown(
          data['emergency_accessed_at']!,
          _emergencyAccessedAtMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CapsuleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CapsuleRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      title:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}title'],
          )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      categoryId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}category_id'],
          )!,
      coverId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}cover_id'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      sealedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}sealed_at'],
      ),
      unlockAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}unlock_at'],
          )!,
      unlockIncludesTime:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}unlock_includes_time'],
          )!,
      openedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}opened_at'],
      ),
      emergencyAccessedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}emergency_accessed_at'],
      ),
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}status'],
          )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $CapsuleRowsTable createAlias(String alias) {
    return $CapsuleRowsTable(attachedDatabase, alias);
  }
}

class CapsuleRow extends DataClass implements Insertable<CapsuleRow> {
  final String id;
  final String title;
  final String? description;
  final String categoryId;
  final String coverId;
  final DateTime createdAt;
  final DateTime? sealedAt;
  final DateTime unlockAt;
  final bool unlockIncludesTime;
  final DateTime? openedAt;
  final DateTime? emergencyAccessedAt;
  final String status;
  final DateTime? deletedAt;
  const CapsuleRow({
    required this.id,
    required this.title,
    this.description,
    required this.categoryId,
    required this.coverId,
    required this.createdAt,
    this.sealedAt,
    required this.unlockAt,
    required this.unlockIncludesTime,
    this.openedAt,
    this.emergencyAccessedAt,
    required this.status,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['category_id'] = Variable<String>(categoryId);
    map['cover_id'] = Variable<String>(coverId);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || sealedAt != null) {
      map['sealed_at'] = Variable<DateTime>(sealedAt);
    }
    map['unlock_at'] = Variable<DateTime>(unlockAt);
    map['unlock_includes_time'] = Variable<bool>(unlockIncludesTime);
    if (!nullToAbsent || openedAt != null) {
      map['opened_at'] = Variable<DateTime>(openedAt);
    }
    if (!nullToAbsent || emergencyAccessedAt != null) {
      map['emergency_accessed_at'] = Variable<DateTime>(emergencyAccessedAt);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  CapsuleRowsCompanion toCompanion(bool nullToAbsent) {
    return CapsuleRowsCompanion(
      id: Value(id),
      title: Value(title),
      description:
          description == null && nullToAbsent
              ? const Value.absent()
              : Value(description),
      categoryId: Value(categoryId),
      coverId: Value(coverId),
      createdAt: Value(createdAt),
      sealedAt:
          sealedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(sealedAt),
      unlockAt: Value(unlockAt),
      unlockIncludesTime: Value(unlockIncludesTime),
      openedAt:
          openedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(openedAt),
      emergencyAccessedAt:
          emergencyAccessedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(emergencyAccessedAt),
      status: Value(status),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
    );
  }

  factory CapsuleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CapsuleRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      coverId: serializer.fromJson<String>(json['coverId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      sealedAt: serializer.fromJson<DateTime?>(json['sealedAt']),
      unlockAt: serializer.fromJson<DateTime>(json['unlockAt']),
      unlockIncludesTime: serializer.fromJson<bool>(json['unlockIncludesTime']),
      openedAt: serializer.fromJson<DateTime?>(json['openedAt']),
      emergencyAccessedAt: serializer.fromJson<DateTime?>(
        json['emergencyAccessedAt'],
      ),
      status: serializer.fromJson<String>(json['status']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'categoryId': serializer.toJson<String>(categoryId),
      'coverId': serializer.toJson<String>(coverId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'sealedAt': serializer.toJson<DateTime?>(sealedAt),
      'unlockAt': serializer.toJson<DateTime>(unlockAt),
      'unlockIncludesTime': serializer.toJson<bool>(unlockIncludesTime),
      'openedAt': serializer.toJson<DateTime?>(openedAt),
      'emergencyAccessedAt': serializer.toJson<DateTime?>(emergencyAccessedAt),
      'status': serializer.toJson<String>(status),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  CapsuleRow copyWith({
    String? id,
    String? title,
    Value<String?> description = const Value.absent(),
    String? categoryId,
    String? coverId,
    DateTime? createdAt,
    Value<DateTime?> sealedAt = const Value.absent(),
    DateTime? unlockAt,
    bool? unlockIncludesTime,
    Value<DateTime?> openedAt = const Value.absent(),
    Value<DateTime?> emergencyAccessedAt = const Value.absent(),
    String? status,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => CapsuleRow(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    categoryId: categoryId ?? this.categoryId,
    coverId: coverId ?? this.coverId,
    createdAt: createdAt ?? this.createdAt,
    sealedAt: sealedAt.present ? sealedAt.value : this.sealedAt,
    unlockAt: unlockAt ?? this.unlockAt,
    unlockIncludesTime: unlockIncludesTime ?? this.unlockIncludesTime,
    openedAt: openedAt.present ? openedAt.value : this.openedAt,
    emergencyAccessedAt:
        emergencyAccessedAt.present
            ? emergencyAccessedAt.value
            : this.emergencyAccessedAt,
    status: status ?? this.status,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  CapsuleRow copyWithCompanion(CapsuleRowsCompanion data) {
    return CapsuleRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      coverId: data.coverId.present ? data.coverId.value : this.coverId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      sealedAt: data.sealedAt.present ? data.sealedAt.value : this.sealedAt,
      unlockAt: data.unlockAt.present ? data.unlockAt.value : this.unlockAt,
      unlockIncludesTime:
          data.unlockIncludesTime.present
              ? data.unlockIncludesTime.value
              : this.unlockIncludesTime,
      openedAt: data.openedAt.present ? data.openedAt.value : this.openedAt,
      emergencyAccessedAt:
          data.emergencyAccessedAt.present
              ? data.emergencyAccessedAt.value
              : this.emergencyAccessedAt,
      status: data.status.present ? data.status.value : this.status,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CapsuleRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('categoryId: $categoryId, ')
          ..write('coverId: $coverId, ')
          ..write('createdAt: $createdAt, ')
          ..write('sealedAt: $sealedAt, ')
          ..write('unlockAt: $unlockAt, ')
          ..write('unlockIncludesTime: $unlockIncludesTime, ')
          ..write('openedAt: $openedAt, ')
          ..write('emergencyAccessedAt: $emergencyAccessedAt, ')
          ..write('status: $status, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    categoryId,
    coverId,
    createdAt,
    sealedAt,
    unlockAt,
    unlockIncludesTime,
    openedAt,
    emergencyAccessedAt,
    status,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CapsuleRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.categoryId == this.categoryId &&
          other.coverId == this.coverId &&
          other.createdAt == this.createdAt &&
          other.sealedAt == this.sealedAt &&
          other.unlockAt == this.unlockAt &&
          other.unlockIncludesTime == this.unlockIncludesTime &&
          other.openedAt == this.openedAt &&
          other.emergencyAccessedAt == this.emergencyAccessedAt &&
          other.status == this.status &&
          other.deletedAt == this.deletedAt);
}

class CapsuleRowsCompanion extends UpdateCompanion<CapsuleRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<String> categoryId;
  final Value<String> coverId;
  final Value<DateTime> createdAt;
  final Value<DateTime?> sealedAt;
  final Value<DateTime> unlockAt;
  final Value<bool> unlockIncludesTime;
  final Value<DateTime?> openedAt;
  final Value<DateTime?> emergencyAccessedAt;
  final Value<String> status;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const CapsuleRowsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.coverId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.sealedAt = const Value.absent(),
    this.unlockAt = const Value.absent(),
    this.unlockIncludesTime = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.emergencyAccessedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CapsuleRowsCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    required String categoryId,
    required String coverId,
    required DateTime createdAt,
    this.sealedAt = const Value.absent(),
    required DateTime unlockAt,
    required bool unlockIncludesTime,
    this.openedAt = const Value.absent(),
    this.emergencyAccessedAt = const Value.absent(),
    required String status,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       categoryId = Value(categoryId),
       coverId = Value(coverId),
       createdAt = Value(createdAt),
       unlockAt = Value(unlockAt),
       unlockIncludesTime = Value(unlockIncludesTime),
       status = Value(status);
  static Insertable<CapsuleRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? categoryId,
    Expression<String>? coverId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? sealedAt,
    Expression<DateTime>? unlockAt,
    Expression<bool>? unlockIncludesTime,
    Expression<DateTime>? openedAt,
    Expression<DateTime>? emergencyAccessedAt,
    Expression<String>? status,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (categoryId != null) 'category_id': categoryId,
      if (coverId != null) 'cover_id': coverId,
      if (createdAt != null) 'created_at': createdAt,
      if (sealedAt != null) 'sealed_at': sealedAt,
      if (unlockAt != null) 'unlock_at': unlockAt,
      if (unlockIncludesTime != null)
        'unlock_includes_time': unlockIncludesTime,
      if (openedAt != null) 'opened_at': openedAt,
      if (emergencyAccessedAt != null)
        'emergency_accessed_at': emergencyAccessedAt,
      if (status != null) 'status': status,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CapsuleRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<String>? categoryId,
    Value<String>? coverId,
    Value<DateTime>? createdAt,
    Value<DateTime?>? sealedAt,
    Value<DateTime>? unlockAt,
    Value<bool>? unlockIncludesTime,
    Value<DateTime?>? openedAt,
    Value<DateTime?>? emergencyAccessedAt,
    Value<String>? status,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return CapsuleRowsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      coverId: coverId ?? this.coverId,
      createdAt: createdAt ?? this.createdAt,
      sealedAt: sealedAt ?? this.sealedAt,
      unlockAt: unlockAt ?? this.unlockAt,
      unlockIncludesTime: unlockIncludesTime ?? this.unlockIncludesTime,
      openedAt: openedAt ?? this.openedAt,
      emergencyAccessedAt: emergencyAccessedAt ?? this.emergencyAccessedAt,
      status: status ?? this.status,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (coverId.present) {
      map['cover_id'] = Variable<String>(coverId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (sealedAt.present) {
      map['sealed_at'] = Variable<DateTime>(sealedAt.value);
    }
    if (unlockAt.present) {
      map['unlock_at'] = Variable<DateTime>(unlockAt.value);
    }
    if (unlockIncludesTime.present) {
      map['unlock_includes_time'] = Variable<bool>(unlockIncludesTime.value);
    }
    if (openedAt.present) {
      map['opened_at'] = Variable<DateTime>(openedAt.value);
    }
    if (emergencyAccessedAt.present) {
      map['emergency_accessed_at'] = Variable<DateTime>(
        emergencyAccessedAt.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CapsuleRowsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('categoryId: $categoryId, ')
          ..write('coverId: $coverId, ')
          ..write('createdAt: $createdAt, ')
          ..write('sealedAt: $sealedAt, ')
          ..write('unlockAt: $unlockAt, ')
          ..write('unlockIncludesTime: $unlockIncludesTime, ')
          ..write('openedAt: $openedAt, ')
          ..write('emergencyAccessedAt: $emergencyAccessedAt, ')
          ..write('status: $status, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CapsuleItemRowsTable extends CapsuleItemRows
    with TableInfo<$CapsuleItemRowsTable, CapsuleItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CapsuleItemRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capsuleIdMeta = const VerificationMeta(
    'capsuleId',
  );
  @override
  late final GeneratedColumn<String> capsuleId = GeneratedColumn<String>(
    'capsule_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES capsule_rows (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _encryptedPathMeta = const VerificationMeta(
    'encryptedPath',
  );
  @override
  late final GeneratedColumn<String> encryptedPath = GeneratedColumn<String>(
    'encrypted_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _encryptedTextMeta = const VerificationMeta(
    'encryptedText',
  );
  @override
  late final GeneratedColumn<String> encryptedText = GeneratedColumn<String>(
    'encrypted_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _textTitleMeta = const VerificationMeta(
    'textTitle',
  );
  @override
  late final GeneratedColumn<String> textTitle = GeneratedColumn<String>(
    'text_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _byteSizeMeta = const VerificationMeta(
    'byteSize',
  );
  @override
  late final GeneratedColumn<int> byteSize = GeneratedColumn<int>(
    'byte_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    capsuleId,
    type,
    encryptedPath,
    encryptedText,
    textTitle,
    mimeType,
    byteSize,
    createdAt,
    orderIndex,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'capsule_item_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<CapsuleItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('capsule_id')) {
      context.handle(
        _capsuleIdMeta,
        capsuleId.isAcceptableOrUnknown(data['capsule_id']!, _capsuleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_capsuleIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('encrypted_path')) {
      context.handle(
        _encryptedPathMeta,
        encryptedPath.isAcceptableOrUnknown(
          data['encrypted_path']!,
          _encryptedPathMeta,
        ),
      );
    }
    if (data.containsKey('encrypted_text')) {
      context.handle(
        _encryptedTextMeta,
        encryptedText.isAcceptableOrUnknown(
          data['encrypted_text']!,
          _encryptedTextMeta,
        ),
      );
    }
    if (data.containsKey('text_title')) {
      context.handle(
        _textTitleMeta,
        textTitle.isAcceptableOrUnknown(data['text_title']!, _textTitleMeta),
      );
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    }
    if (data.containsKey('byte_size')) {
      context.handle(
        _byteSizeMeta,
        byteSize.isAcceptableOrUnknown(data['byte_size']!, _byteSizeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CapsuleItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CapsuleItemRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      capsuleId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}capsule_id'],
          )!,
      type:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}type'],
          )!,
      encryptedPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}encrypted_path'],
      ),
      encryptedText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}encrypted_text'],
      ),
      textTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_title'],
      ),
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      ),
      byteSize:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}byte_size'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      orderIndex:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}order_index'],
          )!,
    );
  }

  @override
  $CapsuleItemRowsTable createAlias(String alias) {
    return $CapsuleItemRowsTable(attachedDatabase, alias);
  }
}

class CapsuleItemRow extends DataClass implements Insertable<CapsuleItemRow> {
  final String id;
  final String capsuleId;
  final String type;
  final String? encryptedPath;
  final String? encryptedText;
  final String? textTitle;
  final String? mimeType;
  final int byteSize;
  final DateTime createdAt;
  final int orderIndex;
  const CapsuleItemRow({
    required this.id,
    required this.capsuleId,
    required this.type,
    this.encryptedPath,
    this.encryptedText,
    this.textTitle,
    this.mimeType,
    required this.byteSize,
    required this.createdAt,
    required this.orderIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['capsule_id'] = Variable<String>(capsuleId);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || encryptedPath != null) {
      map['encrypted_path'] = Variable<String>(encryptedPath);
    }
    if (!nullToAbsent || encryptedText != null) {
      map['encrypted_text'] = Variable<String>(encryptedText);
    }
    if (!nullToAbsent || textTitle != null) {
      map['text_title'] = Variable<String>(textTitle);
    }
    if (!nullToAbsent || mimeType != null) {
      map['mime_type'] = Variable<String>(mimeType);
    }
    map['byte_size'] = Variable<int>(byteSize);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }

  CapsuleItemRowsCompanion toCompanion(bool nullToAbsent) {
    return CapsuleItemRowsCompanion(
      id: Value(id),
      capsuleId: Value(capsuleId),
      type: Value(type),
      encryptedPath:
          encryptedPath == null && nullToAbsent
              ? const Value.absent()
              : Value(encryptedPath),
      encryptedText:
          encryptedText == null && nullToAbsent
              ? const Value.absent()
              : Value(encryptedText),
      textTitle:
          textTitle == null && nullToAbsent
              ? const Value.absent()
              : Value(textTitle),
      mimeType:
          mimeType == null && nullToAbsent
              ? const Value.absent()
              : Value(mimeType),
      byteSize: Value(byteSize),
      createdAt: Value(createdAt),
      orderIndex: Value(orderIndex),
    );
  }

  factory CapsuleItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CapsuleItemRow(
      id: serializer.fromJson<String>(json['id']),
      capsuleId: serializer.fromJson<String>(json['capsuleId']),
      type: serializer.fromJson<String>(json['type']),
      encryptedPath: serializer.fromJson<String?>(json['encryptedPath']),
      encryptedText: serializer.fromJson<String?>(json['encryptedText']),
      textTitle: serializer.fromJson<String?>(json['textTitle']),
      mimeType: serializer.fromJson<String?>(json['mimeType']),
      byteSize: serializer.fromJson<int>(json['byteSize']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'capsuleId': serializer.toJson<String>(capsuleId),
      'type': serializer.toJson<String>(type),
      'encryptedPath': serializer.toJson<String?>(encryptedPath),
      'encryptedText': serializer.toJson<String?>(encryptedText),
      'textTitle': serializer.toJson<String?>(textTitle),
      'mimeType': serializer.toJson<String?>(mimeType),
      'byteSize': serializer.toJson<int>(byteSize),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'orderIndex': serializer.toJson<int>(orderIndex),
    };
  }

  CapsuleItemRow copyWith({
    String? id,
    String? capsuleId,
    String? type,
    Value<String?> encryptedPath = const Value.absent(),
    Value<String?> encryptedText = const Value.absent(),
    Value<String?> textTitle = const Value.absent(),
    Value<String?> mimeType = const Value.absent(),
    int? byteSize,
    DateTime? createdAt,
    int? orderIndex,
  }) => CapsuleItemRow(
    id: id ?? this.id,
    capsuleId: capsuleId ?? this.capsuleId,
    type: type ?? this.type,
    encryptedPath:
        encryptedPath.present ? encryptedPath.value : this.encryptedPath,
    encryptedText:
        encryptedText.present ? encryptedText.value : this.encryptedText,
    textTitle: textTitle.present ? textTitle.value : this.textTitle,
    mimeType: mimeType.present ? mimeType.value : this.mimeType,
    byteSize: byteSize ?? this.byteSize,
    createdAt: createdAt ?? this.createdAt,
    orderIndex: orderIndex ?? this.orderIndex,
  );
  CapsuleItemRow copyWithCompanion(CapsuleItemRowsCompanion data) {
    return CapsuleItemRow(
      id: data.id.present ? data.id.value : this.id,
      capsuleId: data.capsuleId.present ? data.capsuleId.value : this.capsuleId,
      type: data.type.present ? data.type.value : this.type,
      encryptedPath:
          data.encryptedPath.present
              ? data.encryptedPath.value
              : this.encryptedPath,
      encryptedText:
          data.encryptedText.present
              ? data.encryptedText.value
              : this.encryptedText,
      textTitle: data.textTitle.present ? data.textTitle.value : this.textTitle,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      byteSize: data.byteSize.present ? data.byteSize.value : this.byteSize,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CapsuleItemRow(')
          ..write('id: $id, ')
          ..write('capsuleId: $capsuleId, ')
          ..write('type: $type, ')
          ..write('encryptedPath: $encryptedPath, ')
          ..write('encryptedText: $encryptedText, ')
          ..write('textTitle: $textTitle, ')
          ..write('mimeType: $mimeType, ')
          ..write('byteSize: $byteSize, ')
          ..write('createdAt: $createdAt, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    capsuleId,
    type,
    encryptedPath,
    encryptedText,
    textTitle,
    mimeType,
    byteSize,
    createdAt,
    orderIndex,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CapsuleItemRow &&
          other.id == this.id &&
          other.capsuleId == this.capsuleId &&
          other.type == this.type &&
          other.encryptedPath == this.encryptedPath &&
          other.encryptedText == this.encryptedText &&
          other.textTitle == this.textTitle &&
          other.mimeType == this.mimeType &&
          other.byteSize == this.byteSize &&
          other.createdAt == this.createdAt &&
          other.orderIndex == this.orderIndex);
}

class CapsuleItemRowsCompanion extends UpdateCompanion<CapsuleItemRow> {
  final Value<String> id;
  final Value<String> capsuleId;
  final Value<String> type;
  final Value<String?> encryptedPath;
  final Value<String?> encryptedText;
  final Value<String?> textTitle;
  final Value<String?> mimeType;
  final Value<int> byteSize;
  final Value<DateTime> createdAt;
  final Value<int> orderIndex;
  final Value<int> rowid;
  const CapsuleItemRowsCompanion({
    this.id = const Value.absent(),
    this.capsuleId = const Value.absent(),
    this.type = const Value.absent(),
    this.encryptedPath = const Value.absent(),
    this.encryptedText = const Value.absent(),
    this.textTitle = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.byteSize = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CapsuleItemRowsCompanion.insert({
    required String id,
    required String capsuleId,
    required String type,
    this.encryptedPath = const Value.absent(),
    this.encryptedText = const Value.absent(),
    this.textTitle = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.byteSize = const Value.absent(),
    required DateTime createdAt,
    required int orderIndex,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       capsuleId = Value(capsuleId),
       type = Value(type),
       createdAt = Value(createdAt),
       orderIndex = Value(orderIndex);
  static Insertable<CapsuleItemRow> custom({
    Expression<String>? id,
    Expression<String>? capsuleId,
    Expression<String>? type,
    Expression<String>? encryptedPath,
    Expression<String>? encryptedText,
    Expression<String>? textTitle,
    Expression<String>? mimeType,
    Expression<int>? byteSize,
    Expression<DateTime>? createdAt,
    Expression<int>? orderIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (capsuleId != null) 'capsule_id': capsuleId,
      if (type != null) 'type': type,
      if (encryptedPath != null) 'encrypted_path': encryptedPath,
      if (encryptedText != null) 'encrypted_text': encryptedText,
      if (textTitle != null) 'text_title': textTitle,
      if (mimeType != null) 'mime_type': mimeType,
      if (byteSize != null) 'byte_size': byteSize,
      if (createdAt != null) 'created_at': createdAt,
      if (orderIndex != null) 'order_index': orderIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CapsuleItemRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? capsuleId,
    Value<String>? type,
    Value<String?>? encryptedPath,
    Value<String?>? encryptedText,
    Value<String?>? textTitle,
    Value<String?>? mimeType,
    Value<int>? byteSize,
    Value<DateTime>? createdAt,
    Value<int>? orderIndex,
    Value<int>? rowid,
  }) {
    return CapsuleItemRowsCompanion(
      id: id ?? this.id,
      capsuleId: capsuleId ?? this.capsuleId,
      type: type ?? this.type,
      encryptedPath: encryptedPath ?? this.encryptedPath,
      encryptedText: encryptedText ?? this.encryptedText,
      textTitle: textTitle ?? this.textTitle,
      mimeType: mimeType ?? this.mimeType,
      byteSize: byteSize ?? this.byteSize,
      createdAt: createdAt ?? this.createdAt,
      orderIndex: orderIndex ?? this.orderIndex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (capsuleId.present) {
      map['capsule_id'] = Variable<String>(capsuleId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (encryptedPath.present) {
      map['encrypted_path'] = Variable<String>(encryptedPath.value);
    }
    if (encryptedText.present) {
      map['encrypted_text'] = Variable<String>(encryptedText.value);
    }
    if (textTitle.present) {
      map['text_title'] = Variable<String>(textTitle.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (byteSize.present) {
      map['byte_size'] = Variable<int>(byteSize.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CapsuleItemRowsCompanion(')
          ..write('id: $id, ')
          ..write('capsuleId: $capsuleId, ')
          ..write('type: $type, ')
          ..write('encryptedPath: $encryptedPath, ')
          ..write('encryptedText: $encryptedText, ')
          ..write('textTitle: $textTitle, ')
          ..write('mimeType: $mimeType, ')
          ..write('byteSize: $byteSize, ')
          ..write('createdAt: $createdAt, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingRowsTable extends AppSettingRows
    with TableInfo<$AppSettingRowsTable, AppSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_setting_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingRow(
      key:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}key'],
          )!,
      value:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}value'],
          )!,
    );
  }

  @override
  $AppSettingRowsTable createAlias(String alias) {
    return $AppSettingRowsTable(attachedDatabase, alias);
  }
}

class AppSettingRow extends DataClass implements Insertable<AppSettingRow> {
  final String key;
  final String value;
  const AppSettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingRowsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingRowsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSettingRow copyWith({String? key, String? value}) =>
      AppSettingRow(key: key ?? this.key, value: value ?? this.value);
  AppSettingRow copyWithCompanion(AppSettingRowsCompanion data) {
    return AppSettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingRowsCompanion extends UpdateCompanion<AppSettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingRowsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingRowsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingRowsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingRowsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingRowsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BackupMetadataRowsTable extends BackupMetadataRows
    with TableInfo<$BackupMetadataRowsTable, BackupMetadataRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BackupMetadataRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _destinationNameMeta = const VerificationMeta(
    'destinationName',
  );
  @override
  late final GeneratedColumn<String> destinationName = GeneratedColumn<String>(
    'destination_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _byteSizeMeta = const VerificationMeta(
    'byteSize',
  );
  @override
  late final GeneratedColumn<int> byteSize = GeneratedColumn<int>(
    'byte_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    destinationName,
    byteSize,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'backup_metadata_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<BackupMetadataRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('destination_name')) {
      context.handle(
        _destinationNameMeta,
        destinationName.isAcceptableOrUnknown(
          data['destination_name']!,
          _destinationNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_destinationNameMeta);
    }
    if (data.containsKey('byte_size')) {
      context.handle(
        _byteSizeMeta,
        byteSize.isAcceptableOrUnknown(data['byte_size']!, _byteSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_byteSizeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BackupMetadataRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BackupMetadataRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      destinationName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}destination_name'],
          )!,
      byteSize:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}byte_size'],
          )!,
    );
  }

  @override
  $BackupMetadataRowsTable createAlias(String alias) {
    return $BackupMetadataRowsTable(attachedDatabase, alias);
  }
}

class BackupMetadataRow extends DataClass
    implements Insertable<BackupMetadataRow> {
  final int id;
  final DateTime createdAt;
  final String destinationName;
  final int byteSize;
  const BackupMetadataRow({
    required this.id,
    required this.createdAt,
    required this.destinationName,
    required this.byteSize,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['destination_name'] = Variable<String>(destinationName);
    map['byte_size'] = Variable<int>(byteSize);
    return map;
  }

  BackupMetadataRowsCompanion toCompanion(bool nullToAbsent) {
    return BackupMetadataRowsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      destinationName: Value(destinationName),
      byteSize: Value(byteSize),
    );
  }

  factory BackupMetadataRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BackupMetadataRow(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      destinationName: serializer.fromJson<String>(json['destinationName']),
      byteSize: serializer.fromJson<int>(json['byteSize']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'destinationName': serializer.toJson<String>(destinationName),
      'byteSize': serializer.toJson<int>(byteSize),
    };
  }

  BackupMetadataRow copyWith({
    int? id,
    DateTime? createdAt,
    String? destinationName,
    int? byteSize,
  }) => BackupMetadataRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    destinationName: destinationName ?? this.destinationName,
    byteSize: byteSize ?? this.byteSize,
  );
  BackupMetadataRow copyWithCompanion(BackupMetadataRowsCompanion data) {
    return BackupMetadataRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      destinationName:
          data.destinationName.present
              ? data.destinationName.value
              : this.destinationName,
      byteSize: data.byteSize.present ? data.byteSize.value : this.byteSize,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BackupMetadataRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('destinationName: $destinationName, ')
          ..write('byteSize: $byteSize')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, destinationName, byteSize);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BackupMetadataRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.destinationName == this.destinationName &&
          other.byteSize == this.byteSize);
}

class BackupMetadataRowsCompanion extends UpdateCompanion<BackupMetadataRow> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<String> destinationName;
  final Value<int> byteSize;
  const BackupMetadataRowsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.destinationName = const Value.absent(),
    this.byteSize = const Value.absent(),
  });
  BackupMetadataRowsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime createdAt,
    required String destinationName,
    required int byteSize,
  }) : createdAt = Value(createdAt),
       destinationName = Value(destinationName),
       byteSize = Value(byteSize);
  static Insertable<BackupMetadataRow> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? destinationName,
    Expression<int>? byteSize,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (destinationName != null) 'destination_name': destinationName,
      if (byteSize != null) 'byte_size': byteSize,
    });
  }

  BackupMetadataRowsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<String>? destinationName,
    Value<int>? byteSize,
  }) {
    return BackupMetadataRowsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      destinationName: destinationName ?? this.destinationName,
      byteSize: byteSize ?? this.byteSize,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (destinationName.present) {
      map['destination_name'] = Variable<String>(destinationName.value);
    }
    if (byteSize.present) {
      map['byte_size'] = Variable<int>(byteSize.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BackupMetadataRowsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('destinationName: $destinationName, ')
          ..write('byteSize: $byteSize')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoryRowsTable categoryRows = $CategoryRowsTable(this);
  late final $CapsuleRowsTable capsuleRows = $CapsuleRowsTable(this);
  late final $CapsuleItemRowsTable capsuleItemRows = $CapsuleItemRowsTable(
    this,
  );
  late final $AppSettingRowsTable appSettingRows = $AppSettingRowsTable(this);
  late final $BackupMetadataRowsTable backupMetadataRows =
      $BackupMetadataRowsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categoryRows,
    capsuleRows,
    capsuleItemRows,
    appSettingRows,
    backupMetadataRows,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'capsule_rows',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('capsule_item_rows', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CategoryRowsTableCreateCompanionBuilder =
    CategoryRowsCompanion Function({
      required String id,
      required String name,
      Value<bool> isDefault,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CategoryRowsTableUpdateCompanionBuilder =
    CategoryRowsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<bool> isDefault,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$CategoryRowsTableReferences
    extends BaseReferences<_$AppDatabase, $CategoryRowsTable, CategoryRow> {
  $$CategoryRowsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CapsuleRowsTable, List<CapsuleRow>>
  _capsuleRowsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.capsuleRows,
    aliasName: $_aliasNameGenerator(
      db.categoryRows.id,
      db.capsuleRows.categoryId,
    ),
  );

  $$CapsuleRowsTableProcessedTableManager get capsuleRowsRefs {
    final manager = $$CapsuleRowsTableTableManager(
      $_db,
      $_db.capsuleRows,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_capsuleRowsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoryRowsTableFilterComposer
    extends Composer<_$AppDatabase, $CategoryRowsTable> {
  $$CategoryRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> capsuleRowsRefs(
    Expression<bool> Function($$CapsuleRowsTableFilterComposer f) f,
  ) {
    final $$CapsuleRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.capsuleRows,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CapsuleRowsTableFilterComposer(
            $db: $db,
            $table: $db.capsuleRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoryRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoryRowsTable> {
  $$CategoryRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoryRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoryRowsTable> {
  $$CategoryRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> capsuleRowsRefs<T extends Object>(
    Expression<T> Function($$CapsuleRowsTableAnnotationComposer a) f,
  ) {
    final $$CapsuleRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.capsuleRows,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CapsuleRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.capsuleRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoryRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoryRowsTable,
          CategoryRow,
          $$CategoryRowsTableFilterComposer,
          $$CategoryRowsTableOrderingComposer,
          $$CategoryRowsTableAnnotationComposer,
          $$CategoryRowsTableCreateCompanionBuilder,
          $$CategoryRowsTableUpdateCompanionBuilder,
          (CategoryRow, $$CategoryRowsTableReferences),
          CategoryRow,
          PrefetchHooks Function({bool capsuleRowsRefs})
        > {
  $$CategoryRowsTableTableManager(_$AppDatabase db, $CategoryRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$CategoryRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$CategoryRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$CategoryRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoryRowsCompanion(
                id: id,
                name: name,
                isDefault: isDefault,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<bool> isDefault = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CategoryRowsCompanion.insert(
                id: id,
                name: name,
                isDefault: isDefault,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$CategoryRowsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({capsuleRowsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (capsuleRowsRefs) db.capsuleRows],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (capsuleRowsRefs)
                    await $_getPrefetchedData<
                      CategoryRow,
                      $CategoryRowsTable,
                      CapsuleRow
                    >(
                      currentTable: table,
                      referencedTable: $$CategoryRowsTableReferences
                          ._capsuleRowsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$CategoryRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).capsuleRowsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.categoryId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoryRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoryRowsTable,
      CategoryRow,
      $$CategoryRowsTableFilterComposer,
      $$CategoryRowsTableOrderingComposer,
      $$CategoryRowsTableAnnotationComposer,
      $$CategoryRowsTableCreateCompanionBuilder,
      $$CategoryRowsTableUpdateCompanionBuilder,
      (CategoryRow, $$CategoryRowsTableReferences),
      CategoryRow,
      PrefetchHooks Function({bool capsuleRowsRefs})
    >;
typedef $$CapsuleRowsTableCreateCompanionBuilder =
    CapsuleRowsCompanion Function({
      required String id,
      required String title,
      Value<String?> description,
      required String categoryId,
      required String coverId,
      required DateTime createdAt,
      Value<DateTime?> sealedAt,
      required DateTime unlockAt,
      required bool unlockIncludesTime,
      Value<DateTime?> openedAt,
      Value<DateTime?> emergencyAccessedAt,
      required String status,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$CapsuleRowsTableUpdateCompanionBuilder =
    CapsuleRowsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> description,
      Value<String> categoryId,
      Value<String> coverId,
      Value<DateTime> createdAt,
      Value<DateTime?> sealedAt,
      Value<DateTime> unlockAt,
      Value<bool> unlockIncludesTime,
      Value<DateTime?> openedAt,
      Value<DateTime?> emergencyAccessedAt,
      Value<String> status,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$CapsuleRowsTableReferences
    extends BaseReferences<_$AppDatabase, $CapsuleRowsTable, CapsuleRow> {
  $$CapsuleRowsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoryRowsTable _categoryIdTable(_$AppDatabase db) =>
      db.categoryRows.createAlias(
        $_aliasNameGenerator(db.capsuleRows.categoryId, db.categoryRows.id),
      );

  $$CategoryRowsTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$CategoryRowsTableTableManager(
      $_db,
      $_db.categoryRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CapsuleItemRowsTable, List<CapsuleItemRow>>
  _capsuleItemRowsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.capsuleItemRows,
    aliasName: $_aliasNameGenerator(
      db.capsuleRows.id,
      db.capsuleItemRows.capsuleId,
    ),
  );

  $$CapsuleItemRowsTableProcessedTableManager get capsuleItemRowsRefs {
    final manager = $$CapsuleItemRowsTableTableManager(
      $_db,
      $_db.capsuleItemRows,
    ).filter((f) => f.capsuleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _capsuleItemRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CapsuleRowsTableFilterComposer
    extends Composer<_$AppDatabase, $CapsuleRowsTable> {
  $$CapsuleRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverId => $composableBuilder(
    column: $table.coverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get sealedAt => $composableBuilder(
    column: $table.sealedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get unlockAt => $composableBuilder(
    column: $table.unlockAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get unlockIncludesTime => $composableBuilder(
    column: $table.unlockIncludesTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get emergencyAccessedAt => $composableBuilder(
    column: $table.emergencyAccessedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoryRowsTableFilterComposer get categoryId {
    final $$CategoryRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categoryRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryRowsTableFilterComposer(
            $db: $db,
            $table: $db.categoryRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> capsuleItemRowsRefs(
    Expression<bool> Function($$CapsuleItemRowsTableFilterComposer f) f,
  ) {
    final $$CapsuleItemRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.capsuleItemRows,
      getReferencedColumn: (t) => t.capsuleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CapsuleItemRowsTableFilterComposer(
            $db: $db,
            $table: $db.capsuleItemRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CapsuleRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $CapsuleRowsTable> {
  $$CapsuleRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverId => $composableBuilder(
    column: $table.coverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get sealedAt => $composableBuilder(
    column: $table.sealedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unlockAt => $composableBuilder(
    column: $table.unlockAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get unlockIncludesTime => $composableBuilder(
    column: $table.unlockIncludesTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get emergencyAccessedAt => $composableBuilder(
    column: $table.emergencyAccessedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoryRowsTableOrderingComposer get categoryId {
    final $$CategoryRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categoryRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryRowsTableOrderingComposer(
            $db: $db,
            $table: $db.categoryRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CapsuleRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CapsuleRowsTable> {
  $$CapsuleRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverId =>
      $composableBuilder(column: $table.coverId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get sealedAt =>
      $composableBuilder(column: $table.sealedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get unlockAt =>
      $composableBuilder(column: $table.unlockAt, builder: (column) => column);

  GeneratedColumn<bool> get unlockIncludesTime => $composableBuilder(
    column: $table.unlockIncludesTime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get openedAt =>
      $composableBuilder(column: $table.openedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get emergencyAccessedAt => $composableBuilder(
    column: $table.emergencyAccessedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$CategoryRowsTableAnnotationComposer get categoryId {
    final $$CategoryRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categoryRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.categoryRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> capsuleItemRowsRefs<T extends Object>(
    Expression<T> Function($$CapsuleItemRowsTableAnnotationComposer a) f,
  ) {
    final $$CapsuleItemRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.capsuleItemRows,
      getReferencedColumn: (t) => t.capsuleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CapsuleItemRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.capsuleItemRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CapsuleRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CapsuleRowsTable,
          CapsuleRow,
          $$CapsuleRowsTableFilterComposer,
          $$CapsuleRowsTableOrderingComposer,
          $$CapsuleRowsTableAnnotationComposer,
          $$CapsuleRowsTableCreateCompanionBuilder,
          $$CapsuleRowsTableUpdateCompanionBuilder,
          (CapsuleRow, $$CapsuleRowsTableReferences),
          CapsuleRow,
          PrefetchHooks Function({bool categoryId, bool capsuleItemRowsRefs})
        > {
  $$CapsuleRowsTableTableManager(_$AppDatabase db, $CapsuleRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$CapsuleRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$CapsuleRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$CapsuleRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> coverId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> sealedAt = const Value.absent(),
                Value<DateTime> unlockAt = const Value.absent(),
                Value<bool> unlockIncludesTime = const Value.absent(),
                Value<DateTime?> openedAt = const Value.absent(),
                Value<DateTime?> emergencyAccessedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CapsuleRowsCompanion(
                id: id,
                title: title,
                description: description,
                categoryId: categoryId,
                coverId: coverId,
                createdAt: createdAt,
                sealedAt: sealedAt,
                unlockAt: unlockAt,
                unlockIncludesTime: unlockIncludesTime,
                openedAt: openedAt,
                emergencyAccessedAt: emergencyAccessedAt,
                status: status,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> description = const Value.absent(),
                required String categoryId,
                required String coverId,
                required DateTime createdAt,
                Value<DateTime?> sealedAt = const Value.absent(),
                required DateTime unlockAt,
                required bool unlockIncludesTime,
                Value<DateTime?> openedAt = const Value.absent(),
                Value<DateTime?> emergencyAccessedAt = const Value.absent(),
                required String status,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CapsuleRowsCompanion.insert(
                id: id,
                title: title,
                description: description,
                categoryId: categoryId,
                coverId: coverId,
                createdAt: createdAt,
                sealedAt: sealedAt,
                unlockAt: unlockAt,
                unlockIncludesTime: unlockIncludesTime,
                openedAt: openedAt,
                emergencyAccessedAt: emergencyAccessedAt,
                status: status,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$CapsuleRowsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            categoryId = false,
            capsuleItemRowsRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (capsuleItemRowsRefs) db.capsuleItemRows,
              ],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (categoryId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.categoryId,
                            referencedTable: $$CapsuleRowsTableReferences
                                ._categoryIdTable(db),
                            referencedColumn:
                                $$CapsuleRowsTableReferences
                                    ._categoryIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (capsuleItemRowsRefs)
                    await $_getPrefetchedData<
                      CapsuleRow,
                      $CapsuleRowsTable,
                      CapsuleItemRow
                    >(
                      currentTable: table,
                      referencedTable: $$CapsuleRowsTableReferences
                          ._capsuleItemRowsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$CapsuleRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).capsuleItemRowsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.capsuleId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CapsuleRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CapsuleRowsTable,
      CapsuleRow,
      $$CapsuleRowsTableFilterComposer,
      $$CapsuleRowsTableOrderingComposer,
      $$CapsuleRowsTableAnnotationComposer,
      $$CapsuleRowsTableCreateCompanionBuilder,
      $$CapsuleRowsTableUpdateCompanionBuilder,
      (CapsuleRow, $$CapsuleRowsTableReferences),
      CapsuleRow,
      PrefetchHooks Function({bool categoryId, bool capsuleItemRowsRefs})
    >;
typedef $$CapsuleItemRowsTableCreateCompanionBuilder =
    CapsuleItemRowsCompanion Function({
      required String id,
      required String capsuleId,
      required String type,
      Value<String?> encryptedPath,
      Value<String?> encryptedText,
      Value<String?> textTitle,
      Value<String?> mimeType,
      Value<int> byteSize,
      required DateTime createdAt,
      required int orderIndex,
      Value<int> rowid,
    });
typedef $$CapsuleItemRowsTableUpdateCompanionBuilder =
    CapsuleItemRowsCompanion Function({
      Value<String> id,
      Value<String> capsuleId,
      Value<String> type,
      Value<String?> encryptedPath,
      Value<String?> encryptedText,
      Value<String?> textTitle,
      Value<String?> mimeType,
      Value<int> byteSize,
      Value<DateTime> createdAt,
      Value<int> orderIndex,
      Value<int> rowid,
    });

final class $$CapsuleItemRowsTableReferences
    extends
        BaseReferences<_$AppDatabase, $CapsuleItemRowsTable, CapsuleItemRow> {
  $$CapsuleItemRowsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CapsuleRowsTable _capsuleIdTable(_$AppDatabase db) =>
      db.capsuleRows.createAlias(
        $_aliasNameGenerator(db.capsuleItemRows.capsuleId, db.capsuleRows.id),
      );

  $$CapsuleRowsTableProcessedTableManager get capsuleId {
    final $_column = $_itemColumn<String>('capsule_id')!;

    final manager = $$CapsuleRowsTableTableManager(
      $_db,
      $_db.capsuleRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_capsuleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CapsuleItemRowsTableFilterComposer
    extends Composer<_$AppDatabase, $CapsuleItemRowsTable> {
  $$CapsuleItemRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get encryptedPath => $composableBuilder(
    column: $table.encryptedPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get encryptedText => $composableBuilder(
    column: $table.encryptedText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textTitle => $composableBuilder(
    column: $table.textTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get byteSize => $composableBuilder(
    column: $table.byteSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  $$CapsuleRowsTableFilterComposer get capsuleId {
    final $$CapsuleRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.capsuleId,
      referencedTable: $db.capsuleRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CapsuleRowsTableFilterComposer(
            $db: $db,
            $table: $db.capsuleRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CapsuleItemRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $CapsuleItemRowsTable> {
  $$CapsuleItemRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get encryptedPath => $composableBuilder(
    column: $table.encryptedPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get encryptedText => $composableBuilder(
    column: $table.encryptedText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textTitle => $composableBuilder(
    column: $table.textTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get byteSize => $composableBuilder(
    column: $table.byteSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  $$CapsuleRowsTableOrderingComposer get capsuleId {
    final $$CapsuleRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.capsuleId,
      referencedTable: $db.capsuleRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CapsuleRowsTableOrderingComposer(
            $db: $db,
            $table: $db.capsuleRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CapsuleItemRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CapsuleItemRowsTable> {
  $$CapsuleItemRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get encryptedPath => $composableBuilder(
    column: $table.encryptedPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get encryptedText => $composableBuilder(
    column: $table.encryptedText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get textTitle =>
      $composableBuilder(column: $table.textTitle, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get byteSize =>
      $composableBuilder(column: $table.byteSize, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  $$CapsuleRowsTableAnnotationComposer get capsuleId {
    final $$CapsuleRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.capsuleId,
      referencedTable: $db.capsuleRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CapsuleRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.capsuleRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CapsuleItemRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CapsuleItemRowsTable,
          CapsuleItemRow,
          $$CapsuleItemRowsTableFilterComposer,
          $$CapsuleItemRowsTableOrderingComposer,
          $$CapsuleItemRowsTableAnnotationComposer,
          $$CapsuleItemRowsTableCreateCompanionBuilder,
          $$CapsuleItemRowsTableUpdateCompanionBuilder,
          (CapsuleItemRow, $$CapsuleItemRowsTableReferences),
          CapsuleItemRow,
          PrefetchHooks Function({bool capsuleId})
        > {
  $$CapsuleItemRowsTableTableManager(
    _$AppDatabase db,
    $CapsuleItemRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$CapsuleItemRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$CapsuleItemRowsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$CapsuleItemRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> capsuleId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> encryptedPath = const Value.absent(),
                Value<String?> encryptedText = const Value.absent(),
                Value<String?> textTitle = const Value.absent(),
                Value<String?> mimeType = const Value.absent(),
                Value<int> byteSize = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CapsuleItemRowsCompanion(
                id: id,
                capsuleId: capsuleId,
                type: type,
                encryptedPath: encryptedPath,
                encryptedText: encryptedText,
                textTitle: textTitle,
                mimeType: mimeType,
                byteSize: byteSize,
                createdAt: createdAt,
                orderIndex: orderIndex,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String capsuleId,
                required String type,
                Value<String?> encryptedPath = const Value.absent(),
                Value<String?> encryptedText = const Value.absent(),
                Value<String?> textTitle = const Value.absent(),
                Value<String?> mimeType = const Value.absent(),
                Value<int> byteSize = const Value.absent(),
                required DateTime createdAt,
                required int orderIndex,
                Value<int> rowid = const Value.absent(),
              }) => CapsuleItemRowsCompanion.insert(
                id: id,
                capsuleId: capsuleId,
                type: type,
                encryptedPath: encryptedPath,
                encryptedText: encryptedText,
                textTitle: textTitle,
                mimeType: mimeType,
                byteSize: byteSize,
                createdAt: createdAt,
                orderIndex: orderIndex,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$CapsuleItemRowsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({capsuleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (capsuleId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.capsuleId,
                            referencedTable: $$CapsuleItemRowsTableReferences
                                ._capsuleIdTable(db),
                            referencedColumn:
                                $$CapsuleItemRowsTableReferences
                                    ._capsuleIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CapsuleItemRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CapsuleItemRowsTable,
      CapsuleItemRow,
      $$CapsuleItemRowsTableFilterComposer,
      $$CapsuleItemRowsTableOrderingComposer,
      $$CapsuleItemRowsTableAnnotationComposer,
      $$CapsuleItemRowsTableCreateCompanionBuilder,
      $$CapsuleItemRowsTableUpdateCompanionBuilder,
      (CapsuleItemRow, $$CapsuleItemRowsTableReferences),
      CapsuleItemRow,
      PrefetchHooks Function({bool capsuleId})
    >;
typedef $$AppSettingRowsTableCreateCompanionBuilder =
    AppSettingRowsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingRowsTableUpdateCompanionBuilder =
    AppSettingRowsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingRowsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingRowsTable> {
  $$AppSettingRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingRowsTable> {
  $$AppSettingRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingRowsTable> {
  $$AppSettingRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingRowsTable,
          AppSettingRow,
          $$AppSettingRowsTableFilterComposer,
          $$AppSettingRowsTableOrderingComposer,
          $$AppSettingRowsTableAnnotationComposer,
          $$AppSettingRowsTableCreateCompanionBuilder,
          $$AppSettingRowsTableUpdateCompanionBuilder,
          (
            AppSettingRow,
            BaseReferences<_$AppDatabase, $AppSettingRowsTable, AppSettingRow>,
          ),
          AppSettingRow,
          PrefetchHooks Function()
        > {
  $$AppSettingRowsTableTableManager(
    _$AppDatabase db,
    $AppSettingRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$AppSettingRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$AppSettingRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$AppSettingRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  AppSettingRowsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingRowsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingRowsTable,
      AppSettingRow,
      $$AppSettingRowsTableFilterComposer,
      $$AppSettingRowsTableOrderingComposer,
      $$AppSettingRowsTableAnnotationComposer,
      $$AppSettingRowsTableCreateCompanionBuilder,
      $$AppSettingRowsTableUpdateCompanionBuilder,
      (
        AppSettingRow,
        BaseReferences<_$AppDatabase, $AppSettingRowsTable, AppSettingRow>,
      ),
      AppSettingRow,
      PrefetchHooks Function()
    >;
typedef $$BackupMetadataRowsTableCreateCompanionBuilder =
    BackupMetadataRowsCompanion Function({
      Value<int> id,
      required DateTime createdAt,
      required String destinationName,
      required int byteSize,
    });
typedef $$BackupMetadataRowsTableUpdateCompanionBuilder =
    BackupMetadataRowsCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      Value<String> destinationName,
      Value<int> byteSize,
    });

class $$BackupMetadataRowsTableFilterComposer
    extends Composer<_$AppDatabase, $BackupMetadataRowsTable> {
  $$BackupMetadataRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destinationName => $composableBuilder(
    column: $table.destinationName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get byteSize => $composableBuilder(
    column: $table.byteSize,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BackupMetadataRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $BackupMetadataRowsTable> {
  $$BackupMetadataRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destinationName => $composableBuilder(
    column: $table.destinationName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get byteSize => $composableBuilder(
    column: $table.byteSize,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BackupMetadataRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BackupMetadataRowsTable> {
  $$BackupMetadataRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get destinationName => $composableBuilder(
    column: $table.destinationName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get byteSize =>
      $composableBuilder(column: $table.byteSize, builder: (column) => column);
}

class $$BackupMetadataRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BackupMetadataRowsTable,
          BackupMetadataRow,
          $$BackupMetadataRowsTableFilterComposer,
          $$BackupMetadataRowsTableOrderingComposer,
          $$BackupMetadataRowsTableAnnotationComposer,
          $$BackupMetadataRowsTableCreateCompanionBuilder,
          $$BackupMetadataRowsTableUpdateCompanionBuilder,
          (
            BackupMetadataRow,
            BaseReferences<
              _$AppDatabase,
              $BackupMetadataRowsTable,
              BackupMetadataRow
            >,
          ),
          BackupMetadataRow,
          PrefetchHooks Function()
        > {
  $$BackupMetadataRowsTableTableManager(
    _$AppDatabase db,
    $BackupMetadataRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$BackupMetadataRowsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$BackupMetadataRowsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$BackupMetadataRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> destinationName = const Value.absent(),
                Value<int> byteSize = const Value.absent(),
              }) => BackupMetadataRowsCompanion(
                id: id,
                createdAt: createdAt,
                destinationName: destinationName,
                byteSize: byteSize,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime createdAt,
                required String destinationName,
                required int byteSize,
              }) => BackupMetadataRowsCompanion.insert(
                id: id,
                createdAt: createdAt,
                destinationName: destinationName,
                byteSize: byteSize,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BackupMetadataRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BackupMetadataRowsTable,
      BackupMetadataRow,
      $$BackupMetadataRowsTableFilterComposer,
      $$BackupMetadataRowsTableOrderingComposer,
      $$BackupMetadataRowsTableAnnotationComposer,
      $$BackupMetadataRowsTableCreateCompanionBuilder,
      $$BackupMetadataRowsTableUpdateCompanionBuilder,
      (
        BackupMetadataRow,
        BaseReferences<
          _$AppDatabase,
          $BackupMetadataRowsTable,
          BackupMetadataRow
        >,
      ),
      BackupMetadataRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoryRowsTableTableManager get categoryRows =>
      $$CategoryRowsTableTableManager(_db, _db.categoryRows);
  $$CapsuleRowsTableTableManager get capsuleRows =>
      $$CapsuleRowsTableTableManager(_db, _db.capsuleRows);
  $$CapsuleItemRowsTableTableManager get capsuleItemRows =>
      $$CapsuleItemRowsTableTableManager(_db, _db.capsuleItemRows);
  $$AppSettingRowsTableTableManager get appSettingRows =>
      $$AppSettingRowsTableTableManager(_db, _db.appSettingRows);
  $$BackupMetadataRowsTableTableManager get backupMetadataRows =>
      $$BackupMetadataRowsTableTableManager(_db, _db.backupMetadataRows);
}
