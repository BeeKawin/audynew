import 'package:drift/drift.dart';

class UserAccessories extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get accessoryId => integer()();
  BoolColumn get owned => boolean().withDefault(const Constant(false))();
  IntColumn get x => integer().nullable()();
  IntColumn get y => integer().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}
