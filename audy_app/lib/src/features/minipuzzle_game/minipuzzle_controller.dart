import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'minipuzzle_models.dart';

/// Controller for MiniPuzzle game state management.
class MiniPuzzleController extends ChangeNotifier {
  MiniPuzzleType? _currentGameType;
  MiniPuzzleDifficulty? _currentDifficulty;
  MiniPuzzleConfig? _config;

  int _currentRound = 0;
  final List<MiniPuzzleRoundResult> _roundResults = [];
  DateTime? _sessionStartTime;
  DateTime? _roundStartTime;

  int _attemptsInRound = 0;
  bool _roundComplete = false;
  bool _showingFeedback = false;
  bool _isCorrect = false;
  String _feedbackKey = '';

  PatternData? _patternData;
  OddOneOutData? _oddOneOutData;
  PuzzleData? _puzzleData;

  final Random _random = Random();
  Timer? _feedbackTimer;

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

  PatternData? get patternData => _patternData;
  OddOneOutData? get oddOneOutData => _oddOneOutData;
  PuzzleData? get puzzleData => _puzzleData;

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

  void startGame(MiniPuzzleType type, MiniPuzzleDifficulty difficulty) {
    _feedbackTimer?.cancel();
    _currentGameType = type;
    _currentDifficulty = difficulty;
    _config = MiniPuzzleConfig(difficulty);
    _currentRound = 0;
    _roundResults.clear();
    _sessionStartTime = DateTime.now();

    _startNewRound();
    notifyListeners();
  }

  void _startNewRound() {
    _feedbackTimer?.cancel();
    _currentRound++;
    _attemptsInRound = 0;
    _roundComplete = false;
    _showingFeedback = false;
    _isCorrect = false;
    _roundStartTime = DateTime.now();

    switch (_currentGameType!) {
      case MiniPuzzleType.pattern:
        _patternData = _generatePatternData();
        break;
      case MiniPuzzleType.oddOneOut:
        _oddOneOutData = _generateOddOneOutData();
        break;
      case MiniPuzzleType.puzzle:
        _puzzleData = _generatePuzzleData();
        break;
    }

    notifyListeners();
  }

  PatternData _generatePatternData() {
    final pool = [
      PatternToken(
        id: 'circle',
        icon: Icons.circle_rounded,
        color: const Color(0xFF5BA8E5),
      ),
      PatternToken(
        id: 'square',
        icon: Icons.square_rounded,
        color: const Color(0xFFE784B7),
      ),
      PatternToken(
        id: 'triangle',
        icon: Icons.change_history_rounded,
        color: const Color(0xFF66C78F),
      ),
      PatternToken(
        id: 'star',
        icon: Icons.star_rounded,
        color: const Color(0xFFE0A72E),
      ),
    ]..shuffle(_random);

    late final List<PatternToken> sequence;
    late final PatternToken correctAnswer;

    switch (_currentDifficulty!) {
      case MiniPuzzleDifficulty.easy:
        sequence = [pool[0], pool[1], pool[0]];
        correctAnswer = pool[1];
        break;
      case MiniPuzzleDifficulty.medium:
        final useAab = _random.nextBool();
        sequence = useAab
            ? [pool[0], pool[0], pool[1], pool[0], pool[0]]
            : [pool[0], pool[1], pool[1], pool[0], pool[1]];
        correctAnswer = pool[1];
        break;
      case MiniPuzzleDifficulty.hard:
        sequence = [pool[0], pool[1], pool[2], pool[0], pool[1]];
        correctAnswer = pool[2];
        break;
    }

    final choices = [correctAnswer];
    final wrongChoices = pool.where((p) => p.id != correctAnswer.id).toList()
      ..shuffle(_random);
    choices.addAll(wrongChoices.take(_config!.choiceCount - 1));
    choices.shuffle(_random);

    return PatternData(
      sequence: sequence,
      choices: choices,
      correctAnswer: correctAnswer,
    );
  }

  OddOneOutData _generateOddOneOutData() {
    final count = _config!.oddOneOutChoiceCount;
    final icons = [
      Icons.circle_rounded,
      Icons.circle_rounded,
      Icons.circle_rounded,
      Icons.circle_rounded,
      Icons.star_rounded,
    ];
    final shapeIcons = [
      Icons.square_rounded,
      Icons.square_rounded,
      Icons.square_rounded,
      Icons.change_history_rounded,
      Icons.square_rounded,
    ];
    final colors = [
      const Color(0xFF5BA8E5),
      const Color(0xFFE784B7),
      const Color(0xFF66C78F),
      const Color(0xFFE0A72E),
      const Color(0xFF7B8EA8),
    ];

    final correctIndex = _random.nextInt(count);
    final items = List.generate(count, (i) {
      final isOdd = i == correctIndex;
      switch (_currentDifficulty!) {
        case MiniPuzzleDifficulty.easy:
          return OddOneOutItem(
            id: 'odd_$i',
            label: isOdd ? 'Different color' : 'Same color',
            icon: Icons.circle_rounded,
            color: isOdd ? colors[1] : colors[0],
          );
        case MiniPuzzleDifficulty.medium:
          return OddOneOutItem(
            id: 'odd_$i',
            label: isOdd ? 'Different shape' : 'Same shape',
            icon: isOdd ? Icons.star_rounded : Icons.square_rounded,
            color: colors[2],
          );
        case MiniPuzzleDifficulty.hard:
          return OddOneOutItem(
            id: 'odd_$i',
            label: isOdd ? 'Odd one' : 'Group item',
            icon: isOdd ? icons.last : shapeIcons[i % shapeIcons.length],
            color: isOdd ? colors[4] : colors[i % 3],
          );
      }
    })..shuffle(_random);

    return OddOneOutData(
      items: items,
      correctItemId: 'odd_$correctIndex',
    );
  }

  PuzzleData _generatePuzzleData() {
    final pieceCount = _config!.itemCount;
    final icons = [
      Icons.circle_rounded,
      Icons.square_rounded,
      Icons.change_history_rounded,
      Icons.star_rounded,
    ];
    final colors = [
      const Color(0xFF5BA8E5),
      const Color(0xFFE784B7),
      const Color(0xFF66C78F),
      const Color(0xFFE0A72E),
    ];

    final pieces = List.generate(pieceCount, (i) {
      return PuzzlePiece(
        id: 'piece_$i',
        icon: icons[i % icons.length],
        color: colors[i % colors.length],
        targetSlotId: 'slot_$i',
      );
    })..shuffle(_random);

    final slots = List.generate(pieceCount, (i) {
      return PuzzleSlot(
        id: 'slot_$i',
        hintIcon: icons[i % icons.length],
        hintColor: colors[i % colors.length],
      );
    });

    return PuzzleData(pieces: pieces, slots: slots);
  }

  void submitPatternAnswer(PatternToken selected) {
    if (_roundComplete || _patternData == null || _showingFeedback) return;

    _attemptsInRound++;
    if (selected.id == _patternData!.correctAnswer.id) {
      _completeCorrectRound();
    } else {
      _showRetryFeedback();
    }
  }

  void submitOddOneOutAnswer(String itemId) {
    if (_roundComplete || _oddOneOutData == null || _showingFeedback) return;

    _attemptsInRound++;
    if (itemId == _oddOneOutData!.correctItemId) {
      _completeCorrectRound();
    } else {
      _showRetryFeedback();
    }
  }

  void placePuzzlePiece(String pieceId, String slotId) {
    if (_roundComplete || _puzzleData == null || _showingFeedback) return;

    final pieceIndex = _puzzleData!.pieces.indexWhere((p) => p.id == pieceId);
    if (pieceIndex == -1) return;

    _attemptsInRound++;
    final piece = _puzzleData!.pieces[pieceIndex];
    if (piece.targetSlotId != slotId) {
      _showRetryFeedback();
      return;
    }

    final updatedPieces = List<PuzzlePiece>.from(_puzzleData!.pieces);
    updatedPieces[pieceIndex] = piece.copyWith(currentSlotId: slotId);
    _puzzleData = PuzzleData(pieces: updatedPieces, slots: _puzzleData!.slots);

    final allPlaced = updatedPieces.every((p) => p.currentSlotId != null);
    if (allPlaced) {
      _completeCorrectRound();
    } else {
      notifyListeners();
    }
  }

  void _completeCorrectRound() {
    _feedbackTimer?.cancel();
    _roundComplete = true;
    _showingFeedback = true;
    _isCorrect = true;
    _feedbackKey = _getRandomPositiveFeedback();

    _roundResults.add(
      MiniPuzzleRoundResult(
        roundNumber: _currentRound,
        isCorrect: true,
        attempts: _attemptsInRound,
        timeTaken: DateTime.now().difference(_roundStartTime!),
      ),
    );

    notifyListeners();
  }

  void _showRetryFeedback() {
    _feedbackTimer?.cancel();
    _roundComplete = false;
    _showingFeedback = true;
    _isCorrect = false;
    _feedbackKey = 'feedback_try_again';
    notifyListeners();

    _feedbackTimer = Timer(const Duration(milliseconds: 900), () {
      if (_roundComplete) return;
      _showingFeedback = false;
      notifyListeners();
    });
  }

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

  void nextRound() {
    if (_currentRound < totalRounds) {
      _startNewRound();
    }
  }

  void resetGame() {
    if (_currentGameType != null && _currentDifficulty != null) {
      startGame(_currentGameType!, _currentDifficulty!);
    }
  }

  MiniPuzzleSessionData getSessionData() {
    return MiniPuzzleSessionData(
      gameType: _currentGameType!,
      difficulty: _currentDifficulty!,
      rounds: _roundResults,
      startTime: _sessionStartTime!,
      endTime: DateTime.now(),
    );
  }

  void clearFeedback() {
    _feedbackTimer?.cancel();
    _showingFeedback = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _feedbackTimer?.cancel();
    super.dispose();
  }
}
