import 'package:flutter/material.dart';

/// Types of mini-puzzle games available
enum MiniPuzzleType { pattern, sorting, puzzle }

/// Difficulty levels for each game
enum MiniPuzzleDifficulty { easy, medium, hard }

/// Represents a single round's result
class MiniPuzzleRoundResult {
  final int roundNumber;
  final bool isCorrect;
  final int attempts;
  final Duration timeTaken;

  const MiniPuzzleRoundResult({
    required this.roundNumber,
    required this.isCorrect,
    required this.attempts,
    required this.timeTaken,
  });
}

/// Complete session data after 3 rounds
class MiniPuzzleSessionData {
  final MiniPuzzleType gameType;
  final MiniPuzzleDifficulty difficulty;
  final List<MiniPuzzleRoundResult> rounds;
  final DateTime startTime;
  final DateTime endTime;

  const MiniPuzzleSessionData({
    required this.gameType,
    required this.difficulty,
    required this.rounds,
    required this.startTime,
    required this.endTime,
  });

  int get totalCorrect => rounds.where((r) => r.isCorrect).length;
  int get totalAttempts => rounds.fold(0, (sum, r) => sum + r.attempts);
  int get totalRounds => rounds.length;
  int get stars => _calculateStars();

  int _calculateStars() {
    final correct = totalCorrect;
    if (correct >= 3) return 3;
    if (correct >= 2) return 2;
    return 1;
  }

  /// Calculate points: 3 points per correct answer
  int get pointsEarned => totalCorrect * 3;

  Map<String, dynamic> toJson() => {
    'gameType': gameType.name,
    'difficulty': difficulty.name,
    'totalCorrect': totalCorrect,
    'totalAttempts': totalAttempts,
    'stars': stars,
    'points': pointsEarned,
  };
}

/// Pattern game data
class PatternData {
  final List<PatternToken> sequence;
  final List<PatternToken> choices;
  final PatternToken correctAnswer;

  const PatternData({
    required this.sequence,
    required this.choices,
    required this.correctAnswer,
  });
}

/// A single pattern token
class PatternToken {
  final IconData icon;
  final Color color;
  final String id;

  const PatternToken({
    required this.id,
    required this.icon,
    required this.color,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PatternToken && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Sorting game data
class SortingData {
  final SortingItem itemToSort;
  final List<String> categories;
  final String correctCategory;

  const SortingData({
    required this.itemToSort,
    required this.categories,
    required this.correctCategory,
  });
}

/// An item to be sorted
class SortingItem {
  final String id;
  final String label;
  final IconData icon;
  final Color color;

  const SortingItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });
}

/// Puzzle game data
class PuzzleData {
  final List<PuzzlePiece> pieces;
  final List<PuzzleSlot> slots;

  const PuzzleData({required this.pieces, required this.slots});
}

/// A puzzle piece
class PuzzlePiece {
  final String id;
  final IconData icon;
  final Color color;
  final String targetSlotId;
  String? currentSlotId;

  PuzzlePiece({
    required this.id,
    required this.icon,
    required this.color,
    required this.targetSlotId,
    this.currentSlotId,
  });

  bool get isPlacedCorrectly => currentSlotId == targetSlotId;

  PuzzlePiece copyWith({String? currentSlotId}) {
    return PuzzlePiece(
      id: id,
      icon: icon,
      color: color,
      targetSlotId: targetSlotId,
      currentSlotId: currentSlotId ?? this.currentSlotId,
    );
  }
}

/// A puzzle slot (drop target)
class PuzzleSlot {
  final String id;
  final IconData? hintIcon;
  final Color hintColor;

  const PuzzleSlot({required this.id, this.hintIcon, required this.hintColor});
}

/// Game configuration based on difficulty
class MiniPuzzleConfig {
  final MiniPuzzleDifficulty difficulty;

  const MiniPuzzleConfig(this.difficulty);

  /// Number of items based on difficulty
  int get itemCount {
    switch (difficulty) {
      case MiniPuzzleDifficulty.easy:
        return 2;
      case MiniPuzzleDifficulty.medium:
        return 3;
      case MiniPuzzleDifficulty.hard:
        return 4;
    }
  }

  /// Pattern sequence length
  int get patternSequenceLength {
    switch (difficulty) {
      case MiniPuzzleDifficulty.easy:
        return 2;
      case MiniPuzzleDifficulty.medium:
        return 3;
      case MiniPuzzleDifficulty.hard:
        return 4;
    }
  }

  /// Number of choices to show
  int get choiceCount {
    switch (difficulty) {
      case MiniPuzzleDifficulty.easy:
        return 2;
      case MiniPuzzleDifficulty.medium:
        return 3;
      case MiniPuzzleDifficulty.hard:
        return 4;
    }
  }
}

/// Game metadata for selection screen
class MiniPuzzleGameInfo {
  final MiniPuzzleType type;
  final String titleKey;
  final IconData icon;
  final Color color;
  final String descriptionKey;

  const MiniPuzzleGameInfo({
    required this.type,
    required this.titleKey,
    required this.icon,
    required this.color,
    required this.descriptionKey,
  });
}
