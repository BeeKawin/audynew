import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

enum ReadingModule { letters, words, sentences }

enum SortShape { circle, square, triangle }

enum RequestMethod { get, post, put }

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

class ReadingPracticeState {
  const ReadingPracticeState({
    required this.prompt,
    required this.progressCurrent,
    required this.progressTotal,
    this.lastAttempt = '',
    this.feedback = 'Tap Listen, then say it clearly.',
  });

  final String prompt;
  final int progressCurrent;
  final int progressTotal;
  final String lastAttempt;
  final String feedback;

  ReadingPracticeState copyWith({
    String? prompt,
    int? progressCurrent,
    int? progressTotal,
    String? lastAttempt,
    String? feedback,
  }) {
    return ReadingPracticeState(
      prompt: prompt ?? this.prompt,
      progressCurrent: progressCurrent ?? this.progressCurrent,
      progressTotal: progressTotal ?? this.progressTotal,
      lastAttempt: lastAttempt ?? this.lastAttempt,
      feedback: feedback ?? this.feedback,
    );
  }
}

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
  late final Map<ReadingModule, List<String>> _readingPrompts;
  late final List<ColorPiece> _colorPieces;

  final List<PreparedRequest> preparedRequests = [];

  int emotionQuestionIndex = 0;
  int emotionScore = 0;
  String emotionFeedback = 'Choose the matching emotion.';

  bool eyeContactRunning = false;
  int eyeContactElapsedMs = 0;
  int eyeContactBestMs = 0;

  String colorFeedback = 'Select a shape, then tap a basket.';
  String? selectedColorPieceId;
  int colorMatches = 0;
  int colorMisses = 0;

  int reactionRound = 1;
  int reactionScore = 0;
  int reactionMisses = 0;
  bool reactionWaitingForSymbol = false;
  bool reactionSymbolVisible = false;
  String reactionFeedback = 'Tap the play area to start a round.';
  IconData reactionSymbol = Icons.auto_awesome_rounded;

  final Map<ReadingModule, ReadingPracticeState> readingStates = {};

  final List<SocialMessage> socialMessages = [];
  double socialConfidence = 0.20;
  String socialFeedback = 'Start a conversation with a short message.';

  int learningPoints = 245;
  int gamesPlayed = 47;
  int dayStreak = 5;

  late List<AccessoryItem> accessories;

  Timer? _eyeContactTimer;
  Timer? _reactionRevealTimer;
  DateTime? _reactionRoundStartedAt;

  /// Returns the current dashboard completion ratio from local feature progress.
  double get dashboardProgress {
    var completed = 0;
    if (emotionScore > 0) completed++;
    if (readingStates.values.any((state) => state.progressCurrent > 0)) completed++;
    if (socialMessages.where((message) => message.isUser).isNotEmpty) completed++;
    if (colorMatches > 0 || reactionScore > 0 || eyeContactBestMs > 0) completed++;
    return completed / 4;
  }

  /// Returns a human-readable progress label for the dashboard progress card.
  String get dashboardProgressLabel =>
      '${(dashboardProgress * 100).round()}% Complete';

  /// Returns the active emotion question displayed on the emotion screen.
  EmotionQuestion get currentEmotionQuestion =>
      _emotionQuestions[emotionQuestionIndex];

  /// Returns the active color piece selected by the user, if any.
  ColorPiece? get selectedColorPiece {
    if (selectedColorPieceId == null) return null;
    return _colorPieces.firstWhere(
      (piece) => piece.id == selectedColorPieceId,
      orElse: () => _colorPieces.first,
    );
  }

  /// Exposes the current color pieces available for sorting.
  List<ColorPiece> get colorPieces => List.unmodifiable(_colorPieces);

  /// Returns the formatted eye contact timer label for the UI.
  String get eyeContactFormatted =>
      '${(eyeContactElapsedMs / 1000).toStringAsFixed(1)}s';

  /// Returns the current reaction score label shown in the UI.
  String get reactionScoreLabel => 'Score: $reactionScore';

  /// Returns the current reaction miss label shown in the UI.
  String get reactionMissLabel => 'Misses: $reactionMisses';

  /// Returns the current reaction round label shown in the UI.
  String get reactionRoundLabel => 'Round: $reactionRound / 10';

  /// Returns the number of unlocked achievements derived from local progress.
  int get unlockedAchievementCount =>
      achievements.where((achievement) => achievement.unlocked).length;

  /// Returns the profile achievements list derived from current state.
  List<AchievementItem> get achievements {
    return [
      AchievementItem(
        title: 'First Steps',
        description: 'Complete your first game',
        unlocked: emotionScore > 0 || colorMatches > 0 || reactionScore > 0,
      ),
      AchievementItem(
        title: 'Emotion Expert',
        description: 'Master 5 emotions',
        unlocked: emotionScore >= 5,
      ),
      AchievementItem(
        title: 'Quick Reflexes',
        description: 'Score 90% in Reaction Time',
        unlocked: reactionScore >= 3 && reactionMisses <= 1,
      ),
      AchievementItem(
        title: 'Color Master',
        description: 'Perfect score in Color Sorting',
        unlocked: colorMatches >= 3 && colorMisses == 0,
      ),
      AchievementItem(
        title: 'Reading Star',
        description: 'Complete 20 reading sessions',
        unlocked: readingStates.values.fold<int>(
              0,
              (sum, state) => sum + state.progressCurrent,
            ) >=
            20,
      ),
      AchievementItem(
        title: 'Social Butterfly',
        description: 'Have 10 conversations',
        unlocked:
            socialMessages.where((message) => message.isUser).length >= 10,
      ),
    ];
  }

  /// Validates and submits an emotion answer without sending it to a backend.
  void submitEmotionAnswer(String answer) {
    final isCorrect = answer == currentEmotionQuestion.correctAnswer;
    emotionFeedback = isCorrect
        ? 'Great job! $answer is correct.'
        : 'Nice try. The correct answer is ${currentEmotionQuestion.correctAnswer}.';
    if (isCorrect) {
      emotionScore += 1;
      learningPoints += 5;
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
    emotionQuestionIndex = (emotionQuestionIndex + 1) % _emotionQuestions.length;
    notifyListeners();
  }

  /// Creates a draft backend request representing an audio playback intent.
  void prepareAudioPrompt(String feature, String prompt) {
    _prepareRequest(
      feature: feature,
      endpoint: '/api/audio/play',
      method: RequestMethod.post,
      payload: {'prompt': prompt, 'voice': 'friendly-guide'},
    );
    notifyListeners();
  }

  /// Starts the eye contact timer and prepares a draft session request.
  void startEyeContactSession() {
    if (eyeContactRunning) return;
    eyeContactRunning = true;
    _prepareRequest(
      feature: 'eye_contact',
      endpoint: '/api/games/eye-contact/start',
      method: RequestMethod.post,
      payload: {'startedAt': DateTime.now().toIso8601String()},
    );
    _eyeContactTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      eyeContactElapsedMs += 100;
      notifyListeners();
    });
    notifyListeners();
  }

  /// Stops the eye contact timer and stores a draft completion request.
  void stopEyeContactSession() {
    if (!eyeContactRunning) return;
    eyeContactRunning = false;
    _eyeContactTimer?.cancel();
    eyeContactBestMs = max(eyeContactBestMs, eyeContactElapsedMs);
    learningPoints += (eyeContactElapsedMs / 1000).floor();
    _prepareRequest(
      feature: 'eye_contact',
      endpoint: '/api/games/eye-contact/complete',
      method: RequestMethod.post,
      payload: {
        'durationMs': eyeContactElapsedMs,
        'bestDurationMs': eyeContactBestMs,
      },
    );
    notifyListeners();
  }

  /// Resets the eye contact timer state locally.
  void resetEyeContactSession() {
    _eyeContactTimer?.cancel();
    eyeContactRunning = false;
    eyeContactElapsedMs = 0;
    notifyListeners();
  }

  /// Marks a color piece as selected and updates local guidance text.
  void selectColorPiece(String pieceId) {
    selectedColorPieceId = pieceId;
    final piece = selectedColorPiece;
    colorFeedback = piece == null
        ? 'Select a shape, then tap a basket.'
        : 'Selected ${piece.colorName} ${piece.shape.name}.';
    notifyListeners();
  }

  /// Attempts to drop the selected piece on a basket and prepares a draft result.
  void submitColorBasket(String basketColor) {
    final piece = selectedColorPiece;
    if (piece == null) {
      colorFeedback = 'Select a shape before choosing a basket.';
      notifyListeners();
      return;
    }

    final isCorrect =
        piece.colorName.toLowerCase() == basketColor.toLowerCase();
    if (isCorrect) {
      colorMatches += 1;
      learningPoints += 3;
      _colorPieces.removeWhere((item) => item.id == piece.id);
      selectedColorPieceId = _colorPieces.isEmpty ? null : _colorPieces.first.id;
      colorFeedback = 'Correct! ${piece.colorName} matches $basketColor.';
    } else {
      colorMisses += 1;
      colorFeedback =
          'Not quite. ${piece.colorName} should not go in $basketColor.';
    }
    _prepareRequest(
      feature: 'color_sorting',
      endpoint: '/api/games/color-sorting/move',
      method: RequestMethod.post,
      payload: {
        'pieceId': piece.id,
        'pieceColor': piece.colorName,
        'basketColor': basketColor,
        'isCorrect': isCorrect,
        'matches': colorMatches,
        'misses': colorMisses,
      },
    );
    notifyListeners();
  }

  /// Starts or advances a reaction round without sending live network traffic.
  void startReactionRound() {
    if (reactionWaitingForSymbol || reactionSymbolVisible) return;
    reactionWaitingForSymbol = true;
    reactionFeedback = 'Wait for the symbol, then tap fast.';
    final delayMs = 600 + _random.nextInt(800);
    _reactionRoundStartedAt = DateTime.now();
    _reactionRevealTimer?.cancel();
    _reactionRevealTimer = Timer(Duration(milliseconds: delayMs), () {
      reactionWaitingForSymbol = false;
      reactionSymbolVisible = true;
      reactionSymbol = [
        Icons.auto_awesome_rounded,
        Icons.star_rounded,
        Icons.flash_on_rounded,
      ][_random.nextInt(3)];
      notifyListeners();
    });
    notifyListeners();
  }

  /// Handles taps on the reaction surface and prepares a draft result payload.
  void registerReactionTap() {
    if (reactionSymbolVisible) {
      reactionScore += 1;
      learningPoints += 4;
      reactionFeedback = 'Great reaction!';
      _prepareRequest(
        feature: 'reaction_time',
        endpoint: '/api/games/reaction-time/round',
        method: RequestMethod.post,
        payload: {
          'round': reactionRound,
          'result': 'success',
          'latencyMs': DateTime.now()
              .difference(_reactionRoundStartedAt ?? DateTime.now())
              .inMilliseconds,
        },
      );
      _finishReactionRound();
    } else if (reactionWaitingForSymbol) {
      reactionMisses += 1;
      reactionFeedback = 'Too early. Wait for the symbol.';
      _prepareRequest(
        feature: 'reaction_time',
        endpoint: '/api/games/reaction-time/round',
        method: RequestMethod.post,
        payload: {
          'round': reactionRound,
          'result': 'too_early',
        },
      );
      _finishReactionRound();
    } else {
      startReactionRound();
      return;
    }
    notifyListeners();
  }

  /// Validates a practice attempt and prepares a backend-ready reading payload.
  void submitReadingAttempt(ReadingModule module, String attempt) {
    final error = validatePracticeInput(attempt);
    final state = readingStates[module]!;
    if (error != null) {
      readingStates[module] = state.copyWith(feedback: error);
      notifyListeners();
      return;
    }

    final normalizedAttempt = _normalizeText(attempt);
    final normalizedPrompt = _normalizeText(state.prompt);
    final isCorrect = normalizedAttempt == normalizedPrompt;
    var nextPrompt = state.prompt;
    if (isCorrect) {
      final prompts = _readingPrompts[module]!;
      final currentIndex = prompts.indexOf(state.prompt);
      nextPrompt = prompts[(currentIndex + 1) % prompts.length];
    }
    readingStates[module] = state.copyWith(
      prompt: nextPrompt,
      progressCurrent: min(state.progressCurrent + (isCorrect ? 1 : 0), state.progressTotal),
      lastAttempt: attempt,
      feedback: isCorrect
          ? 'Nice speaking practice. Keep going.'
          : 'Close. Try matching the prompt more exactly.',
    );
    if (isCorrect) {
      learningPoints += 4;
    }
    _prepareRequest(
      feature: 'reading_practice',
      endpoint: '/api/reading/attempt',
      method: RequestMethod.post,
      payload: {
        'module': module.name,
        'prompt': state.prompt,
        'attempt': attempt,
        'isCorrect': isCorrect,
      },
    );
    notifyListeners();
  }

  /// Validates chat input before it becomes a draft conversation message.
  String? validateChatMessage(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Please type a short message first.';
    if (trimmed.length > 120) return 'Keep the message under 120 characters.';
    return null;
  }

  /// Validates spoken practice input before it updates progress.
  String? validatePracticeInput(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Type what the learner said before submitting.';
    if (trimmed.length > 80) return 'Keep the practice attempt under 80 characters.';
    return null;
  }

  /// Adds a chat message locally, generates a friendly bot reply, and prepares a draft request.
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

  /// Purchases an accessory locally if enough points exist and prepares a draft order payload.
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
    _eyeContactTimer?.cancel();
    _reactionRevealTimer?.cancel();
    super.dispose();
  }

  void _finishReactionRound() {
    reactionWaitingForSymbol = false;
    reactionSymbolVisible = false;
    reactionRound = min(reactionRound + 1, 10);
    _reactionRevealTimer?.cancel();
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

  String _normalizeText(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
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

    _readingPrompts = {
      ReadingModule.letters: ['A', 'B', 'C'],
      ReadingModule.words: ['Dog', 'Apple', 'Book'],
      ReadingModule.sentences: ['I love you', 'I am happy', 'Let us read'],
    };

    readingStates[ReadingModule.letters] = const ReadingPracticeState(
      prompt: 'A',
      progressCurrent: 1,
      progressTotal: 3,
    );
    readingStates[ReadingModule.words] = const ReadingPracticeState(
      prompt: 'Dog',
      progressCurrent: 2,
      progressTotal: 5,
    );
    readingStates[ReadingModule.sentences] = const ReadingPracticeState(
      prompt: 'I love you',
      progressCurrent: 1,
      progressTotal: 3,
    );

    _colorPieces = const [
      ColorPiece(
        id: 'red-circle',
        colorName: 'Red',
        shape: SortShape.circle,
        color: Color(0xFFFF8D91),
      ),
      ColorPiece(
        id: 'blue-square',
        colorName: 'Blue',
        shape: SortShape.square,
        color: Color(0xFF8FBCEC),
      ),
      ColorPiece(
        id: 'green-circle',
        colorName: 'Green',
        shape: SortShape.circle,
        color: Color(0xFF90F48A),
      ),
      ColorPiece(
        id: 'red-square',
        colorName: 'Red',
        shape: SortShape.square,
        color: Color(0xFFFF8D91),
      ),
      ColorPiece(
        id: 'blue-triangle',
        colorName: 'Blue',
        shape: SortShape.triangle,
        color: Color(0xFF8FBCEC),
      ),
    ].toList();

    selectedColorPieceId = _colorPieces.first.id;

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
