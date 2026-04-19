import 'package:drift/drift.dart';

class UserAchievements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get achievementId => integer()();
  BoolColumn get unlocked => boolean().withDefault(const Constant(false))();
  DateTimeColumn get unlockedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}
