import 'package:drift/drift.dart';

import '../database/database.dart';
import '../models/progress_model.dart';
import '../models/game_session_model.dart';

export '../models/progress_model.dart';
export '../models/game_session_model.dart';

/// Local data source for offline-first architecture
/// All operations are synchronous with local SQLite (Drift)
class LocalDataSource {
  final AppDatabase db;

  LocalDataSource(this.db);

  // ==================== USER PROGRESS ====================

  Future<ProgressData?> getProgress() async {
    final results = await db.select(db.userProgress).get();
    if (results.isEmpty) return null;

    final row = results.first;
    return ProgressData(
      learningPoints: row.learningPoints,
      spentLearningPoints: row.spentLearningPoints,
      gamesPlayed: row.gamesPlayed,
      dayStreak: row.dayStreak,
      lastPlayedAt: row.lastPlayedAt,
      puzzleGamesCompleted: row.puzzleGamesCompleted,
      readingExercisesCompleted: row.readingExercisesCompleted,
      sortingGamesCompleted: row.sortingGamesCompleted,
      emotionsRecognized: row.emotionsRecognized,
      chatMessagesSent: row.chatMessagesSent,
      sortGameUnlockedLevel: row.sortGameUnlockedLevel,
      gamesInCurrentSession: row.gamesInCurrentSession,
    );
  }

  Future<void> saveProgress(ProgressData progress) async {
    final existing = await db.select(db.userProgress).get();

    if (existing.isEmpty) {
      // Insert new row if none exists
      await db
          .into(db.userProgress)
          .insert(
            UserProgressCompanion.insert(
              learningPoints: Value(progress.learningPoints),
              spentLearningPoints: Value(progress.spentLearningPoints),
              gamesPlayed: Value(progress.gamesPlayed),
              dayStreak: Value(progress.dayStreak),
              lastPlayedAt: progress.lastPlayedAt != null
                  ? Value(progress.lastPlayedAt!)
                  : const Value.absent(),
              updatedAt: DateTime.now(),
              isSynced: const Value(false),
              puzzleGamesCompleted: Value(progress.puzzleGamesCompleted),
              readingExercisesCompleted: Value(
                progress.readingExercisesCompleted,
              ),
              sortingGamesCompleted: Value(progress.sortingGamesCompleted),
              emotionsRecognized: Value(progress.emotionsRecognized),
              chatMessagesSent: Value(progress.chatMessagesSent),
              sortGameUnlockedLevel: Value(progress.sortGameUnlockedLevel),
              gamesInCurrentSession: Value(progress.gamesInCurrentSession),
            ),
          );
    } else {
      // Update the existing row by id
      await (db.update(
        db.userProgress,
      )..where((t) => t.id.equals(existing.first.id))).write(
        UserProgressCompanion(
          learningPoints: Value(progress.learningPoints),
          spentLearningPoints: Value(progress.spentLearningPoints),
          gamesPlayed: Value(progress.gamesPlayed),
          dayStreak: Value(progress.dayStreak),
          lastPlayedAt: progress.lastPlayedAt != null
              ? Value(progress.lastPlayedAt!)
              : const Value.absent(),
          updatedAt: Value(DateTime.now()),
          isSynced: const Value(false),
          puzzleGamesCompleted: Value(progress.puzzleGamesCompleted),
          readingExercisesCompleted: Value(progress.readingExercisesCompleted),
          sortingGamesCompleted: Value(progress.sortingGamesCompleted),
          emotionsRecognized: Value(progress.emotionsRecognized),
          chatMessagesSent: Value(progress.chatMessagesSent),
          sortGameUnlockedLevel: Value(progress.sortGameUnlockedLevel),
          gamesInCurrentSession: Value(progress.gamesInCurrentSession),
        ),
      );
    }
  }

  Future<void> resetProgress() async {
    final existing = await db.select(db.userProgress).get();

    if (existing.isEmpty) {
      // Insert new row if none exists
      await db
          .into(db.userProgress)
          .insert(
            UserProgressCompanion.insert(
              learningPoints: const Value(0),
              spentLearningPoints: const Value(0),
              gamesPlayed: const Value(0),
              dayStreak: const Value(1),
              lastPlayedAt: Value(DateTime.now()),
              updatedAt: DateTime.now(),
              isSynced: const Value(false),
              puzzleGamesCompleted: const Value(0),
              readingExercisesCompleted: const Value(0),
              sortingGamesCompleted: const Value(0),
              emotionsRecognized: const Value(0),
              chatMessagesSent: const Value(0),
              sortGameUnlockedLevel: const Value(0),
              gamesInCurrentSession: const Value(0),
            ),
          );
    } else {
      // Update the existing row by id with reset values
      await (db.update(
        db.userProgress,
      )..where((t) => t.id.equals(existing.first.id))).write(
        UserProgressCompanion(
          learningPoints: const Value(0),
          spentLearningPoints: const Value(0),
          gamesPlayed: const Value(0),
          dayStreak: const Value(1),
          lastPlayedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
          isSynced: const Value(false),
          puzzleGamesCompleted: const Value(0),
          readingExercisesCompleted: const Value(0),
          sortingGamesCompleted: const Value(0),
          emotionsRecognized: const Value(0),
          chatMessagesSent: const Value(0),
          sortGameUnlockedLevel: const Value(0),
          gamesInCurrentSession: const Value(0),
        ),
      );
    }
  }

  // ==================== USER PREFERENCES ====================

  Future<UserPreferences?> getUserPreferences() async {
    final results = await db.select(db.userPreferences).get();
    if (results.isEmpty) return null;

    final row = results.first;
    return UserPreferences(
      communicationLevel: row.communicationLevel,
      sensorySensitivity: row.sensorySensitivity,
      learningPace: row.learningPace,
      favoriteInterests: row.favoriteInterests,
      ownedSkinIds: row.ownedSkinIds,
      selectedSkinId: row.selectedSkinId,
    );
  }

  Future<void> saveUserPreferences(UserPreferences preferences) async {
    final existing = await db.select(db.userPreferences).get();

    if (existing.isEmpty) {
      // Insert new row if none exists
      await db
          .into(db.userPreferences)
          .insert(
            UserPreferencesCompanion.insert(
              communicationLevel: Value(preferences.communicationLevel),
              sensorySensitivity: Value(preferences.sensorySensitivity),
              learningPace: Value(preferences.learningPace),
              favoriteInterests: Value(preferences.favoriteInterests),
              ownedSkinIds: Value(preferences.ownedSkinIds),
              selectedSkinId: Value(preferences.selectedSkinId),
              updatedAt: DateTime.now(),
              isSynced: const Value(false),
            ),
          );
    } else {
      // Update the existing row by id
      await (db.update(
        db.userPreferences,
      )..where((t) => t.id.equals(existing.first.id))).write(
        UserPreferencesCompanion(
          communicationLevel: Value(preferences.communicationLevel),
          sensorySensitivity: Value(preferences.sensorySensitivity),
          learningPace: Value(preferences.learningPace),
          favoriteInterests: Value(preferences.favoriteInterests),
          ownedSkinIds: Value(preferences.ownedSkinIds),
          selectedSkinId: Value(preferences.selectedSkinId),
          updatedAt: Value(DateTime.now()),
          isSynced: const Value(false),
        ),
      );
    }
  }

  Future<void> seedDefaultPreferences() async {
    // Initialize default preferences if empty
    final prefs = await db.select(db.userPreferences).get();
    if (prefs.isEmpty) {
      await db
          .into(db.userPreferences)
          .insert(
            UserPreferencesCompanion.insert(
              communicationLevel: const Value(3), // Full sentences (default)
              sensorySensitivity: const Value(1), // Medium (default)
              learningPace: const Value(1), // Standard (default)
              favoriteInterests: const Value(''),
              ownedSkinIds: const Value('0'),
              selectedSkinId: const Value(0),
              updatedAt: DateTime.now(),
              isSynced: const Value(false),
            ),
          );
    }
  }

  // ==================== USER REWARDS ====================

  Future<List<RewardData>> getUserRewards() async {
    final rewards = await db.select(db.userRewards).get();
    return rewards
        .map(
          (r) => RewardData(
            id: r.id,
            prize: r.prize,
            conditionType: r.conditionType,
            targetCount: r.targetCount,
            currentProgress: r.currentProgress,
            isCompleted: r.isCompleted,
            isClaimed: r.isClaimed,
            createdAt: r.createdAt,
          ),
        )
        .toList();
  }

  Future<List<RewardData>> getActiveRewards() async {
    final all = await getUserRewards();
    return all.where((r) => !r.isCompleted).toList();
  }

  Future<int> addReward(
    String prize,
    String conditionType,
    int targetCount,
  ) async {
    final id = await db
        .into(db.userRewards)
        .insert(
          UserRewardsCompanion.insert(
            prize: prize,
            conditionType: conditionType,
            targetCount: targetCount,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
    return id;
  }

  Future<void> updateRewardProgress(int rewardId, int progress) async {
    await db
        .update(db.userRewards)
        .replace(
          UserRewardsCompanion(
            id: Value(rewardId),
            currentProgress: Value(progress),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> markRewardCompleted(int rewardId) async {
    final existing = await db.select(db.userRewards).get();
    final reward = existing.firstWhere((r) => r.id == rewardId);

    await db
        .update(db.userRewards)
        .replace(
          UserRewardsCompanion(
            id: Value(rewardId),
            prize: Value(reward.prize),
            conditionType: Value(reward.conditionType),
            targetCount: Value(reward.targetCount),
            currentProgress: Value(reward.currentProgress),
            isCompleted: const Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> claimReward(int rewardId) async {
    final existing = await db.select(db.userRewards).get();
    final reward = existing.firstWhere((r) => r.id == rewardId);

    await db
        .update(db.userRewards)
        .replace(
          UserRewardsCompanion(
            id: Value(rewardId),
            prize: Value(reward.prize),
            conditionType: Value(reward.conditionType),
            targetCount: Value(reward.targetCount),
            currentProgress: Value(reward.currentProgress),
            isCompleted: const Value(true),
            isClaimed: const Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> deleteReward(int rewardId) async {
    await (db.delete(db.userRewards)..where((r) => r.id.equals(rewardId))).go();
  }

  // ==================== ACHIEVEMENTS ====================

  Future<List<AchievementData>> getAllAchievements() async {
    final achievements = await db.select(db.achievements).get();
    final userAchievements = await db.select(db.userAchievements).get();

    final userMap = {for (var ua in userAchievements) ua.achievementId: ua};

    return achievements.map((a) {
      final userA = userMap[a.id];
      return AchievementData(
        id: a.id,
        key: a.key,
        title: a.title,
        description: a.description,
        unlocked: userA?.unlocked ?? false,
        unlockedAt: userA?.unlockedAt,
      );
    }).toList();
  }

  Future<void> unlockAchievement(int achievementId) async {
    await db
        .into(db.userAchievements)
        .insertOnConflictUpdate(
          UserAchievementsCompanion.insert(
            achievementId: achievementId,
            unlocked: const Value(true),
            unlockedAt: Value(DateTime.now()),
            updatedAt: DateTime.now(),
            isSynced: const Value(false),
          ),
        );
  }

  // ==================== SEED DATA ====================

  Future<void> seedInitialData() async {
    // Seed achievements if empty
    final achievementCount = await db.select(db.achievements).get();
    if (achievementCount.isEmpty) {
      await _seedAchievements();
    }

    // Initialize user progress if empty
    final progress = await db.select(db.userProgress).get();
    if (progress.isEmpty) {
      await db
          .into(db.userProgress)
          .insert(
            UserProgressCompanion.insert(
              learningPoints: const Value(0),
              spentLearningPoints: const Value(0),
              gamesPlayed: const Value(0),
              dayStreak: const Value(1),
              lastPlayedAt: const Value.absent(),
              updatedAt: DateTime.now(),
              isSynced: const Value(false),
              puzzleGamesCompleted: const Value(0),
              readingExercisesCompleted: const Value(0),
              sortingGamesCompleted: const Value(0),
              emotionsRecognized: const Value(0),
              chatMessagesSent: const Value(0),
              sortGameUnlockedLevel: const Value(0),
            ),
          );
    }

    // Initialize user preferences if empty
    await seedDefaultPreferences();
  }

  Future<void> _seedAchievements() async {
    final defaultAchievements = [
      (
        key: 'first_steps',
        title: 'First Steps',
        desc: 'Complete your first game',
      ),
      (
        key: 'emotion_expert',
        title: 'Emotion Expert',
        desc: 'Master 5 emotions',
      ),
      (
        key: 'quick_reflexes',
        title: 'Quick Reflexes',
        desc: 'Average under 300ms',
      ),
      (
        key: 'social_butterfly',
        title: 'Social Butterfly',
        desc: 'Have 10 conversations',
      ),
      (
        key: 'puzzle_starter',
        title: 'Puzzle Starter',
        desc: 'Complete first mini-puzzle',
      ),
      (
        key: 'speed_star',
        title: 'Speed Star',
        desc: 'Complete emotion game fast',
      ),
      (
        key: 'sorting_champion',
        title: 'Sorting Champion',
        desc: 'Complete 10 sorting games',
      ),
      (
        key: 'reading_buddy',
        title: 'Reading Buddy',
        desc: 'Complete 5 reading exercises',
      ),
      (
        key: 'emotion_explorer',
        title: 'Emotion Explorer',
        desc: 'Recognize all 5 emotions',
      ),
      (
        key: 'streak_keeper',
        title: 'Streak Keeper',
        desc: 'Play for 3 days in a row',
      ),
      (key: 'social_star', title: 'Social Star', desc: 'Send 20 chat messages'),
      (
        key: 'fast_learner',
        title: 'Fast Learner',
        desc: 'Complete 3 games in one session',
      ),
      (
        key: 'reward_creator',
        title: 'Reward Creator',
        desc: 'Create 5 rewards',
      ),
    ];

    for (var achievement in defaultAchievements) {
      await db
          .into(db.achievements)
          .insert(
            AchievementsCompanion.insert(
              key: achievement.key,
              title: achievement.title,
              description: achievement.desc,
            ),
          );
    }
  }

  // ==================== GAME SESSIONS ====================

  /// Save a game session record
  Future<int> saveGameSession(GameSessionData session) async {
    return await db
        .into(db.gameSessions)
        .insert(
          GameSessionsCompanion.insert(
            gameType: session.gameType,
            levelId: session.levelId != null
                ? Value(session.levelId!)
                : const Value.absent(),
            difficulty: session.difficulty != null
                ? Value(session.difficulty!)
                : const Value.absent(),
            correctActions: Value(session.correctActions),
            totalActions: Value(session.totalActions),
            accuracyPercent: Value(session.accuracyPercent),
            starsEarned: session.starsEarned != null
                ? Value(session.starsEarned!)
                : const Value.absent(),
            durationSeconds: Value(session.durationSeconds),
            sessionStartedAt: session.sessionStartedAt,
            sessionEndedAt: session.sessionEndedAt,
            createdAt: DateTime.now(),
            isSynced: const Value(false),
          ),
        );
  }

  /// Get game sessions with optional date filter
  Future<List<GameSessionData>> getGameSessions({int? daysBack}) async {
    var query = db.select(db.gameSessions);

    if (daysBack != null) {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysBack));
      query = query
        ..where((s) => s.sessionStartedAt.isBiggerOrEqualValue(cutoffDate));
    }

    final results = await query.get();
    return results
        .map(
          (row) => GameSessionData(
            id: row.id,
            gameType: row.gameType,
            levelId: row.levelId,
            difficulty: row.difficulty,
            correctActions: row.correctActions,
            totalActions: row.totalActions,
            accuracyPercent: row.accuracyPercent,
            starsEarned: row.starsEarned,
            durationSeconds: row.durationSeconds,
            sessionStartedAt: row.sessionStartedAt,
            sessionEndedAt: row.sessionEndedAt,
            createdAt: row.createdAt,
            isSynced: row.isSynced,
          ),
        )
        .toList();
  }

  /// Get total play time in seconds with optional date filter
  Future<int> getTotalPlayTimeSeconds({int? daysBack}) async {
    var query = db.select(db.gameSessions);

    if (daysBack != null) {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysBack));
      query = query
        ..where((s) => s.sessionStartedAt.isBiggerOrEqualValue(cutoffDate));
    }

    final sessions = await query.get();
    return sessions.fold<int>(0, (sum, s) => sum + s.durationSeconds);
  }

  /// Get play time breakdown by game type
  Future<Map<String, int>> getPlayTimeByGameType({int? daysBack}) async {
    var query = db.select(db.gameSessions);

    if (daysBack != null) {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysBack));
      query = query
        ..where((s) => s.sessionStartedAt.isBiggerOrEqualValue(cutoffDate));
    }

    final sessions = await query.get();
    final Map<String, int> result = {};

    for (final session in sessions) {
      result[session.gameType] =
          (result[session.gameType] ?? 0) + session.durationSeconds;
    }

    return result;
  }

  /// Get average accuracy per game type
  Future<Map<String, double>> getSkillAverages({int daysBack = 30}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysBack));
    final sessions = await (db.select(
      db.gameSessions,
    )..where((s) => s.sessionStartedAt.isBiggerOrEqualValue(cutoffDate))).get();

    final Map<String, List<int>> accuracyByType = {};

    for (final session in sessions) {
      accuracyByType
          .putIfAbsent(session.gameType, () => [])
          .add(session.accuracyPercent);
    }

    return accuracyByType.map((type, accuracies) {
      final avg = accuracies.reduce((a, b) => a + b) / accuracies.length;
      return MapEntry(type, avg / 100.0); // Convert to 0.0-1.0 range
    });
  }

  /// Get skill trends over time (daily averages for the past N days)
  Future<Map<String, List<double>>> getSkillTrends({int daysBack = 7}) async {
    final results = <String, List<double>>{};
    final now = DateTime.now();

    for (int i = 0; i < daysBack; i++) {
      final date = now.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final sessions =
          await (db.select(db.gameSessions)
                ..where(
                  (s) => s.sessionStartedAt.isBiggerOrEqualValue(dayStart),
                )
                ..where((s) => s.sessionStartedAt.isSmallerThanValue(dayEnd)))
              .get();

      // Group by game type and calculate daily average
      final Map<String, List<int>> dailyAccuracies = {};
      for (final session in sessions) {
        dailyAccuracies
            .putIfAbsent(session.gameType, () => [])
            .add(session.accuracyPercent);
        if (session.gameType == 'emotion_classify' ||
            session.gameType == 'emotion_mimic') {
          dailyAccuracies
              .putIfAbsent('emotion', () => [])
              .add(session.accuracyPercent);
        }
      }

      dailyAccuracies.forEach((type, accuracies) {
        final avg =
            accuracies.reduce((a, b) => a + b) / accuracies.length / 100.0;
        results.putIfAbsent(type, () => []).add(avg);
      });
    }

    // Reverse lists so oldest data appears first in dashboard charts.
    results.updateAll((key, value) => value.reversed.toList());

    return results;
  }
}

// Data models are exported from progress_model.dart
