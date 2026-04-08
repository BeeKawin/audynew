/// Comprehensive data model for user progress
class ProgressData {
  final int learningPoints;
  final int gamesPlayed;
  final int dayStreak;
  final DateTime? lastPlayedAt;

  const ProgressData({
    required this.learningPoints,
    required this.gamesPlayed,
    required this.dayStreak,
    this.lastPlayedAt,
  });
}

/// Accessory data with ownership and placement info
class AccessoryData {
  final int id;
  final String name;
  final String iconName;
  final int cost;
  final bool owned;
  final int? x;
  final int? y;

  const AccessoryData({
    required this.id,
    required this.name,
    required this.iconName,
    required this.cost,
    required this.owned,
    this.x,
    this.y,
  });
}

/// Achievement data with unlock status
class AchievementData {
  final int id;
  final String key;
  final String title;
  final String description;
  final bool unlocked;
  final DateTime? unlockedAt;

  const AchievementData({
    required this.id,
    required this.key,
    required this.title,
    required this.description,
    required this.unlocked,
    this.unlockedAt,
  });
}
