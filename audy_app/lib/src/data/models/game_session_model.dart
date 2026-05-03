/// Data model for a single game session
/// Used for recording gameplay analytics
class GameSessionData {
  final int? id;
  final String gameType;
  final String? levelId;
  final String? difficulty;
  final int correctActions;
  final int totalActions;
  final int accuracyPercent;
  final int? starsEarned;
  final int durationSeconds;
  final DateTime sessionStartedAt;
  final DateTime sessionEndedAt;
  final DateTime? createdAt;
  final bool isSynced;

  const GameSessionData({
    this.id,
    required this.gameType,
    this.levelId,
    this.difficulty,
    required this.correctActions,
    required this.totalActions,
    required this.accuracyPercent,
    this.starsEarned,
    required this.durationSeconds,
    required this.sessionStartedAt,
    required this.sessionEndedAt,
    this.createdAt,
    this.isSynced = false,
  });

  /// Calculate duration from start/end times if not provided directly
  factory GameSessionData.fromTimes({
    int? id,
    required String gameType,
    String? levelId,
    String? difficulty,
    int correctActions = 0,
    int totalActions = 0,
    int? starsEarned,
    required DateTime sessionStartedAt,
    required DateTime sessionEndedAt,
    DateTime? createdAt,
    bool isSynced = false,
  }) {
    final duration = sessionEndedAt.difference(sessionStartedAt);
    final accuracy = totalActions > 0
        ? ((correctActions / totalActions) * 100).round()
        : 0;

    return GameSessionData(
      id: id,
      gameType: gameType,
      levelId: levelId,
      difficulty: difficulty,
      correctActions: correctActions,
      totalActions: totalActions,
      accuracyPercent: accuracy,
      starsEarned: starsEarned,
      durationSeconds: duration.inSeconds,
      sessionStartedAt: sessionStartedAt,
      sessionEndedAt: sessionEndedAt,
      createdAt: createdAt,
      isSynced: isSynced,
    );
  }

  GameSessionData copyWith({
    int? id,
    String? gameType,
    String? levelId,
    String? difficulty,
    int? correctActions,
    int? totalActions,
    int? accuracyPercent,
    int? starsEarned,
    int? durationSeconds,
    DateTime? sessionStartedAt,
    DateTime? sessionEndedAt,
    DateTime? createdAt,
    bool? isSynced,
  }) {
    return GameSessionData(
      id: id ?? this.id,
      gameType: gameType ?? this.gameType,
      levelId: levelId ?? this.levelId,
      difficulty: difficulty ?? this.difficulty,
      correctActions: correctActions ?? this.correctActions,
      totalActions: totalActions ?? this.totalActions,
      accuracyPercent: accuracyPercent ?? this.accuracyPercent,
      starsEarned: starsEarned ?? this.starsEarned,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      sessionStartedAt: sessionStartedAt ?? this.sessionStartedAt,
      sessionEndedAt: sessionEndedAt ?? this.sessionEndedAt,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
