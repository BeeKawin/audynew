import '../datasources/local_data_source.dart';

/// Storage repository implementing offline-first architecture
/// Local database is source of truth
class StorageRepository {
  final LocalDataSource local;

  StorageRepository(this.local);

  // ==================== PROGRESS ====================

  Future<ProgressData?> getProgress() => local.getProgress();

  Future<void> saveProgress(ProgressData progress) =>
      local.saveProgress(progress);

  Future<void> resetProgress() => local.resetProgress();

  Future<void> addPoints(int value) async {
    final current = await local.getProgress();
    if (current != null) {
      await local.saveProgress(
        ProgressData(
          learningPoints: current.learningPoints + value,
          gamesPlayed: current.gamesPlayed,
          dayStreak: current.dayStreak,
          lastPlayedAt: current.lastPlayedAt,
        ),
      );
    }
  }

  // ==================== USER REWARDS ====================

  Future<List<RewardData>> getUserRewards() => local.getUserRewards();

  Future<List<RewardData>> getActiveRewards() => local.getActiveRewards();

  Future<int> addReward(String prize, String conditionType, int targetCount) =>
      local.addReward(prize, conditionType, targetCount);

  Future<void> updateRewardProgress(int rewardId, int progress) =>
      local.updateRewardProgress(rewardId, progress);

  Future<void> markRewardCompleted(int rewardId) =>
      local.markRewardCompleted(rewardId);

  Future<void> claimReward(int rewardId) => local.claimReward(rewardId);

  Future<void> deleteReward(int rewardId) => local.deleteReward(rewardId);

  // ==================== ACHIEVEMENTS ====================

  Future<List<AchievementData>> getAllAchievements() =>
      local.getAllAchievements();

  Future<void> unlockAchievement(int achievementId) =>
      local.unlockAchievement(achievementId);

  // ==================== SEED ====================

  Future<void> seedInitialData() => local.seedInitialData();
}
