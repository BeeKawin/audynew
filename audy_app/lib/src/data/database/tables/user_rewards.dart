import 'package:drift/drift.dart';

class UserRewards extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get prize => text()();
  TextColumn get conditionType => text()();
  IntColumn get targetCount => integer()();
  IntColumn get currentProgress => integer().withDefault(const Constant(0))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isClaimed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
