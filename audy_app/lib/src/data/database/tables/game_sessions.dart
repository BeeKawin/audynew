import 'package:drift/drift.dart';

/// Table storing individual game sessions for analytics
/// Tracks play time, accuracy, and performance per game type
class GameSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  /// Game type: sorting, emotion_classify, emotion_mimic, minipuzzle, reaction, reading
  TextColumn get gameType => text()();
  
  /// Level identifier (for sorting, puzzle games)
  TextColumn get levelId => text().nullable()();
  
  /// Difficulty: easy, medium, hard
  TextColumn get difficulty => text().nullable()();
  
  /// Number of correct actions/answers
  IntColumn get correctActions => integer().withDefault(const Constant(0))();
  
  /// Total actions/attempts
  IntColumn get totalActions => integer().withDefault(const Constant(0))();
  
  /// Accuracy percentage (0-100)
  IntColumn get accuracyPercent => integer().withDefault(const Constant(0))();
  
  /// Stars earned (for games with star system)
  IntColumn get starsEarned => integer().nullable()();
  
  /// Duration in seconds
  IntColumn get durationSeconds => integer().withDefault(const Constant(0))();
  
  /// When the session started
  DateTimeColumn get sessionStartedAt => dateTime()();
  
  /// When the session ended
  DateTimeColumn get sessionEndedAt => dateTime()();
  
  /// Row creation timestamp
  DateTimeColumn get createdAt => dateTime()();
  
  /// Future-proof for cloud sync
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}
