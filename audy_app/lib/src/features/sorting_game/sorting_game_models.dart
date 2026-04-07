import 'package:flutter/material.dart';

/// Represents a single item that the player must sort into a category.
/// Used across all sorting game variants (animals, shapes, food, emotions, etc.)
class SortItem {
  const SortItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.categoryId,
    this.color,
  });

  final String id;
  final String label;
  final IconData icon;
  final String categoryId;
  final Color? color;
}

/// A category (basket/bin) that items are sorted into.
/// Each level defines 2-5 categories depending on difficulty.
class SortCategory {
  const SortCategory({
    required this.id,
    required this.label,
    required this.icon,
    this.color,
  });

  final String id;
  final String label;
  final IconData icon;
  final Color? color;
}

/// A single round within a level.
/// Each round presents a set of items to sort into categories.
class SortRound {
  const SortRound({
    required this.items,
    required this.categories,
    this.hintEnabled = true,
    this.distractorCount = 0,
  });

  final List<SortItem> items;
  final List<SortCategory> categories;
  final bool hintEnabled;
  final int distractorCount;
}

/// Difficulty level for the sorting game.
/// Higher levels have more items, more categories, fewer hints, and distractors.
enum SortDifficulty {
  easy, // Level 1-2: 2 categories, 3-4 items, hints on
  medium, // Level 3-4: 3 categories, 5-7 items, hints partial
  hard, // Level 5-6: 4 categories, 8-10 items, hints off, distractors
}

/// A complete level definition with multiple rounds.
/// Levels progressively increase in difficulty following ABA principles:
/// - Repetition with variation across rounds
/// - Gradual difficulty progression
/// - Clear feedback at each step
class SortGameLevel {
  const SortGameLevel({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.theme,
    required this.rounds,
    required this.starsRequired,
    this.isLocked = false,
  });

  final String id;
  final String name;
  final SortDifficulty difficulty;
  final SortTheme theme;
  final List<SortRound> rounds;

  /// Number of stars needed to unlock the next level.
  final int starsRequired;
  final bool isLocked;

  int get totalRounds => rounds.length;
}

/// Visual theme for a level (animals, shapes, food, etc.)
class SortTheme {
  const SortTheme({
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.icon,
    required this.instructionText,
  });

  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData icon;

  /// Short instruction shown at the start of each round.
  final String instructionText;
}

/// Tracks a single action attempt during the game.
/// Structured for future analytics / AI adaptivity.
class SortActionRecord {
  const SortActionRecord({
    required this.itemId,
    required this.selectedCategoryId,
    required this.correctCategoryId,
    required this.isCorrect,
    required this.responseTimeMs,
    required this.roundIndex,
    this.hintUsed = false,
  });

  final String itemId;
  final String selectedCategoryId;
  final String correctCategoryId;
  final bool isCorrect;
  final int responseTimeMs;
  final int roundIndex;
  final bool hintUsed;
}

/// Complete session data for a single game playthrough.
/// Structured for future analysis, AI adaptivity, and backend integration.
class SortGameSessionData {
  const SortGameSessionData({
    this.userId,
    required this.levelId,
    required this.levelName,
    required this.difficulty,
    required this.themeName,
    required this.roundResults,
    required this.totalActions,
    required this.correctActions,
    required this.incorrectActions,
    required this.totalStars,
    required this.completionStatus,
    required this.sessionStartedAt,
    required this.sessionEndedAt,
    required this.averageResponseTimeMs,
    this.hintsUsed = 0,
  });

  /// Placeholder for user identification (future backend integration).
  final String? userId;
  final String levelId;
  final String levelName;
  final String difficulty;
  final String themeName;

  /// Per-round breakdown of actions.
  final List<SortRoundResult> roundResults;

  /// Aggregate stats.
  final int totalActions;
  final int correctActions;
  final int incorrectActions;
  final int totalStars;
  final int hintsUsed;

  /// One of: 'completed', 'abandoned', 'partial'.
  final String completionStatus;
  final DateTime sessionStartedAt;
  final DateTime sessionEndedAt;
  final int averageResponseTimeMs;

  /// Convert to a JSON-ready map for future backend / analytics use.
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'level_id': levelId,
      'level_name': levelName,
      'difficulty': difficulty,
      'theme': themeName,
      'total_actions': totalActions,
      'correct_actions': correctActions,
      'incorrect_actions': incorrectActions,
      'accuracy_percent': totalActions > 0
          ? ((correctActions / totalActions) * 100).round()
          : 0,
      'total_stars': totalStars,
      'hints_used': hintsUsed,
      'completion_status': completionStatus,
      'session_started_at': sessionStartedAt.toIso8601String(),
      'session_ended_at': sessionEndedAt.toIso8601String(),
      'average_response_time_ms': averageResponseTimeMs,
      'round_results': roundResults.map((r) => r.toJson()).toList(),
    };
  }
}

/// Per-round result summary.
class SortRoundResult {
  const SortRoundResult({
    required this.roundIndex,
    required this.actions,
    required this.correctCount,
    required this.incorrectCount,
    required this.roundTimeMs,
    required this.starsEarned,
  });

  final int roundIndex;
  final List<SortActionRecord> actions;
  final int correctCount;
  final int incorrectCount;
  final int roundTimeMs;
  final int starsEarned;

  Map<String, dynamic> toJson() {
    return {
      'round': roundIndex,
      'correct': correctCount,
      'incorrect': incorrectCount,
      'time_ms': roundTimeMs,
      'stars': starsEarned,
      'actions': actions
          .map(
            (a) => {
              'item_id': a.itemId,
              'selected_category': a.selectedCategoryId,
              'correct_category': a.correctCategoryId,
              'is_correct': a.isCorrect,
              'response_time_ms': a.responseTimeMs,
              'hint_used': a.hintUsed,
            },
          )
          .toList(),
    };
  }
}
