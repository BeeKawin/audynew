import '../datasources/local_data_source.dart';
import '../models/progress_model.dart';

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

  // ==================== ACCESSORIES ====================

  Future<List<AccessoryData>> getAllAccessories() => local.getAllAccessories();

  Future<List<AccessoryData>> getOwnedAccessories() =>
      local.getOwnedAccessories();

  Future<void> purchaseAccessory(int accessoryId) =>
      local.purchaseAccessory(accessoryId);

  Future<void> placeAccessory(int accessoryId, int x, int y) =>
      local.placeAccessory(accessoryId, x, y);

  Future<void> resetAccessoryPlacements() => local.resetAccessoryPlacements();

  // ==================== ACHIEVEMENTS ====================

  Future<List<AchievementData>> getAllAchievements() =>
      local.getAllAchievements();

  Future<void> unlockAchievement(int achievementId) =>
      local.unlockAchievement(achievementId);

  // ==================== SEED ====================

  Future<void> seedInitialData() => local.seedInitialData();
}
