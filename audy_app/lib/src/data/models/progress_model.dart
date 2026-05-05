/// Comprehensive data model for user progress
class ProgressData {
  final int learningPoints;
  final int gamesPlayed;
  final int dayStreak;
  final DateTime? lastPlayedAt;

  // Game-specific counters for achievement tracking
  final int puzzleGamesCompleted;
  final int readingExercisesCompleted;
  final int sortingGamesCompleted;
  final int emotionsRecognized;
  final int chatMessagesSent;

  // Sorting game level unlock progress (0 = first level only)
  final int sortGameUnlockedLevel;

  // Meltdown protection - games played in current session
  final int gamesInCurrentSession;

  const ProgressData({
    required this.learningPoints,
    required this.gamesPlayed,
    required this.dayStreak,
    this.lastPlayedAt,
    this.puzzleGamesCompleted = 0,
    this.readingExercisesCompleted = 0,
    this.sortingGamesCompleted = 0,
    this.emotionsRecognized = 0,
    this.chatMessagesSent = 0,
    this.sortGameUnlockedLevel = 0,
    this.gamesInCurrentSession = 0,
  });
}

/// User reward data
class RewardData {
  final int id;
  final String prize;
  final String conditionType;
  final int targetCount;
  final int currentProgress;
  final bool isCompleted;
  final bool isClaimed;
  final DateTime createdAt;

  const RewardData({
    required this.id,
    required this.prize,
    required this.conditionType,
    required this.targetCount,
    required this.currentProgress,
    required this.isCompleted,
    required this.isClaimed,
    required this.createdAt,
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

/// User preferences data for autism-related personalization
/// Stores settings to customize the app experience
class UserPreferences {
  final int
  communicationLevel; // 0=non-verbal, 1=single words, 2=short phrases, 3=full sentences
  final int sensorySensitivity; // 0=low, 1=medium, 2=high
  final int learningPace; // 0=slower, 1=standard, 2=faster
  final String favoriteInterests; // comma-separated list

  const UserPreferences({
    this.communicationLevel = 3,
    this.sensorySensitivity = 1,
    this.learningPace = 1,
    this.favoriteInterests = '',
  });

  /// Get favorite interests as a list
  List<String> get interestsList {
    if (favoriteInterests.isEmpty) return [];
    return favoriteInterests.split(',').where((s) => s.isNotEmpty).toList();
  }

  /// Create copy with updated values
  UserPreferences copyWith({
    int? communicationLevel,
    int? sensorySensitivity,
    int? learningPace,
    String? favoriteInterests,
  }) {
    return UserPreferences(
      communicationLevel: communicationLevel ?? this.communicationLevel,
      sensorySensitivity: sensorySensitivity ?? this.sensorySensitivity,
      learningPace: learningPace ?? this.learningPace,
      favoriteInterests: favoriteInterests ?? this.favoriteInterests,
    );
  }
}
