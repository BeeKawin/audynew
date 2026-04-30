import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'tables/user_progress.dart';
import 'tables/user_rewards.dart';
import 'tables/achievements.dart';
import 'tables/user_achievements.dart';

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
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}
