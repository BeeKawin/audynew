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
  static const VerificationMeta _spentLearningPointsMeta =
      const VerificationMeta('spentLearningPoints');
  @override
  late final GeneratedColumn<int> spentLearningPoints = GeneratedColumn<int>(
    'spent_learning_points',
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
  static const VerificationMeta _puzzleGamesCompletedMeta =
      const VerificationMeta('puzzleGamesCompleted');
  @override
  late final GeneratedColumn<int> puzzleGamesCompleted = GeneratedColumn<int>(
    'puzzle_games_completed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _readingExercisesCompletedMeta =
      const VerificationMeta('readingExercisesCompleted');
  @override
  late final GeneratedColumn<int> readingExercisesCompleted =
      GeneratedColumn<int>(
        'reading_exercises_completed',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _sortingGamesCompletedMeta =
      const VerificationMeta('sortingGamesCompleted');
  @override
  late final GeneratedColumn<int> sortingGamesCompleted = GeneratedColumn<int>(
    'sorting_games_completed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _emotionsRecognizedMeta =
      const VerificationMeta('emotionsRecognized');
  @override
  late final GeneratedColumn<int> emotionsRecognized = GeneratedColumn<int>(
    'emotions_recognized',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _chatMessagesSentMeta = const VerificationMeta(
    'chatMessagesSent',
  );
  @override
  late final GeneratedColumn<int> chatMessagesSent = GeneratedColumn<int>(
    'chat_messages_sent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sortGameUnlockedLevelMeta =
      const VerificationMeta('sortGameUnlockedLevel');
  @override
  late final GeneratedColumn<int> sortGameUnlockedLevel = GeneratedColumn<int>(
    'sort_game_unlocked_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _gamesInCurrentSessionMeta =
      const VerificationMeta('gamesInCurrentSession');
  @override
  late final GeneratedColumn<int> gamesInCurrentSession = GeneratedColumn<int>(
    'games_in_current_session',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    learningPoints,
    spentLearningPoints,
    gamesPlayed,
    dayStreak,
    lastPlayedAt,
    updatedAt,
    isSynced,
    puzzleGamesCompleted,
    readingExercisesCompleted,
    sortingGamesCompleted,
    emotionsRecognized,
    chatMessagesSent,
    sortGameUnlockedLevel,
    gamesInCurrentSession,
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
    if (data.containsKey('spent_learning_points')) {
      context.handle(
        _spentLearningPointsMeta,
        spentLearningPoints.isAcceptableOrUnknown(
          data['spent_learning_points']!,
          _spentLearningPointsMeta,
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
    if (data.containsKey('puzzle_games_completed')) {
      context.handle(
        _puzzleGamesCompletedMeta,
        puzzleGamesCompleted.isAcceptableOrUnknown(
          data['puzzle_games_completed']!,
          _puzzleGamesCompletedMeta,
        ),
      );
    }
    if (data.containsKey('reading_exercises_completed')) {
      context.handle(
        _readingExercisesCompletedMeta,
        readingExercisesCompleted.isAcceptableOrUnknown(
          data['reading_exercises_completed']!,
          _readingExercisesCompletedMeta,
        ),
      );
    }
    if (data.containsKey('sorting_games_completed')) {
      context.handle(
        _sortingGamesCompletedMeta,
        sortingGamesCompleted.isAcceptableOrUnknown(
          data['sorting_games_completed']!,
          _sortingGamesCompletedMeta,
        ),
      );
    }
    if (data.containsKey('emotions_recognized')) {
      context.handle(
        _emotionsRecognizedMeta,
        emotionsRecognized.isAcceptableOrUnknown(
          data['emotions_recognized']!,
          _emotionsRecognizedMeta,
        ),
      );
    }
    if (data.containsKey('chat_messages_sent')) {
      context.handle(
        _chatMessagesSentMeta,
        chatMessagesSent.isAcceptableOrUnknown(
          data['chat_messages_sent']!,
          _chatMessagesSentMeta,
        ),
      );
    }
    if (data.containsKey('sort_game_unlocked_level')) {
      context.handle(
        _sortGameUnlockedLevelMeta,
        sortGameUnlockedLevel.isAcceptableOrUnknown(
          data['sort_game_unlocked_level']!,
          _sortGameUnlockedLevelMeta,
        ),
      );
    }
    if (data.containsKey('games_in_current_session')) {
      context.handle(
        _gamesInCurrentSessionMeta,
        gamesInCurrentSession.isAcceptableOrUnknown(
          data['games_in_current_session']!,
          _gamesInCurrentSessionMeta,
        ),
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
      spentLearningPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}spent_learning_points'],
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
      puzzleGamesCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}puzzle_games_completed'],
      )!,
      readingExercisesCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reading_exercises_completed'],
      )!,
      sortingGamesCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sorting_games_completed'],
      )!,
      emotionsRecognized: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}emotions_recognized'],
      )!,
      chatMessagesSent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chat_messages_sent'],
      )!,
      sortGameUnlockedLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_game_unlocked_level'],
      )!,
      gamesInCurrentSession: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}games_in_current_session'],
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
  final int spentLearningPoints;
  final int gamesPlayed;
  final int dayStreak;
  final DateTime? lastPlayedAt;
  final DateTime updatedAt;
  final bool isSynced;
  final int puzzleGamesCompleted;
  final int readingExercisesCompleted;
  final int sortingGamesCompleted;
  final int emotionsRecognized;
  final int chatMessagesSent;
  final int sortGameUnlockedLevel;
  final int gamesInCurrentSession;
  const UserProgressData({
    required this.id,
    required this.learningPoints,
    required this.spentLearningPoints,
    required this.gamesPlayed,
    required this.dayStreak,
    this.lastPlayedAt,
    required this.updatedAt,
    required this.isSynced,
    required this.puzzleGamesCompleted,
    required this.readingExercisesCompleted,
    required this.sortingGamesCompleted,
    required this.emotionsRecognized,
    required this.chatMessagesSent,
    required this.sortGameUnlockedLevel,
    required this.gamesInCurrentSession,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['learning_points'] = Variable<int>(learningPoints);
    map['spent_learning_points'] = Variable<int>(spentLearningPoints);
    map['games_played'] = Variable<int>(gamesPlayed);
    map['day_streak'] = Variable<int>(dayStreak);
    if (!nullToAbsent || lastPlayedAt != null) {
      map['last_played_at'] = Variable<DateTime>(lastPlayedAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_synced'] = Variable<bool>(isSynced);
    map['puzzle_games_completed'] = Variable<int>(puzzleGamesCompleted);
    map['reading_exercises_completed'] = Variable<int>(
      readingExercisesCompleted,
    );
    map['sorting_games_completed'] = Variable<int>(sortingGamesCompleted);
    map['emotions_recognized'] = Variable<int>(emotionsRecognized);
    map['chat_messages_sent'] = Variable<int>(chatMessagesSent);
    map['sort_game_unlocked_level'] = Variable<int>(sortGameUnlockedLevel);
    map['games_in_current_session'] = Variable<int>(gamesInCurrentSession);
    return map;
  }

  UserProgressCompanion toCompanion(bool nullToAbsent) {
    return UserProgressCompanion(
      id: Value(id),
      learningPoints: Value(learningPoints),
      spentLearningPoints: Value(spentLearningPoints),
      gamesPlayed: Value(gamesPlayed),
      dayStreak: Value(dayStreak),
      lastPlayedAt: lastPlayedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPlayedAt),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
      puzzleGamesCompleted: Value(puzzleGamesCompleted),
      readingExercisesCompleted: Value(readingExercisesCompleted),
      sortingGamesCompleted: Value(sortingGamesCompleted),
      emotionsRecognized: Value(emotionsRecognized),
      chatMessagesSent: Value(chatMessagesSent),
      sortGameUnlockedLevel: Value(sortGameUnlockedLevel),
      gamesInCurrentSession: Value(gamesInCurrentSession),
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
      spentLearningPoints: serializer.fromJson<int>(
        json['spentLearningPoints'],
      ),
      gamesPlayed: serializer.fromJson<int>(json['gamesPlayed']),
      dayStreak: serializer.fromJson<int>(json['dayStreak']),
      lastPlayedAt: serializer.fromJson<DateTime?>(json['lastPlayedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      puzzleGamesCompleted: serializer.fromJson<int>(
        json['puzzleGamesCompleted'],
      ),
      readingExercisesCompleted: serializer.fromJson<int>(
        json['readingExercisesCompleted'],
      ),
      sortingGamesCompleted: serializer.fromJson<int>(
        json['sortingGamesCompleted'],
      ),
      emotionsRecognized: serializer.fromJson<int>(json['emotionsRecognized']),
      chatMessagesSent: serializer.fromJson<int>(json['chatMessagesSent']),
      sortGameUnlockedLevel: serializer.fromJson<int>(
        json['sortGameUnlockedLevel'],
      ),
      gamesInCurrentSession: serializer.fromJson<int>(
        json['gamesInCurrentSession'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'learningPoints': serializer.toJson<int>(learningPoints),
      'spentLearningPoints': serializer.toJson<int>(spentLearningPoints),
      'gamesPlayed': serializer.toJson<int>(gamesPlayed),
      'dayStreak': serializer.toJson<int>(dayStreak),
      'lastPlayedAt': serializer.toJson<DateTime?>(lastPlayedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'puzzleGamesCompleted': serializer.toJson<int>(puzzleGamesCompleted),
      'readingExercisesCompleted': serializer.toJson<int>(
        readingExercisesCompleted,
      ),
      'sortingGamesCompleted': serializer.toJson<int>(sortingGamesCompleted),
      'emotionsRecognized': serializer.toJson<int>(emotionsRecognized),
      'chatMessagesSent': serializer.toJson<int>(chatMessagesSent),
      'sortGameUnlockedLevel': serializer.toJson<int>(sortGameUnlockedLevel),
      'gamesInCurrentSession': serializer.toJson<int>(gamesInCurrentSession),
    };
  }

  UserProgressData copyWith({
    int? id,
    int? learningPoints,
    int? spentLearningPoints,
    int? gamesPlayed,
    int? dayStreak,
    Value<DateTime?> lastPlayedAt = const Value.absent(),
    DateTime? updatedAt,
    bool? isSynced,
    int? puzzleGamesCompleted,
    int? readingExercisesCompleted,
    int? sortingGamesCompleted,
    int? emotionsRecognized,
    int? chatMessagesSent,
    int? sortGameUnlockedLevel,
    int? gamesInCurrentSession,
  }) => UserProgressData(
    id: id ?? this.id,
    learningPoints: learningPoints ?? this.learningPoints,
    spentLearningPoints: spentLearningPoints ?? this.spentLearningPoints,
    gamesPlayed: gamesPlayed ?? this.gamesPlayed,
    dayStreak: dayStreak ?? this.dayStreak,
    lastPlayedAt: lastPlayedAt.present ? lastPlayedAt.value : this.lastPlayedAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isSynced: isSynced ?? this.isSynced,
    puzzleGamesCompleted: puzzleGamesCompleted ?? this.puzzleGamesCompleted,
    readingExercisesCompleted:
        readingExercisesCompleted ?? this.readingExercisesCompleted,
    sortingGamesCompleted: sortingGamesCompleted ?? this.sortingGamesCompleted,
    emotionsRecognized: emotionsRecognized ?? this.emotionsRecognized,
    chatMessagesSent: chatMessagesSent ?? this.chatMessagesSent,
    sortGameUnlockedLevel: sortGameUnlockedLevel ?? this.sortGameUnlockedLevel,
    gamesInCurrentSession: gamesInCurrentSession ?? this.gamesInCurrentSession,
  );
  UserProgressData copyWithCompanion(UserProgressCompanion data) {
    return UserProgressData(
      id: data.id.present ? data.id.value : this.id,
      learningPoints: data.learningPoints.present
          ? data.learningPoints.value
          : this.learningPoints,
      spentLearningPoints: data.spentLearningPoints.present
          ? data.spentLearningPoints.value
          : this.spentLearningPoints,
      gamesPlayed: data.gamesPlayed.present
          ? data.gamesPlayed.value
          : this.gamesPlayed,
      dayStreak: data.dayStreak.present ? data.dayStreak.value : this.dayStreak,
      lastPlayedAt: data.lastPlayedAt.present
          ? data.lastPlayedAt.value
          : this.lastPlayedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      puzzleGamesCompleted: data.puzzleGamesCompleted.present
          ? data.puzzleGamesCompleted.value
          : this.puzzleGamesCompleted,
      readingExercisesCompleted: data.readingExercisesCompleted.present
          ? data.readingExercisesCompleted.value
          : this.readingExercisesCompleted,
      sortingGamesCompleted: data.sortingGamesCompleted.present
          ? data.sortingGamesCompleted.value
          : this.sortingGamesCompleted,
      emotionsRecognized: data.emotionsRecognized.present
          ? data.emotionsRecognized.value
          : this.emotionsRecognized,
      chatMessagesSent: data.chatMessagesSent.present
          ? data.chatMessagesSent.value
          : this.chatMessagesSent,
      sortGameUnlockedLevel: data.sortGameUnlockedLevel.present
          ? data.sortGameUnlockedLevel.value
          : this.sortGameUnlockedLevel,
      gamesInCurrentSession: data.gamesInCurrentSession.present
          ? data.gamesInCurrentSession.value
          : this.gamesInCurrentSession,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProgressData(')
          ..write('id: $id, ')
          ..write('learningPoints: $learningPoints, ')
          ..write('spentLearningPoints: $spentLearningPoints, ')
          ..write('gamesPlayed: $gamesPlayed, ')
          ..write('dayStreak: $dayStreak, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('puzzleGamesCompleted: $puzzleGamesCompleted, ')
          ..write('readingExercisesCompleted: $readingExercisesCompleted, ')
          ..write('sortingGamesCompleted: $sortingGamesCompleted, ')
          ..write('emotionsRecognized: $emotionsRecognized, ')
          ..write('chatMessagesSent: $chatMessagesSent, ')
          ..write('sortGameUnlockedLevel: $sortGameUnlockedLevel, ')
          ..write('gamesInCurrentSession: $gamesInCurrentSession')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    learningPoints,
    spentLearningPoints,
    gamesPlayed,
    dayStreak,
    lastPlayedAt,
    updatedAt,
    isSynced,
    puzzleGamesCompleted,
    readingExercisesCompleted,
    sortingGamesCompleted,
    emotionsRecognized,
    chatMessagesSent,
    sortGameUnlockedLevel,
    gamesInCurrentSession,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProgressData &&
          other.id == this.id &&
          other.learningPoints == this.learningPoints &&
          other.spentLearningPoints == this.spentLearningPoints &&
          other.gamesPlayed == this.gamesPlayed &&
          other.dayStreak == this.dayStreak &&
          other.lastPlayedAt == this.lastPlayedAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced &&
          other.puzzleGamesCompleted == this.puzzleGamesCompleted &&
          other.readingExercisesCompleted == this.readingExercisesCompleted &&
          other.sortingGamesCompleted == this.sortingGamesCompleted &&
          other.emotionsRecognized == this.emotionsRecognized &&
          other.chatMessagesSent == this.chatMessagesSent &&
          other.sortGameUnlockedLevel == this.sortGameUnlockedLevel &&
          other.gamesInCurrentSession == this.gamesInCurrentSession);
}

class UserProgressCompanion extends UpdateCompanion<UserProgressData> {
  final Value<int> id;
  final Value<int> learningPoints;
  final Value<int> spentLearningPoints;
  final Value<int> gamesPlayed;
  final Value<int> dayStreak;
  final Value<DateTime?> lastPlayedAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isSynced;
  final Value<int> puzzleGamesCompleted;
  final Value<int> readingExercisesCompleted;
  final Value<int> sortingGamesCompleted;
  final Value<int> emotionsRecognized;
  final Value<int> chatMessagesSent;
  final Value<int> sortGameUnlockedLevel;
  final Value<int> gamesInCurrentSession;
  const UserProgressCompanion({
    this.id = const Value.absent(),
    this.learningPoints = const Value.absent(),
    this.spentLearningPoints = const Value.absent(),
    this.gamesPlayed = const Value.absent(),
    this.dayStreak = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.puzzleGamesCompleted = const Value.absent(),
    this.readingExercisesCompleted = const Value.absent(),
    this.sortingGamesCompleted = const Value.absent(),
    this.emotionsRecognized = const Value.absent(),
    this.chatMessagesSent = const Value.absent(),
    this.sortGameUnlockedLevel = const Value.absent(),
    this.gamesInCurrentSession = const Value.absent(),
  });
  UserProgressCompanion.insert({
    this.id = const Value.absent(),
    this.learningPoints = const Value.absent(),
    this.spentLearningPoints = const Value.absent(),
    this.gamesPlayed = const Value.absent(),
    this.dayStreak = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    required DateTime updatedAt,
    this.isSynced = const Value.absent(),
    this.puzzleGamesCompleted = const Value.absent(),
    this.readingExercisesCompleted = const Value.absent(),
    this.sortingGamesCompleted = const Value.absent(),
    this.emotionsRecognized = const Value.absent(),
    this.chatMessagesSent = const Value.absent(),
    this.sortGameUnlockedLevel = const Value.absent(),
    this.gamesInCurrentSession = const Value.absent(),
  }) : updatedAt = Value(updatedAt);
  static Insertable<UserProgressData> custom({
    Expression<int>? id,
    Expression<int>? learningPoints,
    Expression<int>? spentLearningPoints,
    Expression<int>? gamesPlayed,
    Expression<int>? dayStreak,
    Expression<DateTime>? lastPlayedAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isSynced,
    Expression<int>? puzzleGamesCompleted,
    Expression<int>? readingExercisesCompleted,
    Expression<int>? sortingGamesCompleted,
    Expression<int>? emotionsRecognized,
    Expression<int>? chatMessagesSent,
    Expression<int>? sortGameUnlockedLevel,
    Expression<int>? gamesInCurrentSession,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (learningPoints != null) 'learning_points': learningPoints,
      if (spentLearningPoints != null)
        'spent_learning_points': spentLearningPoints,
      if (gamesPlayed != null) 'games_played': gamesPlayed,
      if (dayStreak != null) 'day_streak': dayStreak,
      if (lastPlayedAt != null) 'last_played_at': lastPlayedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (puzzleGamesCompleted != null)
        'puzzle_games_completed': puzzleGamesCompleted,
      if (readingExercisesCompleted != null)
        'reading_exercises_completed': readingExercisesCompleted,
      if (sortingGamesCompleted != null)
        'sorting_games_completed': sortingGamesCompleted,
      if (emotionsRecognized != null) 'emotions_recognized': emotionsRecognized,
      if (chatMessagesSent != null) 'chat_messages_sent': chatMessagesSent,
      if (sortGameUnlockedLevel != null)
        'sort_game_unlocked_level': sortGameUnlockedLevel,
      if (gamesInCurrentSession != null)
        'games_in_current_session': gamesInCurrentSession,
    });
  }

  UserProgressCompanion copyWith({
    Value<int>? id,
    Value<int>? learningPoints,
    Value<int>? spentLearningPoints,
    Value<int>? gamesPlayed,
    Value<int>? dayStreak,
    Value<DateTime?>? lastPlayedAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isSynced,
    Value<int>? puzzleGamesCompleted,
    Value<int>? readingExercisesCompleted,
    Value<int>? sortingGamesCompleted,
    Value<int>? emotionsRecognized,
    Value<int>? chatMessagesSent,
    Value<int>? sortGameUnlockedLevel,
    Value<int>? gamesInCurrentSession,
  }) {
    return UserProgressCompanion(
      id: id ?? this.id,
      learningPoints: learningPoints ?? this.learningPoints,
      spentLearningPoints:
          spentLearningPoints ?? this.spentLearningPoints,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      dayStreak: dayStreak ?? this.dayStreak,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      puzzleGamesCompleted: puzzleGamesCompleted ?? this.puzzleGamesCompleted,
      readingExercisesCompleted:
          readingExercisesCompleted ?? this.readingExercisesCompleted,
      sortingGamesCompleted:
          sortingGamesCompleted ?? this.sortingGamesCompleted,
      emotionsRecognized: emotionsRecognized ?? this.emotionsRecognized,
      chatMessagesSent: chatMessagesSent ?? this.chatMessagesSent,
      sortGameUnlockedLevel:
          sortGameUnlockedLevel ?? this.sortGameUnlockedLevel,
      gamesInCurrentSession:
          gamesInCurrentSession ?? this.gamesInCurrentSession,
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
    if (spentLearningPoints.present) {
      map['spent_learning_points'] = Variable<int>(spentLearningPoints.value);
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
    if (puzzleGamesCompleted.present) {
      map['puzzle_games_completed'] = Variable<int>(puzzleGamesCompleted.value);
    }
    if (readingExercisesCompleted.present) {
      map['reading_exercises_completed'] = Variable<int>(
        readingExercisesCompleted.value,
      );
    }
    if (sortingGamesCompleted.present) {
      map['sorting_games_completed'] = Variable<int>(
        sortingGamesCompleted.value,
      );
    }
    if (emotionsRecognized.present) {
      map['emotions_recognized'] = Variable<int>(emotionsRecognized.value);
    }
    if (chatMessagesSent.present) {
      map['chat_messages_sent'] = Variable<int>(chatMessagesSent.value);
    }
    if (sortGameUnlockedLevel.present) {
      map['sort_game_unlocked_level'] = Variable<int>(
        sortGameUnlockedLevel.value,
      );
    }
    if (gamesInCurrentSession.present) {
      map['games_in_current_session'] = Variable<int>(
        gamesInCurrentSession.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProgressCompanion(')
          ..write('id: $id, ')
          ..write('learningPoints: $learningPoints, ')
          ..write('spentLearningPoints: $spentLearningPoints, ')
          ..write('gamesPlayed: $gamesPlayed, ')
          ..write('dayStreak: $dayStreak, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('puzzleGamesCompleted: $puzzleGamesCompleted, ')
          ..write('readingExercisesCompleted: $readingExercisesCompleted, ')
          ..write('sortingGamesCompleted: $sortingGamesCompleted, ')
          ..write('emotionsRecognized: $emotionsRecognized, ')
          ..write('chatMessagesSent: $chatMessagesSent, ')
          ..write('sortGameUnlockedLevel: $sortGameUnlockedLevel, ')
          ..write('gamesInCurrentSession: $gamesInCurrentSession')
          ..write(')'))
        .toString();
  }
}

class $UserRewardsTable extends UserRewards
    with TableInfo<$UserRewardsTable, UserReward> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserRewardsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _prizeMeta = const VerificationMeta('prize');
  @override
  late final GeneratedColumn<String> prize = GeneratedColumn<String>(
    'prize',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conditionTypeMeta = const VerificationMeta(
    'conditionType',
  );
  @override
  late final GeneratedColumn<String> conditionType = GeneratedColumn<String>(
    'condition_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetCountMeta = const VerificationMeta(
    'targetCount',
  );
  @override
  late final GeneratedColumn<int> targetCount = GeneratedColumn<int>(
    'target_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentProgressMeta = const VerificationMeta(
    'currentProgress',
  );
  @override
  late final GeneratedColumn<int> currentProgress = GeneratedColumn<int>(
    'current_progress',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isClaimedMeta = const VerificationMeta(
    'isClaimed',
  );
  @override
  late final GeneratedColumn<bool> isClaimed = GeneratedColumn<bool>(
    'is_claimed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_claimed" IN (0, 1))',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    prize,
    conditionType,
    targetCount,
    currentProgress,
    isCompleted,
    isClaimed,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_rewards';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserReward> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('prize')) {
      context.handle(
        _prizeMeta,
        prize.isAcceptableOrUnknown(data['prize']!, _prizeMeta),
      );
    } else if (isInserting) {
      context.missing(_prizeMeta);
    }
    if (data.containsKey('condition_type')) {
      context.handle(
        _conditionTypeMeta,
        conditionType.isAcceptableOrUnknown(
          data['condition_type']!,
          _conditionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conditionTypeMeta);
    }
    if (data.containsKey('target_count')) {
      context.handle(
        _targetCountMeta,
        targetCount.isAcceptableOrUnknown(
          data['target_count']!,
          _targetCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetCountMeta);
    }
    if (data.containsKey('current_progress')) {
      context.handle(
        _currentProgressMeta,
        currentProgress.isAcceptableOrUnknown(
          data['current_progress']!,
          _currentProgressMeta,
        ),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('is_claimed')) {
      context.handle(
        _isClaimedMeta,
        isClaimed.isAcceptableOrUnknown(data['is_claimed']!, _isClaimedMeta),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserReward map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserReward(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      prize: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prize'],
      )!,
      conditionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}condition_type'],
      )!,
      targetCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_count'],
      )!,
      currentProgress: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_progress'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      isClaimed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_claimed'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserRewardsTable createAlias(String alias) {
    return $UserRewardsTable(attachedDatabase, alias);
  }
}

class UserReward extends DataClass implements Insertable<UserReward> {
  final int id;
  final String prize;
  final String conditionType;
  final int targetCount;
  final int currentProgress;
  final bool isCompleted;
  final bool isClaimed;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UserReward({
    required this.id,
    required this.prize,
    required this.conditionType,
    required this.targetCount,
    required this.currentProgress,
    required this.isCompleted,
    required this.isClaimed,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['prize'] = Variable<String>(prize);
    map['condition_type'] = Variable<String>(conditionType);
    map['target_count'] = Variable<int>(targetCount);
    map['current_progress'] = Variable<int>(currentProgress);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['is_claimed'] = Variable<bool>(isClaimed);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserRewardsCompanion toCompanion(bool nullToAbsent) {
    return UserRewardsCompanion(
      id: Value(id),
      prize: Value(prize),
      conditionType: Value(conditionType),
      targetCount: Value(targetCount),
      currentProgress: Value(currentProgress),
      isCompleted: Value(isCompleted),
      isClaimed: Value(isClaimed),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserReward.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserReward(
      id: serializer.fromJson<int>(json['id']),
      prize: serializer.fromJson<String>(json['prize']),
      conditionType: serializer.fromJson<String>(json['conditionType']),
      targetCount: serializer.fromJson<int>(json['targetCount']),
      currentProgress: serializer.fromJson<int>(json['currentProgress']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      isClaimed: serializer.fromJson<bool>(json['isClaimed']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'prize': serializer.toJson<String>(prize),
      'conditionType': serializer.toJson<String>(conditionType),
      'targetCount': serializer.toJson<int>(targetCount),
      'currentProgress': serializer.toJson<int>(currentProgress),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'isClaimed': serializer.toJson<bool>(isClaimed),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserReward copyWith({
    int? id,
    String? prize,
    String? conditionType,
    int? targetCount,
    int? currentProgress,
    bool? isCompleted,
    bool? isClaimed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UserReward(
    id: id ?? this.id,
    prize: prize ?? this.prize,
    conditionType: conditionType ?? this.conditionType,
    targetCount: targetCount ?? this.targetCount,
    currentProgress: currentProgress ?? this.currentProgress,
    isCompleted: isCompleted ?? this.isCompleted,
    isClaimed: isClaimed ?? this.isClaimed,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserReward copyWithCompanion(UserRewardsCompanion data) {
    return UserReward(
      id: data.id.present ? data.id.value : this.id,
      prize: data.prize.present ? data.prize.value : this.prize,
      conditionType: data.conditionType.present
          ? data.conditionType.value
          : this.conditionType,
      targetCount: data.targetCount.present
          ? data.targetCount.value
          : this.targetCount,
      currentProgress: data.currentProgress.present
          ? data.currentProgress.value
          : this.currentProgress,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      isClaimed: data.isClaimed.present ? data.isClaimed.value : this.isClaimed,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserReward(')
          ..write('id: $id, ')
          ..write('prize: $prize, ')
          ..write('conditionType: $conditionType, ')
          ..write('targetCount: $targetCount, ')
          ..write('currentProgress: $currentProgress, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('isClaimed: $isClaimed, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    prize,
    conditionType,
    targetCount,
    currentProgress,
    isCompleted,
    isClaimed,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserReward &&
          other.id == this.id &&
          other.prize == this.prize &&
          other.conditionType == this.conditionType &&
          other.targetCount == this.targetCount &&
          other.currentProgress == this.currentProgress &&
          other.isCompleted == this.isCompleted &&
          other.isClaimed == this.isClaimed &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserRewardsCompanion extends UpdateCompanion<UserReward> {
  final Value<int> id;
  final Value<String> prize;
  final Value<String> conditionType;
  final Value<int> targetCount;
  final Value<int> currentProgress;
  final Value<bool> isCompleted;
  final Value<bool> isClaimed;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const UserRewardsCompanion({
    this.id = const Value.absent(),
    this.prize = const Value.absent(),
    this.conditionType = const Value.absent(),
    this.targetCount = const Value.absent(),
    this.currentProgress = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.isClaimed = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserRewardsCompanion.insert({
    this.id = const Value.absent(),
    required String prize,
    required String conditionType,
    required int targetCount,
    this.currentProgress = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.isClaimed = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : prize = Value(prize),
       conditionType = Value(conditionType),
       targetCount = Value(targetCount),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<UserReward> custom({
    Expression<int>? id,
    Expression<String>? prize,
    Expression<String>? conditionType,
    Expression<int>? targetCount,
    Expression<int>? currentProgress,
    Expression<bool>? isCompleted,
    Expression<bool>? isClaimed,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (prize != null) 'prize': prize,
      if (conditionType != null) 'condition_type': conditionType,
      if (targetCount != null) 'target_count': targetCount,
      if (currentProgress != null) 'current_progress': currentProgress,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (isClaimed != null) 'is_claimed': isClaimed,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserRewardsCompanion copyWith({
    Value<int>? id,
    Value<String>? prize,
    Value<String>? conditionType,
    Value<int>? targetCount,
    Value<int>? currentProgress,
    Value<bool>? isCompleted,
    Value<bool>? isClaimed,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return UserRewardsCompanion(
      id: id ?? this.id,
      prize: prize ?? this.prize,
      conditionType: conditionType ?? this.conditionType,
      targetCount: targetCount ?? this.targetCount,
      currentProgress: currentProgress ?? this.currentProgress,
      isCompleted: isCompleted ?? this.isCompleted,
      isClaimed: isClaimed ?? this.isClaimed,
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
    if (prize.present) {
      map['prize'] = Variable<String>(prize.value);
    }
    if (conditionType.present) {
      map['condition_type'] = Variable<String>(conditionType.value);
    }
    if (targetCount.present) {
      map['target_count'] = Variable<int>(targetCount.value);
    }
    if (currentProgress.present) {
      map['current_progress'] = Variable<int>(currentProgress.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (isClaimed.present) {
      map['is_claimed'] = Variable<bool>(isClaimed.value);
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
    return (StringBuffer('UserRewardsCompanion(')
          ..write('id: $id, ')
          ..write('prize: $prize, ')
          ..write('conditionType: $conditionType, ')
          ..write('targetCount: $targetCount, ')
          ..write('currentProgress: $currentProgress, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('isClaimed: $isClaimed, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
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

class $GameSessionsTable extends GameSessions
    with TableInfo<$GameSessionsTable, GameSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameSessionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _gameTypeMeta = const VerificationMeta(
    'gameType',
  );
  @override
  late final GeneratedColumn<String> gameType = GeneratedColumn<String>(
    'game_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelIdMeta = const VerificationMeta(
    'levelId',
  );
  @override
  late final GeneratedColumn<String> levelId = GeneratedColumn<String>(
    'level_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
    'difficulty',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _correctActionsMeta = const VerificationMeta(
    'correctActions',
  );
  @override
  late final GeneratedColumn<int> correctActions = GeneratedColumn<int>(
    'correct_actions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalActionsMeta = const VerificationMeta(
    'totalActions',
  );
  @override
  late final GeneratedColumn<int> totalActions = GeneratedColumn<int>(
    'total_actions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _accuracyPercentMeta = const VerificationMeta(
    'accuracyPercent',
  );
  @override
  late final GeneratedColumn<int> accuracyPercent = GeneratedColumn<int>(
    'accuracy_percent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _starsEarnedMeta = const VerificationMeta(
    'starsEarned',
  );
  @override
  late final GeneratedColumn<int> starsEarned = GeneratedColumn<int>(
    'stars_earned',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sessionStartedAtMeta = const VerificationMeta(
    'sessionStartedAt',
  );
  @override
  late final GeneratedColumn<DateTime> sessionStartedAt =
      GeneratedColumn<DateTime>(
        'session_started_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _sessionEndedAtMeta = const VerificationMeta(
    'sessionEndedAt',
  );
  @override
  late final GeneratedColumn<DateTime> sessionEndedAt =
      GeneratedColumn<DateTime>(
        'session_ended_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
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
    gameType,
    levelId,
    difficulty,
    correctActions,
    totalActions,
    accuracyPercent,
    starsEarned,
    durationSeconds,
    sessionStartedAt,
    sessionEndedAt,
    createdAt,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('game_type')) {
      context.handle(
        _gameTypeMeta,
        gameType.isAcceptableOrUnknown(data['game_type']!, _gameTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_gameTypeMeta);
    }
    if (data.containsKey('level_id')) {
      context.handle(
        _levelIdMeta,
        levelId.isAcceptableOrUnknown(data['level_id']!, _levelIdMeta),
      );
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('correct_actions')) {
      context.handle(
        _correctActionsMeta,
        correctActions.isAcceptableOrUnknown(
          data['correct_actions']!,
          _correctActionsMeta,
        ),
      );
    }
    if (data.containsKey('total_actions')) {
      context.handle(
        _totalActionsMeta,
        totalActions.isAcceptableOrUnknown(
          data['total_actions']!,
          _totalActionsMeta,
        ),
      );
    }
    if (data.containsKey('accuracy_percent')) {
      context.handle(
        _accuracyPercentMeta,
        accuracyPercent.isAcceptableOrUnknown(
          data['accuracy_percent']!,
          _accuracyPercentMeta,
        ),
      );
    }
    if (data.containsKey('stars_earned')) {
      context.handle(
        _starsEarnedMeta,
        starsEarned.isAcceptableOrUnknown(
          data['stars_earned']!,
          _starsEarnedMeta,
        ),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('session_started_at')) {
      context.handle(
        _sessionStartedAtMeta,
        sessionStartedAt.isAcceptableOrUnknown(
          data['session_started_at']!,
          _sessionStartedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionStartedAtMeta);
    }
    if (data.containsKey('session_ended_at')) {
      context.handle(
        _sessionEndedAtMeta,
        sessionEndedAt.isAcceptableOrUnknown(
          data['session_ended_at']!,
          _sessionEndedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionEndedAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
  GameSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      gameType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_type'],
      )!,
      levelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level_id'],
      ),
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}difficulty'],
      ),
      correctActions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_actions'],
      )!,
      totalActions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_actions'],
      )!,
      accuracyPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accuracy_percent'],
      )!,
      starsEarned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stars_earned'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      sessionStartedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}session_started_at'],
      )!,
      sessionEndedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}session_ended_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $GameSessionsTable createAlias(String alias) {
    return $GameSessionsTable(attachedDatabase, alias);
  }
}

class GameSession extends DataClass implements Insertable<GameSession> {
  final int id;

  /// Game type: sorting, emotion_classify, emotion_mimic, minipuzzle, reaction, reading
  final String gameType;

  /// Level identifier (for sorting, puzzle games)
  final String? levelId;

  /// Difficulty: easy, medium, hard
  final String? difficulty;

  /// Number of correct actions/answers
  final int correctActions;

  /// Total actions/attempts
  final int totalActions;

  /// Accuracy percentage (0-100)
  final int accuracyPercent;

  /// Stars earned (for games with star system)
  final int? starsEarned;

  /// Duration in seconds
  final int durationSeconds;

  /// When the session started
  final DateTime sessionStartedAt;

  /// When the session ended
  final DateTime sessionEndedAt;

  /// Row creation timestamp
  final DateTime createdAt;

  /// Future-proof for cloud sync
  final bool isSynced;
  const GameSession({
    required this.id,
    required this.gameType,
    this.levelId,
    this.difficulty,
    required this.correctActions,
    required this.totalActions,
    required this.accuracyPercent,
    this.starsEarned,
    required this.durationSeconds,
    required this.sessionStartedAt,
    required this.sessionEndedAt,
    required this.createdAt,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['game_type'] = Variable<String>(gameType);
    if (!nullToAbsent || levelId != null) {
      map['level_id'] = Variable<String>(levelId);
    }
    if (!nullToAbsent || difficulty != null) {
      map['difficulty'] = Variable<String>(difficulty);
    }
    map['correct_actions'] = Variable<int>(correctActions);
    map['total_actions'] = Variable<int>(totalActions);
    map['accuracy_percent'] = Variable<int>(accuracyPercent);
    if (!nullToAbsent || starsEarned != null) {
      map['stars_earned'] = Variable<int>(starsEarned);
    }
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['session_started_at'] = Variable<DateTime>(sessionStartedAt);
    map['session_ended_at'] = Variable<DateTime>(sessionEndedAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  GameSessionsCompanion toCompanion(bool nullToAbsent) {
    return GameSessionsCompanion(
      id: Value(id),
      gameType: Value(gameType),
      levelId: levelId == null && nullToAbsent
          ? const Value.absent()
          : Value(levelId),
      difficulty: difficulty == null && nullToAbsent
          ? const Value.absent()
          : Value(difficulty),
      correctActions: Value(correctActions),
      totalActions: Value(totalActions),
      accuracyPercent: Value(accuracyPercent),
      starsEarned: starsEarned == null && nullToAbsent
          ? const Value.absent()
          : Value(starsEarned),
      durationSeconds: Value(durationSeconds),
      sessionStartedAt: Value(sessionStartedAt),
      sessionEndedAt: Value(sessionEndedAt),
      createdAt: Value(createdAt),
      isSynced: Value(isSynced),
    );
  }

  factory GameSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameSession(
      id: serializer.fromJson<int>(json['id']),
      gameType: serializer.fromJson<String>(json['gameType']),
      levelId: serializer.fromJson<String?>(json['levelId']),
      difficulty: serializer.fromJson<String?>(json['difficulty']),
      correctActions: serializer.fromJson<int>(json['correctActions']),
      totalActions: serializer.fromJson<int>(json['totalActions']),
      accuracyPercent: serializer.fromJson<int>(json['accuracyPercent']),
      starsEarned: serializer.fromJson<int?>(json['starsEarned']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      sessionStartedAt: serializer.fromJson<DateTime>(json['sessionStartedAt']),
      sessionEndedAt: serializer.fromJson<DateTime>(json['sessionEndedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'gameType': serializer.toJson<String>(gameType),
      'levelId': serializer.toJson<String?>(levelId),
      'difficulty': serializer.toJson<String?>(difficulty),
      'correctActions': serializer.toJson<int>(correctActions),
      'totalActions': serializer.toJson<int>(totalActions),
      'accuracyPercent': serializer.toJson<int>(accuracyPercent),
      'starsEarned': serializer.toJson<int?>(starsEarned),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'sessionStartedAt': serializer.toJson<DateTime>(sessionStartedAt),
      'sessionEndedAt': serializer.toJson<DateTime>(sessionEndedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  GameSession copyWith({
    int? id,
    String? gameType,
    Value<String?> levelId = const Value.absent(),
    Value<String?> difficulty = const Value.absent(),
    int? correctActions,
    int? totalActions,
    int? accuracyPercent,
    Value<int?> starsEarned = const Value.absent(),
    int? durationSeconds,
    DateTime? sessionStartedAt,
    DateTime? sessionEndedAt,
    DateTime? createdAt,
    bool? isSynced,
  }) => GameSession(
    id: id ?? this.id,
    gameType: gameType ?? this.gameType,
    levelId: levelId.present ? levelId.value : this.levelId,
    difficulty: difficulty.present ? difficulty.value : this.difficulty,
    correctActions: correctActions ?? this.correctActions,
    totalActions: totalActions ?? this.totalActions,
    accuracyPercent: accuracyPercent ?? this.accuracyPercent,
    starsEarned: starsEarned.present ? starsEarned.value : this.starsEarned,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    sessionStartedAt: sessionStartedAt ?? this.sessionStartedAt,
    sessionEndedAt: sessionEndedAt ?? this.sessionEndedAt,
    createdAt: createdAt ?? this.createdAt,
    isSynced: isSynced ?? this.isSynced,
  );
  GameSession copyWithCompanion(GameSessionsCompanion data) {
    return GameSession(
      id: data.id.present ? data.id.value : this.id,
      gameType: data.gameType.present ? data.gameType.value : this.gameType,
      levelId: data.levelId.present ? data.levelId.value : this.levelId,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      correctActions: data.correctActions.present
          ? data.correctActions.value
          : this.correctActions,
      totalActions: data.totalActions.present
          ? data.totalActions.value
          : this.totalActions,
      accuracyPercent: data.accuracyPercent.present
          ? data.accuracyPercent.value
          : this.accuracyPercent,
      starsEarned: data.starsEarned.present
          ? data.starsEarned.value
          : this.starsEarned,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      sessionStartedAt: data.sessionStartedAt.present
          ? data.sessionStartedAt.value
          : this.sessionStartedAt,
      sessionEndedAt: data.sessionEndedAt.present
          ? data.sessionEndedAt.value
          : this.sessionEndedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameSession(')
          ..write('id: $id, ')
          ..write('gameType: $gameType, ')
          ..write('levelId: $levelId, ')
          ..write('difficulty: $difficulty, ')
          ..write('correctActions: $correctActions, ')
          ..write('totalActions: $totalActions, ')
          ..write('accuracyPercent: $accuracyPercent, ')
          ..write('starsEarned: $starsEarned, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('sessionStartedAt: $sessionStartedAt, ')
          ..write('sessionEndedAt: $sessionEndedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    gameType,
    levelId,
    difficulty,
    correctActions,
    totalActions,
    accuracyPercent,
    starsEarned,
    durationSeconds,
    sessionStartedAt,
    sessionEndedAt,
    createdAt,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameSession &&
          other.id == this.id &&
          other.gameType == this.gameType &&
          other.levelId == this.levelId &&
          other.difficulty == this.difficulty &&
          other.correctActions == this.correctActions &&
          other.totalActions == this.totalActions &&
          other.accuracyPercent == this.accuracyPercent &&
          other.starsEarned == this.starsEarned &&
          other.durationSeconds == this.durationSeconds &&
          other.sessionStartedAt == this.sessionStartedAt &&
          other.sessionEndedAt == this.sessionEndedAt &&
          other.createdAt == this.createdAt &&
          other.isSynced == this.isSynced);
}

class GameSessionsCompanion extends UpdateCompanion<GameSession> {
  final Value<int> id;
  final Value<String> gameType;
  final Value<String?> levelId;
  final Value<String?> difficulty;
  final Value<int> correctActions;
  final Value<int> totalActions;
  final Value<int> accuracyPercent;
  final Value<int?> starsEarned;
  final Value<int> durationSeconds;
  final Value<DateTime> sessionStartedAt;
  final Value<DateTime> sessionEndedAt;
  final Value<DateTime> createdAt;
  final Value<bool> isSynced;
  const GameSessionsCompanion({
    this.id = const Value.absent(),
    this.gameType = const Value.absent(),
    this.levelId = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.correctActions = const Value.absent(),
    this.totalActions = const Value.absent(),
    this.accuracyPercent = const Value.absent(),
    this.starsEarned = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.sessionStartedAt = const Value.absent(),
    this.sessionEndedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
  });
  GameSessionsCompanion.insert({
    this.id = const Value.absent(),
    required String gameType,
    this.levelId = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.correctActions = const Value.absent(),
    this.totalActions = const Value.absent(),
    this.accuracyPercent = const Value.absent(),
    this.starsEarned = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    required DateTime sessionStartedAt,
    required DateTime sessionEndedAt,
    required DateTime createdAt,
    this.isSynced = const Value.absent(),
  }) : gameType = Value(gameType),
       sessionStartedAt = Value(sessionStartedAt),
       sessionEndedAt = Value(sessionEndedAt),
       createdAt = Value(createdAt);
  static Insertable<GameSession> custom({
    Expression<int>? id,
    Expression<String>? gameType,
    Expression<String>? levelId,
    Expression<String>? difficulty,
    Expression<int>? correctActions,
    Expression<int>? totalActions,
    Expression<int>? accuracyPercent,
    Expression<int>? starsEarned,
    Expression<int>? durationSeconds,
    Expression<DateTime>? sessionStartedAt,
    Expression<DateTime>? sessionEndedAt,
    Expression<DateTime>? createdAt,
    Expression<bool>? isSynced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gameType != null) 'game_type': gameType,
      if (levelId != null) 'level_id': levelId,
      if (difficulty != null) 'difficulty': difficulty,
      if (correctActions != null) 'correct_actions': correctActions,
      if (totalActions != null) 'total_actions': totalActions,
      if (accuracyPercent != null) 'accuracy_percent': accuracyPercent,
      if (starsEarned != null) 'stars_earned': starsEarned,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (sessionStartedAt != null) 'session_started_at': sessionStartedAt,
      if (sessionEndedAt != null) 'session_ended_at': sessionEndedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  GameSessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? gameType,
    Value<String?>? levelId,
    Value<String?>? difficulty,
    Value<int>? correctActions,
    Value<int>? totalActions,
    Value<int>? accuracyPercent,
    Value<int?>? starsEarned,
    Value<int>? durationSeconds,
    Value<DateTime>? sessionStartedAt,
    Value<DateTime>? sessionEndedAt,
    Value<DateTime>? createdAt,
    Value<bool>? isSynced,
  }) {
    return GameSessionsCompanion(
      id: id ?? this.id,
      gameType: gameType ?? this.gameType,
      levelId: levelId ?? this.levelId,
      difficulty: difficulty ?? this.difficulty,
      correctActions: correctActions ?? this.correctActions,
      totalActions: totalActions ?? this.totalActions,
      accuracyPercent: accuracyPercent ?? this.accuracyPercent,
      starsEarned: starsEarned ?? this.starsEarned,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      sessionStartedAt: sessionStartedAt ?? this.sessionStartedAt,
      sessionEndedAt: sessionEndedAt ?? this.sessionEndedAt,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (gameType.present) {
      map['game_type'] = Variable<String>(gameType.value);
    }
    if (levelId.present) {
      map['level_id'] = Variable<String>(levelId.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (correctActions.present) {
      map['correct_actions'] = Variable<int>(correctActions.value);
    }
    if (totalActions.present) {
      map['total_actions'] = Variable<int>(totalActions.value);
    }
    if (accuracyPercent.present) {
      map['accuracy_percent'] = Variable<int>(accuracyPercent.value);
    }
    if (starsEarned.present) {
      map['stars_earned'] = Variable<int>(starsEarned.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (sessionStartedAt.present) {
      map['session_started_at'] = Variable<DateTime>(sessionStartedAt.value);
    }
    if (sessionEndedAt.present) {
      map['session_ended_at'] = Variable<DateTime>(sessionEndedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameSessionsCompanion(')
          ..write('id: $id, ')
          ..write('gameType: $gameType, ')
          ..write('levelId: $levelId, ')
          ..write('difficulty: $difficulty, ')
          ..write('correctActions: $correctActions, ')
          ..write('totalActions: $totalActions, ')
          ..write('accuracyPercent: $accuracyPercent, ')
          ..write('starsEarned: $starsEarned, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('sessionStartedAt: $sessionStartedAt, ')
          ..write('sessionEndedAt: $sessionEndedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }
}

class $UserPreferencesTable extends UserPreferences
    with TableInfo<$UserPreferencesTable, UserPreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPreferencesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _communicationLevelMeta =
      const VerificationMeta('communicationLevel');
  @override
  late final GeneratedColumn<int> communicationLevel = GeneratedColumn<int>(
    'communication_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _sensorySensitivityMeta =
      const VerificationMeta('sensorySensitivity');
  @override
  late final GeneratedColumn<int> sensorySensitivity = GeneratedColumn<int>(
    'sensory_sensitivity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _learningPaceMeta = const VerificationMeta(
    'learningPace',
  );
  @override
  late final GeneratedColumn<int> learningPace = GeneratedColumn<int>(
    'learning_pace',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _favoriteInterestsMeta = const VerificationMeta(
    'favoriteInterests',
  );
  @override
  late final GeneratedColumn<String> favoriteInterests =
      GeneratedColumn<String>(
        'favorite_interests',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _ownedSkinIdsMeta = const VerificationMeta(
    'ownedSkinIds',
  );
  @override
  late final GeneratedColumn<String> ownedSkinIds = GeneratedColumn<String>(
    'owned_skin_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('0'),
  );
  static const VerificationMeta _selectedSkinIdMeta = const VerificationMeta(
    'selectedSkinId',
  );
  @override
  late final GeneratedColumn<int> selectedSkinId = GeneratedColumn<int>(
    'selected_skin_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    communicationLevel,
    sensorySensitivity,
    learningPace,
    favoriteInterests,
    ownedSkinIds,
    selectedSkinId,
    updatedAt,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserPreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('communication_level')) {
      context.handle(
        _communicationLevelMeta,
        communicationLevel.isAcceptableOrUnknown(
          data['communication_level']!,
          _communicationLevelMeta,
        ),
      );
    }
    if (data.containsKey('sensory_sensitivity')) {
      context.handle(
        _sensorySensitivityMeta,
        sensorySensitivity.isAcceptableOrUnknown(
          data['sensory_sensitivity']!,
          _sensorySensitivityMeta,
        ),
      );
    }
    if (data.containsKey('learning_pace')) {
      context.handle(
        _learningPaceMeta,
        learningPace.isAcceptableOrUnknown(
          data['learning_pace']!,
          _learningPaceMeta,
        ),
      );
    }
    if (data.containsKey('favorite_interests')) {
      context.handle(
        _favoriteInterestsMeta,
        favoriteInterests.isAcceptableOrUnknown(
          data['favorite_interests']!,
          _favoriteInterestsMeta,
        ),
      );
    }
    if (data.containsKey('owned_skin_ids')) {
      context.handle(
        _ownedSkinIdsMeta,
        ownedSkinIds.isAcceptableOrUnknown(
          data['owned_skin_ids']!,
          _ownedSkinIdsMeta,
        ),
      );
    }
    if (data.containsKey('selected_skin_id')) {
      context.handle(
        _selectedSkinIdMeta,
        selectedSkinId.isAcceptableOrUnknown(
          data['selected_skin_id']!,
          _selectedSkinIdMeta,
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
  UserPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPreference(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      communicationLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}communication_level'],
      )!,
      sensorySensitivity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sensory_sensitivity'],
      )!,
      learningPace: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}learning_pace'],
      )!,
      favoriteInterests: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}favorite_interests'],
      )!,
      ownedSkinIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owned_skin_ids'],
      )!,
      selectedSkinId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}selected_skin_id'],
      )!,
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
  $UserPreferencesTable createAlias(String alias) {
    return $UserPreferencesTable(attachedDatabase, alias);
  }
}

class UserPreference extends DataClass implements Insertable<UserPreference> {
  final int id;
  final int communicationLevel;
  final int sensorySensitivity;
  final int learningPace;
  final String favoriteInterests;
  final String ownedSkinIds;
  final int selectedSkinId;
  final DateTime updatedAt;
  final bool isSynced;
  const UserPreference({
    required this.id,
    required this.communicationLevel,
    required this.sensorySensitivity,
    required this.learningPace,
    required this.favoriteInterests,
    required this.ownedSkinIds,
    required this.selectedSkinId,
    required this.updatedAt,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['communication_level'] = Variable<int>(communicationLevel);
    map['sensory_sensitivity'] = Variable<int>(sensorySensitivity);
    map['learning_pace'] = Variable<int>(learningPace);
    map['favorite_interests'] = Variable<String>(favoriteInterests);
    map['owned_skin_ids'] = Variable<String>(ownedSkinIds);
    map['selected_skin_id'] = Variable<int>(selectedSkinId);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  UserPreferencesCompanion toCompanion(bool nullToAbsent) {
    return UserPreferencesCompanion(
      id: Value(id),
      communicationLevel: Value(communicationLevel),
      sensorySensitivity: Value(sensorySensitivity),
      learningPace: Value(learningPace),
      favoriteInterests: Value(favoriteInterests),
      ownedSkinIds: Value(ownedSkinIds),
      selectedSkinId: Value(selectedSkinId),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
    );
  }

  factory UserPreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPreference(
      id: serializer.fromJson<int>(json['id']),
      communicationLevel: serializer.fromJson<int>(json['communicationLevel']),
      sensorySensitivity: serializer.fromJson<int>(json['sensorySensitivity']),
      learningPace: serializer.fromJson<int>(json['learningPace']),
      favoriteInterests: serializer.fromJson<String>(json['favoriteInterests']),
      ownedSkinIds: serializer.fromJson<String>(json['ownedSkinIds']),
      selectedSkinId: serializer.fromJson<int>(json['selectedSkinId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'communicationLevel': serializer.toJson<int>(communicationLevel),
      'sensorySensitivity': serializer.toJson<int>(sensorySensitivity),
      'learningPace': serializer.toJson<int>(learningPace),
      'favoriteInterests': serializer.toJson<String>(favoriteInterests),
      'ownedSkinIds': serializer.toJson<String>(ownedSkinIds),
      'selectedSkinId': serializer.toJson<int>(selectedSkinId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  UserPreference copyWith({
    int? id,
    int? communicationLevel,
    int? sensorySensitivity,
    int? learningPace,
    String? favoriteInterests,
    String? ownedSkinIds,
    int? selectedSkinId,
    DateTime? updatedAt,
    bool? isSynced,
  }) => UserPreference(
    id: id ?? this.id,
    communicationLevel: communicationLevel ?? this.communicationLevel,
    sensorySensitivity: sensorySensitivity ?? this.sensorySensitivity,
    learningPace: learningPace ?? this.learningPace,
    favoriteInterests: favoriteInterests ?? this.favoriteInterests,
    ownedSkinIds: ownedSkinIds ?? this.ownedSkinIds,
    selectedSkinId: selectedSkinId ?? this.selectedSkinId,
    updatedAt: updatedAt ?? this.updatedAt,
    isSynced: isSynced ?? this.isSynced,
  );
  UserPreference copyWithCompanion(UserPreferencesCompanion data) {
    return UserPreference(
      id: data.id.present ? data.id.value : this.id,
      communicationLevel: data.communicationLevel.present
          ? data.communicationLevel.value
          : this.communicationLevel,
      sensorySensitivity: data.sensorySensitivity.present
          ? data.sensorySensitivity.value
          : this.sensorySensitivity,
      learningPace: data.learningPace.present
          ? data.learningPace.value
          : this.learningPace,
      favoriteInterests: data.favoriteInterests.present
          ? data.favoriteInterests.value
          : this.favoriteInterests,
      ownedSkinIds: data.ownedSkinIds.present
          ? data.ownedSkinIds.value
          : this.ownedSkinIds,
      selectedSkinId: data.selectedSkinId.present
          ? data.selectedSkinId.value
          : this.selectedSkinId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserPreference(')
          ..write('id: $id, ')
          ..write('communicationLevel: $communicationLevel, ')
          ..write('sensorySensitivity: $sensorySensitivity, ')
          ..write('learningPace: $learningPace, ')
          ..write('favoriteInterests: $favoriteInterests, ')
          ..write('ownedSkinIds: $ownedSkinIds, ')
          ..write('selectedSkinId: $selectedSkinId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    communicationLevel,
    sensorySensitivity,
    learningPace,
    favoriteInterests,
    ownedSkinIds,
    selectedSkinId,
    updatedAt,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPreference &&
          other.id == this.id &&
          other.communicationLevel == this.communicationLevel &&
          other.sensorySensitivity == this.sensorySensitivity &&
          other.learningPace == this.learningPace &&
          other.favoriteInterests == this.favoriteInterests &&
          other.ownedSkinIds == this.ownedSkinIds &&
          other.selectedSkinId == this.selectedSkinId &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced);
}

class UserPreferencesCompanion extends UpdateCompanion<UserPreference> {
  final Value<int> id;
  final Value<int> communicationLevel;
  final Value<int> sensorySensitivity;
  final Value<int> learningPace;
  final Value<String> favoriteInterests;
  final Value<String> ownedSkinIds;
  final Value<int> selectedSkinId;
  final Value<DateTime> updatedAt;
  final Value<bool> isSynced;
  const UserPreferencesCompanion({
    this.id = const Value.absent(),
    this.communicationLevel = const Value.absent(),
    this.sensorySensitivity = const Value.absent(),
    this.learningPace = const Value.absent(),
    this.favoriteInterests = const Value.absent(),
    this.ownedSkinIds = const Value.absent(),
    this.selectedSkinId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
  });
  UserPreferencesCompanion.insert({
    this.id = const Value.absent(),
    this.communicationLevel = const Value.absent(),
    this.sensorySensitivity = const Value.absent(),
    this.learningPace = const Value.absent(),
    this.favoriteInterests = const Value.absent(),
    this.ownedSkinIds = const Value.absent(),
    this.selectedSkinId = const Value.absent(),
    required DateTime updatedAt,
    this.isSynced = const Value.absent(),
  }) : updatedAt = Value(updatedAt);
  static Insertable<UserPreference> custom({
    Expression<int>? id,
    Expression<int>? communicationLevel,
    Expression<int>? sensorySensitivity,
    Expression<int>? learningPace,
    Expression<String>? favoriteInterests,
    Expression<String>? ownedSkinIds,
    Expression<int>? selectedSkinId,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isSynced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (communicationLevel != null) 'communication_level': communicationLevel,
      if (sensorySensitivity != null) 'sensory_sensitivity': sensorySensitivity,
      if (learningPace != null) 'learning_pace': learningPace,
      if (favoriteInterests != null) 'favorite_interests': favoriteInterests,
      if (ownedSkinIds != null) 'owned_skin_ids': ownedSkinIds,
      if (selectedSkinId != null) 'selected_skin_id': selectedSkinId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  UserPreferencesCompanion copyWith({
    Value<int>? id,
    Value<int>? communicationLevel,
    Value<int>? sensorySensitivity,
    Value<int>? learningPace,
    Value<String>? favoriteInterests,
    Value<String>? ownedSkinIds,
    Value<int>? selectedSkinId,
    Value<DateTime>? updatedAt,
    Value<bool>? isSynced,
  }) {
    return UserPreferencesCompanion(
      id: id ?? this.id,
      communicationLevel: communicationLevel ?? this.communicationLevel,
      sensorySensitivity: sensorySensitivity ?? this.sensorySensitivity,
      learningPace: learningPace ?? this.learningPace,
      favoriteInterests: favoriteInterests ?? this.favoriteInterests,
      ownedSkinIds: ownedSkinIds ?? this.ownedSkinIds,
      selectedSkinId: selectedSkinId ?? this.selectedSkinId,
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
    if (communicationLevel.present) {
      map['communication_level'] = Variable<int>(communicationLevel.value);
    }
    if (sensorySensitivity.present) {
      map['sensory_sensitivity'] = Variable<int>(sensorySensitivity.value);
    }
    if (learningPace.present) {
      map['learning_pace'] = Variable<int>(learningPace.value);
    }
    if (favoriteInterests.present) {
      map['favorite_interests'] = Variable<String>(favoriteInterests.value);
    }
    if (ownedSkinIds.present) {
      map['owned_skin_ids'] = Variable<String>(ownedSkinIds.value);
    }
    if (selectedSkinId.present) {
      map['selected_skin_id'] = Variable<int>(selectedSkinId.value);
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
    return (StringBuffer('UserPreferencesCompanion(')
          ..write('id: $id, ')
          ..write('communicationLevel: $communicationLevel, ')
          ..write('sensorySensitivity: $sensorySensitivity, ')
          ..write('learningPace: $learningPace, ')
          ..write('favoriteInterests: $favoriteInterests, ')
          ..write('ownedSkinIds: $ownedSkinIds, ')
          ..write('selectedSkinId: $selectedSkinId, ')
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
  late final $UserRewardsTable userRewards = $UserRewardsTable(this);
  late final $AchievementsTable achievements = $AchievementsTable(this);
  late final $UserAchievementsTable userAchievements = $UserAchievementsTable(
    this,
  );
  late final $GameSessionsTable gameSessions = $GameSessionsTable(this);
  late final $UserPreferencesTable userPreferences = $UserPreferencesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userProgress,
    userRewards,
    achievements,
    userAchievements,
    gameSessions,
    userPreferences,
  ];
}

typedef $$UserProgressTableCreateCompanionBuilder =
    UserProgressCompanion Function({
      Value<int> id,
      Value<int> learningPoints,
      Value<int> spentLearningPoints,
      Value<int> gamesPlayed,
      Value<int> dayStreak,
      Value<DateTime?> lastPlayedAt,
      required DateTime updatedAt,
      Value<bool> isSynced,
      Value<int> puzzleGamesCompleted,
      Value<int> readingExercisesCompleted,
      Value<int> sortingGamesCompleted,
      Value<int> emotionsRecognized,
      Value<int> chatMessagesSent,
      Value<int> sortGameUnlockedLevel,
      Value<int> gamesInCurrentSession,
    });
typedef $$UserProgressTableUpdateCompanionBuilder =
    UserProgressCompanion Function({
      Value<int> id,
      Value<int> learningPoints,
      Value<int> spentLearningPoints,
      Value<int> gamesPlayed,
      Value<int> dayStreak,
      Value<DateTime?> lastPlayedAt,
      Value<DateTime> updatedAt,
      Value<bool> isSynced,
      Value<int> puzzleGamesCompleted,
      Value<int> readingExercisesCompleted,
      Value<int> sortingGamesCompleted,
      Value<int> emotionsRecognized,
      Value<int> chatMessagesSent,
      Value<int> sortGameUnlockedLevel,
      Value<int> gamesInCurrentSession,
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

  ColumnFilters<int> get spentLearningPoints => $composableBuilder(
    column: $table.spentLearningPoints,
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

  ColumnFilters<int> get puzzleGamesCompleted => $composableBuilder(
    column: $table.puzzleGamesCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get readingExercisesCompleted => $composableBuilder(
    column: $table.readingExercisesCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortingGamesCompleted => $composableBuilder(
    column: $table.sortingGamesCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get emotionsRecognized => $composableBuilder(
    column: $table.emotionsRecognized,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chatMessagesSent => $composableBuilder(
    column: $table.chatMessagesSent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortGameUnlockedLevel => $composableBuilder(
    column: $table.sortGameUnlockedLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gamesInCurrentSession => $composableBuilder(
    column: $table.gamesInCurrentSession,
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

  ColumnOrderings<int> get spentLearningPoints => $composableBuilder(
    column: $table.spentLearningPoints,
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

  ColumnOrderings<int> get puzzleGamesCompleted => $composableBuilder(
    column: $table.puzzleGamesCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get readingExercisesCompleted => $composableBuilder(
    column: $table.readingExercisesCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortingGamesCompleted => $composableBuilder(
    column: $table.sortingGamesCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get emotionsRecognized => $composableBuilder(
    column: $table.emotionsRecognized,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chatMessagesSent => $composableBuilder(
    column: $table.chatMessagesSent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortGameUnlockedLevel => $composableBuilder(
    column: $table.sortGameUnlockedLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gamesInCurrentSession => $composableBuilder(
    column: $table.gamesInCurrentSession,
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

  GeneratedColumn<int> get spentLearningPoints => $composableBuilder(
    column: $table.spentLearningPoints,
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

  GeneratedColumn<int> get puzzleGamesCompleted => $composableBuilder(
    column: $table.puzzleGamesCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get readingExercisesCompleted => $composableBuilder(
    column: $table.readingExercisesCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortingGamesCompleted => $composableBuilder(
    column: $table.sortingGamesCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get emotionsRecognized => $composableBuilder(
    column: $table.emotionsRecognized,
    builder: (column) => column,
  );

  GeneratedColumn<int> get chatMessagesSent => $composableBuilder(
    column: $table.chatMessagesSent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortGameUnlockedLevel => $composableBuilder(
    column: $table.sortGameUnlockedLevel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get gamesInCurrentSession => $composableBuilder(
    column: $table.gamesInCurrentSession,
    builder: (column) => column,
  );
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
                Value<int> spentLearningPoints = const Value.absent(),
                Value<int> gamesPlayed = const Value.absent(),
                Value<int> dayStreak = const Value.absent(),
                Value<DateTime?> lastPlayedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> puzzleGamesCompleted = const Value.absent(),
                Value<int> readingExercisesCompleted = const Value.absent(),
                Value<int> sortingGamesCompleted = const Value.absent(),
                Value<int> emotionsRecognized = const Value.absent(),
                Value<int> chatMessagesSent = const Value.absent(),
                Value<int> sortGameUnlockedLevel = const Value.absent(),
                Value<int> gamesInCurrentSession = const Value.absent(),
              }) => UserProgressCompanion(
                id: id,
                learningPoints: learningPoints,
                spentLearningPoints: spentLearningPoints,
                gamesPlayed: gamesPlayed,
                dayStreak: dayStreak,
                lastPlayedAt: lastPlayedAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                puzzleGamesCompleted: puzzleGamesCompleted,
                readingExercisesCompleted: readingExercisesCompleted,
                sortingGamesCompleted: sortingGamesCompleted,
                emotionsRecognized: emotionsRecognized,
                chatMessagesSent: chatMessagesSent,
                sortGameUnlockedLevel: sortGameUnlockedLevel,
                gamesInCurrentSession: gamesInCurrentSession,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> learningPoints = const Value.absent(),
                Value<int> spentLearningPoints = const Value.absent(),
                Value<int> gamesPlayed = const Value.absent(),
                Value<int> dayStreak = const Value.absent(),
                Value<DateTime?> lastPlayedAt = const Value.absent(),
                required DateTime updatedAt,
                Value<bool> isSynced = const Value.absent(),
                Value<int> puzzleGamesCompleted = const Value.absent(),
                Value<int> readingExercisesCompleted = const Value.absent(),
                Value<int> sortingGamesCompleted = const Value.absent(),
                Value<int> emotionsRecognized = const Value.absent(),
                Value<int> chatMessagesSent = const Value.absent(),
                Value<int> sortGameUnlockedLevel = const Value.absent(),
                Value<int> gamesInCurrentSession = const Value.absent(),
              }) => UserProgressCompanion.insert(
                id: id,
                learningPoints: learningPoints,
                spentLearningPoints: spentLearningPoints,
                gamesPlayed: gamesPlayed,
                dayStreak: dayStreak,
                lastPlayedAt: lastPlayedAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                puzzleGamesCompleted: puzzleGamesCompleted,
                readingExercisesCompleted: readingExercisesCompleted,
                sortingGamesCompleted: sortingGamesCompleted,
                emotionsRecognized: emotionsRecognized,
                chatMessagesSent: chatMessagesSent,
                sortGameUnlockedLevel: sortGameUnlockedLevel,
                gamesInCurrentSession: gamesInCurrentSession,
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
typedef $$UserRewardsTableCreateCompanionBuilder =
    UserRewardsCompanion Function({
      Value<int> id,
      required String prize,
      required String conditionType,
      required int targetCount,
      Value<int> currentProgress,
      Value<bool> isCompleted,
      Value<bool> isClaimed,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$UserRewardsTableUpdateCompanionBuilder =
    UserRewardsCompanion Function({
      Value<int> id,
      Value<String> prize,
      Value<String> conditionType,
      Value<int> targetCount,
      Value<int> currentProgress,
      Value<bool> isCompleted,
      Value<bool> isClaimed,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$UserRewardsTableFilterComposer
    extends Composer<_$AppDatabase, $UserRewardsTable> {
  $$UserRewardsTableFilterComposer({
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

  ColumnFilters<String> get prize => $composableBuilder(
    column: $table.prize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conditionType => $composableBuilder(
    column: $table.conditionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetCount => $composableBuilder(
    column: $table.targetCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentProgress => $composableBuilder(
    column: $table.currentProgress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isClaimed => $composableBuilder(
    column: $table.isClaimed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserRewardsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserRewardsTable> {
  $$UserRewardsTableOrderingComposer({
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

  ColumnOrderings<String> get prize => $composableBuilder(
    column: $table.prize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conditionType => $composableBuilder(
    column: $table.conditionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetCount => $composableBuilder(
    column: $table.targetCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentProgress => $composableBuilder(
    column: $table.currentProgress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isClaimed => $composableBuilder(
    column: $table.isClaimed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserRewardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserRewardsTable> {
  $$UserRewardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get prize =>
      $composableBuilder(column: $table.prize, builder: (column) => column);

  GeneratedColumn<String> get conditionType => $composableBuilder(
    column: $table.conditionType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetCount => $composableBuilder(
    column: $table.targetCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentProgress => $composableBuilder(
    column: $table.currentProgress,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isClaimed =>
      $composableBuilder(column: $table.isClaimed, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserRewardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserRewardsTable,
          UserReward,
          $$UserRewardsTableFilterComposer,
          $$UserRewardsTableOrderingComposer,
          $$UserRewardsTableAnnotationComposer,
          $$UserRewardsTableCreateCompanionBuilder,
          $$UserRewardsTableUpdateCompanionBuilder,
          (
            UserReward,
            BaseReferences<_$AppDatabase, $UserRewardsTable, UserReward>,
          ),
          UserReward,
          PrefetchHooks Function()
        > {
  $$UserRewardsTableTableManager(_$AppDatabase db, $UserRewardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserRewardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserRewardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserRewardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> prize = const Value.absent(),
                Value<String> conditionType = const Value.absent(),
                Value<int> targetCount = const Value.absent(),
                Value<int> currentProgress = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<bool> isClaimed = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserRewardsCompanion(
                id: id,
                prize: prize,
                conditionType: conditionType,
                targetCount: targetCount,
                currentProgress: currentProgress,
                isCompleted: isCompleted,
                isClaimed: isClaimed,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String prize,
                required String conditionType,
                required int targetCount,
                Value<int> currentProgress = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<bool> isClaimed = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => UserRewardsCompanion.insert(
                id: id,
                prize: prize,
                conditionType: conditionType,
                targetCount: targetCount,
                currentProgress: currentProgress,
                isCompleted: isCompleted,
                isClaimed: isClaimed,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserRewardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserRewardsTable,
      UserReward,
      $$UserRewardsTableFilterComposer,
      $$UserRewardsTableOrderingComposer,
      $$UserRewardsTableAnnotationComposer,
      $$UserRewardsTableCreateCompanionBuilder,
      $$UserRewardsTableUpdateCompanionBuilder,
      (
        UserReward,
        BaseReferences<_$AppDatabase, $UserRewardsTable, UserReward>,
      ),
      UserReward,
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
typedef $$GameSessionsTableCreateCompanionBuilder =
    GameSessionsCompanion Function({
      Value<int> id,
      required String gameType,
      Value<String?> levelId,
      Value<String?> difficulty,
      Value<int> correctActions,
      Value<int> totalActions,
      Value<int> accuracyPercent,
      Value<int?> starsEarned,
      Value<int> durationSeconds,
      required DateTime sessionStartedAt,
      required DateTime sessionEndedAt,
      required DateTime createdAt,
      Value<bool> isSynced,
    });
typedef $$GameSessionsTableUpdateCompanionBuilder =
    GameSessionsCompanion Function({
      Value<int> id,
      Value<String> gameType,
      Value<String?> levelId,
      Value<String?> difficulty,
      Value<int> correctActions,
      Value<int> totalActions,
      Value<int> accuracyPercent,
      Value<int?> starsEarned,
      Value<int> durationSeconds,
      Value<DateTime> sessionStartedAt,
      Value<DateTime> sessionEndedAt,
      Value<DateTime> createdAt,
      Value<bool> isSynced,
    });

class $$GameSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $GameSessionsTable> {
  $$GameSessionsTableFilterComposer({
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

  ColumnFilters<String> get gameType => $composableBuilder(
    column: $table.gameType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get levelId => $composableBuilder(
    column: $table.levelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctActions => $composableBuilder(
    column: $table.correctActions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalActions => $composableBuilder(
    column: $table.totalActions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accuracyPercent => $composableBuilder(
    column: $table.accuracyPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get starsEarned => $composableBuilder(
    column: $table.starsEarned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get sessionStartedAt => $composableBuilder(
    column: $table.sessionStartedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get sessionEndedAt => $composableBuilder(
    column: $table.sessionEndedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GameSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $GameSessionsTable> {
  $$GameSessionsTableOrderingComposer({
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

  ColumnOrderings<String> get gameType => $composableBuilder(
    column: $table.gameType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get levelId => $composableBuilder(
    column: $table.levelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctActions => $composableBuilder(
    column: $table.correctActions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalActions => $composableBuilder(
    column: $table.totalActions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accuracyPercent => $composableBuilder(
    column: $table.accuracyPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get starsEarned => $composableBuilder(
    column: $table.starsEarned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get sessionStartedAt => $composableBuilder(
    column: $table.sessionStartedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get sessionEndedAt => $composableBuilder(
    column: $table.sessionEndedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GameSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameSessionsTable> {
  $$GameSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get gameType =>
      $composableBuilder(column: $table.gameType, builder: (column) => column);

  GeneratedColumn<String> get levelId =>
      $composableBuilder(column: $table.levelId, builder: (column) => column);

  GeneratedColumn<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<int> get correctActions => $composableBuilder(
    column: $table.correctActions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalActions => $composableBuilder(
    column: $table.totalActions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get accuracyPercent => $composableBuilder(
    column: $table.accuracyPercent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get starsEarned => $composableBuilder(
    column: $table.starsEarned,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get sessionStartedAt => $composableBuilder(
    column: $table.sessionStartedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get sessionEndedAt => $composableBuilder(
    column: $table.sessionEndedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$GameSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameSessionsTable,
          GameSession,
          $$GameSessionsTableFilterComposer,
          $$GameSessionsTableOrderingComposer,
          $$GameSessionsTableAnnotationComposer,
          $$GameSessionsTableCreateCompanionBuilder,
          $$GameSessionsTableUpdateCompanionBuilder,
          (
            GameSession,
            BaseReferences<_$AppDatabase, $GameSessionsTable, GameSession>,
          ),
          GameSession,
          PrefetchHooks Function()
        > {
  $$GameSessionsTableTableManager(_$AppDatabase db, $GameSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> gameType = const Value.absent(),
                Value<String?> levelId = const Value.absent(),
                Value<String?> difficulty = const Value.absent(),
                Value<int> correctActions = const Value.absent(),
                Value<int> totalActions = const Value.absent(),
                Value<int> accuracyPercent = const Value.absent(),
                Value<int?> starsEarned = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<DateTime> sessionStartedAt = const Value.absent(),
                Value<DateTime> sessionEndedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => GameSessionsCompanion(
                id: id,
                gameType: gameType,
                levelId: levelId,
                difficulty: difficulty,
                correctActions: correctActions,
                totalActions: totalActions,
                accuracyPercent: accuracyPercent,
                starsEarned: starsEarned,
                durationSeconds: durationSeconds,
                sessionStartedAt: sessionStartedAt,
                sessionEndedAt: sessionEndedAt,
                createdAt: createdAt,
                isSynced: isSynced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String gameType,
                Value<String?> levelId = const Value.absent(),
                Value<String?> difficulty = const Value.absent(),
                Value<int> correctActions = const Value.absent(),
                Value<int> totalActions = const Value.absent(),
                Value<int> accuracyPercent = const Value.absent(),
                Value<int?> starsEarned = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                required DateTime sessionStartedAt,
                required DateTime sessionEndedAt,
                required DateTime createdAt,
                Value<bool> isSynced = const Value.absent(),
              }) => GameSessionsCompanion.insert(
                id: id,
                gameType: gameType,
                levelId: levelId,
                difficulty: difficulty,
                correctActions: correctActions,
                totalActions: totalActions,
                accuracyPercent: accuracyPercent,
                starsEarned: starsEarned,
                durationSeconds: durationSeconds,
                sessionStartedAt: sessionStartedAt,
                sessionEndedAt: sessionEndedAt,
                createdAt: createdAt,
                isSynced: isSynced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GameSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameSessionsTable,
      GameSession,
      $$GameSessionsTableFilterComposer,
      $$GameSessionsTableOrderingComposer,
      $$GameSessionsTableAnnotationComposer,
      $$GameSessionsTableCreateCompanionBuilder,
      $$GameSessionsTableUpdateCompanionBuilder,
      (
        GameSession,
        BaseReferences<_$AppDatabase, $GameSessionsTable, GameSession>,
      ),
      GameSession,
      PrefetchHooks Function()
    >;
typedef $$UserPreferencesTableCreateCompanionBuilder =
    UserPreferencesCompanion Function({
      Value<int> id,
      Value<int> communicationLevel,
      Value<int> sensorySensitivity,
      Value<int> learningPace,
      Value<String> favoriteInterests,
      Value<String> ownedSkinIds,
      Value<int> selectedSkinId,
      required DateTime updatedAt,
      Value<bool> isSynced,
    });
typedef $$UserPreferencesTableUpdateCompanionBuilder =
    UserPreferencesCompanion Function({
      Value<int> id,
      Value<int> communicationLevel,
      Value<int> sensorySensitivity,
      Value<int> learningPace,
      Value<String> favoriteInterests,
      Value<String> ownedSkinIds,
      Value<int> selectedSkinId,
      Value<DateTime> updatedAt,
      Value<bool> isSynced,
    });

class $$UserPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableFilterComposer({
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

  ColumnFilters<int> get communicationLevel => $composableBuilder(
    column: $table.communicationLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sensorySensitivity => $composableBuilder(
    column: $table.sensorySensitivity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get learningPace => $composableBuilder(
    column: $table.learningPace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get favoriteInterests => $composableBuilder(
    column: $table.favoriteInterests,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownedSkinIds => $composableBuilder(
    column: $table.ownedSkinIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get selectedSkinId => $composableBuilder(
    column: $table.selectedSkinId,
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

class $$UserPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableOrderingComposer({
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

  ColumnOrderings<int> get communicationLevel => $composableBuilder(
    column: $table.communicationLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sensorySensitivity => $composableBuilder(
    column: $table.sensorySensitivity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get learningPace => $composableBuilder(
    column: $table.learningPace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get favoriteInterests => $composableBuilder(
    column: $table.favoriteInterests,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownedSkinIds => $composableBuilder(
    column: $table.ownedSkinIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get selectedSkinId => $composableBuilder(
    column: $table.selectedSkinId,
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

class $$UserPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get communicationLevel => $composableBuilder(
    column: $table.communicationLevel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sensorySensitivity => $composableBuilder(
    column: $table.sensorySensitivity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get learningPace => $composableBuilder(
    column: $table.learningPace,
    builder: (column) => column,
  );

  GeneratedColumn<String> get favoriteInterests => $composableBuilder(
    column: $table.favoriteInterests,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownedSkinIds => $composableBuilder(
    column: $table.ownedSkinIds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get selectedSkinId => $composableBuilder(
    column: $table.selectedSkinId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$UserPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserPreferencesTable,
          UserPreference,
          $$UserPreferencesTableFilterComposer,
          $$UserPreferencesTableOrderingComposer,
          $$UserPreferencesTableAnnotationComposer,
          $$UserPreferencesTableCreateCompanionBuilder,
          $$UserPreferencesTableUpdateCompanionBuilder,
          (
            UserPreference,
            BaseReferences<
              _$AppDatabase,
              $UserPreferencesTable,
              UserPreference
            >,
          ),
          UserPreference,
          PrefetchHooks Function()
        > {
  $$UserPreferencesTableTableManager(
    _$AppDatabase db,
    $UserPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserPreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> communicationLevel = const Value.absent(),
                Value<int> sensorySensitivity = const Value.absent(),
                Value<int> learningPace = const Value.absent(),
                Value<String> favoriteInterests = const Value.absent(),
                Value<String> ownedSkinIds = const Value.absent(),
                Value<int> selectedSkinId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => UserPreferencesCompanion(
                id: id,
                communicationLevel: communicationLevel,
                sensorySensitivity: sensorySensitivity,
                learningPace: learningPace,
                favoriteInterests: favoriteInterests,
                ownedSkinIds: ownedSkinIds,
                selectedSkinId: selectedSkinId,
                updatedAt: updatedAt,
                isSynced: isSynced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> communicationLevel = const Value.absent(),
                Value<int> sensorySensitivity = const Value.absent(),
                Value<int> learningPace = const Value.absent(),
                Value<String> favoriteInterests = const Value.absent(),
                Value<String> ownedSkinIds = const Value.absent(),
                Value<int> selectedSkinId = const Value.absent(),
                required DateTime updatedAt,
                Value<bool> isSynced = const Value.absent(),
              }) => UserPreferencesCompanion.insert(
                id: id,
                communicationLevel: communicationLevel,
                sensorySensitivity: sensorySensitivity,
                learningPace: learningPace,
                favoriteInterests: favoriteInterests,
                ownedSkinIds: ownedSkinIds,
                selectedSkinId: selectedSkinId,
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

typedef $$UserPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserPreferencesTable,
      UserPreference,
      $$UserPreferencesTableFilterComposer,
      $$UserPreferencesTableOrderingComposer,
      $$UserPreferencesTableAnnotationComposer,
      $$UserPreferencesTableCreateCompanionBuilder,
      $$UserPreferencesTableUpdateCompanionBuilder,
      (
        UserPreference,
        BaseReferences<_$AppDatabase, $UserPreferencesTable, UserPreference>,
      ),
      UserPreference,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserProgressTableTableManager get userProgress =>
      $$UserProgressTableTableManager(_db, _db.userProgress);
  $$UserRewardsTableTableManager get userRewards =>
      $$UserRewardsTableTableManager(_db, _db.userRewards);
  $$AchievementsTableTableManager get achievements =>
      $$AchievementsTableTableManager(_db, _db.achievements);
  $$UserAchievementsTableTableManager get userAchievements =>
      $$UserAchievementsTableTableManager(_db, _db.userAchievements);
  $$GameSessionsTableTableManager get gameSessions =>
      $$GameSessionsTableTableManager(_db, _db.gameSessions);
  $$UserPreferencesTableTableManager get userPreferences =>
      $$UserPreferencesTableTableManager(_db, _db.userPreferences);
}
