import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../data/datasources/local_data_source.dart';
import '../data/models/progress_model.dart';
import '../data/repositories/storage_repository.dart';
import '../services/chat_service.dart';
import '../services/speech_service.dart';

enum SortShape { circle, square, triangle }

// Callbacks for UI notifications
typedef AchievementUnlockCallback = void Function(AchievementItem achievement);
typedef LevelUpCallback = void Function(int newLevel);

enum RequestMethod { get, post, put }

enum ReactionGameState { idle, waiting, ready, tooEarly, result }

enum ColorSortRound { colorOnly, colorAndShape, withDistractors }

class ColorPiece {
  const ColorPiece({
    required this.id,
    required this.colorName,
    required this.shape,
    required this.color,
  });

  final String id;
  final String colorName;
  final SortShape shape;
  final Color color;
}

class AccessoryItem {
  const AccessoryItem({
    required this.name,
    required this.icon,
    required this.cost,
    required this.owned,
  });

  final String name;
  final IconData icon;
  final int cost;
  final bool owned;

  AccessoryItem copyWith({bool? owned}) {
    return AccessoryItem(
      name: name,
      icon: icon,
      cost: cost,
      owned: owned ?? this.owned,
    );
  }
}

class ColorSortRoundData {
  const ColorSortRoundData({
    required this.round,
    required this.label,
    required this.instruction,
    required this.pieces,
    required this.baskets,
  });

  final ColorSortRound round;
  final String label;
  final String instruction;
  final List<ColorPiece> pieces;
  final List<String> baskets;
}

class PreparedRequest {
  const PreparedRequest({
    required this.feature,
    required this.endpoint,
    required this.method,
    required this.payload,
    required this.createdAt,
  });

  final String feature;
  final String endpoint;
  final RequestMethod method;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
}

class SocialMessage {
  const SocialMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.createdAt,
  });

  final String id;
  final String text;
  final bool isUser;
  final DateTime createdAt;
}

class EmotionQuestion {
  const EmotionQuestion({
    required this.prompt,
    required this.correctAnswer,
    required this.options,
    required this.icon,
  });

  final String prompt;
  final String correctAnswer;
  final List<String> options;
  final IconData icon;
}

class AchievementItem {
  const AchievementItem({
    required this.title,
    required this.description,
    required this.unlocked,
  });

  final String title;
  final String description;
  final bool unlocked;
}

class PlacedAccessory {
  final String name;
  final IconData icon;
  final int? x;
  final int? y;

  const PlacedAccessory({
    required this.name,
    required this.icon,
    this.x,
    this.y,
  });
}

class AudyController extends ChangeNotifier {
  final StorageRepository? storage;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Callbacks for UI notifications
  AchievementUnlockCallback? onAchievementUnlock;
  LevelUpCallback? onLevelUp;

  AudyController({this.storage}) {
    _seedState();
    _loadFromStorage();
    _initThaiChat();
  }

  // Placed accessories in the room
  final List<PlacedAccessory> _placedAccessories = [];
  List<PlacedAccessory> get placedAccessories =>
      List.unmodifiable(_placedAccessories);

  // Get only owned accessories
  List<AccessoryItem> get ownedAccessories =>
      accessories.where((a) => a.owned).toList();

  // Achievement tracking
  final Set<String> _unlockedAchievementKeys = {};

  // Level tracking
  int _currentLevel = 0;
  int get currentLevel => _currentLevel;

  final Random _random = Random();

  late final List<EmotionQuestion> _emotionQuestions;
  late List<ColorPiece> _colorPieces;

  final List<PreparedRequest> preparedRequests = [];

  int emotionQuestionIndex = 0;
  int emotionScore = 0;
  String emotionFeedback = 'Choose the matching emotion.';
  int emotionCurrentRound = 1;
  int emotionTotalRounds = 4;
  String emotionCurrentTarget = '';
  String emotionLastDetected = '';
  double emotionLastConfidence = 0.0;

  ColorSortRound colorCurrentRound = ColorSortRound.colorOnly;
  String? selectedColorPieceId;
  int colorMatches = 0;
  int colorMisses = 0;
  int colorTotalItems = 0;
  int _colorRoundMatches = 0;
  int _colorRoundMisses = 0;
  bool colorRoundComplete = false;
  final List<Map<String, dynamic>> colorRoundResults = [];
  final List<int> colorSortTimes = [];
  DateTime? _colorSortRoundStartedAt;
  Map<String, dynamic>? colorApiPayload;
  String _colorFeedback = 'Tap a piece, then tap the matching basket.';
  String get colorFeedback => _colorFeedback;

  final int reactionTotalRounds = 5;
  int reactionRound = 1;
  final List<int> reactionTimes = [];
  int reactionMisses = 0;
  ReactionGameState reactionState = ReactionGameState.idle;
  int currentReactionTimeMs = 0;
  String reactionFeedback = 'Tap the container when it turns green.';
  Map<String, dynamic>? reactionApiPayload;

  final List<SocialMessage> socialMessages = [];
  double socialConfidence = 0.20;
  String socialFeedback = 'Start a conversation with a short message.';

  // Thai Chat Services
  late final SpeechService speechService;
  late final ChatService chatService;

  // Thai voice messages
  final List<SocialMessage> thaiSocialMessages = [];

  int learningPoints = 0;
  int gamesPlayed = 0;
  int dayStreak = 1;
  int totalStars = 3;

  // Achievement tracking
  int puzzleGamesCompleted = 0;
  int readingExercisesCompleted = 0;
  int chatMessagesSent = 0;
  int sortingGamesCompleted = 0;
  int emotionsRecognized = 0;
  int colorsSortedCorrectly = 0;
  int gamesInCurrentSession = 0;
  DateTime? sessionStartTime;

  late List<AccessoryItem> accessories;

  Timer? _reactionRevealTimer;
  DateTime? _reactionRoundStartedAt;

  String get colorRoundLabel {
    switch (colorCurrentRound) {
      case ColorSortRound.colorOnly:
        return 'Round 1: Sort by color';
      case ColorSortRound.colorAndShape:
        return 'Round 2: Color & shape';
      case ColorSortRound.withDistractors:
        return 'Round 3: Watch for fakes!';
    }
  }

  bool get isColorSortComplete => colorRoundResults.length >= 3;

  int get colorTotalAccuracy {
    final totalCorrect = colorRoundResults.fold<int>(
      0,
      (sum, r) => sum + (r['correct'] as int),
    );
    final totalAttempts = colorRoundResults.fold<int>(
      0,
      (sum, r) => sum + (r['correct'] as int) + (r['misses'] as int),
    );
    if (totalAttempts == 0) return 0;
    return (totalCorrect / totalAttempts * 100).round();
  }

  int get colorAverageSortTimeMs {
    if (colorSortTimes.isEmpty) return 0;
    return colorSortTimes.reduce((a, b) => a + b) ~/ colorSortTimes.length;
  }

  int get colorTotalStars {
    int stars = 0;
    for (final result in colorRoundResults) {
      final accuracy =
          (result['correct'] as int) /
          ((result['correct'] as int) + (result['misses'] as int));
      if (accuracy >= 0.9) {
        stars += 3;
      } else if (accuracy >= 0.6) {
        stars += 2;
      } else {
        stars += 1;
      }
    }
    return stars;
  }

  String get reactionRoundLabel =>
      'Round: $reactionRound / $reactionTotalRounds';

  int get reactionAverageMs {
    if (reactionTimes.isEmpty) return 0;
    return reactionTimes.reduce((a, b) => a + b) ~/ reactionTimes.length;
  }

  bool get isReactionGameComplete =>
      reactionTimes.length >= reactionTotalRounds;

  EmotionQuestion get currentEmotionQuestion =>
      _emotionQuestions[emotionQuestionIndex];

  ColorPiece? get selectedColorPiece {
    if (selectedColorPieceId == null) return null;
    return _colorPieces.firstWhere(
      (piece) => piece.id == selectedColorPieceId,
      orElse: () => _colorPieces.first,
    );
  }

  List<ColorPiece> get colorPieces => List.unmodifiable(_colorPieces);

  int get unlockedAchievementCount =>
      achievements.where((achievement) => achievement.unlocked).length;

  List<AchievementItem> get achievements {
    return [
      AchievementItem(
        title: 'First Steps',
        description: 'Complete your first game',
        unlocked:
            emotionScore > 0 || colorMatches > 0 || reactionTimes.isNotEmpty,
      ),
      AchievementItem(
        title: 'Emotion Expert',
        description: 'Master 5 emotions',
        unlocked: emotionScore >= 5,
      ),
      AchievementItem(
        title: 'Quick Reflexes',
        description: 'Average under 300ms in Reaction Time',
        unlocked: reactionTimes.isNotEmpty && reactionAverageMs < 300,
      ),
      AchievementItem(
        title: 'Color Master',
        description: 'Perfect score in Color Sorting',
        unlocked: colorMatches >= 3 && colorMisses == 0,
      ),
      AchievementItem(
        title: 'Social Butterfly',
        description: 'Have 10 conversations',
        unlocked:
            socialMessages.where((message) => message.isUser).length >= 10,
      ),
      // NEW ACHIEVEMENTS
      AchievementItem(
        title: 'Puzzle Starter',
        description: 'Complete first mini-puzzle',
        unlocked: puzzleGamesCompleted >= 1,
      ),
      AchievementItem(
        title: 'Speed Star',
        description: 'Complete emotion game fast',
        unlocked: false, // Tracked via trackEmotionGameCompleted
      ),
      AchievementItem(
        title: 'Sorting Champion',
        description: 'Complete 10 sorting games',
        unlocked: sortingGamesCompleted >= 10,
      ),
      AchievementItem(
        title: 'Reading Buddy',
        description: 'Complete 5 reading exercises',
        unlocked: readingExercisesCompleted >= 5,
      ),
      AchievementItem(
        title: 'Emotion Explorer',
        description: 'Recognize all 5 emotions',
        unlocked: emotionsRecognized >= 5,
      ),
      AchievementItem(
        title: 'Streak Keeper',
        description: 'Play for 3 days in a row',
        unlocked: dayStreak >= 3,
      ),
      AchievementItem(
        title: 'Social Star',
        description: 'Send 20 chat messages',
        unlocked: chatMessagesSent >= 20,
      ),
      AchievementItem(
        title: 'Color Pro',
        description: 'Sort 50 colors correctly',
        unlocked: colorsSortedCorrectly >= 50,
      ),
      AchievementItem(
        title: 'Fast Learner',
        description: 'Complete 3 games in one session',
        unlocked: gamesInCurrentSession >= 3,
      ),
      AchievementItem(
        title: 'Master Collector',
        description: 'Own 10 accessories',
        unlocked: accessories.where((a) => a.owned).length >= 10,
      ),
    ];
  }

  Future<void> submitEmotionAnswer(String answer) async {
    final isCorrect = answer == currentEmotionQuestion.correctAnswer;
    emotionFeedback = isCorrect
        ? 'Great job! $answer is correct.'
        : 'Nice try. The correct answer is ${currentEmotionQuestion.correctAnswer}.';
    if (isCorrect) {
      emotionScore += 1;
      emotionCurrentTarget = currentEmotionQuestion.correctAnswer;
    }
    gamesPlayed += 1;
    // Add points and check achievements/level up
    await addPoints(isCorrect ? 5 : 0);
    _prepareRequest(
      feature: 'emotion_game',
      endpoint: '/api/games/emotion/answer',
      method: RequestMethod.post,
      payload: {
        'question': currentEmotionQuestion.prompt,
        'selectedAnswer': answer,
        'correctAnswer': currentEmotionQuestion.correctAnswer,
        'isCorrect': isCorrect,
        'score': emotionScore,
      },
    );
    emotionQuestionIndex =
        (emotionQuestionIndex + 1) % _emotionQuestions.length;
    notifyListeners();
  }

  void advanceEmotionRound() {
    if (emotionCurrentRound < emotionTotalRounds) {
      emotionCurrentRound += 1;
    }
    emotionQuestionIndex =
        (emotionQuestionIndex + 1) % _emotionQuestions.length;
    emotionLastDetected = '';
    emotionLastConfidence = 0.0;
    notifyListeners();
  }

  bool get isEmotionGameComplete => emotionCurrentRound >= emotionTotalRounds;

  void resetEmotionGame() {
    emotionCurrentRound = 1;
    emotionScore = 0;
    emotionQuestionIndex = 0;
    emotionFeedback = 'Choose the matching emotion.';
    emotionCurrentTarget = '';
    emotionLastDetected = '';
    emotionLastConfidence = 0.0;
    notifyListeners();
  }

  void setEmotionResult({
    required String detected,
    required double confidence,
  }) {
    emotionLastDetected = detected;
    emotionLastConfidence = confidence;
    notifyListeners();
  }

  void recordEmotionGamePlay() {
    gamesPlayed += 1;
    notifyListeners();
  }

  Future<void> handleColorDrop(ColorPiece piece, String basketColor) async {
    final isCorrect =
        piece.colorName.toLowerCase() == basketColor.toLowerCase();
    if (isCorrect) {
      colorMatches += 1;
      _colorRoundMatches += 1;
      _colorPieces.removeWhere((item) => item.id == piece.id);
      _colorFeedback = 'Correct!';
    } else {
      colorMisses += 1;
      _colorRoundMisses += 1;
      _colorFeedback = 'Try again.';
    }

    if (_colorPieces.isEmpty) {
      _finishColorSortRound();
    }

    // Add points and check achievements/level up
    if (isCorrect) {
      await addPoints(3);
    }

    notifyListeners();
  }

  void startColorSortRound() {
    _colorFeedback = 'Tap a piece, then tap the matching basket.';
    _colorRoundMatches = 0;
    _colorRoundMisses = 0;
    colorRoundComplete = false;
    _colorSortRoundStartedAt = DateTime.now();
    _setupColorRound();
    notifyListeners();
  }

  void advanceColorSortRound() {
    colorRoundComplete = false;
    _colorRoundMatches = 0;
    _colorRoundMisses = 0;
    _colorSortRoundStartedAt = DateTime.now();
    switch (colorCurrentRound) {
      case ColorSortRound.colorOnly:
        colorCurrentRound = ColorSortRound.colorAndShape;
        break;
      case ColorSortRound.colorAndShape:
        colorCurrentRound = ColorSortRound.withDistractors;
        break;
      case ColorSortRound.withDistractors:
        return;
    }
    _colorFeedback = 'Tap a piece, then tap the matching basket.';
    _setupColorRound();
    notifyListeners();
  }

  void resetColorSortGame() {
    colorCurrentRound = ColorSortRound.colorOnly;
    colorMatches = 0;
    colorMisses = 0;
    _colorRoundMatches = 0;
    _colorRoundMisses = 0;
    colorRoundComplete = false;
    colorRoundResults.clear();
    colorSortTimes.clear();
    colorApiPayload = null;
    selectedColorPieceId = null;
    _colorFeedback = 'Tap a piece, then tap the matching basket.';
    _colorSortRoundStartedAt = null;
    _setupColorRound();
    notifyListeners();
  }

  void _setupColorRound() {
    switch (colorCurrentRound) {
      case ColorSortRound.colorOnly:
        _colorPieces = const [
          ColorPiece(
            id: 'r1',
            colorName: 'Red',
            shape: SortShape.circle,
            color: Color(0xFFFF8D91),
          ),
          ColorPiece(
            id: 'b1',
            colorName: 'Blue',
            shape: SortShape.circle,
            color: Color(0xFF8FBCEC),
          ),
          ColorPiece(
            id: 'g1',
            colorName: 'Green',
            shape: SortShape.circle,
            color: Color(0xFF90F48A),
          ),
        ];
        break;
      case ColorSortRound.colorAndShape:
        _colorPieces = const [
          ColorPiece(
            id: 'r1',
            colorName: 'Red',
            shape: SortShape.circle,
            color: Color(0xFFFF8D91),
          ),
          ColorPiece(
            id: 'b1',
            colorName: 'Blue',
            shape: SortShape.square,
            color: Color(0xFF8FBCEC),
          ),
          ColorPiece(
            id: 'g1',
            colorName: 'Green',
            shape: SortShape.triangle,
            color: Color(0xFF90F48A),
          ),
          ColorPiece(
            id: 'y1',
            colorName: 'Yellow',
            shape: SortShape.circle,
            color: Color(0xFFFFF68C),
          ),
        ];
        break;
      case ColorSortRound.withDistractors:
        _colorPieces = const [
          ColorPiece(
            id: 'r1',
            colorName: 'Red',
            shape: SortShape.circle,
            color: Color(0xFFFF8D91),
          ),
          ColorPiece(
            id: 'b1',
            colorName: 'Blue',
            shape: SortShape.square,
            color: Color(0xFF8FBCEC),
          ),
          ColorPiece(
            id: 'g1',
            colorName: 'Green',
            shape: SortShape.triangle,
            color: Color(0xFF90F48A),
          ),
          ColorPiece(
            id: 'y1',
            colorName: 'Yellow',
            shape: SortShape.circle,
            color: Color(0xFFFFF68C),
          ),
          ColorPiece(
            id: 'p1',
            colorName: 'Purple',
            shape: SortShape.square,
            color: Color(0xFFDDD0F4),
          ),
        ];
        break;
    }
    selectedColorPieceId = _colorPieces.first.id;
    colorTotalItems = _colorPieces.length;
  }

  void _finishColorSortRound() {
    final elapsed = DateTime.now()
        .difference(_colorSortRoundStartedAt ?? DateTime.now())
        .inMilliseconds;
    colorSortTimes.add(elapsed);

    final roundData = {
      'round': colorCurrentRound.name,
      'correct': _colorRoundMatches,
      'misses': _colorRoundMisses,
      'timeMs': elapsed,
    };
    colorRoundResults.add(roundData);

    colorRoundComplete = true;

    _prepareRequest(
      feature: 'color_sorting',
      endpoint: '/api/games/color-sorting/round',
      method: RequestMethod.post,
      payload: roundData,
    );

    if (colorRoundResults.length >= 3) {
      colorApiPayload = {
        'game': 'color_sorting',
        'totalRounds': 3,
        'roundResults': List<Map<String, dynamic>>.from(colorRoundResults),
        'totalCorrect': colorMatches,
        'totalMisses': colorMisses,
        'accuracy': colorTotalAccuracy,
        'averageTimeMs': colorAverageSortTimeMs,
        'stars': colorTotalStars,
        'completedAt': DateTime.now().toIso8601String(),
      };
    }
  }

  void startReactionRound() {
    if (reactionState != ReactionGameState.idle) return;
    reactionState = ReactionGameState.waiting;
    reactionFeedback = 'Wait for green...';
    final delayMs = 1000 + _random.nextInt(2000);
    _reactionRoundStartedAt = DateTime.now();
    _reactionRevealTimer?.cancel();
    _reactionRevealTimer = Timer(Duration(milliseconds: delayMs), () {
      reactionState = ReactionGameState.ready;
      reactionFeedback = 'Tap now!';
      notifyListeners();
    });
    notifyListeners();
  }

  Future<void> handleReactionContainerTap() async {
    if (reactionState == ReactionGameState.ready) {
      final elapsed = DateTime.now()
          .difference(_reactionRoundStartedAt ?? DateTime.now())
          .inMilliseconds;
      currentReactionTimeMs = elapsed;
      reactionTimes.add(elapsed);
      reactionFeedback = '$elapsed ms';
      reactionState = ReactionGameState.result;
      // Add points and check achievements/level up
      await addPoints(4);
      _prepareRequest(
        feature: 'reaction_time',
        endpoint: '/api/games/reaction-time/round',
        method: RequestMethod.post,
        payload: {'round': reactionRound, 'reactionTimeMs': elapsed},
      );
      notifyListeners();
    } else if (reactionState == ReactionGameState.waiting) {
      reactionMisses += 1;
      reactionState = ReactionGameState.tooEarly;
      reactionFeedback = 'Too early!';
      _prepareRequest(
        feature: 'reaction_time',
        endpoint: '/api/games/reaction-time/round',
        method: RequestMethod.post,
        payload: {'round': reactionRound, 'result': 'too_early'},
      );
      notifyListeners();
    } else if (reactionState == ReactionGameState.tooEarly) {
      reactionState = ReactionGameState.waiting;
      reactionFeedback = 'Wait for green...';
      _reactionRoundStartedAt = DateTime.now();
      final delayMs = 1000 + _random.nextInt(2000);
      _reactionRevealTimer?.cancel();
      _reactionRevealTimer = Timer(Duration(milliseconds: delayMs), () {
        reactionState = ReactionGameState.ready;
        reactionFeedback = 'Tap now!';
        notifyListeners();
      });
      notifyListeners();
    } else if (reactionState == ReactionGameState.result) {
      if (reactionRound >= reactionTotalRounds) {
        reactionApiPayload = {
          'game': 'reaction_time',
          'totalRounds': reactionTotalRounds,
          'roundTimes': List<int>.from(reactionTimes),
          'averageTimeMs': reactionAverageMs,
          'misses': reactionMisses,
          'completedAt': DateTime.now().toIso8601String(),
        };
        reactionState = ReactionGameState.idle;
      } else {
        reactionRound += 1;
        reactionState = ReactionGameState.idle;
      }
      notifyListeners();
    } else if (reactionState == ReactionGameState.idle) {
      startReactionRound();
    }
  }

  String? validateChatMessage(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Please type a short message first.';
    if (trimmed.length > 120) return 'Keep the message under 120 characters.';
    return null;
  }

  Future<void> submitSocialMessage(String message) async {
    final error = validateChatMessage(message);
    if (error != null) {
      socialFeedback = error;
      notifyListeners();
      return;
    }

    final trimmed = message.trim();
    socialMessages.add(
      SocialMessage(
        id: 'user-${DateTime.now().microsecondsSinceEpoch}',
        text: trimmed,
        isUser: true,
        createdAt: DateTime.now(),
      ),
    );
    socialMessages.add(
      SocialMessage(
        id: 'bot-${DateTime.now().microsecondsSinceEpoch}',
        text: _buildBotReply(trimmed),
        isUser: false,
        createdAt: DateTime.now(),
      ),
    );
    socialConfidence = min(1.0, socialConfidence + 0.08);
    socialFeedback = 'Draft conversation prepared for backend syncing.';
    // Add points and check achievements/level up
    await addPoints(2);
    _prepareRequest(
      feature: 'social_practice',
      endpoint: '/api/social/messages',
      method: RequestMethod.post,
      payload: {
        'message': trimmed,
        'confidence': socialConfidence,
        'conversationLength': socialMessages.length,
      },
    );
    notifyListeners();
  }

  Future<void> unlockAccessory(String accessoryName) async {
    final index = accessories.indexWhere((item) => item.name == accessoryName);
    if (index == -1) return;
    final accessory = accessories[index];
    if (accessory.owned) return;
    if (learningPoints < accessory.cost) {
      _prepareRequest(
        feature: 'rewards',
        endpoint: '/api/rewards/purchase-attempt',
        method: RequestMethod.post,
        payload: {
          'accessory': accessory.name,
          'result': 'insufficient_points',
          'points': learningPoints,
        },
      );
      notifyListeners();
      return;
    }
    learningPoints -= accessory.cost;
    accessories[index] = accessory.copyWith(owned: true);

    // Save purchase to storage
    if (storage != null) {
      final accessoryData = await storage!.getAllAccessories();
      final data = accessoryData.firstWhere((a) => a.name == accessoryName);
      await storage!.purchaseAccessory(data.id);
      await _saveProgress(); // Save updated points
    }

    _prepareRequest(
      feature: 'rewards',
      endpoint: '/api/rewards/purchase',
      method: RequestMethod.post,
      payload: {
        'accessory': accessory.name,
        'cost': accessory.cost,
        'remainingPoints': learningPoints,
      },
    );
    notifyListeners();
  }

  /// Reset progress but keep owned accessories
  Future<void> resetProgress() async {
    learningPoints = 0;
    gamesPlayed = 0;
    dayStreak = 1;
    emotionScore = 0;
    colorMatches = 0;
    colorMisses = 0;
    reactionTimes.clear();
    reactionMisses = 0;
    _placedAccessories.clear();
    _currentLevel = 0;
    _unlockedAchievementKeys.clear();

    // Reset in storage
    if (storage != null) {
      await storage!.resetProgress();
      await storage!.resetAccessoryPlacements();
    }

    notifyListeners();
  }

  /// Place an accessory in the room at specific coordinates
  Future<void> placeAccessoryInRoom(String accessoryName, int x, int y) async {
    final accessory = accessories.firstWhere(
      (a) => a.name == accessoryName && a.owned,
      orElse: () => throw Exception('Accessory not found or not owned'),
    );

    _placedAccessories.add(
      PlacedAccessory(name: accessory.name, icon: accessory.icon, x: x, y: y),
    );

    // Save placement to storage
    if (storage != null) {
      final accessoryData = await storage!.getAllAccessories();
      final data = accessoryData.firstWhere((a) => a.name == accessoryName);
      await storage!.placeAccessory(data.id, x, y);
    }

    notifyListeners();
  }

  // ==================== STORAGE INTEGRATION ====================

  /// Load data from local storage
  /// NOTE: Learning points are reset to 0 for each login session
  Future<void> _loadFromStorage() async {
    if (storage == null) return;

    try {
      // Load progress (but reset learning points to 0 for new session)
      final progress = await storage!.getProgress();
      if (progress != null) {
        // RESET: Learning points always start at 0 for each session
        learningPoints = 0;
        gamesPlayed = progress.gamesPlayed;
        dayStreak = progress.dayStreak;
        _currentLevel = 0;

        // Save the reset points to storage
        await _saveProgress();

        // Update streak based on last play date
        await _updateDayStreak();
      }

      // Load accessories
      final accessoryData = await storage!.getAllAccessories();
      for (var data in accessoryData) {
        final index = accessories.indexWhere((a) => a.name == data.name);
        if (index != -1) {
          accessories[index] = accessories[index].copyWith(owned: data.owned);
          // Restore placed accessories
          if (data.owned && data.x != null && data.y != null) {
            _placedAccessories.add(
              PlacedAccessory(
                name: data.name,
                icon: LocalDataSource.getIconFromName(data.iconName),
                x: data.x,
                y: data.y,
              ),
            );
          }
        }
      }

      // Load achievements
      final achievementData = await storage!.getAllAchievements();
      for (var data in achievementData) {
        if (data.unlocked) {
          _unlockedAchievementKeys.add(data.key);
        }
      }

      notifyListeners();
    } catch (e) {
      // Ignore storage errors, use defaults
      debugPrint('Storage load error: $e');
    }
  }

  /// Save progress to storage
  Future<void> _saveProgress() async {
    if (storage == null) return;

    try {
      await storage!.saveProgress(
        ProgressData(
          learningPoints: learningPoints,
          gamesPlayed: gamesPlayed,
          dayStreak: dayStreak,
          lastPlayedAt: DateTime.now(),
        ),
      );
    } catch (e) {
      debugPrint('Storage save error: $e');
    }
  }

  /// Update day streak based on last play date
  Future<void> _updateDayStreak() async {
    if (storage == null) return;

    final progress = await storage!.getProgress();
    if (progress?.lastPlayedAt != null) {
      final lastPlayed = progress!.lastPlayedAt!;
      final now = DateTime.now();
      final difference = now.difference(lastPlayed).inDays;

      if (difference == 1) {
        // Consecutive day
        dayStreak += 1;
      } else if (difference > 1) {
        // Streak broken
        dayStreak = 1;
      }
      // Same day: no change
    }
  }

  /// Get current level based on points
  int _getLevelFromPoints(int points) {
    if (points >= 1000) return 4; // Master
    if (points >= 500) return 3; // Expert
    if (points >= 250) return 2; // Explorer
    if (points >= 100) return 1; // Learner
    return 0; // Beginner
  }

  /// Check for level up and trigger celebration
  void _checkLevelUp(int oldPoints, int newPoints) {
    final oldLevel = _getLevelFromPoints(oldPoints);
    final newLevel = _getLevelFromPoints(newPoints);

    if (newLevel > oldLevel) {
      _currentLevel = newLevel;
      _playLevelUpSound();
      onLevelUp?.call(newLevel);
    }
  }

  /// Play level up sound
  Future<void> _playLevelUpSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/level_up.mp3'));
    } catch (e) {
      // Sound not available, ignore
    }
  }

  /// Check achievements and trigger unlock notifications
  void _checkAchievements() {
    final currentAchievements = achievements;
    for (var achievement in currentAchievements) {
      // Find the key for this achievement
      String? key;
      if (achievement.title == 'First Steps') key = 'first_steps';
      if (achievement.title == 'Emotion Expert') key = 'emotion_expert';
      if (achievement.title == 'Quick Reflexes') key = 'quick_reflexes';
      if (achievement.title == 'Color Master') key = 'color_master';
      if (achievement.title == 'Social Butterfly') key = 'social_butterfly';
      if (achievement.title == 'Puzzle Starter') key = 'puzzle_starter';
      if (achievement.title == 'Speed Star') key = 'speed_star';
      if (achievement.title == 'Sorting Champion') key = 'sorting_champion';
      if (achievement.title == 'Reading Buddy') key = 'reading_buddy';
      if (achievement.title == 'Emotion Explorer') key = 'emotion_explorer';
      if (achievement.title == 'Streak Keeper') key = 'streak_keeper';
      if (achievement.title == 'Social Star') key = 'social_star';
      if (achievement.title == 'Color Pro') key = 'color_pro';
      if (achievement.title == 'Fast Learner') key = 'fast_learner';
      if (achievement.title == 'Master Collector') key = 'master_collector';

      if (key != null &&
          achievement.unlocked &&
          !_unlockedAchievementKeys.contains(key)) {
        _unlockedAchievementKeys.add(key);
        _unlockAchievementInStorage(key);
        onAchievementUnlock?.call(achievement);
      }
    }
  }

  /// Unlock achievement in storage
  Future<void> _unlockAchievementInStorage(String key) async {
    if (storage == null) return;

    try {
      final allAchievements = await storage!.getAllAchievements();
      final achievement = allAchievements.firstWhere((a) => a.key == key);
      await storage!.unlockAchievement(achievement.id);
    } catch (e) {
      debugPrint('Achievement unlock error: $e');
    }
  }

  // ==================== NEW ACHIEVEMENT TRACKING METHODS ====================

  /// Track puzzle game completion
  void trackPuzzleCompleted() {
    puzzleGamesCompleted++;
    if (puzzleGamesCompleted >= 1) {
      _unlockAchievement('puzzle_starter');
    }
    _checkAchievements();
    notifyListeners();
  }

  /// Track reading exercise completion
  void trackReadingCompleted() {
    readingExercisesCompleted++;
    if (readingExercisesCompleted >= 5) {
      _unlockAchievement('reading_buddy');
    }
    _checkAchievements();
    notifyListeners();
  }

  /// Track chat message sent
  void trackMessageSent() {
    chatMessagesSent++;
    if (chatMessagesSent >= 20) {
      _unlockAchievement('social_star');
    }
    // Also check Social Butterfly (10 conversations)
    if (chatMessagesSent >= 10) {
      _unlockAchievement('social_butterfly');
    }
    _checkAchievements();
    notifyListeners();
  }

  /// Track sorting game completion
  void trackSortingCompleted() {
    sortingGamesCompleted++;
    if (sortingGamesCompleted >= 10) {
      _unlockAchievement('sorting_champion');
    }
    _trackGameInSession();
    _checkAchievements();
    notifyListeners();
  }

  /// Track color sorted correctly
  void trackColorSorted() {
    colorsSortedCorrectly++;
    if (colorsSortedCorrectly >= 50) {
      _unlockAchievement('color_pro');
    }
    _checkAchievements();
    notifyListeners();
  }

  /// Track emotion recognized correctly
  void trackEmotionRecognized() {
    emotionsRecognized++;
    if (emotionsRecognized >= 5) {
      _unlockAchievement('emotion_explorer');
    }
    _checkAchievements();
    notifyListeners();
  }

  /// Track emotion game completion (for Speed Star)
  void trackEmotionGameCompleted({required int durationSeconds}) {
    if (durationSeconds < 10) {
      _unlockAchievement('speed_star');
    }
    _trackGameInSession();
    _checkAchievements();
    notifyListeners();
  }

  /// Track games in current session (for Fast Learner)
  void _trackGameInSession() {
    sessionStartTime ??= DateTime.now();
    gamesInCurrentSession++;
    if (gamesInCurrentSession >= 3) {
      _unlockAchievement('fast_learner');
    }
  }

  /// Check Master Collector achievement (called when accessory is purchased)
  void checkMasterCollector() {
    final ownedCount = accessories.where((a) => a.owned).length;
    if (ownedCount >= 10) {
      _unlockAchievement('master_collector');
    }
    _checkAchievements();
    notifyListeners();
  }

  // ==================== THAI CHAT METHODS ====================

  /// Initialize Thai chat services
  void _initThaiChat() {
    speechService = SpeechService();
    speechService.init();
    chatService = ChatService(baseUrl: 'http://localhost:8000');

    // Seed Thai messages
    final now = DateTime.now();
    thaiSocialMessages.addAll([
      SocialMessage(
        id: 'bot-1',
        text: 'สวัสดี! ฉันคือเพื่อนที่คุยสนุก 🤗',
        isUser: false,
        createdAt: now,
      ),
      SocialMessage(
        id: 'bot-2',
        text: 'วันนี้เธอทำอะไรมา?',
        isUser: false,
        createdAt: now,
      ),
    ]);
  }

  /// Submit Thai message via ChatService
  Future<void> submitThaiSocialMessage(String message) async {
    final error = validateThaiChatMessage(message);
    if (error != null) {
      socialFeedback = error;
      notifyListeners();
      return;
    }

    final trimmed = message.trim();

    // Add user message
    thaiSocialMessages.add(
      SocialMessage(
        id: 'user-${DateTime.now().microsecondsSinceEpoch}',
        text: trimmed,
        isUser: true,
        createdAt: DateTime.now(),
      ),
    );

    try {
      // Get response from backend
      final response = await chatService.sendMessage(trimmed);

      // Add bot response
      thaiSocialMessages.add(
        SocialMessage(
          id: 'bot-${DateTime.now().microsecondsSinceEpoch}',
          text: response.response,
          isUser: false,
          createdAt: response.timestamp,
        ),
      );

      // Track message sent (achievement)
      trackMessageSent();

      // Add points
      await addPoints(2);

      socialFeedback = 'ข้อความส่งแล้ว';
    } catch (e) {
      // Fallback to offline mode
      thaiSocialMessages.add(
        SocialMessage(
          id: 'bot-${DateTime.now().microsecondsSinceEpoch}',
          text: 'ขอโทษนะ เชื่อมต่อไม่ได้ ลองใหม่อีกครั้ง',
          isUser: false,
          createdAt: DateTime.now(),
        ),
      );
      socialFeedback = 'เชื่อมต่อล้มเหลว';
    }

    notifyListeners();
  }

  /// Speak bot response (Thai TTS)
  Future<void> speakThaiResponse(String text) async {
    await speechService.speakThai(text);
  }

  /// Listen for Thai speech (STT)
  Future<String?> listenThaiSpeech() async {
    return await speechService.listenThai();
  }

  /// Validate Thai message
  String? validateThaiChatMessage(String message) {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      return 'กรุณาพิมพ์ข้อความ';
    }
    if (trimmed.length > 200) {
      return 'ข้อความสั้นเกินไป';
    }
    return null;
  }

  /// Generic unlock achievement by key
  void _unlockAchievement(String key) {
    if (!_unlockedAchievementKeys.contains(key)) {
      _unlockedAchievementKeys.add(key);
      _unlockAchievementInStorage(key);
      // Map key to title
      final keyToTitle = {
        'first_steps': 'First Steps',
        'emotion_expert': 'Emotion Expert',
        'quick_reflexes': 'Quick Reflexes',
        'color_master': 'Color Master',
        'social_butterfly': 'Social Butterfly',
        'puzzle_starter': 'Puzzle Starter',
        'speed_star': 'Speed Star',
        'sorting_champion': 'Sorting Champion',
        'reading_buddy': 'Reading Buddy',
        'emotion_explorer': 'Emotion Explorer',
        'streak_keeper': 'Streak Keeper',
        'social_star': 'Social Star',
        'color_pro': 'Color Pro',
        'fast_learner': 'Fast Learner',
        'master_collector': 'Master Collector',
      };
      final title = keyToTitle[key] ?? key;
      // Find and trigger the callback
      final achievement = achievements.firstWhere(
        (a) => a.title == title,
        orElse: () =>
            AchievementItem(title: title, description: '', unlocked: true),
      );
      onAchievementUnlock?.call(achievement);
    }
  }

  /// Add points with level up check and persistence
  Future<void> addPoints(int points) async {
    final oldPoints = learningPoints;
    learningPoints += points;

    // Check for level up
    _checkLevelUp(oldPoints, learningPoints);

    // Check achievements
    _checkAchievements();

    // Save to storage
    await _saveProgress();

    notifyListeners();
  }

  @override
  void dispose() {
    _reactionRevealTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void resetReactionGame() {
    reactionRound = 1;
    reactionTimes.clear();
    reactionMisses = 0;
    reactionState = ReactionGameState.idle;
    currentReactionTimeMs = 0;
    reactionFeedback = 'Tap the container when it turns green.';
    reactionApiPayload = null;
    _reactionRevealTimer?.cancel();
    notifyListeners();
  }

  void _prepareRequest({
    required String feature,
    required String endpoint,
    required RequestMethod method,
    required Map<String, dynamic> payload,
  }) {
    preparedRequests.insert(
      0,
      PreparedRequest(
        feature: feature,
        endpoint: endpoint,
        method: method,
        payload: payload,
        createdAt: DateTime.now(),
      ),
    );
  }

  String _buildBotReply(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('pizza')) {
      return 'Pizza sounds yummy. What drink did you have with it?';
    }
    if (lower.contains('play')) {
      return 'That sounds fun. Who do you like to play with?';
    }
    if (lower.contains('hello') || lower.contains('hi')) {
      return 'Hello! I am happy to chat with you today.';
    }
    return 'Thanks for sharing. Can you tell me a little more?';
  }

  void _seedState() {
    _emotionQuestions = const [
      EmotionQuestion(
        prompt: 'Show your happy face',
        correctAnswer: 'Happy',
        options: ['Happy', 'Sad', 'Angry', 'Surprised', 'Scared'],
        icon: Icons.sentiment_satisfied_alt_rounded,
      ),
      EmotionQuestion(
        prompt: 'Which feeling looks worried?',
        correctAnswer: 'Scared',
        options: ['Happy', 'Scared', 'Calm', 'Angry', 'Proud'],
        icon: Icons.sentiment_dissatisfied_rounded,
      ),
    ];

    _setupColorRound();

    socialMessages.addAll([
      SocialMessage(
        id: 'bot-1',
        text: 'Hi! I am your friendly chat buddy!',
        isUser: false,
        createdAt: DateTime.now(),
      ),
      SocialMessage(
        id: 'bot-2',
        text: 'What did you eat today?',
        isUser: false,
        createdAt: DateTime.now(),
      ),
      SocialMessage(
        id: 'user-1',
        text: 'Pizza!',
        isUser: true,
        createdAt: DateTime.now(),
      ),
      SocialMessage(
        id: 'bot-3',
        text: 'Sounds delicious! What do you like to play?',
        isUser: false,
        createdAt: DateTime.now(),
      ),
    ]);

    accessories = const [
      AccessoryItem(
        name: 'Party Hat',
        icon: Icons.celebration_outlined,
        cost: 20,
        owned: false,
      ),
      AccessoryItem(
        name: 'Sunglasses',
        icon: Icons.wb_sunny_outlined,
        cost: 20,
        owned: false,
      ),
      AccessoryItem(
        name: 'Bow Tie',
        icon: Icons.style_outlined,
        cost: 40,
        owned: false,
      ),
      AccessoryItem(
        name: 'Crown',
        icon: Icons.workspace_premium_outlined,
        cost: 100,
        owned: false,
      ),
      AccessoryItem(
        name: 'Star Badge',
        icon: Icons.star_outline_rounded,
        cost: 60,
        owned: false,
      ),
      AccessoryItem(
        name: 'Heart Pin',
        icon: Icons.favorite_outlined,
        cost: 30,
        owned: false,
      ),
      AccessoryItem(
        name: 'Rainbow Band',
        icon: Icons.palette_outlined,
        cost: 50,
        owned: false,
      ),
      AccessoryItem(
        name: 'Peace Sign',
        icon: Icons.spa_outlined,
        cost: 45,
        owned: false,
      ),
      AccessoryItem(
        name: 'Music Note',
        icon: Icons.music_note_outlined,
        cost: 35,
        owned: false,
      ),
      AccessoryItem(
        name: 'Bookworm',
        icon: Icons.menu_book_outlined,
        cost: 55,
        owned: false,
      ),
      AccessoryItem(
        name: 'Puzzle Piece',
        icon: Icons.extension_outlined,
        cost: 70,
        owned: false,
      ),
      AccessoryItem(
        name: 'Flower',
        icon: Icons.local_florist_outlined,
        cost: 40,
        owned: false,
      ),
      AccessoryItem(
        name: 'Rocket',
        icon: Icons.rocket_launch_outlined,
        cost: 80,
        owned: false,
      ),
      AccessoryItem(
        name: 'Medal',
        icon: Icons.military_tech_outlined,
        cost: 90,
        owned: false,
      ),
      AccessoryItem(
        name: 'Glow Star',
        icon: Icons.auto_awesome_outlined,
        cost: 120,
        owned: false,
      ),
    ];
  }
}

class AudyScope extends InheritedNotifier<AudyController> {
  const AudyScope({
    super.key,
    required AudyController controller,
    required super.child,
  }) : super(notifier: controller);

  static AudyController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AudyScope>();
    assert(scope != null, 'AudyScope is missing above this widget.');
    return scope!.notifier!;
  }
}
