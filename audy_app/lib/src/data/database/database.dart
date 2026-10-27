import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'tables/user_progress.dart';
import 'tables/user_rewards.dart';
import 'tables/game_sessions.dart';
import 'tables/user_preferences.dart';

part 'database.g.dart';

QueryExecutor _openConnection(
  String name,
  void Function(String)? onWebStorageWarning,
) {
  return driftDatabase(
    name: name,
    native: const DriftNativeOptions(
      databaseDirectory: getApplicationSupportDirectory,
    ),
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
      onResult: (result) {
        if (result.chosenImplementation == WasmStorageImplementation.inMemory) {
          onWebStorageWarning?.call(
            'This browser can only keep local progress until this tab closes. Use regular browsing to keep it.',
          );
        } else if (result.chosenImplementation ==
            WasmStorageImplementation.unsafeIndexedDb) {
          onWebStorageWarning?.call(
            'Please keep AUDY open in only one tab in this browser.',
          );
        }
      },
    ),
  );
}

@DriftDatabase(
  tables: [UserProgress, UserRewards, GameSessions, UserPreferences],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase({
    String name = 'audy_db',
    void Function(String)? onWebStorageWarning,
  }) : super(_openConnection(name, onWebStorageWarning));
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 9;

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
        // Migration from version 6 to 7: Add reward skin economy state
        if (from <= 6) {
          await m.addColumn(userProgress, userProgress.spentLearningPoints);
        }
        if (from >= 5 && from <= 6) {
          await m.addColumn(userPreferences, userPreferences.ownedSkinIds);
          await m.addColumn(userPreferences, userPreferences.selectedSkinId);
        }
        // Migration from version 7 to 8: Reset analytics session history only.
        if (from <= 7) {
          await delete(gameSessions).go();
        }
        if (from <= 8) {
          await transaction(() async {
            await customStatement('DROP TABLE IF EXISTS user_achievements');
            await customStatement('DROP TABLE IF EXISTS achievements');
          });
        }
      },
    );
  }
}
