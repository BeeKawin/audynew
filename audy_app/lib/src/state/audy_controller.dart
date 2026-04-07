import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

enum SortShape { circle, square, triangle }

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

class AudyController extends ChangeNotifier {
  AudyController() {
    _seedState();
  }

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

  int learningPoints = 245;
  int gamesPlayed = 47;
  int dayStreak = 5;
  int totalStars = 3;

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
    ];
  }

  void submitEmotionAnswer(String answer) {
    final isCorrect = answer == currentEmotionQuestion.correctAnswer;
    emotionFeedback = isCorrect
        ? 'Great job! $answer is correct.'
        : 'Nice try. The correct answer is ${currentEmotionQuestion.correctAnswer}.';
    if (isCorrect) {
      emotionScore += 1;
      learningPoints += 5;
      emotionCurrentTarget = currentEmotionQuestion.correctAnswer;
    }
    gamesPlayed += 1;
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

  void handleColorDrop(ColorPiece piece, String basketColor) {
    final isCorrect =
        piece.colorName.toLowerCase() == basketColor.toLowerCase();
    if (isCorrect) {
      colorMatches += 1;
      _colorRoundMatches += 1;
      learningPoints += 3;
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

  void handleReactionContainerTap() {
    if (reactionState == ReactionGameState.ready) {
      final elapsed = DateTime.now()
          .difference(_reactionRoundStartedAt ?? DateTime.now())
          .inMilliseconds;
      currentReactionTimeMs = elapsed;
      reactionTimes.add(elapsed);
      learningPoints += 4;
      reactionFeedback = '$elapsed ms';
      reactionState = ReactionGameState.result;
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

  void submitSocialMessage(String message) {
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
    learningPoints += 2;
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

  void unlockAccessory(String accessoryName) {
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

  @override
  void dispose() {
    _reactionRevealTimer?.cancel();
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
        cost: 0,
        owned: true,
      ),
      AccessoryItem(
        name: 'Sunglasses',
        icon: Icons.wb_sunny_outlined,
        cost: 0,
        owned: true,
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
