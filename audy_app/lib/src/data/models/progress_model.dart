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

/// Weekly report data for parent dashboard
class WeeklyReportData {
  final int gamesPlayed;
  final int pointsEarned;
  final int currentStreak;
  final int achievementsUnlocked;
  final DateTime weekStart;
  final DateTime weekEnd;
  final Map<String, double> skillProgress;
  final int totalPlayTimeMinutes;

  const WeeklyReportData({
    required this.gamesPlayed,
    required this.pointsEarned,
    required this.currentStreak,
    required this.achievementsUnlocked,
    required this.weekStart,
    required this.weekEnd,
    required this.skillProgress,
    required this.totalPlayTimeMinutes,
  });
}

/// Child profile data for institution panel
class ChildProfileData {
  final String id;
  final String name;
  final int age;
  final DateTime joinedDate;
  final int gamesPlayed;
  final int learningPoints;
  final int achievementsUnlocked;
  final int dayStreak;
  final Map<String, double> skillAverages;

  const ChildProfileData({
    required this.id,
    required this.name,
    required this.age,
    required this.joinedDate,
    required this.gamesPlayed,
    required this.learningPoints,
    required this.achievementsUnlocked,
    required this.dayStreak,
    required this.skillAverages,
  });
}

/// Group performance data for institution overview
class GroupPerformanceData {
  final int totalChildren;
  final double averageGamesPerChild;
  final double averagePointsPerChild;
  final double averageStreak;
  final Map<String, double> averageSkillProgress;
  final int totalAchievementsUnlocked;
  final DateTime reportGeneratedAt;

  const GroupPerformanceData({
    required this.totalChildren,
    required this.averageGamesPerChild,
    required this.averagePointsPerChild,
    required this.averageStreak,
    required this.averageSkillProgress,
    required this.totalAchievementsUnlocked,
    required this.reportGeneratedAt,
  });
}
