import 'package:drift/drift.dart';

import '../database/database.dart';
import '../models/progress_model.dart';

export '../models/progress_model.dart';

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
      gamesPlayed: row.gamesPlayed,
      dayStreak: row.dayStreak,
      lastPlayedAt: row.lastPlayedAt,
    );
  }

  Future<void> saveProgress(ProgressData progress) async {
    await db
        .into(db.userProgress)
        .insertOnConflictUpdate(
          UserProgressCompanion.insert(
            learningPoints: Value(progress.learningPoints),
            gamesPlayed: Value(progress.gamesPlayed),
            dayStreak: Value(progress.dayStreak),
            lastPlayedAt: progress.lastPlayedAt != null
                ? Value(progress.lastPlayedAt!)
                : const Value.absent(),
            updatedAt: DateTime.now(),
            isSynced: const Value(false),
          ),
        );
  }

  Future<void> resetProgress() async {
    await db
        .into(db.userProgress)
        .insertOnConflictUpdate(
          UserProgressCompanion.insert(
            learningPoints: const Value(0),
            gamesPlayed: const Value(0),
            dayStreak: const Value(1),
            lastPlayedAt: Value(DateTime.now()),
            updatedAt: DateTime.now(),
            isSynced: const Value(false),
          ),
        );
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

  Future<int> addReward(String prize, String conditionType, int targetCount) async {
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
              gamesPlayed: const Value(0),
              dayStreak: const Value(1),
              lastPlayedAt: const Value.absent(),
              updatedAt: DateTime.now(),
              isSynced: const Value(false),
            ),
          );
    }
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
        key: 'color_master',
        title: 'Color Master',
        desc: 'Perfect color sorting',
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
      (key: 'color_pro', title: 'Color Pro', desc: 'Sort 50 colors correctly'),
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
}

// Data models are exported from progress_model.dart
