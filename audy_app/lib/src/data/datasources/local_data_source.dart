import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import '../database/database.dart';
import '../models/progress_model.dart';

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

  // ==================== ACCESSORIES ====================

  Future<List<AccessoryData>> getAllAccessories() async {
    final accessories = await db.select(db.accessories).get();
    final userAccessories = await db.select(db.userAccessories).get();

    final userMap = {for (var ua in userAccessories) ua.accessoryId: ua};

    return accessories.map((a) {
      final userA = userMap[a.id];
      return AccessoryData(
        id: a.id,
        name: a.name,
        iconName: a.iconName,
        cost: a.cost,
        owned: userA?.owned ?? false,
        x: userA?.x,
        y: userA?.y,
      );
    }).toList();
  }

  Future<List<AccessoryData>> getOwnedAccessories() async {
    final all = await getAllAccessories();
    return all.where((a) => a.owned).toList();
  }

  Future<void> purchaseAccessory(int accessoryId) async {
    await db
        .into(db.userAccessories)
        .insertOnConflictUpdate(
          UserAccessoriesCompanion.insert(
            accessoryId: accessoryId,
            owned: const Value(true),
            x: const Value.absent(),
            y: const Value.absent(),
            updatedAt: DateTime.now(),
            isSynced: const Value(false),
          ),
        );
  }

  Future<void> placeAccessory(int accessoryId, int x, int y) async {
    final existing = await db.select(db.userAccessories).get();
    final userAccessory = existing.firstWhere(
      (ua) => ua.accessoryId == accessoryId,
      orElse: () => throw Exception('Accessory not found'),
    );

    await db
        .update(db.userAccessories)
        .replace(
          UserAccessoriesCompanion(
            id: Value(userAccessory.id),
            accessoryId: Value(accessoryId),
            owned: Value(userAccessory.owned),
            x: Value(x),
            y: Value(y),
            updatedAt: Value(DateTime.now()),
            isSynced: const Value(false),
          ),
        );
  }

  Future<void> resetAccessoryPlacements() async {
    final userAccessories = await db.select(db.userAccessories).get();
    for (var ua in userAccessories) {
      await db
          .update(db.userAccessories)
          .replace(
            UserAccessoriesCompanion(
              id: Value(ua.id),
              accessoryId: Value(ua.accessoryId),
              owned: Value(ua.owned),
              x: const Value.absent(),
              y: const Value.absent(),
              updatedAt: Value(DateTime.now()),
              isSynced: const Value(false),
            ),
          );
    }
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
    // Seed accessories if empty
    final accessoryCount = await db.select(db.accessories).get();
    if (accessoryCount.isEmpty) {
      await _seedAccessories();
    }

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

    // Initialize user accessories (mark free ones as owned)
    final userAccessories = await db.select(db.userAccessories).get();
    if (userAccessories.isEmpty) {
      final accessories = await db.select(db.accessories).get();
      for (var accessory in accessories) {
        await db
            .into(db.userAccessories)
            .insert(
              UserAccessoriesCompanion.insert(
                accessoryId: accessory.id,
                owned: Value(
                  accessory.cost == 0,
                ), // Free items owned by default
                x: const Value.absent(),
                y: const Value.absent(),
                updatedAt: DateTime.now(),
                isSynced: const Value(false),
              ),
            );
      }
    }
  }

  Future<void> _seedAccessories() async {
    final defaultAccessories = [
      (name: 'Party Hat', icon: 'celebration_outlined', cost: 0),
      (name: 'Sunglasses', icon: 'wb_sunny_outlined', cost: 0),
      (name: 'Bow Tie', icon: 'style_outlined', cost: 40),
      (name: 'Crown', icon: 'workspace_premium_outlined', cost: 100),
      (name: 'Star Badge', icon: 'star_outline_rounded', cost: 60),
    ];

    for (var accessory in defaultAccessories) {
      await db
          .into(db.accessories)
          .insert(
            AccessoriesCompanion.insert(
              name: accessory.name,
              iconName: accessory.icon,
              cost: accessory.cost,
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

  // Icon name to IconData mapping helper
  static IconData getIconFromName(String name) {
    switch (name) {
      case 'celebration_outlined':
        return Icons.celebration_outlined;
      case 'wb_sunny_outlined':
        return Icons.wb_sunny_outlined;
      case 'style_outlined':
        return Icons.style_outlined;
      case 'workspace_premium_outlined':
        return Icons.workspace_premium_outlined;
      case 'star_outline_rounded':
        return Icons.star_outline_rounded;
      default:
        return Icons.star;
    }
  }
}
