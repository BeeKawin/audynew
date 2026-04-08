import 'package:drift/drift.dart';

class UserProgress extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get learningPoints => integer().withDefault(const Constant(0))();
  IntColumn get gamesPlayed => integer().withDefault(const Constant(0))();
  IntColumn get dayStreak => integer().withDefault(const Constant(1))();
  DateTimeColumn get lastPlayedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}
