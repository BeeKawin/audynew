// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UserProgressTable extends UserProgress
    with TableInfo<$UserProgressTable, UserProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProgressTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _learningPointsMeta = const VerificationMeta(
    'learningPoints',
  );
  @override
  late final GeneratedColumn<int> learningPoints = GeneratedColumn<int>(
    'learning_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _gamesPlayedMeta = const VerificationMeta(
    'gamesPlayed',
  );
  @override
  late final GeneratedColumn<int> gamesPlayed = GeneratedColumn<int>(
    'games_played',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dayStreakMeta = const VerificationMeta(
    'dayStreak',
  );
  @override
  late final GeneratedColumn<int> dayStreak = GeneratedColumn<int>(
    'day_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _lastPlayedAtMeta = const VerificationMeta(
    'lastPlayedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPlayedAt = GeneratedColumn<DateTime>(
    'last_played_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    learningPoints,
    gamesPlayed,
    dayStreak,
    lastPlayedAt,
    updatedAt,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('learning_points')) {
      context.handle(
        _learningPointsMeta,
        learningPoints.isAcceptableOrUnknown(
          data['learning_points']!,
          _learningPointsMeta,
        ),
      );
    }
    if (data.containsKey('games_played')) {
      context.handle(
        _gamesPlayedMeta,
        gamesPlayed.isAcceptableOrUnknown(
          data['games_played']!,
          _gamesPlayedMeta,
        ),
      );
    }
    if (data.containsKey('day_streak')) {
      context.handle(
        _dayStreakMeta,
        dayStreak.isAcceptableOrUnknown(data['day_streak']!, _dayStreakMeta),
      );
    }
    if (data.containsKey('last_played_at')) {
      context.handle(
        _lastPlayedAtMeta,
        lastPlayedAt.isAcceptableOrUnknown(
          data['last_played_at']!,
          _lastPlayedAtMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProgressData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      learningPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}learning_points'],
      )!,
      gamesPlayed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}games_played'],
      )!,
      dayStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_streak'],
      )!,
      lastPlayedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_played_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $UserProgressTable createAlias(String alias) {
    return $UserProgressTable(attachedDatabase, alias);
  }
}

class UserProgressData extends DataClass
    implements Insertable<UserProgressData> {
  final int id;
  final int learningPoints;
  final int gamesPlayed;
  final int dayStreak;
  final DateTime? lastPlayedAt;
  final DateTime updatedAt;
  final bool isSynced;
  const UserProgressData({
    required this.id,
    required this.learningPoints,
    required this.gamesPlayed,
    required this.dayStreak,
    this.lastPlayedAt,
    required this.updatedAt,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['learning_points'] = Variable<int>(learningPoints);
    map['games_played'] = Variable<int>(gamesPlayed);
    map['day_streak'] = Variable<int>(dayStreak);
    if (!nullToAbsent || lastPlayedAt != null) {
      map['last_played_at'] = Variable<DateTime>(lastPlayedAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  UserProgressCompanion toCompanion(bool nullToAbsent) {
    return UserProgressCompanion(
      id: Value(id),
      learningPoints: Value(learningPoints),
      gamesPlayed: Value(gamesPlayed),
      dayStreak: Value(dayStreak),
      lastPlayedAt: lastPlayedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPlayedAt),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
    );
  }

  factory UserProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProgressData(
      id: serializer.fromJson<int>(json['id']),
      learningPoints: serializer.fromJson<int>(json['learningPoints']),
      gamesPlayed: serializer.fromJson<int>(json['gamesPlayed']),
      dayStreak: serializer.fromJson<int>(json['dayStreak']),
      lastPlayedAt: serializer.fromJson<DateTime?>(json['lastPlayedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'learningPoints': serializer.toJson<int>(learningPoints),
      'gamesPlayed': serializer.toJson<int>(gamesPlayed),
      'dayStreak': serializer.toJson<int>(dayStreak),
      'lastPlayedAt': serializer.toJson<DateTime?>(lastPlayedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  UserProgressData copyWith({
    int? id,
    int? learningPoints,
    int? gamesPlayed,
    int? dayStreak,
    Value<DateTime?> lastPlayedAt = const Value.absent(),
    DateTime? updatedAt,
    bool? isSynced,
  }) => UserProgressData(
    id: id ?? this.id,
    learningPoints: learningPoints ?? this.learningPoints,
    gamesPlayed: gamesPlayed ?? this.gamesPlayed,
    dayStreak: dayStreak ?? this.dayStreak,
    lastPlayedAt: lastPlayedAt.present ? lastPlayedAt.value : this.lastPlayedAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isSynced: isSynced ?? this.isSynced,
  );
  UserProgressData copyWithCompanion(UserProgressCompanion data) {
    return UserProgressData(
      id: data.id.present ? data.id.value : this.id,
      learningPoints: data.learningPoints.present
          ? data.learningPoints.value
          : this.learningPoints,
      gamesPlayed: data.gamesPlayed.present
          ? data.gamesPlayed.value
          : this.gamesPlayed,
      dayStreak: data.dayStreak.present ? data.dayStreak.value : this.dayStreak,
      lastPlayedAt: data.lastPlayedAt.present
          ? data.lastPlayedAt.value
          : this.lastPlayedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProgressData(')
          ..write('id: $id, ')
          ..write('learningPoints: $learningPoints, ')
          ..write('gamesPlayed: $gamesPlayed, ')
          ..write('dayStreak: $dayStreak, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    learningPoints,
    gamesPlayed,
    dayStreak,
    lastPlayedAt,
    updatedAt,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProgressData &&
          other.id == this.id &&
          other.learningPoints == this.learningPoints &&
          other.gamesPlayed == this.gamesPlayed &&
          other.dayStreak == this.dayStreak &&
          other.lastPlayedAt == this.lastPlayedAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced);
}

class UserProgressCompanion extends UpdateCompanion<UserProgressData> {
  final Value<int> id;
  final Value<int> learningPoints;
  final Value<int> gamesPlayed;
  final Value<int> dayStreak;
  final Value<DateTime?> lastPlayedAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isSynced;
  const UserProgressCompanion({
    this.id = const Value.absent(),
    this.learningPoints = const Value.absent(),
    this.gamesPlayed = const Value.absent(),
    this.dayStreak = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
  });
  UserProgressCompanion.insert({
    this.id = const Value.absent(),
    this.learningPoints = const Value.absent(),
    this.gamesPlayed = const Value.absent(),
    this.dayStreak = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    required DateTime updatedAt,
    this.isSynced = const Value.absent(),
  }) : updatedAt = Value(updatedAt);
  static Insertable<UserProgressData> custom({
    Expression<int>? id,
    Expression<int>? learningPoints,
    Expression<int>? gamesPlayed,
    Expression<int>? dayStreak,
    Expression<DateTime>? lastPlayedAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isSynced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (learningPoints != null) 'learning_points': learningPoints,
      if (gamesPlayed != null) 'games_played': gamesPlayed,
      if (dayStreak != null) 'day_streak': dayStreak,
      if (lastPlayedAt != null) 'last_played_at': lastPlayedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  UserProgressCompanion copyWith({
    Value<int>? id,
    Value<int>? learningPoints,
    Value<int>? gamesPlayed,
    Value<int>? dayStreak,
    Value<DateTime?>? lastPlayedAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isSynced,
  }) {
    return UserProgressCompanion(
      id: id ?? this.id,
      learningPoints: learningPoints ?? this.learningPoints,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      dayStreak: dayStreak ?? this.dayStreak,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (learningPoints.present) {
      map['learning_points'] = Variable<int>(learningPoints.value);
    }
    if (gamesPlayed.present) {
      map['games_played'] = Variable<int>(gamesPlayed.value);
    }
    if (dayStreak.present) {
      map['day_streak'] = Variable<int>(dayStreak.value);
    }
    if (lastPlayedAt.present) {
      map['last_played_at'] = Variable<DateTime>(lastPlayedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProgressCompanion(')
          ..write('id: $id, ')
          ..write('learningPoints: $learningPoints, ')
          ..write('gamesPlayed: $gamesPlayed, ')
          ..write('dayStreak: $dayStreak, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }
}

class $AccessoriesTable extends Accessories
    with TableInfo<$AccessoriesTable, Accessory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccessoriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<int> cost = GeneratedColumn<int>(
    'cost',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconNameMeta = const VerificationMeta(
    'iconName',
  );
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
    'icon_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, cost, iconName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accessories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Accessory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('cost')) {
      context.handle(
        _costMeta,
        cost.isAcceptableOrUnknown(data['cost']!, _costMeta),
      );
    } else if (isInserting) {
      context.missing(_costMeta);
    }
    if (data.containsKey('icon_name')) {
      context.handle(
        _iconNameMeta,
        iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta),
      );
    } else if (isInserting) {
      context.missing(_iconNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Accessory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Accessory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      cost: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cost'],
      )!,
      iconName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_name'],
      )!,
    );
  }

  @override
  $AccessoriesTable createAlias(String alias) {
    return $AccessoriesTable(attachedDatabase, alias);
  }
}

class Accessory extends DataClass implements Insertable<Accessory> {
  final int id;
  final String name;
  final int cost;
  final String iconName;
  const Accessory({
    required this.id,
    required this.name,
    required this.cost,
    required this.iconName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['cost'] = Variable<int>(cost);
    map['icon_name'] = Variable<String>(iconName);
    return map;
  }

  AccessoriesCompanion toCompanion(bool nullToAbsent) {
    return AccessoriesCompanion(
      id: Value(id),
      name: Value(name),
      cost: Value(cost),
      iconName: Value(iconName),
    );
  }

  factory Accessory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Accessory(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      cost: serializer.fromJson<int>(json['cost']),
      iconName: serializer.fromJson<String>(json['iconName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'cost': serializer.toJson<int>(cost),
      'iconName': serializer.toJson<String>(iconName),
    };
  }

  Accessory copyWith({int? id, String? name, int? cost, String? iconName}) =>
      Accessory(
        id: id ?? this.id,
        name: name ?? this.name,
        cost: cost ?? this.cost,
        iconName: iconName ?? this.iconName,
      );
  Accessory copyWithCompanion(AccessoriesCompanion data) {
    return Accessory(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      cost: data.cost.present ? data.cost.value : this.cost,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Accessory(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('cost: $cost, ')
          ..write('iconName: $iconName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, cost, iconName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Accessory &&
          other.id == this.id &&
          other.name == this.name &&
          other.cost == this.cost &&
          other.iconName == this.iconName);
}

class AccessoriesCompanion extends UpdateCompanion<Accessory> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> cost;
  final Value<String> iconName;
  const AccessoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.cost = const Value.absent(),
    this.iconName = const Value.absent(),
  });
  AccessoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int cost,
    required String iconName,
  }) : name = Value(name),
       cost = Value(cost),
       iconName = Value(iconName);
  static Insertable<Accessory> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? cost,
    Expression<String>? iconName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (cost != null) 'cost': cost,
      if (iconName != null) 'icon_name': iconName,
    });
  }

  AccessoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? cost,
    Value<String>? iconName,
  }) {
    return AccessoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      cost: cost ?? this.cost,
      iconName: iconName ?? this.iconName,
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
    if (cost.present) {
      map['cost'] = Variable<int>(cost.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccessoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('cost: $cost, ')
          ..write('iconName: $iconName')
          ..write(')'))
        .toString();
  }
}

class $UserAccessoriesTable extends UserAccessories
    with TableInfo<$UserAccessoriesTable, UserAccessory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserAccessoriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _accessoryIdMeta = const VerificationMeta(
    'accessoryId',
  );
  @override
  late final GeneratedColumn<int> accessoryId = GeneratedColumn<int>(
    'accessory_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownedMeta = const VerificationMeta('owned');
  @override
  late final GeneratedColumn<bool> owned = GeneratedColumn<bool>(
    'owned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("owned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _xMeta = const VerificationMeta('x');
  @override
  late final GeneratedColumn<int> x = GeneratedColumn<int>(
    'x',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yMeta = const VerificationMeta('y');
  @override
  late final GeneratedColumn<int> y = GeneratedColumn<int>(
    'y',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accessoryId,
    owned,
    x,
    y,
    updatedAt,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_accessories';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserAccessory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('accessory_id')) {
      context.handle(
        _accessoryIdMeta,
        accessoryId.isAcceptableOrUnknown(
          data['accessory_id']!,
          _accessoryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accessoryIdMeta);
    }
    if (data.containsKey('owned')) {
      context.handle(
        _ownedMeta,
        owned.isAcceptableOrUnknown(data['owned']!, _ownedMeta),
      );
    }
    if (data.containsKey('x')) {
      context.handle(_xMeta, x.isAcceptableOrUnknown(data['x']!, _xMeta));
    }
    if (data.containsKey('y')) {
      context.handle(_yMeta, y.isAcceptableOrUnknown(data['y']!, _yMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserAccessory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserAccessory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      accessoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accessory_id'],
      )!,
      owned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}owned'],
      )!,
      x: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}x'],
      ),
      y: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}y'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $UserAccessoriesTable createAlias(String alias) {
    return $UserAccessoriesTable(attachedDatabase, alias);
  }
}

class UserAccessory extends DataClass implements Insertable<UserAccessory> {
  final int id;
  final int accessoryId;
  final bool owned;
  final int? x;
  final int? y;
  final DateTime updatedAt;
  final bool isSynced;
  const UserAccessory({
    required this.id,
    required this.accessoryId,
    required this.owned,
    this.x,
    this.y,
    required this.updatedAt,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['accessory_id'] = Variable<int>(accessoryId);
    map['owned'] = Variable<bool>(owned);
    if (!nullToAbsent || x != null) {
      map['x'] = Variable<int>(x);
    }
    if (!nullToAbsent || y != null) {
      map['y'] = Variable<int>(y);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  UserAccessoriesCompanion toCompanion(bool nullToAbsent) {
    return UserAccessoriesCompanion(
      id: Value(id),
      accessoryId: Value(accessoryId),
      owned: Value(owned),
      x: x == null && nullToAbsent ? const Value.absent() : Value(x),
      y: y == null && nullToAbsent ? const Value.absent() : Value(y),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
    );
  }

  factory UserAccessory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserAccessory(
      id: serializer.fromJson<int>(json['id']),
      accessoryId: serializer.fromJson<int>(json['accessoryId']),
      owned: serializer.fromJson<bool>(json['owned']),
      x: serializer.fromJson<int?>(json['x']),
      y: serializer.fromJson<int?>(json['y']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'accessoryId': serializer.toJson<int>(accessoryId),
      'owned': serializer.toJson<bool>(owned),
      'x': serializer.toJson<int?>(x),
      'y': serializer.toJson<int?>(y),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  UserAccessory copyWith({
    int? id,
    int? accessoryId,
    bool? owned,
    Value<int?> x = const Value.absent(),
    Value<int?> y = const Value.absent(),
    DateTime? updatedAt,
    bool? isSynced,
  }) => UserAccessory(
    id: id ?? this.id,
    accessoryId: accessoryId ?? this.accessoryId,
    owned: owned ?? this.owned,
    x: x.present ? x.value : this.x,
    y: y.present ? y.value : this.y,
    updatedAt: updatedAt ?? this.updatedAt,
    isSynced: isSynced ?? this.isSynced,
  );
  UserAccessory copyWithCompanion(UserAccessoriesCompanion data) {
    return UserAccessory(
      id: data.id.present ? data.id.value : this.id,
      accessoryId: data.accessoryId.present
          ? data.accessoryId.value
          : this.accessoryId,
      owned: data.owned.present ? data.owned.value : this.owned,
      x: data.x.present ? data.x.value : this.x,
      y: data.y.present ? data.y.value : this.y,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserAccessory(')
          ..write('id: $id, ')
          ..write('accessoryId: $accessoryId, ')
          ..write('owned: $owned, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, accessoryId, owned, x, y, updatedAt, isSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserAccessory &&
          other.id == this.id &&
          other.accessoryId == this.accessoryId &&
          other.owned == this.owned &&
          other.x == this.x &&
          other.y == this.y &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced);
}

class UserAccessoriesCompanion extends UpdateCompanion<UserAccessory> {
  final Value<int> id;
  final Value<int> accessoryId;
  final Value<bool> owned;
  final Value<int?> x;
  final Value<int?> y;
  final Value<DateTime> updatedAt;
  final Value<bool> isSynced;
  const UserAccessoriesCompanion({
    this.id = const Value.absent(),
    this.accessoryId = const Value.absent(),
    this.owned = const Value.absent(),
    this.x = const Value.absent(),
    this.y = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
  });
  UserAccessoriesCompanion.insert({
    this.id = const Value.absent(),
    required int accessoryId,
    this.owned = const Value.absent(),
    this.x = const Value.absent(),
    this.y = const Value.absent(),
    required DateTime updatedAt,
    this.isSynced = const Value.absent(),
  }) : accessoryId = Value(accessoryId),
       updatedAt = Value(updatedAt);
  static Insertable<UserAccessory> custom({
    Expression<int>? id,
    Expression<int>? accessoryId,
    Expression<bool>? owned,
    Expression<int>? x,
    Expression<int>? y,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isSynced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accessoryId != null) 'accessory_id': accessoryId,
      if (owned != null) 'owned': owned,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  UserAccessoriesCompanion copyWith({
    Value<int>? id,
    Value<int>? accessoryId,
    Value<bool>? owned,
    Value<int?>? x,
    Value<int?>? y,
    Value<DateTime>? updatedAt,
    Value<bool>? isSynced,
  }) {
    return UserAccessoriesCompanion(
      id: id ?? this.id,
      accessoryId: accessoryId ?? this.accessoryId,
      owned: owned ?? this.owned,
      x: x ?? this.x,
      y: y ?? this.y,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (accessoryId.present) {
      map['accessory_id'] = Variable<int>(accessoryId.value);
    }
    if (owned.present) {
      map['owned'] = Variable<bool>(owned.value);
    }
    if (x.present) {
      map['x'] = Variable<int>(x.value);
    }
    if (y.present) {
      map['y'] = Variable<int>(y.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserAccessoriesCompanion(')
          ..write('id: $id, ')
          ..write('accessoryId: $accessoryId, ')
          ..write('owned: $owned, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }
}

class $AchievementsTable extends Achievements
    with TableInfo<$AchievementsTable, Achievement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AchievementsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, key, title, description];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'achievements';
  @override
  VerificationContext validateIntegrity(
    Insertable<Achievement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
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
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Achievement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Achievement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
    );
  }

  @override
  $AchievementsTable createAlias(String alias) {
    return $AchievementsTable(attachedDatabase, alias);
  }
}

class Achievement extends DataClass implements Insertable<Achievement> {
  final int id;
  final String key;
  final String title;
  final String description;
  const Achievement({
    required this.id,
    required this.key,
    required this.title,
    required this.description,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['key'] = Variable<String>(key);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    return map;
  }

  AchievementsCompanion toCompanion(bool nullToAbsent) {
    return AchievementsCompanion(
      id: Value(id),
      key: Value(key),
      title: Value(title),
      description: Value(description),
    );
  }

  factory Achievement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Achievement(
      id: serializer.fromJson<int>(json['id']),
      key: serializer.fromJson<String>(json['key']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'key': serializer.toJson<String>(key),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
    };
  }

  Achievement copyWith({
    int? id,
    String? key,
    String? title,
    String? description,
  }) => Achievement(
    id: id ?? this.id,
    key: key ?? this.key,
    title: title ?? this.title,
    description: description ?? this.description,
  );
  Achievement copyWithCompanion(AchievementsCompanion data) {
    return Achievement(
      id: data.id.present ? data.id.value : this.id,
      key: data.key.present ? data.key.value : this.key,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Achievement(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('title: $title, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, key, title, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Achievement &&
          other.id == this.id &&
          other.key == this.key &&
          other.title == this.title &&
          other.description == this.description);
}

class AchievementsCompanion extends UpdateCompanion<Achievement> {
  final Value<int> id;
  final Value<String> key;
  final Value<String> title;
  final Value<String> description;
  const AchievementsCompanion({
    this.id = const Value.absent(),
    this.key = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
  });
  AchievementsCompanion.insert({
    this.id = const Value.absent(),
    required String key,
    required String title,
    required String description,
  }) : key = Value(key),
       title = Value(title),
       description = Value(description);
  static Insertable<Achievement> custom({
    Expression<int>? id,
    Expression<String>? key,
    Expression<String>? title,
    Expression<String>? description,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (key != null) 'key': key,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
    });
  }

  AchievementsCompanion copyWith({
    Value<int>? id,
    Value<String>? key,
    Value<String>? title,
    Value<String>? description,
  }) {
    return AchievementsCompanion(
      id: id ?? this.id,
      key: key ?? this.key,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AchievementsCompanion(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('title: $title, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }
}

class $UserAchievementsTable extends UserAchievements
    with TableInfo<$UserAchievementsTable, UserAchievement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserAchievementsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _achievementIdMeta = const VerificationMeta(
    'achievementId',
  );
  @override
  late final GeneratedColumn<int> achievementId = GeneratedColumn<int>(
    'achievement_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unlockedMeta = const VerificationMeta(
    'unlocked',
  );
  @override
  late final GeneratedColumn<bool> unlocked = GeneratedColumn<bool>(
    'unlocked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("unlocked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
    'unlocked_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    achievementId,
    unlocked,
    unlockedAt,
    updatedAt,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_achievements';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserAchievement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('achievement_id')) {
      context.handle(
        _achievementIdMeta,
        achievementId.isAcceptableOrUnknown(
          data['achievement_id']!,
          _achievementIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_achievementIdMeta);
    }
    if (data.containsKey('unlocked')) {
      context.handle(
        _unlockedMeta,
        unlocked.isAcceptableOrUnknown(data['unlocked']!, _unlockedMeta),
      );
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserAchievement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserAchievement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      achievementId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}achievement_id'],
      )!,
      unlocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}unlocked'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unlocked_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $UserAchievementsTable createAlias(String alias) {
    return $UserAchievementsTable(attachedDatabase, alias);
  }
}

class UserAchievement extends DataClass implements Insertable<UserAchievement> {
  final int id;
  final int achievementId;
  final bool unlocked;
  final DateTime? unlockedAt;
  final DateTime updatedAt;
  final bool isSynced;
  const UserAchievement({
    required this.id,
    required this.achievementId,
    required this.unlocked,
    this.unlockedAt,
    required this.updatedAt,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['achievement_id'] = Variable<int>(achievementId);
    map['unlocked'] = Variable<bool>(unlocked);
    if (!nullToAbsent || unlockedAt != null) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  UserAchievementsCompanion toCompanion(bool nullToAbsent) {
    return UserAchievementsCompanion(
      id: Value(id),
      achievementId: Value(achievementId),
      unlocked: Value(unlocked),
      unlockedAt: unlockedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(unlockedAt),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
    );
  }

  factory UserAchievement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserAchievement(
      id: serializer.fromJson<int>(json['id']),
      achievementId: serializer.fromJson<int>(json['achievementId']),
      unlocked: serializer.fromJson<bool>(json['unlocked']),
      unlockedAt: serializer.fromJson<DateTime?>(json['unlockedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'achievementId': serializer.toJson<int>(achievementId),
      'unlocked': serializer.toJson<bool>(unlocked),
      'unlockedAt': serializer.toJson<DateTime?>(unlockedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  UserAchievement copyWith({
    int? id,
    int? achievementId,
    bool? unlocked,
    Value<DateTime?> unlockedAt = const Value.absent(),
    DateTime? updatedAt,
    bool? isSynced,
  }) => UserAchievement(
    id: id ?? this.id,
    achievementId: achievementId ?? this.achievementId,
    unlocked: unlocked ?? this.unlocked,
    unlockedAt: unlockedAt.present ? unlockedAt.value : this.unlockedAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isSynced: isSynced ?? this.isSynced,
  );
  UserAchievement copyWithCompanion(UserAchievementsCompanion data) {
    return UserAchievement(
      id: data.id.present ? data.id.value : this.id,
      achievementId: data.achievementId.present
          ? data.achievementId.value
          : this.achievementId,
      unlocked: data.unlocked.present ? data.unlocked.value : this.unlocked,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserAchievement(')
          ..write('id: $id, ')
          ..write('achievementId: $achievementId, ')
          ..write('unlocked: $unlocked, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, achievementId, unlocked, unlockedAt, updatedAt, isSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserAchievement &&
          other.id == this.id &&
          other.achievementId == this.achievementId &&
          other.unlocked == this.unlocked &&
          other.unlockedAt == this.unlockedAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced);
}

class UserAchievementsCompanion extends UpdateCompanion<UserAchievement> {
  final Value<int> id;
  final Value<int> achievementId;
  final Value<bool> unlocked;
  final Value<DateTime?> unlockedAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isSynced;
  const UserAchievementsCompanion({
    this.id = const Value.absent(),
    this.achievementId = const Value.absent(),
    this.unlocked = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
  });
  UserAchievementsCompanion.insert({
    this.id = const Value.absent(),
    required int achievementId,
    this.unlocked = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    required DateTime updatedAt,
    this.isSynced = const Value.absent(),
  }) : achievementId = Value(achievementId),
       updatedAt = Value(updatedAt);
  static Insertable<UserAchievement> custom({
    Expression<int>? id,
    Expression<int>? achievementId,
    Expression<bool>? unlocked,
    Expression<DateTime>? unlockedAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isSynced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (achievementId != null) 'achievement_id': achievementId,
      if (unlocked != null) 'unlocked': unlocked,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  UserAchievementsCompanion copyWith({
    Value<int>? id,
    Value<int>? achievementId,
    Value<bool>? unlocked,
    Value<DateTime?>? unlockedAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isSynced,
  }) {
    return UserAchievementsCompanion(
      id: id ?? this.id,
      achievementId: achievementId ?? this.achievementId,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (achievementId.present) {
      map['achievement_id'] = Variable<int>(achievementId.value);
    }
    if (unlocked.present) {
      map['unlocked'] = Variable<bool>(unlocked.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserAchievementsCompanion(')
          ..write('id: $id, ')
          ..write('achievementId: $achievementId, ')
          ..write('unlocked: $unlocked, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserProgressTable userProgress = $UserProgressTable(this);
  late final $AccessoriesTable accessories = $AccessoriesTable(this);
  late final $UserAccessoriesTable userAccessories = $UserAccessoriesTable(
    this,
  );
  late final $AchievementsTable achievements = $AchievementsTable(this);
  late final $UserAchievementsTable userAchievements = $UserAchievementsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userProgress,
    accessories,
    userAccessories,
    achievements,
    userAchievements,
  ];
}

typedef $$UserProgressTableCreateCompanionBuilder =
    UserProgressCompanion Function({
      Value<int> id,
      Value<int> learningPoints,
      Value<int> gamesPlayed,
      Value<int> dayStreak,
      Value<DateTime?> lastPlayedAt,
      required DateTime updatedAt,
      Value<bool> isSynced,
    });
typedef $$UserProgressTableUpdateCompanionBuilder =
    UserProgressCompanion Function({
      Value<int> id,
      Value<int> learningPoints,
      Value<int> gamesPlayed,
      Value<int> dayStreak,
      Value<DateTime?> lastPlayedAt,
      Value<DateTime> updatedAt,
      Value<bool> isSynced,
    });

class $$UserProgressTableFilterComposer
    extends Composer<_$AppDatabase, $UserProgressTable> {
  $$UserProgressTableFilterComposer({
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

  ColumnFilters<int> get learningPoints => $composableBuilder(
    column: $table.learningPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gamesPlayed => $composableBuilder(
    column: $table.gamesPlayed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayStreak => $composableBuilder(
    column: $table.dayStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProgressTable> {
  $$UserProgressTableOrderingComposer({
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

  ColumnOrderings<int> get learningPoints => $composableBuilder(
    column: $table.learningPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gamesPlayed => $composableBuilder(
    column: $table.gamesPlayed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayStreak => $composableBuilder(
    column: $table.dayStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProgressTable> {
  $$UserProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get learningPoints => $composableBuilder(
    column: $table.learningPoints,
    builder: (column) => column,
  );

  GeneratedColumn<int> get gamesPlayed => $composableBuilder(
    column: $table.gamesPlayed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dayStreak =>
      $composableBuilder(column: $table.dayStreak, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$UserProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProgressTable,
          UserProgressData,
          $$UserProgressTableFilterComposer,
          $$UserProgressTableOrderingComposer,
          $$UserProgressTableAnnotationComposer,
          $$UserProgressTableCreateCompanionBuilder,
          $$UserProgressTableUpdateCompanionBuilder,
          (
            UserProgressData,
            BaseReferences<_$AppDatabase, $UserProgressTable, UserProgressData>,
          ),
          UserProgressData,
          PrefetchHooks Function()
        > {
  $$UserProgressTableTableManager(_$AppDatabase db, $UserProgressTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> learningPoints = const Value.absent(),
                Value<int> gamesPlayed = const Value.absent(),
                Value<int> dayStreak = const Value.absent(),
                Value<DateTime?> lastPlayedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => UserProgressCompanion(
                id: id,
                learningPoints: learningPoints,
                gamesPlayed: gamesPlayed,
                dayStreak: dayStreak,
                lastPlayedAt: lastPlayedAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> learningPoints = const Value.absent(),
                Value<int> gamesPlayed = const Value.absent(),
                Value<int> dayStreak = const Value.absent(),
                Value<DateTime?> lastPlayedAt = const Value.absent(),
                required DateTime updatedAt,
                Value<bool> isSynced = const Value.absent(),
              }) => UserProgressCompanion.insert(
                id: id,
                learningPoints: learningPoints,
                gamesPlayed: gamesPlayed,
                dayStreak: dayStreak,
                lastPlayedAt: lastPlayedAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProgressTable,
      UserProgressData,
      $$UserProgressTableFilterComposer,
      $$UserProgressTableOrderingComposer,
      $$UserProgressTableAnnotationComposer,
      $$UserProgressTableCreateCompanionBuilder,
      $$UserProgressTableUpdateCompanionBuilder,
      (
        UserProgressData,
        BaseReferences<_$AppDatabase, $UserProgressTable, UserProgressData>,
      ),
      UserProgressData,
      PrefetchHooks Function()
    >;
typedef $$AccessoriesTableCreateCompanionBuilder =
    AccessoriesCompanion Function({
      Value<int> id,
      required String name,
      required int cost,
      required String iconName,
    });
typedef $$AccessoriesTableUpdateCompanionBuilder =
    AccessoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> cost,
      Value<String> iconName,
    });

class $$AccessoriesTableFilterComposer
    extends Composer<_$AppDatabase, $AccessoriesTable> {
  $$AccessoriesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AccessoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $AccessoriesTable> {
  $$AccessoriesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccessoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccessoriesTable> {
  $$AccessoriesTableAnnotationComposer({
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

  GeneratedColumn<int> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => column);

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);
}

class $$AccessoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccessoriesTable,
          Accessory,
          $$AccessoriesTableFilterComposer,
          $$AccessoriesTableOrderingComposer,
          $$AccessoriesTableAnnotationComposer,
          $$AccessoriesTableCreateCompanionBuilder,
          $$AccessoriesTableUpdateCompanionBuilder,
          (
            Accessory,
            BaseReferences<_$AppDatabase, $AccessoriesTable, Accessory>,
          ),
          Accessory,
          PrefetchHooks Function()
        > {
  $$AccessoriesTableTableManager(_$AppDatabase db, $AccessoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccessoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccessoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccessoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> cost = const Value.absent(),
                Value<String> iconName = const Value.absent(),
              }) => AccessoriesCompanion(
                id: id,
                name: name,
                cost: cost,
                iconName: iconName,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int cost,
                required String iconName,
              }) => AccessoriesCompanion.insert(
                id: id,
                name: name,
                cost: cost,
                iconName: iconName,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AccessoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccessoriesTable,
      Accessory,
      $$AccessoriesTableFilterComposer,
      $$AccessoriesTableOrderingComposer,
      $$AccessoriesTableAnnotationComposer,
      $$AccessoriesTableCreateCompanionBuilder,
      $$AccessoriesTableUpdateCompanionBuilder,
      (Accessory, BaseReferences<_$AppDatabase, $AccessoriesTable, Accessory>),
      Accessory,
      PrefetchHooks Function()
    >;
typedef $$UserAccessoriesTableCreateCompanionBuilder =
    UserAccessoriesCompanion Function({
      Value<int> id,
      required int accessoryId,
      Value<bool> owned,
      Value<int?> x,
      Value<int?> y,
      required DateTime updatedAt,
      Value<bool> isSynced,
    });
typedef $$UserAccessoriesTableUpdateCompanionBuilder =
    UserAccessoriesCompanion Function({
      Value<int> id,
      Value<int> accessoryId,
      Value<bool> owned,
      Value<int?> x,
      Value<int?> y,
      Value<DateTime> updatedAt,
      Value<bool> isSynced,
    });

class $$UserAccessoriesTableFilterComposer
    extends Composer<_$AppDatabase, $UserAccessoriesTable> {
  $$UserAccessoriesTableFilterComposer({
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

  ColumnFilters<int> get accessoryId => $composableBuilder(
    column: $table.accessoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get owned => $composableBuilder(
    column: $table.owned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserAccessoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserAccessoriesTable> {
  $$UserAccessoriesTableOrderingComposer({
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

  ColumnOrderings<int> get accessoryId => $composableBuilder(
    column: $table.accessoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get owned => $composableBuilder(
    column: $table.owned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserAccessoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserAccessoriesTable> {
  $$UserAccessoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get accessoryId => $composableBuilder(
    column: $table.accessoryId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get owned =>
      $composableBuilder(column: $table.owned, builder: (column) => column);

  GeneratedColumn<int> get x =>
      $composableBuilder(column: $table.x, builder: (column) => column);

  GeneratedColumn<int> get y =>
      $composableBuilder(column: $table.y, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$UserAccessoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserAccessoriesTable,
          UserAccessory,
          $$UserAccessoriesTableFilterComposer,
          $$UserAccessoriesTableOrderingComposer,
          $$UserAccessoriesTableAnnotationComposer,
          $$UserAccessoriesTableCreateCompanionBuilder,
          $$UserAccessoriesTableUpdateCompanionBuilder,
          (
            UserAccessory,
            BaseReferences<_$AppDatabase, $UserAccessoriesTable, UserAccessory>,
          ),
          UserAccessory,
          PrefetchHooks Function()
        > {
  $$UserAccessoriesTableTableManager(
    _$AppDatabase db,
    $UserAccessoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserAccessoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserAccessoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserAccessoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> accessoryId = const Value.absent(),
                Value<bool> owned = const Value.absent(),
                Value<int?> x = const Value.absent(),
                Value<int?> y = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => UserAccessoriesCompanion(
                id: id,
                accessoryId: accessoryId,
                owned: owned,
                x: x,
                y: y,
                updatedAt: updatedAt,
                isSynced: isSynced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int accessoryId,
                Value<bool> owned = const Value.absent(),
                Value<int?> x = const Value.absent(),
                Value<int?> y = const Value.absent(),
                required DateTime updatedAt,
                Value<bool> isSynced = const Value.absent(),
              }) => UserAccessoriesCompanion.insert(
                id: id,
                accessoryId: accessoryId,
                owned: owned,
                x: x,
                y: y,
                updatedAt: updatedAt,
                isSynced: isSynced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserAccessoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserAccessoriesTable,
      UserAccessory,
      $$UserAccessoriesTableFilterComposer,
      $$UserAccessoriesTableOrderingComposer,
      $$UserAccessoriesTableAnnotationComposer,
      $$UserAccessoriesTableCreateCompanionBuilder,
      $$UserAccessoriesTableUpdateCompanionBuilder,
      (
        UserAccessory,
        BaseReferences<_$AppDatabase, $UserAccessoriesTable, UserAccessory>,
      ),
      UserAccessory,
      PrefetchHooks Function()
    >;
typedef $$AchievementsTableCreateCompanionBuilder =
    AchievementsCompanion Function({
      Value<int> id,
      required String key,
      required String title,
      required String description,
    });
typedef $$AchievementsTableUpdateCompanionBuilder =
    AchievementsCompanion Function({
      Value<int> id,
      Value<String> key,
      Value<String> title,
      Value<String> description,
    });

class $$AchievementsTableFilterComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableFilterComposer({
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

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
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
}

class $$AchievementsTableOrderingComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableOrderingComposer({
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

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
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
}

class $$AchievementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );
}

class $$AchievementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AchievementsTable,
          Achievement,
          $$AchievementsTableFilterComposer,
          $$AchievementsTableOrderingComposer,
          $$AchievementsTableAnnotationComposer,
          $$AchievementsTableCreateCompanionBuilder,
          $$AchievementsTableUpdateCompanionBuilder,
          (
            Achievement,
            BaseReferences<_$AppDatabase, $AchievementsTable, Achievement>,
          ),
          Achievement,
          PrefetchHooks Function()
        > {
  $$AchievementsTableTableManager(_$AppDatabase db, $AchievementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AchievementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AchievementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AchievementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
              }) => AchievementsCompanion(
                id: id,
                key: key,
                title: title,
                description: description,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String key,
                required String title,
                required String description,
              }) => AchievementsCompanion.insert(
                id: id,
                key: key,
                title: title,
                description: description,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AchievementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AchievementsTable,
      Achievement,
      $$AchievementsTableFilterComposer,
      $$AchievementsTableOrderingComposer,
      $$AchievementsTableAnnotationComposer,
      $$AchievementsTableCreateCompanionBuilder,
      $$AchievementsTableUpdateCompanionBuilder,
      (
        Achievement,
        BaseReferences<_$AppDatabase, $AchievementsTable, Achievement>,
      ),
      Achievement,
      PrefetchHooks Function()
    >;
typedef $$UserAchievementsTableCreateCompanionBuilder =
    UserAchievementsCompanion Function({
      Value<int> id,
      required int achievementId,
      Value<bool> unlocked,
      Value<DateTime?> unlockedAt,
      required DateTime updatedAt,
      Value<bool> isSynced,
    });
typedef $$UserAchievementsTableUpdateCompanionBuilder =
    UserAchievementsCompanion Function({
      Value<int> id,
      Value<int> achievementId,
      Value<bool> unlocked,
      Value<DateTime?> unlockedAt,
      Value<DateTime> updatedAt,
      Value<bool> isSynced,
    });

class $$UserAchievementsTableFilterComposer
    extends Composer<_$AppDatabase, $UserAchievementsTable> {
  $$UserAchievementsTableFilterComposer({
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

  ColumnFilters<int> get achievementId => $composableBuilder(
    column: $table.achievementId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get unlocked => $composableBuilder(
    column: $table.unlocked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserAchievementsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserAchievementsTable> {
  $$UserAchievementsTableOrderingComposer({
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

  ColumnOrderings<int> get achievementId => $composableBuilder(
    column: $table.achievementId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get unlocked => $composableBuilder(
    column: $table.unlocked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserAchievementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserAchievementsTable> {
  $$UserAchievementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get achievementId => $composableBuilder(
    column: $table.achievementId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get unlocked =>
      $composableBuilder(column: $table.unlocked, builder: (column) => column);

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$UserAchievementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserAchievementsTable,
          UserAchievement,
          $$UserAchievementsTableFilterComposer,
          $$UserAchievementsTableOrderingComposer,
          $$UserAchievementsTableAnnotationComposer,
          $$UserAchievementsTableCreateCompanionBuilder,
          $$UserAchievementsTableUpdateCompanionBuilder,
          (
            UserAchievement,
            BaseReferences<
              _$AppDatabase,
              $UserAchievementsTable,
              UserAchievement
            >,
          ),
          UserAchievement,
          PrefetchHooks Function()
        > {
  $$UserAchievementsTableTableManager(
    _$AppDatabase db,
    $UserAchievementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserAchievementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserAchievementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserAchievementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> achievementId = const Value.absent(),
                Value<bool> unlocked = const Value.absent(),
                Value<DateTime?> unlockedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => UserAchievementsCompanion(
                id: id,
                achievementId: achievementId,
                unlocked: unlocked,
                unlockedAt: unlockedAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int achievementId,
                Value<bool> unlocked = const Value.absent(),
                Value<DateTime?> unlockedAt = const Value.absent(),
                required DateTime updatedAt,
                Value<bool> isSynced = const Value.absent(),
              }) => UserAchievementsCompanion.insert(
                id: id,
                achievementId: achievementId,
                unlocked: unlocked,
                unlockedAt: unlockedAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserAchievementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserAchievementsTable,
      UserAchievement,
      $$UserAchievementsTableFilterComposer,
      $$UserAchievementsTableOrderingComposer,
      $$UserAchievementsTableAnnotationComposer,
      $$UserAchievementsTableCreateCompanionBuilder,
      $$UserAchievementsTableUpdateCompanionBuilder,
      (
        UserAchievement,
        BaseReferences<_$AppDatabase, $UserAchievementsTable, UserAchievement>,
      ),
      UserAchievement,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserProgressTableTableManager get userProgress =>
      $$UserProgressTableTableManager(_db, _db.userProgress);
  $$AccessoriesTableTableManager get accessories =>
      $$AccessoriesTableTableManager(_db, _db.accessories);
  $$UserAccessoriesTableTableManager get userAccessories =>
      $$UserAccessoriesTableTableManager(_db, _db.userAccessories);
  $$AchievementsTableTableManager get achievements =>
      $$AchievementsTableTableManager(_db, _db.achievements);
  $$UserAchievementsTableTableManager get userAchievements =>
      $$UserAchievementsTableTableManager(_db, _db.userAchievements);
}
