import 'dart:math';
import 'package:flutter/material.dart';

import 'minipuzzle_models.dart';

/// Controller for MiniPuzzle game state management
class MiniPuzzleController extends ChangeNotifier {
  // Current game configuration
  MiniPuzzleType? _currentGameType;
  MiniPuzzleDifficulty? _currentDifficulty;
  MiniPuzzleConfig? _config;

  // Session tracking
  int _currentRound = 0;
  final List<MiniPuzzleRoundResult> _roundResults = [];
  DateTime? _sessionStartTime;
  DateTime? _roundStartTime;

  // Current round state
  int _attemptsInRound = 0;
  bool _roundComplete = false;
  bool _showingFeedback = false;
  bool _isCorrect = false;
  String _feedbackKey = '';

  // Game data (updated each round)
  PatternData? _patternData;
  SortingData? _sortingData;
  PuzzleData? _puzzleData;

  // Random generator
  final Random _random = Random();

  // Getters
  MiniPuzzleType? get currentGameType => _currentGameType;
  MiniPuzzleDifficulty? get currentDifficulty => _currentDifficulty;
  MiniPuzzleConfig? get config => _config;
  int get currentRound => _currentRound;
  int get totalRounds => 3;
  bool get isSessionComplete => _currentRound >= totalRounds;
  bool get showingFeedback => _showingFeedback;
  bool get isCorrect => _isCorrect;
  String get feedbackKey => _feedbackKey;
  int get attemptsInRound => _attemptsInRound;
  bool get roundComplete => _roundComplete;

  // Game data getters
  PatternData? get patternData => _patternData;
  SortingData? get sortingData => _sortingData;
  PuzzleData? get puzzleData => _puzzleData;

  // Session results
  int get totalCorrect => _roundResults.where((r) => r.isCorrect).length;
  int get totalAttempts => _roundResults.fold(0, (sum, r) => sum + r.attempts);
  int get stars {
    final correct = totalCorrect;
    if (correct >= 3) return 3;
    if (correct >= 2) return 2;
    return 1;
  }

  int get pointsEarned => totalCorrect * 3;

  List<MiniPuzzleRoundResult> get roundResults =>
      List.unmodifiable(_roundResults);

  /// Start a new game session
  void startGame(MiniPuzzleType type, MiniPuzzleDifficulty difficulty) {
    _currentGameType = type;
    _currentDifficulty = difficulty;
    _config = MiniPuzzleConfig(difficulty);
    _currentRound = 0;
    _roundResults.clear();
    _sessionStartTime = DateTime.now();

    _startNewRound();
    notifyListeners();
  }

  /// Start a new round
  void _startNewRound() {
    _currentRound++;
    _attemptsInRound = 0;
    _roundComplete = false;
    _showingFeedback = false;
    _roundStartTime = DateTime.now();

    // Generate game data based on type
    switch (_currentGameType!) {
      case MiniPuzzleType.pattern:
        _patternData = _generatePatternData();
        break;
      case MiniPuzzleType.sorting:
        _sortingData = _generateSortingData();
        break;
      case MiniPuzzleType.puzzle:
        _puzzleData = _generatePuzzleData();
        break;
    }

    notifyListeners();
  }

  /// Generate pattern recognition data
  PatternData _generatePatternData() {
    final pool = [
      PatternToken(
        id: 'circle',
        icon: Icons.circle_rounded,
        color: const Color(0xFF9EC8F2),
      ),
      PatternToken(
        id: 'square',
        icon: Icons.square_rounded,
        color: const Color(0xFFF6B9D7),
      ),
      PatternToken(
        id: 'triangle',
        icon: Icons.change_history_rounded,
        color: const Color(0xFFB8E8C4),
      ),
      PatternToken(
        id: 'star',
        icon: Icons.star_rounded,
        color: const Color(0xFFFFF2A8),
      ),
    ];

    final sequenceLength = _config!.patternSequenceLength;
    final sequence = List.generate(
      sequenceLength,
      (i) => pool[i % pool.length],
    );

    // The next item in pattern
    final correctAnswer = pool[sequenceLength % pool.length];

    // Generate choices including correct answer
    final choices = [correctAnswer];
    final wrongChoices = pool.where((p) => p.id != correctAnswer.id).toList()
      ..shuffle();
    choices.addAll(wrongChoices.take(_config!.choiceCount - 1));
    choices.shuffle();

    return PatternData(
      sequence: sequence,
      choices: choices,
      correctAnswer: correctAnswer,
    );
  }

  /// Generate sorting game data
  SortingData _generateSortingData() {
    final items = [
      SortingItem(
        id: 'dog',
        label: 'Dog',
        icon: Icons.pets_rounded,
        color: const Color(0xFF9EC8F2),
      ),
      SortingItem(
        id: 'cat',
        label: 'Cat',
        icon: Icons.cruelty_free_rounded,
        color: const Color(0xFFF6B9D7),
      ),
      SortingItem(
        id: 'fish',
        label: 'Fish',
        icon: Icons.set_meal_rounded,
        color: const Color(0xFFB8E8C4),
      ),
      SortingItem(
        id: 'apple',
        label: 'Apple',
        icon: Icons.apple_rounded,
        color: const Color(0xFFFFD699),
      ),
      SortingItem(
        id: 'bread',
        label: 'Bread',
        icon: Icons.breakfast_dining_rounded,
        color: const Color(0xFFFFF2A8),
      ),
      SortingItem(
        id: 'carrot',
        label: 'Carrot',
        icon: Icons.eco_rounded,
        color: const Color(0xFFFFB366),
      ),
    ];

    // Pick random item
    final item = items[_random.nextInt(items.length)];
    final isAnimal = ['dog', 'cat', 'fish'].contains(item.id);
    final correctCategory = isAnimal ? 'animal' : 'food';

    return SortingData(
      itemToSort: item,
      categories: ['animal', 'food'],
      correctCategory: correctCategory,
    );
  }

  /// Generate puzzle game data
  PuzzleData _generatePuzzleData() {
    final pieceCount = _config!.itemCount;

    final icons = [
      Icons.circle_rounded,
      Icons.square_rounded,
      Icons.change_history_rounded,
      Icons.star_rounded,
    ];

    final colors = [
      const Color(0xFF9EC8F2),
      const Color(0xFFF6B9D7),
      const Color(0xFFB8E8C4),
      const Color(0xFFFFF2A8),
    ];

    final pieces = List.generate(pieceCount, (i) {
      return PuzzlePiece(
        id: 'piece_$i',
        icon: icons[i % icons.length],
        color: colors[i % colors.length],
        targetSlotId: 'slot_$i',
      );
    })..shuffle();

    final slots = List.generate(pieceCount, (i) {
      return PuzzleSlot(id: 'slot_$i', hintColor: colors[i % colors.length]);
    });

    return PuzzleData(pieces: pieces, slots: slots);
  }

  /// Submit an answer for pattern game
  void submitPatternAnswer(PatternToken selected) {
    if (_roundComplete || _patternData == null) return;

    _attemptsInRound++;
    _isCorrect = selected.id == _patternData!.correctAnswer.id;
    _showingFeedback = true;

    if (_isCorrect) {
      _completeRound();
    } else {
      _feedbackKey = 'feedback_try_again';
      notifyListeners();
    }
  }

  /// Submit an answer for sorting game
  void submitSortingAnswer(String category) {
    if (_roundComplete || _sortingData == null) return;

    _attemptsInRound++;
    _isCorrect = category == _sortingData!.correctCategory;
    _showingFeedback = true;

    if (_isCorrect) {
      _completeRound();
    } else {
      _feedbackKey = 'feedback_try_again';
      notifyListeners();
    }
  }

  /// Place a puzzle piece
  void placePuzzlePiece(String pieceId, String slotId) {
    if (_roundComplete || _puzzleData == null) return;

    final pieceIndex = _puzzleData!.pieces.indexWhere((p) => p.id == pieceId);
    if (pieceIndex == -1) return;

    final piece = _puzzleData!.pieces[pieceIndex];

    // Update piece position
    final updatedPieces = List<PuzzlePiece>.from(_puzzleData!.pieces);
    updatedPieces[pieceIndex] = piece.copyWith(currentSlotId: slotId);
    _puzzleData = PuzzleData(pieces: updatedPieces, slots: _puzzleData!.slots);

    _attemptsInRound++;

    // Check if all pieces are placed
    final allPlaced = updatedPieces.every((p) => p.currentSlotId != null);
    final allCorrect = updatedPieces.every((p) => p.isPlacedCorrectly);

    if (allPlaced) {
      _isCorrect = allCorrect;
      _showingFeedback = true;
      _completeRound();
    } else {
      notifyListeners();
    }
  }

  /// Complete the current round
  void _completeRound() {
    _roundComplete = true;
    _isCorrect = true;
    _feedbackKey = _getRandomPositiveFeedback();

    final roundResult = MiniPuzzleRoundResult(
      roundNumber: _currentRound,
      isCorrect: true,
      attempts: _attemptsInRound,
      timeTaken: DateTime.now().difference(_roundStartTime!),
    );
    _roundResults.add(roundResult);

    notifyListeners();
  }

  /// Get random positive feedback key
  String _getRandomPositiveFeedback() {
    final keys = [
      'feedback_great_job',
      'feedback_well_done',
      'feedback_you_did_it',
      'feedback_amazing',
      'feedback_perfect',
      'feedback_fantastic',
    ];
    return keys[_random.nextInt(keys.length)];
  }

  /// Move to next round
  void nextRound() {
    if (_currentRound < totalRounds) {
      _attemptsInRound = 0;
      _roundComplete = false;
      _showingFeedback = false;
      _startNewRound();
      notifyListeners();
    }
  }

  /// Reset the current game
  void resetGame() {
    if (_currentGameType != null && _currentDifficulty != null) {
      startGame(_currentGameType!, _currentDifficulty!);
    }
  }

  /// Get session data for results screen
  MiniPuzzleSessionData getSessionData() {
    return MiniPuzzleSessionData(
      gameType: _currentGameType!,
      difficulty: _currentDifficulty!,
      rounds: _roundResults,
      startTime: _sessionStartTime!,
      endTime: DateTime.now(),
    );
  }

  /// Clear feedback (for animations)
  void clearFeedback() {
    _showingFeedback = false;
    notifyListeners();
  }
}
