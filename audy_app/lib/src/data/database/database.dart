import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'tables/user_progress.dart';
import 'tables/user_rewards.dart';
import 'tables/achievements.dart';
import 'tables/user_achievements.dart';
import 'tables/game_sessions.dart';
import 'tables/user_preferences.dart';

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
    UserPreferences,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        // Migration from version 1 to 2: Add game counter columns
        if (from == 1) {
          await m.addColumn(userProgress, userProgress.puzzleGamesCompleted);
          await m.addColumn(
            userProgress,
            userProgress.readingExercisesCompleted,
          );
          await m.addColumn(userProgress, userProgress.sortingGamesCompleted);
          await m.addColumn(userProgress, userProgress.emotionsRecognized);
          await m.addColumn(userProgress, userProgress.chatMessagesSent);
        }
        // Migration from version 2 to 3: Add game sessions table
        if (from <= 2) {
          await m.createTable(gameSessions);
        }
        // Migration from version 3 to 4: Add sortGameUnlockedLevel column
        if (from <= 3) {
          await m.addColumn(userProgress, userProgress.sortGameUnlockedLevel);
        }
        // Migration from version 4 to 5: Add userPreferences table
        if (from <= 4) {
          await m.createTable(userPreferences);
        }
        // Migration from version 5 to 6: Add gamesInCurrentSession column
        if (from <= 5) {
          await m.addColumn(userProgress, userProgress.gamesInCurrentSession);
        }
      },
    );
  }
}
