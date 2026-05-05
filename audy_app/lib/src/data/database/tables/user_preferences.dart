import 'package:drift/drift.dart';

/// User preferences table for autism-related settings
/// Stores personalization data to customize the app experience
class UserPreferences extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get communicationLevel =>
      integer().withDefault(const Constant(3))(); // 0=non-verbal, 1=single words, 2=short phrases, 3=full sentences
  IntColumn get sensorySensitivity =>
      integer().withDefault(const Constant(1))(); // 0=low, 1=medium, 2=high
  IntColumn get learningPace =>
      integer().withDefault(const Constant(1))(); // 0=slower, 1=standard, 2=faster
  TextColumn get favoriteInterests =>
      text().withDefault(const Constant(''))(); // comma-separated list
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}
