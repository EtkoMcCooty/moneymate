// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TrackersTable extends Trackers with TableInfo<$TrackersTable, Tracker> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _cycleStartDayMeta =
      const VerificationMeta('cycleStartDay');
  @override
  late final GeneratedColumn<int> cycleStartDay = GeneratedColumn<int>(
      'cycle_start_day', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(15));
  static const VerificationMeta _currencySymbolMeta =
      const VerificationMeta('currencySymbol');
  @override
  late final GeneratedColumn<String> currencySymbol = GeneratedColumn<String>(
      'currency_symbol', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('£'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, cycleStartDay, currencySymbol, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trackers';
  @override
  VerificationContext validateIntegrity(Insertable<Tracker> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('cycle_start_day')) {
      context.handle(
          _cycleStartDayMeta,
          cycleStartDay.isAcceptableOrUnknown(
              data['cycle_start_day']!, _cycleStartDayMeta));
    }
    if (data.containsKey('currency_symbol')) {
      context.handle(
          _currencySymbolMeta,
          currencySymbol.isAcceptableOrUnknown(
              data['currency_symbol']!, _currencySymbolMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tracker map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tracker(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      cycleStartDay: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cycle_start_day'])!,
      currencySymbol: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}currency_symbol'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $TrackersTable createAlias(String alias) {
    return $TrackersTable(attachedDatabase, alias);
  }
}

class Tracker extends DataClass implements Insertable<Tracker> {
  final int id;
  final String name;
  final int cycleStartDay;
  final String currencySymbol;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Tracker(
      {required this.id,
      required this.name,
      required this.cycleStartDay,
      required this.currencySymbol,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['cycle_start_day'] = Variable<int>(cycleStartDay);
    map['currency_symbol'] = Variable<String>(currencySymbol);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TrackersCompanion toCompanion(bool nullToAbsent) {
    return TrackersCompanion(
      id: Value(id),
      name: Value(name),
      cycleStartDay: Value(cycleStartDay),
      currencySymbol: Value(currencySymbol),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Tracker.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tracker(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      cycleStartDay: serializer.fromJson<int>(json['cycleStartDay']),
      currencySymbol: serializer.fromJson<String>(json['currencySymbol']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'cycleStartDay': serializer.toJson<int>(cycleStartDay),
      'currencySymbol': serializer.toJson<String>(currencySymbol),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Tracker copyWith(
          {int? id,
          String? name,
          int? cycleStartDay,
          String? currencySymbol,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Tracker(
        id: id ?? this.id,
        name: name ?? this.name,
        cycleStartDay: cycleStartDay ?? this.cycleStartDay,
        currencySymbol: currencySymbol ?? this.currencySymbol,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Tracker copyWithCompanion(TrackersCompanion data) {
    return Tracker(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      cycleStartDay: data.cycleStartDay.present
          ? data.cycleStartDay.value
          : this.cycleStartDay,
      currencySymbol: data.currencySymbol.present
          ? data.currencySymbol.value
          : this.currencySymbol,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tracker(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('cycleStartDay: $cycleStartDay, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, cycleStartDay, currencySymbol, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tracker &&
          other.id == this.id &&
          other.name == this.name &&
          other.cycleStartDay == this.cycleStartDay &&
          other.currencySymbol == this.currencySymbol &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TrackersCompanion extends UpdateCompanion<Tracker> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> cycleStartDay;
  final Value<String> currencySymbol;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const TrackersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.cycleStartDay = const Value.absent(),
    this.currencySymbol = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TrackersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.cycleStartDay = const Value.absent(),
    this.currencySymbol = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Tracker> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? cycleStartDay,
    Expression<String>? currencySymbol,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (cycleStartDay != null) 'cycle_start_day': cycleStartDay,
      if (currencySymbol != null) 'currency_symbol': currencySymbol,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TrackersCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<int>? cycleStartDay,
      Value<String>? currencySymbol,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return TrackersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      cycleStartDay: cycleStartDay ?? this.cycleStartDay,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (cycleStartDay.present) {
      map['cycle_start_day'] = Variable<int>(cycleStartDay.value);
    }
    if (currencySymbol.present) {
      map['currency_symbol'] = Variable<String>(currencySymbol.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('cycleStartDay: $cycleStartDay, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _trackerIdMeta =
      const VerificationMeta('trackerId');
  @override
  late final GeneratedColumn<int> trackerId = GeneratedColumn<int>(
      'tracker_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES trackers (id) ON DELETE CASCADE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _categoryTypeMeta =
      const VerificationMeta('categoryType');
  @override
  late final GeneratedColumn<String> categoryType = GeneratedColumn<String>(
      'category_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, trackerId, name, categoryType, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<Category> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tracker_id')) {
      context.handle(_trackerIdMeta,
          trackerId.isAcceptableOrUnknown(data['tracker_id']!, _trackerIdMeta));
    } else if (isInserting) {
      context.missing(_trackerIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category_type')) {
      context.handle(
          _categoryTypeMeta,
          categoryType.isAcceptableOrUnknown(
              data['category_type']!, _categoryTypeMeta));
    } else if (isInserting) {
      context.missing(_categoryTypeMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      trackerId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tracker_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      categoryType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_type'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final int trackerId;
  final String name;
  final String categoryType;
  final int sortOrder;
  const Category(
      {required this.id,
      required this.trackerId,
      required this.name,
      required this.categoryType,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tracker_id'] = Variable<int>(trackerId);
    map['name'] = Variable<String>(name);
    map['category_type'] = Variable<String>(categoryType);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      trackerId: Value(trackerId),
      name: Value(name),
      categoryType: Value(categoryType),
      sortOrder: Value(sortOrder),
    );
  }

  factory Category.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      trackerId: serializer.fromJson<int>(json['trackerId']),
      name: serializer.fromJson<String>(json['name']),
      categoryType: serializer.fromJson<String>(json['categoryType']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'trackerId': serializer.toJson<int>(trackerId),
      'name': serializer.toJson<String>(name),
      'categoryType': serializer.toJson<String>(categoryType),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Category copyWith(
          {int? id,
          int? trackerId,
          String? name,
          String? categoryType,
          int? sortOrder}) =>
      Category(
        id: id ?? this.id,
        trackerId: trackerId ?? this.trackerId,
        name: name ?? this.name,
        categoryType: categoryType ?? this.categoryType,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      trackerId: data.trackerId.present ? data.trackerId.value : this.trackerId,
      name: data.name.present ? data.name.value : this.name,
      categoryType: data.categoryType.present
          ? data.categoryType.value
          : this.categoryType,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('trackerId: $trackerId, ')
          ..write('name: $name, ')
          ..write('categoryType: $categoryType, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, trackerId, name, categoryType, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.trackerId == this.trackerId &&
          other.name == this.name &&
          other.categoryType == this.categoryType &&
          other.sortOrder == this.sortOrder);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<int> trackerId;
  final Value<String> name;
  final Value<String> categoryType;
  final Value<int> sortOrder;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.trackerId = const Value.absent(),
    this.name = const Value.absent(),
    this.categoryType = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required int trackerId,
    required String name,
    required String categoryType,
    this.sortOrder = const Value.absent(),
  })  : trackerId = Value(trackerId),
        name = Value(name),
        categoryType = Value(categoryType);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<int>? trackerId,
    Expression<String>? name,
    Expression<String>? categoryType,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trackerId != null) 'tracker_id': trackerId,
      if (name != null) 'name': name,
      if (categoryType != null) 'category_type': categoryType,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  CategoriesCompanion copyWith(
      {Value<int>? id,
      Value<int>? trackerId,
      Value<String>? name,
      Value<String>? categoryType,
      Value<int>? sortOrder}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      trackerId: trackerId ?? this.trackerId,
      name: name ?? this.name,
      categoryType: categoryType ?? this.categoryType,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (trackerId.present) {
      map['tracker_id'] = Variable<int>(trackerId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (categoryType.present) {
      map['category_type'] = Variable<String>(categoryType.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('trackerId: $trackerId, ')
          ..write('name: $name, ')
          ..write('categoryType: $categoryType, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $FinanceItemsTable extends FinanceItems
    with TableInfo<$FinanceItemsTable, FinanceItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FinanceItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES categories (id) ON DELETE CASCADE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _dueDayMeta = const VerificationMeta('dueDay');
  @override
  late final GeneratedColumn<int> dueDay = GeneratedColumn<int>(
      'due_day', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, categoryId, name, dueDay, isArchived];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'finance_items';
  @override
  VerificationContext validateIntegrity(Insertable<FinanceItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('due_day')) {
      context.handle(_dueDayMeta,
          dueDay.isAcceptableOrUnknown(data['due_day']!, _dueDayMeta));
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FinanceItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FinanceItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      dueDay: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}due_day']),
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
    );
  }

  @override
  $FinanceItemsTable createAlias(String alias) {
    return $FinanceItemsTable(attachedDatabase, alias);
  }
}

class FinanceItem extends DataClass implements Insertable<FinanceItem> {
  final int id;
  final int categoryId;
  final String name;
  final int? dueDay;
  final bool isArchived;
  const FinanceItem(
      {required this.id,
      required this.categoryId,
      required this.name,
      this.dueDay,
      required this.isArchived});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category_id'] = Variable<int>(categoryId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || dueDay != null) {
      map['due_day'] = Variable<int>(dueDay);
    }
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  FinanceItemsCompanion toCompanion(bool nullToAbsent) {
    return FinanceItemsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      name: Value(name),
      dueDay:
          dueDay == null && nullToAbsent ? const Value.absent() : Value(dueDay),
      isArchived: Value(isArchived),
    );
  }

  factory FinanceItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FinanceItem(
      id: serializer.fromJson<int>(json['id']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      name: serializer.fromJson<String>(json['name']),
      dueDay: serializer.fromJson<int?>(json['dueDay']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categoryId': serializer.toJson<int>(categoryId),
      'name': serializer.toJson<String>(name),
      'dueDay': serializer.toJson<int?>(dueDay),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  FinanceItem copyWith(
          {int? id,
          int? categoryId,
          String? name,
          Value<int?> dueDay = const Value.absent(),
          bool? isArchived}) =>
      FinanceItem(
        id: id ?? this.id,
        categoryId: categoryId ?? this.categoryId,
        name: name ?? this.name,
        dueDay: dueDay.present ? dueDay.value : this.dueDay,
        isArchived: isArchived ?? this.isArchived,
      );
  FinanceItem copyWithCompanion(FinanceItemsCompanion data) {
    return FinanceItem(
      id: data.id.present ? data.id.value : this.id,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      name: data.name.present ? data.name.value : this.name,
      dueDay: data.dueDay.present ? data.dueDay.value : this.dueDay,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FinanceItem(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('dueDay: $dueDay, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, categoryId, name, dueDay, isArchived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FinanceItem &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.name == this.name &&
          other.dueDay == this.dueDay &&
          other.isArchived == this.isArchived);
}

class FinanceItemsCompanion extends UpdateCompanion<FinanceItem> {
  final Value<int> id;
  final Value<int> categoryId;
  final Value<String> name;
  final Value<int?> dueDay;
  final Value<bool> isArchived;
  const FinanceItemsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.name = const Value.absent(),
    this.dueDay = const Value.absent(),
    this.isArchived = const Value.absent(),
  });
  FinanceItemsCompanion.insert({
    this.id = const Value.absent(),
    required int categoryId,
    required String name,
    this.dueDay = const Value.absent(),
    this.isArchived = const Value.absent(),
  })  : categoryId = Value(categoryId),
        name = Value(name);
  static Insertable<FinanceItem> custom({
    Expression<int>? id,
    Expression<int>? categoryId,
    Expression<String>? name,
    Expression<int>? dueDay,
    Expression<bool>? isArchived,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (name != null) 'name': name,
      if (dueDay != null) 'due_day': dueDay,
      if (isArchived != null) 'is_archived': isArchived,
    });
  }

  FinanceItemsCompanion copyWith(
      {Value<int>? id,
      Value<int>? categoryId,
      Value<String>? name,
      Value<int?>? dueDay,
      Value<bool>? isArchived}) {
    return FinanceItemsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      dueDay: dueDay ?? this.dueDay,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (dueDay.present) {
      map['due_day'] = Variable<int>(dueDay.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FinanceItemsCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('dueDay: $dueDay, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }
}

class $DebtMetadataTable extends DebtMetadata
    with TableInfo<$DebtMetadataTable, DebtMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DebtMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
      'item_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES finance_items (id) ON DELETE CASCADE'));
  static const VerificationMeta _totalPrincipalMeta =
      const VerificationMeta('totalPrincipal');
  @override
  late final GeneratedColumn<double> totalPrincipal = GeneratedColumn<double>(
      'total_principal', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _interestRateMeta =
      const VerificationMeta('interestRate');
  @override
  late final GeneratedColumn<double> interestRate = GeneratedColumn<double>(
      'interest_rate', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, itemId, totalPrincipal, interestRate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'debt_metadata';
  @override
  VerificationContext validateIntegrity(Insertable<DebtMetadataData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('total_principal')) {
      context.handle(
          _totalPrincipalMeta,
          totalPrincipal.isAcceptableOrUnknown(
              data['total_principal']!, _totalPrincipalMeta));
    }
    if (data.containsKey('interest_rate')) {
      context.handle(
          _interestRateMeta,
          interestRate.isAcceptableOrUnknown(
              data['interest_rate']!, _interestRateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DebtMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DebtMetadataData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}item_id'])!,
      totalPrincipal: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}total_principal'])!,
      interestRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}interest_rate'])!,
    );
  }

  @override
  $DebtMetadataTable createAlias(String alias) {
    return $DebtMetadataTable(attachedDatabase, alias);
  }
}

class DebtMetadataData extends DataClass
    implements Insertable<DebtMetadataData> {
  final int id;
  final int itemId;
  final double totalPrincipal;
  final double interestRate;
  const DebtMetadataData(
      {required this.id,
      required this.itemId,
      required this.totalPrincipal,
      required this.interestRate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['item_id'] = Variable<int>(itemId);
    map['total_principal'] = Variable<double>(totalPrincipal);
    map['interest_rate'] = Variable<double>(interestRate);
    return map;
  }

  DebtMetadataCompanion toCompanion(bool nullToAbsent) {
    return DebtMetadataCompanion(
      id: Value(id),
      itemId: Value(itemId),
      totalPrincipal: Value(totalPrincipal),
      interestRate: Value(interestRate),
    );
  }

  factory DebtMetadataData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DebtMetadataData(
      id: serializer.fromJson<int>(json['id']),
      itemId: serializer.fromJson<int>(json['itemId']),
      totalPrincipal: serializer.fromJson<double>(json['totalPrincipal']),
      interestRate: serializer.fromJson<double>(json['interestRate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'itemId': serializer.toJson<int>(itemId),
      'totalPrincipal': serializer.toJson<double>(totalPrincipal),
      'interestRate': serializer.toJson<double>(interestRate),
    };
  }

  DebtMetadataData copyWith(
          {int? id,
          int? itemId,
          double? totalPrincipal,
          double? interestRate}) =>
      DebtMetadataData(
        id: id ?? this.id,
        itemId: itemId ?? this.itemId,
        totalPrincipal: totalPrincipal ?? this.totalPrincipal,
        interestRate: interestRate ?? this.interestRate,
      );
  DebtMetadataData copyWithCompanion(DebtMetadataCompanion data) {
    return DebtMetadataData(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      totalPrincipal: data.totalPrincipal.present
          ? data.totalPrincipal.value
          : this.totalPrincipal,
      interestRate: data.interestRate.present
          ? data.interestRate.value
          : this.interestRate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DebtMetadataData(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('totalPrincipal: $totalPrincipal, ')
          ..write('interestRate: $interestRate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, itemId, totalPrincipal, interestRate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DebtMetadataData &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.totalPrincipal == this.totalPrincipal &&
          other.interestRate == this.interestRate);
}

class DebtMetadataCompanion extends UpdateCompanion<DebtMetadataData> {
  final Value<int> id;
  final Value<int> itemId;
  final Value<double> totalPrincipal;
  final Value<double> interestRate;
  const DebtMetadataCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.totalPrincipal = const Value.absent(),
    this.interestRate = const Value.absent(),
  });
  DebtMetadataCompanion.insert({
    this.id = const Value.absent(),
    required int itemId,
    this.totalPrincipal = const Value.absent(),
    this.interestRate = const Value.absent(),
  }) : itemId = Value(itemId);
  static Insertable<DebtMetadataData> custom({
    Expression<int>? id,
    Expression<int>? itemId,
    Expression<double>? totalPrincipal,
    Expression<double>? interestRate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (totalPrincipal != null) 'total_principal': totalPrincipal,
      if (interestRate != null) 'interest_rate': interestRate,
    });
  }

  DebtMetadataCompanion copyWith(
      {Value<int>? id,
      Value<int>? itemId,
      Value<double>? totalPrincipal,
      Value<double>? interestRate}) {
    return DebtMetadataCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      totalPrincipal: totalPrincipal ?? this.totalPrincipal,
      interestRate: interestRate ?? this.interestRate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<int>(itemId.value);
    }
    if (totalPrincipal.present) {
      map['total_principal'] = Variable<double>(totalPrincipal.value);
    }
    if (interestRate.present) {
      map['interest_rate'] = Variable<double>(interestRate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DebtMetadataCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('totalPrincipal: $totalPrincipal, ')
          ..write('interestRate: $interestRate')
          ..write(')'))
        .toString();
  }
}

class $ItemEntriesTable extends ItemEntries
    with TableInfo<$ItemEntriesTable, ItemEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
      'item_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES finance_items (id) ON DELETE CASCADE'));
  static const VerificationMeta _periodKeyMeta =
      const VerificationMeta('periodKey');
  @override
  late final GeneratedColumn<String> periodKey = GeneratedColumn<String>(
      'period_key', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 7, maxTextLength: 7),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _extraPaymentMeta =
      const VerificationMeta('extraPayment');
  @override
  late final GeneratedColumn<double> extraPayment = GeneratedColumn<double>(
      'extra_payment', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, itemId, periodKey, amount, extraPayment, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'item_entries';
  @override
  VerificationContext validateIntegrity(Insertable<ItemEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('period_key')) {
      context.handle(_periodKeyMeta,
          periodKey.isAcceptableOrUnknown(data['period_key']!, _periodKeyMeta));
    } else if (isInserting) {
      context.missing(_periodKeyMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    }
    if (data.containsKey('extra_payment')) {
      context.handle(
          _extraPaymentMeta,
          extraPayment.isAcceptableOrUnknown(
              data['extra_payment']!, _extraPaymentMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItemEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}item_id'])!,
      periodKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}period_key'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      extraPayment: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}extra_payment'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
    );
  }

  @override
  $ItemEntriesTable createAlias(String alias) {
    return $ItemEntriesTable(attachedDatabase, alias);
  }
}

class ItemEntry extends DataClass implements Insertable<ItemEntry> {
  final int id;
  final int itemId;
  final String periodKey;
  final double amount;
  final double extraPayment;
  final String? note;
  const ItemEntry(
      {required this.id,
      required this.itemId,
      required this.periodKey,
      required this.amount,
      required this.extraPayment,
      this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['item_id'] = Variable<int>(itemId);
    map['period_key'] = Variable<String>(periodKey);
    map['amount'] = Variable<double>(amount);
    map['extra_payment'] = Variable<double>(extraPayment);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  ItemEntriesCompanion toCompanion(bool nullToAbsent) {
    return ItemEntriesCompanion(
      id: Value(id),
      itemId: Value(itemId),
      periodKey: Value(periodKey),
      amount: Value(amount),
      extraPayment: Value(extraPayment),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory ItemEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemEntry(
      id: serializer.fromJson<int>(json['id']),
      itemId: serializer.fromJson<int>(json['itemId']),
      periodKey: serializer.fromJson<String>(json['periodKey']),
      amount: serializer.fromJson<double>(json['amount']),
      extraPayment: serializer.fromJson<double>(json['extraPayment']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'itemId': serializer.toJson<int>(itemId),
      'periodKey': serializer.toJson<String>(periodKey),
      'amount': serializer.toJson<double>(amount),
      'extraPayment': serializer.toJson<double>(extraPayment),
      'note': serializer.toJson<String?>(note),
    };
  }

  ItemEntry copyWith(
          {int? id,
          int? itemId,
          String? periodKey,
          double? amount,
          double? extraPayment,
          Value<String?> note = const Value.absent()}) =>
      ItemEntry(
        id: id ?? this.id,
        itemId: itemId ?? this.itemId,
        periodKey: periodKey ?? this.periodKey,
        amount: amount ?? this.amount,
        extraPayment: extraPayment ?? this.extraPayment,
        note: note.present ? note.value : this.note,
      );
  ItemEntry copyWithCompanion(ItemEntriesCompanion data) {
    return ItemEntry(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      periodKey: data.periodKey.present ? data.periodKey.value : this.periodKey,
      amount: data.amount.present ? data.amount.value : this.amount,
      extraPayment: data.extraPayment.present
          ? data.extraPayment.value
          : this.extraPayment,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemEntry(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('periodKey: $periodKey, ')
          ..write('amount: $amount, ')
          ..write('extraPayment: $extraPayment, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, itemId, periodKey, amount, extraPayment, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemEntry &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.periodKey == this.periodKey &&
          other.amount == this.amount &&
          other.extraPayment == this.extraPayment &&
          other.note == this.note);
}

class ItemEntriesCompanion extends UpdateCompanion<ItemEntry> {
  final Value<int> id;
  final Value<int> itemId;
  final Value<String> periodKey;
  final Value<double> amount;
  final Value<double> extraPayment;
  final Value<String?> note;
  const ItemEntriesCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.periodKey = const Value.absent(),
    this.amount = const Value.absent(),
    this.extraPayment = const Value.absent(),
    this.note = const Value.absent(),
  });
  ItemEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int itemId,
    required String periodKey,
    this.amount = const Value.absent(),
    this.extraPayment = const Value.absent(),
    this.note = const Value.absent(),
  })  : itemId = Value(itemId),
        periodKey = Value(periodKey);
  static Insertable<ItemEntry> custom({
    Expression<int>? id,
    Expression<int>? itemId,
    Expression<String>? periodKey,
    Expression<double>? amount,
    Expression<double>? extraPayment,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (periodKey != null) 'period_key': periodKey,
      if (amount != null) 'amount': amount,
      if (extraPayment != null) 'extra_payment': extraPayment,
      if (note != null) 'note': note,
    });
  }

  ItemEntriesCompanion copyWith(
      {Value<int>? id,
      Value<int>? itemId,
      Value<String>? periodKey,
      Value<double>? amount,
      Value<double>? extraPayment,
      Value<String?>? note}) {
    return ItemEntriesCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      periodKey: periodKey ?? this.periodKey,
      amount: amount ?? this.amount,
      extraPayment: extraPayment ?? this.extraPayment,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<int>(itemId.value);
    }
    if (periodKey.present) {
      map['period_key'] = Variable<String>(periodKey.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (extraPayment.present) {
      map['extra_payment'] = Variable<double>(extraPayment.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemEntriesCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('periodKey: $periodKey, ')
          ..write('amount: $amount, ')
          ..write('extraPayment: $extraPayment, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(Insertable<AppSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory AppSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
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

  AppSetting copyWith({String? key, String? value}) => AppSetting(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
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
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<AppSetting> custom({
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

  AppSettingsCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return AppSettingsCompanion(
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
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TrackersTable trackers = $TrackersTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $FinanceItemsTable financeItems = $FinanceItemsTable(this);
  late final $DebtMetadataTable debtMetadata = $DebtMetadataTable(this);
  late final $ItemEntriesTable itemEntries = $ItemEntriesTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        trackers,
        categories,
        financeItems,
        debtMetadata,
        itemEntries,
        appSettings
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('trackers',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('categories', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('categories',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('finance_items', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('finance_items',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('debt_metadata', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('finance_items',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('item_entries', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$TrackersTableCreateCompanionBuilder = TrackersCompanion Function({
  Value<int> id,
  required String name,
  Value<int> cycleStartDay,
  Value<String> currencySymbol,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$TrackersTableUpdateCompanionBuilder = TrackersCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> cycleStartDay,
  Value<String> currencySymbol,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$TrackersTableReferences
    extends BaseReferences<_$AppDatabase, $TrackersTable, Tracker> {
  $$TrackersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CategoriesTable, List<Category>>
      _categoriesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.categories,
              aliasName: 'trackers__id__categories__tracker_id');

  $$CategoriesTableProcessedTableManager get categoriesRefs {
    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.trackerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_categoriesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TrackersTableFilterComposer
    extends Composer<_$AppDatabase, $TrackersTable> {
  $$TrackersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cycleStartDay => $composableBuilder(
      column: $table.cycleStartDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currencySymbol => $composableBuilder(
      column: $table.currencySymbol,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> categoriesRefs(
      Expression<bool> Function($$CategoriesTableFilterComposer f) f) {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.trackerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TrackersTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackersTable> {
  $$TrackersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cycleStartDay => $composableBuilder(
      column: $table.cycleStartDay,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currencySymbol => $composableBuilder(
      column: $table.currencySymbol,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$TrackersTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackersTable> {
  $$TrackersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get cycleStartDay => $composableBuilder(
      column: $table.cycleStartDay, builder: (column) => column);

  GeneratedColumn<String> get currencySymbol => $composableBuilder(
      column: $table.currencySymbol, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> categoriesRefs<T extends Object>(
      Expression<T> Function($$CategoriesTableAnnotationComposer a) f) {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.trackerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TrackersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TrackersTable,
    Tracker,
    $$TrackersTableFilterComposer,
    $$TrackersTableOrderingComposer,
    $$TrackersTableAnnotationComposer,
    $$TrackersTableCreateCompanionBuilder,
    $$TrackersTableUpdateCompanionBuilder,
    (Tracker, $$TrackersTableReferences),
    Tracker,
    PrefetchHooks Function({bool categoriesRefs})> {
  $$TrackersTableTableManager(_$AppDatabase db, $TrackersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> cycleStartDay = const Value.absent(),
            Value<String> currencySymbol = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              TrackersCompanion(
            id: id,
            name: name,
            cycleStartDay: cycleStartDay,
            currencySymbol: currencySymbol,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<int> cycleStartDay = const Value.absent(),
            Value<String> currencySymbol = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              TrackersCompanion.insert(
            id: id,
            name: name,
            cycleStartDay: cycleStartDay,
            currencySymbol: currencySymbol,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$TrackersTable, Tracker>(table),
                    $$TrackersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({categoriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (categoriesRefs) db.categories],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (categoriesRefs)
                    await $_getPrefetchedDataByColumns<Tracker, $TrackersTable,
                            Category, $CategoriesTable>(
                        currentTable: table,
                        referencedTable:
                            $$TrackersTableReferences._categoriesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TrackersTableReferences(db, table, p0)
                                .categoriesRefs,
                        currentColumn: 'id',
                        referencedColumn: 'tracker_id',
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TrackersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TrackersTable,
    Tracker,
    $$TrackersTableFilterComposer,
    $$TrackersTableOrderingComposer,
    $$TrackersTableAnnotationComposer,
    $$TrackersTableCreateCompanionBuilder,
    $$TrackersTableUpdateCompanionBuilder,
    (Tracker, $$TrackersTableReferences),
    Tracker,
    PrefetchHooks Function({bool categoriesRefs})>;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  required int trackerId,
  required String name,
  required String categoryType,
  Value<int> sortOrder,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  Value<int> trackerId,
  Value<String> name,
  Value<String> categoryType,
  Value<int> sortOrder,
});

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TrackersTable _trackerIdTable(_$AppDatabase db) =>
      db.trackers.createAlias('categories__tracker_id__trackers__id');

  $$TrackersTableProcessedTableManager get trackerId {
    final $_column = $_itemColumn<int>('tracker_id')!;

    final manager = $$TrackersTableTableManager($_db, $_db.trackers)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_trackerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$FinanceItemsTable, List<FinanceItem>>
      _financeItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.financeItems,
              aliasName: 'categories__id__finance_items__category_id');

  $$FinanceItemsTableProcessedTableManager get financeItemsRefs {
    final manager = $$FinanceItemsTableTableManager($_db, $_db.financeItems)
        .filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_financeItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryType => $composableBuilder(
      column: $table.categoryType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  $$TrackersTableFilterComposer get trackerId {
    final $$TrackersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.trackerId,
        referencedTable: $db.trackers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TrackersTableFilterComposer(
              $db: $db,
              $table: $db.trackers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> financeItemsRefs(
      Expression<bool> Function($$FinanceItemsTableFilterComposer f) f) {
    final $$FinanceItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.financeItems,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FinanceItemsTableFilterComposer(
              $db: $db,
              $table: $db.financeItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryType => $composableBuilder(
      column: $table.categoryType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  $$TrackersTableOrderingComposer get trackerId {
    final $$TrackersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.trackerId,
        referencedTable: $db.trackers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TrackersTableOrderingComposer(
              $db: $db,
              $table: $db.trackers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get categoryType => $composableBuilder(
      column: $table.categoryType, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$TrackersTableAnnotationComposer get trackerId {
    final $$TrackersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.trackerId,
        referencedTable: $db.trackers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TrackersTableAnnotationComposer(
              $db: $db,
              $table: $db.trackers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> financeItemsRefs<T extends Object>(
      Expression<T> Function($$FinanceItemsTableAnnotationComposer a) f) {
    final $$FinanceItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.financeItems,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FinanceItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.financeItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, $$CategoriesTableReferences),
    Category,
    PrefetchHooks Function({bool trackerId, bool financeItemsRefs})> {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> trackerId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> categoryType = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
          }) =>
              CategoriesCompanion(
            id: id,
            trackerId: trackerId,
            name: name,
            categoryType: categoryType,
            sortOrder: sortOrder,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int trackerId,
            required String name,
            required String categoryType,
            Value<int> sortOrder = const Value.absent(),
          }) =>
              CategoriesCompanion.insert(
            id: id,
            trackerId: trackerId,
            name: name,
            categoryType: categoryType,
            sortOrder: sortOrder,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CategoriesTable, Category>(table),
                    $$CategoriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {trackerId = false, financeItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (financeItemsRefs) db.financeItems],
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
                      dynamic>>(state) {
                if (trackerId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.trackerId,
                    referencedTable:
                        $$CategoriesTableReferences._trackerIdTable(db),
                    referencedColumn:
                        $$CategoriesTableReferences._trackerIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (financeItemsRefs)
                    await $_getPrefetchedDataByColumns<Category,
                            $CategoriesTable, FinanceItem, $FinanceItemsTable>(
                        currentTable: table,
                        referencedTable: $$CategoriesTableReferences
                            ._financeItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableReferences(db, table, p0)
                                .financeItemsRefs,
                        currentColumn: 'id',
                        referencedColumn: 'category_id',
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, $$CategoriesTableReferences),
    Category,
    PrefetchHooks Function({bool trackerId, bool financeItemsRefs})>;
typedef $$FinanceItemsTableCreateCompanionBuilder = FinanceItemsCompanion
    Function({
  Value<int> id,
  required int categoryId,
  required String name,
  Value<int?> dueDay,
  Value<bool> isArchived,
});
typedef $$FinanceItemsTableUpdateCompanionBuilder = FinanceItemsCompanion
    Function({
  Value<int> id,
  Value<int> categoryId,
  Value<String> name,
  Value<int?> dueDay,
  Value<bool> isArchived,
});

final class $$FinanceItemsTableReferences
    extends BaseReferences<_$AppDatabase, $FinanceItemsTable, FinanceItem> {
  $$FinanceItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('finance_items__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$DebtMetadataTable, List<DebtMetadataData>>
      _debtMetadataRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.debtMetadata,
              aliasName: 'finance_items__id__debt_metadata__item_id');

  $$DebtMetadataTableProcessedTableManager get debtMetadataRefs {
    final manager = $$DebtMetadataTableTableManager($_db, $_db.debtMetadata)
        .filter((f) => f.itemId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_debtMetadataRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ItemEntriesTable, List<ItemEntry>>
      _itemEntriesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.itemEntries,
              aliasName: 'finance_items__id__item_entries__item_id');

  $$ItemEntriesTableProcessedTableManager get itemEntriesRefs {
    final manager = $$ItemEntriesTableTableManager($_db, $_db.itemEntries)
        .filter((f) => f.itemId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_itemEntriesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$FinanceItemsTableFilterComposer
    extends Composer<_$AppDatabase, $FinanceItemsTable> {
  $$FinanceItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dueDay => $composableBuilder(
      column: $table.dueDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> debtMetadataRefs(
      Expression<bool> Function($$DebtMetadataTableFilterComposer f) f) {
    final $$DebtMetadataTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.debtMetadata,
        getReferencedColumn: (t) => t.itemId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DebtMetadataTableFilterComposer(
              $db: $db,
              $table: $db.debtMetadata,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> itemEntriesRefs(
      Expression<bool> Function($$ItemEntriesTableFilterComposer f) f) {
    final $$ItemEntriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.itemEntries,
        getReferencedColumn: (t) => t.itemId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ItemEntriesTableFilterComposer(
              $db: $db,
              $table: $db.itemEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$FinanceItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $FinanceItemsTable> {
  $$FinanceItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dueDay => $composableBuilder(
      column: $table.dueDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FinanceItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FinanceItemsTable> {
  $$FinanceItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get dueDay =>
      $composableBuilder(column: $table.dueDay, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> debtMetadataRefs<T extends Object>(
      Expression<T> Function($$DebtMetadataTableAnnotationComposer a) f) {
    final $$DebtMetadataTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.debtMetadata,
        getReferencedColumn: (t) => t.itemId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DebtMetadataTableAnnotationComposer(
              $db: $db,
              $table: $db.debtMetadata,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> itemEntriesRefs<T extends Object>(
      Expression<T> Function($$ItemEntriesTableAnnotationComposer a) f) {
    final $$ItemEntriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.itemEntries,
        getReferencedColumn: (t) => t.itemId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ItemEntriesTableAnnotationComposer(
              $db: $db,
              $table: $db.itemEntries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$FinanceItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FinanceItemsTable,
    FinanceItem,
    $$FinanceItemsTableFilterComposer,
    $$FinanceItemsTableOrderingComposer,
    $$FinanceItemsTableAnnotationComposer,
    $$FinanceItemsTableCreateCompanionBuilder,
    $$FinanceItemsTableUpdateCompanionBuilder,
    (FinanceItem, $$FinanceItemsTableReferences),
    FinanceItem,
    PrefetchHooks Function(
        {bool categoryId, bool debtMetadataRefs, bool itemEntriesRefs})> {
  $$FinanceItemsTableTableManager(_$AppDatabase db, $FinanceItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FinanceItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FinanceItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FinanceItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> categoryId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int?> dueDay = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
          }) =>
              FinanceItemsCompanion(
            id: id,
            categoryId: categoryId,
            name: name,
            dueDay: dueDay,
            isArchived: isArchived,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int categoryId,
            required String name,
            Value<int?> dueDay = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
          }) =>
              FinanceItemsCompanion.insert(
            id: id,
            categoryId: categoryId,
            name: name,
            dueDay: dueDay,
            isArchived: isArchived,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$FinanceItemsTable, FinanceItem>(table),
                    $$FinanceItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {categoryId = false,
              debtMetadataRefs = false,
              itemEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (debtMetadataRefs) db.debtMetadata,
                if (itemEntriesRefs) db.itemEntries
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
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$FinanceItemsTableReferences._categoryIdTable(db),
                    referencedColumn:
                        $$FinanceItemsTableReferences._categoryIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (debtMetadataRefs)
                    await $_getPrefetchedDataByColumns<
                            FinanceItem,
                            $FinanceItemsTable,
                            DebtMetadataData,
                            $DebtMetadataTable>(
                        currentTable: table,
                        referencedTable: $$FinanceItemsTableReferences
                            ._debtMetadataRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$FinanceItemsTableReferences(db, table, p0)
                                .debtMetadataRefs,
                        currentColumn: 'id',
                        referencedColumn: 'item_id',
                        typedResults: items),
                  if (itemEntriesRefs)
                    await $_getPrefetchedDataByColumns<FinanceItem,
                            $FinanceItemsTable, ItemEntry, $ItemEntriesTable>(
                        currentTable: table,
                        referencedTable: $$FinanceItemsTableReferences
                            ._itemEntriesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$FinanceItemsTableReferences(db, table, p0)
                                .itemEntriesRefs,
                        currentColumn: 'id',
                        referencedColumn: 'item_id',
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$FinanceItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FinanceItemsTable,
    FinanceItem,
    $$FinanceItemsTableFilterComposer,
    $$FinanceItemsTableOrderingComposer,
    $$FinanceItemsTableAnnotationComposer,
    $$FinanceItemsTableCreateCompanionBuilder,
    $$FinanceItemsTableUpdateCompanionBuilder,
    (FinanceItem, $$FinanceItemsTableReferences),
    FinanceItem,
    PrefetchHooks Function(
        {bool categoryId, bool debtMetadataRefs, bool itemEntriesRefs})>;
typedef $$DebtMetadataTableCreateCompanionBuilder = DebtMetadataCompanion
    Function({
  Value<int> id,
  required int itemId,
  Value<double> totalPrincipal,
  Value<double> interestRate,
});
typedef $$DebtMetadataTableUpdateCompanionBuilder = DebtMetadataCompanion
    Function({
  Value<int> id,
  Value<int> itemId,
  Value<double> totalPrincipal,
  Value<double> interestRate,
});

final class $$DebtMetadataTableReferences extends BaseReferences<_$AppDatabase,
    $DebtMetadataTable, DebtMetadataData> {
  $$DebtMetadataTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FinanceItemsTable _itemIdTable(_$AppDatabase db) =>
      db.financeItems.createAlias('debt_metadata__item_id__finance_items__id');

  $$FinanceItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<int>('item_id')!;

    final manager = $$FinanceItemsTableTableManager($_db, $_db.financeItems)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DebtMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $DebtMetadataTable> {
  $$DebtMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalPrincipal => $composableBuilder(
      column: $table.totalPrincipal,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get interestRate => $composableBuilder(
      column: $table.interestRate, builder: (column) => ColumnFilters(column));

  $$FinanceItemsTableFilterComposer get itemId {
    final $$FinanceItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.itemId,
        referencedTable: $db.financeItems,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FinanceItemsTableFilterComposer(
              $db: $db,
              $table: $db.financeItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DebtMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $DebtMetadataTable> {
  $$DebtMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalPrincipal => $composableBuilder(
      column: $table.totalPrincipal,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get interestRate => $composableBuilder(
      column: $table.interestRate,
      builder: (column) => ColumnOrderings(column));

  $$FinanceItemsTableOrderingComposer get itemId {
    final $$FinanceItemsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.itemId,
        referencedTable: $db.financeItems,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FinanceItemsTableOrderingComposer(
              $db: $db,
              $table: $db.financeItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DebtMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $DebtMetadataTable> {
  $$DebtMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get totalPrincipal => $composableBuilder(
      column: $table.totalPrincipal, builder: (column) => column);

  GeneratedColumn<double> get interestRate => $composableBuilder(
      column: $table.interestRate, builder: (column) => column);

  $$FinanceItemsTableAnnotationComposer get itemId {
    final $$FinanceItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.itemId,
        referencedTable: $db.financeItems,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FinanceItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.financeItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DebtMetadataTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DebtMetadataTable,
    DebtMetadataData,
    $$DebtMetadataTableFilterComposer,
    $$DebtMetadataTableOrderingComposer,
    $$DebtMetadataTableAnnotationComposer,
    $$DebtMetadataTableCreateCompanionBuilder,
    $$DebtMetadataTableUpdateCompanionBuilder,
    (DebtMetadataData, $$DebtMetadataTableReferences),
    DebtMetadataData,
    PrefetchHooks Function({bool itemId})> {
  $$DebtMetadataTableTableManager(_$AppDatabase db, $DebtMetadataTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DebtMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DebtMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DebtMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> itemId = const Value.absent(),
            Value<double> totalPrincipal = const Value.absent(),
            Value<double> interestRate = const Value.absent(),
          }) =>
              DebtMetadataCompanion(
            id: id,
            itemId: itemId,
            totalPrincipal: totalPrincipal,
            interestRate: interestRate,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int itemId,
            Value<double> totalPrincipal = const Value.absent(),
            Value<double> interestRate = const Value.absent(),
          }) =>
              DebtMetadataCompanion.insert(
            id: id,
            itemId: itemId,
            totalPrincipal: totalPrincipal,
            interestRate: interestRate,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$DebtMetadataTable, DebtMetadataData>(table),
                    $$DebtMetadataTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({itemId = false}) {
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
                      dynamic>>(state) {
                if (itemId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.itemId,
                    referencedTable:
                        $$DebtMetadataTableReferences._itemIdTable(db),
                    referencedColumn:
                        $$DebtMetadataTableReferences._itemIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$DebtMetadataTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DebtMetadataTable,
    DebtMetadataData,
    $$DebtMetadataTableFilterComposer,
    $$DebtMetadataTableOrderingComposer,
    $$DebtMetadataTableAnnotationComposer,
    $$DebtMetadataTableCreateCompanionBuilder,
    $$DebtMetadataTableUpdateCompanionBuilder,
    (DebtMetadataData, $$DebtMetadataTableReferences),
    DebtMetadataData,
    PrefetchHooks Function({bool itemId})>;
typedef $$ItemEntriesTableCreateCompanionBuilder = ItemEntriesCompanion
    Function({
  Value<int> id,
  required int itemId,
  required String periodKey,
  Value<double> amount,
  Value<double> extraPayment,
  Value<String?> note,
});
typedef $$ItemEntriesTableUpdateCompanionBuilder = ItemEntriesCompanion
    Function({
  Value<int> id,
  Value<int> itemId,
  Value<String> periodKey,
  Value<double> amount,
  Value<double> extraPayment,
  Value<String?> note,
});

final class $$ItemEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $ItemEntriesTable, ItemEntry> {
  $$ItemEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FinanceItemsTable _itemIdTable(_$AppDatabase db) =>
      db.financeItems.createAlias('item_entries__item_id__finance_items__id');

  $$FinanceItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<int>('item_id')!;

    final manager = $$FinanceItemsTableTableManager($_db, $_db.financeItems)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ItemEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ItemEntriesTable> {
  $$ItemEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get periodKey => $composableBuilder(
      column: $table.periodKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get extraPayment => $composableBuilder(
      column: $table.extraPayment, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  $$FinanceItemsTableFilterComposer get itemId {
    final $$FinanceItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.itemId,
        referencedTable: $db.financeItems,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FinanceItemsTableFilterComposer(
              $db: $db,
              $table: $db.financeItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ItemEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemEntriesTable> {
  $$ItemEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get periodKey => $composableBuilder(
      column: $table.periodKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get extraPayment => $composableBuilder(
      column: $table.extraPayment,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  $$FinanceItemsTableOrderingComposer get itemId {
    final $$FinanceItemsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.itemId,
        referencedTable: $db.financeItems,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FinanceItemsTableOrderingComposer(
              $db: $db,
              $table: $db.financeItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ItemEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemEntriesTable> {
  $$ItemEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get periodKey =>
      $composableBuilder(column: $table.periodKey, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<double> get extraPayment => $composableBuilder(
      column: $table.extraPayment, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$FinanceItemsTableAnnotationComposer get itemId {
    final $$FinanceItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.itemId,
        referencedTable: $db.financeItems,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FinanceItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.financeItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ItemEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ItemEntriesTable,
    ItemEntry,
    $$ItemEntriesTableFilterComposer,
    $$ItemEntriesTableOrderingComposer,
    $$ItemEntriesTableAnnotationComposer,
    $$ItemEntriesTableCreateCompanionBuilder,
    $$ItemEntriesTableUpdateCompanionBuilder,
    (ItemEntry, $$ItemEntriesTableReferences),
    ItemEntry,
    PrefetchHooks Function({bool itemId})> {
  $$ItemEntriesTableTableManager(_$AppDatabase db, $ItemEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> itemId = const Value.absent(),
            Value<String> periodKey = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<double> extraPayment = const Value.absent(),
            Value<String?> note = const Value.absent(),
          }) =>
              ItemEntriesCompanion(
            id: id,
            itemId: itemId,
            periodKey: periodKey,
            amount: amount,
            extraPayment: extraPayment,
            note: note,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int itemId,
            required String periodKey,
            Value<double> amount = const Value.absent(),
            Value<double> extraPayment = const Value.absent(),
            Value<String?> note = const Value.absent(),
          }) =>
              ItemEntriesCompanion.insert(
            id: id,
            itemId: itemId,
            periodKey: periodKey,
            amount: amount,
            extraPayment: extraPayment,
            note: note,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ItemEntriesTable, ItemEntry>(table),
                    $$ItemEntriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({itemId = false}) {
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
                      dynamic>>(state) {
                if (itemId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.itemId,
                    referencedTable:
                        $$ItemEntriesTableReferences._itemIdTable(db),
                    referencedColumn:
                        $$ItemEntriesTableReferences._itemIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ItemEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ItemEntriesTable,
    ItemEntry,
    $$ItemEntriesTableFilterComposer,
    $$ItemEntriesTableOrderingComposer,
    $$ItemEntriesTableAnnotationComposer,
    $$ItemEntriesTableCreateCompanionBuilder,
    $$ItemEntriesTableUpdateCompanionBuilder,
    (ItemEntry, $$ItemEntriesTableReferences),
    ItemEntry,
    PrefetchHooks Function({bool itemId})>;
typedef $$AppSettingsTableCreateCompanionBuilder = AppSettingsCompanion
    Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$AppSettingsTableUpdateCompanionBuilder = AppSettingsCompanion
    Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
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

class $$AppSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSetting,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (AppSetting, BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>),
    AppSetting,
    PrefetchHooks Function()> {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$AppSettingsTable, AppSetting>(table),
                    BaseReferences<_$AppDatabase, $AppSettingsTable,
                        AppSetting>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSetting,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (AppSetting, BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>),
    AppSetting,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TrackersTableTableManager get trackers =>
      $$TrackersTableTableManager(_db, _db.trackers);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$FinanceItemsTableTableManager get financeItems =>
      $$FinanceItemsTableTableManager(_db, _db.financeItems);
  $$DebtMetadataTableTableManager get debtMetadata =>
      $$DebtMetadataTableTableManager(_db, _db.debtMetadata);
  $$ItemEntriesTableTableManager get itemEntries =>
      $$ItemEntriesTableTableManager(_db, _db.itemEntries);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
