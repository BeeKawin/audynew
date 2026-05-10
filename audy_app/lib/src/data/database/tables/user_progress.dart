import 'package:drift/drift.dart';

class UserProgress extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get learningPoints => integer().withDefault(const Constant(0))();
  IntColumn get spentLearningPoints =>
      integer().withDefault(const Constant(0))();
  IntColumn get gamesPlayed => integer().withDefault(const Constant(0))();
  IntColumn get dayStreak => integer().withDefault(const Constant(1))();
  DateTimeColumn get lastPlayedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  // Game-specific counters for achievement tracking
  IntColumn get puzzleGamesCompleted =>
      integer().withDefault(const Constant(0))();
  IntColumn get readingExercisesCompleted =>
      integer().withDefault(const Constant(0))();
  IntColumn get sortingGamesCompleted =>
      integer().withDefault(const Constant(0))();
  IntColumn get emotionsRecognized => integer().withDefault(const Constant(0))();
  IntColumn get chatMessagesSent => integer().withDefault(const Constant(0))();
  IntColumn get colorsSortedCorrectly =>
      integer().withDefault(const Constant(0))();
  IntColumn get sortGameUnlockedLevel =>
      integer().withDefault(const Constant(0))();

  // Meltdown protection - games played in current session
  IntColumn get gamesInCurrentSession =>
      integer().withDefault(const Constant(0))();
}
