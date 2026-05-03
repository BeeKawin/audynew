import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'tables/user_progress.dart';
import 'tables/user_rewards.dart';
import 'tables/achievements.dart';
import 'tables/user_achievements.dart';
import 'tables/game_sessions.dart';

part 'database.g.dart';

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'audy_db',
    native: const DriftNativeOptions(
      databaseDirectory: getApplicationSupportDirectory,
    ),
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}

@DriftDatabase(
  tables: [
    UserProgress,
    UserRewards,
    Achievements,
    UserAchievements,
    GameSessions,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        // Migration from version 1 to 2: Add game counter columns
        if (from == 1) {
          await m.addColumn(
            userProgress,
            userProgress.puzzleGamesCompleted,
          );
          await m.addColumn(
            userProgress,
            userProgress.readingExercisesCompleted,
          );
          await m.addColumn(
            userProgress,
            userProgress.sortingGamesCompleted,
          );
          await m.addColumn(
            userProgress,
            userProgress.emotionsRecognized,
          );
          await m.addColumn(
            userProgress,
            userProgress.chatMessagesSent,
          );
          await m.addColumn(
            userProgress,
            userProgress.colorsSortedCorrectly,
          );
        }
        // Migration from version 2 to 3: Add game sessions table
        if (from <= 2) {
          await m.createTable(gameSessions);
        }
      },
    );
  }
}
