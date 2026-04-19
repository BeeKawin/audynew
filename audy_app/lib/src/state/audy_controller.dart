import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/app_strings.dart';
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

class DailyQuest {
  final String id;
  final IconData icon;
  final String label;
  final String type;
  int progress;
  final int target;
  final int rewardPoints;

  DailyQuest({
    required this.id,
    required this.icon,
    required this.label,
    required this.type,
    this.progress = 0,
    required this.target,
    required this.rewardPoints,
  });

  bool get isCompleted => progress >= target;

  DailyQuest copyWith({int? progress}) {
    return DailyQuest(
      id: id,
      icon: icon,
      label: label,
      type: type,
      progress: progress ?? this.progress,
      target: target,
      rewardPoints: rewardPoints,
    );
  }
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
  });

  final String prompt;
  final String correctAnswer;
  final List<String> options;
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

  // Get only owned accessories
  List<AccessoryItem> get ownedAccessories =>
      accessories.where((a) => a.owned).toList();

  // Achievement tracking
  final Set<String> _unlockedAchievementKeys = {};

  // Level tracking
  int _currentLevel = 0;
  int get currentLevel => _currentLevel;

  // Language settings - default to English
  String currentLanguage = 'en'; // 'en' or 'th'

  /// Set current language
  void setLanguage(String lang) {
    currentLanguage = lang;
    notifyListeners();
  }

  /// Translate a string key to current language
  String tr(String key, {Map<String, String>? params}) {
    final translated = AppStrings.get(key, currentLanguage);
    if (params != null) {
      return AppStrings.format(translated, params);
    }
    return translated;
  }

  final Random _random = Random();

  final List<PreparedRequest> preparedRequests = [];

  // ==================== EMOTION CLASSIFY GAME ====================
  late final List<EmotionQuestion> _classifyQuestions;
  int classifyQuestionIndex = 0;
  int classifyScore = 0;
  String classifyFeedback = 'Choose the matching emotion.';
  int classifyCurrentRound = 1;
  int classifyTotalRounds = 3;

  EmotionQuestion get currentClassifyQuestion =>
      _classifyQuestions[classifyQuestionIndex];

  bool get isClassifyGameComplete => classifyCurrentRound > classifyTotalRounds;

  Future<void> submitClassifyAnswer(String answer) async {
    final isCorrect = answer == currentClassifyQuestion.correctAnswer;
    classifyFeedback = isCorrect
        ? 'Great job! $answer is correct.'
        : 'Nice try. The correct answer is ${currentClassifyQuestion.correctAnswer}.';
    if (isCorrect) {
      classifyScore += 1;
    }
    gamesPlayed += 1;
    await addPoints(isCorrect ? 5 : 0);
    classifyQuestionIndex =
        (classifyQuestionIndex + 1) % _classifyQuestions.length;
    notifyListeners();
  }

  void advanceClassifyRound() {
    classifyCurrentRound += 1;
    classifyQuestionIndex =
        (classifyQuestionIndex + 1) % _classifyQuestions.length;
    notifyListeners();
  }

  void resetClassifyGame() {
    classifyCurrentRound = 1;
    classifyScore = 0;
    classifyQuestionIndex = 0;
    classifyFeedback = 'Choose the matching emotion.';
    notifyListeners();
  }

  // ==================== EMOTION MIMIC GAME ====================
  static const List<String> _mimicEmotions = [
    'Happy',
    'Sad',
    'Surprised',
    'Scared',
    'Angry',
    'Calm',
  ];

  int mimicCurrentRound = 1;
  int mimicTotalRounds = 3;
  int mimicScore = 0;
  int _mimicEmotionIndex = 0;
  double mimicLastConfidence = 0.0;

  String get currentMimicTarget => _mimicEmotions[_mimicEmotionIndex];

  bool get isMimicGameComplete => mimicCurrentRound > mimicTotalRounds;

  void advanceMimicRound() {
    mimicCurrentRound += 1;
    _mimicEmotionIndex = (_mimicEmotionIndex + 1) % _mimicEmotions.length;
    mimicLastConfidence = 0.0;
    notifyListeners();
  }

  void resetMimicGame() {
    mimicCurrentRound = 1;
    mimicScore = 0;
    _mimicEmotionIndex = 0;
    mimicLastConfidence = 0.0;
    notifyListeners();
  }

  void recordMimicResult({required bool isMatch, required double confidence}) {
    mimicLastConfidence = confidence;
    if (isMatch) {
      mimicScore += 1;
    }
    notifyListeners();
  }

  /// Track classify game completion (for Speed Star achievement)
  void trackClassifyGameCompleted({required int durationSeconds}) {
    if (durationSeconds < 10) {
      _unlockAchievement('speed_star');
    }
    _trackGameInSession();
    updateQuestProgress('game');
    _checkAchievements();
    notifyListeners();
  }

  /// Track mimic game completion (for Speed Star achievement)
  void trackMimicGameCompleted({required int durationSeconds}) {
    if (durationSeconds < 10) {
      _unlockAchievement('speed_star');
    }
    _trackGameInSession();
    updateQuestProgress('game');
    _checkAchievements();
    notifyListeners();
  }

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
  int sortingGamesCompleted =
      0; // NEW Sorting Game (replaced old color sorting)
  int emotionsRecognized = 0;
  int colorsSortedCorrectly = 0; // Kept for backward compatibility
  int gamesInCurrentSession = 0;
  DateTime? sessionStartTime;

  // NEW Sorting Game tracking
  int newSortingCorrectActions =
      0; // Tracks correct actions in new sorting game for points

  late List<AccessoryItem> accessories;

  Timer? _reactionRevealTimer;
  final Stopwatch _reactionStopwatch = Stopwatch();

  String get reactionRoundLabel =>
      'Round: $reactionRound / $reactionTotalRounds';

  int get reactionAverageMs {
    if (reactionTimes.isEmpty) return 0;
    return reactionTimes.reduce((a, b) => a + b) ~/ reactionTimes.length;
  }

  /// Points earned in reaction game (3 points per successful tap)
  int get reactionPointsEarned => reactionTimes.length * 3;

  bool get isReactionGameComplete =>
      reactionTimes.length >= reactionTotalRounds;

  int get unlockedAchievementCount =>
      achievements.where((achievement) => achievement.unlocked).length;

  List<AchievementItem> get achievements {
    return [
      AchievementItem(
        title: 'First Steps',
        description: 'Complete your first game',
        unlocked:
            classifyScore > 0 ||
            mimicScore > 0 ||
            reactionTimes.isNotEmpty ||
            sortingGamesCompleted > 0,
      ),
      AchievementItem(
        title: 'Emotion Expert',
        description: 'Master 5 emotions',
        unlocked: classifyScore + mimicScore >= 5,
      ),
      AchievementItem(
        title: 'Quick Reflexes',
        description: 'Average under 300ms in Reaction Time',
        unlocked: reactionTimes.isNotEmpty && reactionAverageMs < 300,
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
        unlocked:
            false, // Tracked via trackClassifyGameCompleted or trackMimicGameCompleted
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

  void startReactionRound() {
    if (reactionState != ReactionGameState.idle) return;
    reactionState = ReactionGameState.waiting;
    reactionFeedback = 'Wait for green...';
    final delayMs = 1000 + _random.nextInt(2000);
    _reactionStopwatch
      ..stop()
      ..reset();
    _reactionRevealTimer?.cancel();
    _reactionRevealTimer = Timer(Duration(milliseconds: delayMs), () {
      reactionState = ReactionGameState.ready;
      reactionFeedback = 'Tap now!';
      _reactionStopwatch.start();
      notifyListeners();
    });
    notifyListeners();
  }

  Future<void> handleReactionContainerTap() async {
    if (reactionState == ReactionGameState.ready) {
      _reactionStopwatch.stop();
      final elapsed = _reactionStopwatch.elapsedMilliseconds;
      currentReactionTimeMs = elapsed;
      reactionTimes.add(elapsed);
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
      _reactionStopwatch
        ..stop()
        ..reset();
      final delayMs = 1000 + _random.nextInt(2000);
      _reactionRevealTimer?.cancel();
      _reactionRevealTimer = Timer(Duration(milliseconds: delayMs), () {
        reactionState = ReactionGameState.ready;
        reactionFeedback = 'Tap now!';
        _reactionStopwatch.start();
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
        trackReactionCompleted();
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
    trackMessageSent();
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

  // ==================== ANALYTICS & DASHBOARD DATA ====================

  /// Emotion recognition accuracy (0.0 - 1.0)
  /// Based on all emotion games played (classify + mimic)
  double get emotionAccuracy {
    final totalAttempts = gamesPlayed > 0 ? gamesPlayed : 1;
    final emotionAttempts = classifyScore + mimicScore;
    if (emotionAttempts == 0) return 0.0;
    // Calculate accuracy from completed emotion games
    return (emotionAttempts / totalAttempts).clamp(0.0, 1.0);
  }

  /// Puzzle progress percentage (0.0 - 1.0)
  double get puzzleProgress {
    // Assume 20 puzzles is "mastery" level
    return (puzzleGamesCompleted / 20).clamp(0.0, 1.0);
  }

  /// Sorting progress percentage (0.0 - 1.0)
  double get sortingProgress {
    // Assume 10 sorting games is "mastery" level
    return (sortingGamesCompleted / 10).clamp(0.0, 1.0);
  }

  /// Reaction time progress (lower is better, convert to 0-1 scale)
  /// 300ms is baseline (0.5), 100ms is excellent (1.0), 1000ms is poor (0.0)
  double get reactionProgress {
    if (reactionTimes.isEmpty) return 0.0;
    final avg = reactionAverageMs.toDouble();
    // Normalize: 100ms = 1.0, 1000ms = 0.0
    return ((1000 - avg) / 900).clamp(0.0, 1.0);
  }

  /// Reading progress percentage (0.0 - 1.0)
  double get readingProgress {
    // Assume 15 reading exercises is "mastery" level
    return (readingExercisesCompleted / 15).clamp(0.0, 1.0);
  }

  /// Social progress percentage (0.0 - 1.0)
  double get socialProgress {
    // Assume 20 chat sessions is "mastery" level
    return (chatMessagesSent / 20).clamp(0.0, 1.0);
  }

  /// Skill percentages map for dashboard
  Map<String, double> get skillPercentages {
    return {
      'Emotions': emotionAccuracy,
      'MiniPuzzle': puzzleProgress,
      'Sorting': sortingProgress,
      'Reaction': reactionProgress,
      'Reading': readingProgress,
      'Social': socialProgress,
    };
  }

  /// Game completion counts per category
  Map<String, int> get gameCompletionCounts {
    return {
      'Emotion': classifyScore + mimicScore,
      'MiniPuzzle': puzzleGamesCompleted,
      'Sorting': sortingGamesCompleted,
      'Reaction': reactionTimes.length,
      'Reading': readingExercisesCompleted,
      'Social': chatMessagesSent,
    };
  }

  /// Emotion recognition progress history (simulated weekly data)
  /// Returns list of accuracy values for the past 7 sessions/weeks
  List<double> get emotionProgressHistory {
    if (classifyScore == 0) return [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6];
    final current = emotionAccuracy;
    // Simulate progression from lower to current
    return [
      current * 0.5,
      current * 0.6,
      current * 0.7,
      current * 0.8,
      current * 0.9,
      current * 0.95,
      current,
    ];
  }

  /// Puzzle progress history (simulated weekly data)
  List<double> get puzzleProgressHistory {
    if (puzzleGamesCompleted == 0) {
      return [0.0, 0.1, 0.15, 0.25, 0.35, 0.4, 0.45];
    }
    final current = puzzleProgress;
    return [
      current * 0.3,
      current * 0.4,
      current * 0.5,
      current * 0.65,
      current * 0.8,
      current * 0.9,
      current,
    ];
  }

  /// Generate weekly report data
  WeeklyReportData get weeklyReport {
    final now = DateTime.now();
    final weekStart = now.subtract(const Duration(days: 7));
    return WeeklyReportData(
      gamesPlayed: gamesPlayed,
      pointsEarned: learningPoints,
      currentStreak: dayStreak,
      achievementsUnlocked: unlockedAchievementCount,
      weekStart: weekStart,
      weekEnd: now,
      skillProgress: skillPercentages,
      totalPlayTimeMinutes: gamesPlayed * 5, // Estimate: 5 min per game
    );
  }

  /// Get current child profile data for institution panel
  ChildProfileData get currentChildProfile {
    return ChildProfileData(
      id: 'child-001',
      name: 'CEDT',
      age: 17,
      joinedDate: DateTime(2026, 1, 15),
      gamesPlayed: gamesPlayed,
      learningPoints: learningPoints,
      achievementsUnlocked: unlockedAchievementCount,
      dayStreak: dayStreak,
      skillAverages: skillPercentages,
    );
  }

  /// Get group performance data (placeholder for single child)
  /// In future, this would aggregate across multiple children
  GroupPerformanceData get groupPerformance {
    final child = currentChildProfile;
    return GroupPerformanceData(
      totalChildren: 1,
      averageGamesPerChild: child.gamesPlayed.toDouble(),
      averagePointsPerChild: child.learningPoints.toDouble(),
      averageStreak: child.dayStreak.toDouble(),
      averageSkillProgress: child.skillAverages,
      totalAchievementsUnlocked: child.achievementsUnlocked,
      reportGeneratedAt: DateTime.now(),
    );
  }

  /// Reset progress but keep owned accessories
  Future<void> resetProgress() async {
    learningPoints = 0;
    gamesPlayed = 0;
    dayStreak = 1;
    classifyScore = 0;
    mimicScore = 0;
    reactionTimes.clear();
    reactionMisses = 0;
    _currentLevel = 0;
    _unlockedAchievementKeys.clear();

    // Reset in storage
    if (storage != null) {
      await storage!.resetProgress();
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
    updateQuestProgress('game');
    _checkAchievements();
    notifyListeners();
  }

  /// Track reading exercise completion
  void trackReadingCompleted() {
    readingExercisesCompleted++;
    if (readingExercisesCompleted >= 5) {
      _unlockAchievement('reading_buddy');
    }
    updateQuestProgress('learn');
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
    updateQuestProgress('chat');
    _checkAchievements();
    notifyListeners();
  }

  /// Track sorting game completion
  void trackSortingCompleted() {
    sortingGamesCompleted++;
    if (sortingGamesCompleted >= 10) {
      _unlockAchievement('sorting_champion');
    }
    updateQuestProgress('game');
    _trackGameInSession();
    _checkAchievements();
    notifyListeners();
  }

  /// Track reaction game completed
  void trackReactionCompleted() {
    updateQuestProgress('game');
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
    updateQuestProgress('game');
    _checkAchievements();
    notifyListeners();
  }

  /// Track emotion recognized correctly
  void trackEmotionRecognized() {
    emotionsRecognized++;
    if (emotionsRecognized >= 5) {
      _unlockAchievement('emotion_explorer');
    }
    updateQuestProgress('game');
    _checkAchievements();
    notifyListeners();
  }

  /// Track emotion game completion (for Speed Star)
  void trackEmotionGameCompleted({required int durationSeconds}) {
    if (durationSeconds < 10) {
      _unlockAchievement('speed_star');
    }
    _trackGameInSession();
    updateQuestProgress('game');
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

  bool _isChatLoading = false;
  bool get isChatLoading => _isChatLoading;

  /// Get backend URL based on platform
  ///
  /// IMPORTANT: Update this IP address when running on physical devices!
  /// - Android Emulator: 10.0.2.2
  /// - iOS Simulator: localhost
  /// - Physical Device: Your computer's IP (e.g., 192.168.1.x)
  /// - Web: localhost
  String get _backendBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    }
    if (Platform.isIOS) {
      return 'http://localhost:8000';
    }
    return 'http://localhost:8000';
  }

  /// Initialize Thai chat services
  void _initThaiChat() {
    speechService = SpeechService();
    speechService.init();
    _initChatService();
    _seedThaiMessages();
  }

  /// Initialize or reinitialize chat service with current backend URL
  void _initChatService() {
    chatService = ChatService(baseUrl: _backendBaseUrl);
  }

  /// Update backend URL (useful for testing or changing servers)
  void updateBackendUrl(String newUrl) {
    chatService = ChatService(baseUrl: newUrl);
  }

  /// Check if backend is available
  Future<bool> checkBackendHealth() async {
    try {
      return await chatService.isBackendAvailable();
    } catch (e) {
      return false;
    }
  }

  /// Seed initial Thai chat messages
  void _seedThaiMessages() {
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
    _isChatLoading = true;
    notifyListeners();

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
    } finally {
      _isChatLoading = false;
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
    final oldLevel = _getLevelFromPoints(oldPoints);
    learningPoints += points;
    final newLevel = _getLevelFromPoints(learningPoints);
    final isLevelUp = newLevel > oldLevel;

    // Check for level up
    if (isLevelUp) {
      _currentLevel = newLevel;
      _playLevelUpSound();
      onLevelUp?.call(newLevel);
    }

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
    _reactionStopwatch
      ..stop()
      ..reset();
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
    _classifyQuestions = const [
      EmotionQuestion(
        prompt: 'What emotion is this?',
        correctAnswer: 'Happy',
        options: ['Happy', 'Sad', 'Angry', 'Scared', 'Surprised'],
      ),
      EmotionQuestion(
        prompt: 'How does this person feel?',
        correctAnswer: 'Sad',
        options: ['Happy', 'Sad', 'Angry', 'Scared', 'Surprised'],
      ),
      EmotionQuestion(
        prompt: 'Identify this emotion',
        correctAnswer: 'Angry',
        options: ['Happy', 'Sad', 'Angry', 'Scared', 'Surprised'],
      ),
      EmotionQuestion(
        prompt: 'What feeling do you see?',
        correctAnswer: 'Scared',
        options: ['Happy', 'Sad', 'Angry', 'Scared', 'Surprised'],
      ),
      EmotionQuestion(
        prompt: 'Name this emotion',
        correctAnswer: 'Surprised',
        options: ['Happy', 'Sad', 'Angry', 'Scared', 'Surprised'],
      ),
    ];

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

    // Initialize daily quests
    _initDailyQuests();
  }

  // Daily Quests Pool
  static final List<DailyQuest> _questPool = [
    // Games
    DailyQuest(
      id: 'play_emotion',
      icon: Icons.sentiment_satisfied_rounded,
      label: 'Emotion',
      type: 'game',
      target: 1,
      rewardPoints: 10,
    ),
    DailyQuest(
      id: 'play_puzzle',
      icon: Icons.extension_rounded,
      label: 'Puzzle',
      type: 'game',
      target: 1,
      rewardPoints: 10,
    ),
    DailyQuest(
      id: 'play_sorting',
      icon: Icons.category_rounded,
      label: 'Sorting',
      type: 'game',
      target: 1,
      rewardPoints: 10,
    ),
    DailyQuest(
      id: 'play_reaction',
      icon: Icons.flash_on_rounded,
      label: 'React',
      type: 'game',
      target: 1,
      rewardPoints: 10,
    ),
    // Chat
    DailyQuest(
      id: 'send_messages',
      icon: Icons.chat_bubble_rounded,
      label: 'Chat',
      type: 'chat',
      target: 3,
      rewardPoints: 15,
    ),
    DailyQuest(
      id: 'chat_session',
      icon: Icons.forum_rounded,
      label: 'Talk',
      type: 'chat',
      target: 1,
      rewardPoints: 12,
    ),
    // Learn
    DailyQuest(
      id: 'read_story',
      icon: Icons.menu_book_rounded,
      label: 'Read',
      type: 'learn',
      target: 1,
      rewardPoints: 10,
    ),
    DailyQuest(
      id: 'learn_emotion',
      icon: Icons.face_rounded,
      label: 'Faces',
      type: 'learn',
      target: 2,
      rewardPoints: 12,
    ),
  ];

  // Daily Quests State
  List<DailyQuest> dailyQuests = [];
  int dailyQuestsCompleted = 0;
  bool _allQuestsBonusGiven = false;

  /// Initialize daily quests - randomly select 3 from pool
  void _initDailyQuests() {
    final random = Random();
    final shuffled = List<DailyQuest>.from(_questPool)..shuffle(random);
    dailyQuests = shuffled.take(3).map((q) => q.copyWith(progress: 0)).toList();
    dailyQuestsCompleted = 0;
    _allQuestsBonusGiven = false;
  }

  /// Update quest progress by type
  void updateQuestProgress(String type, {int amount = 1}) {
    bool progressUpdated = false;

    for (var i = 0; i < dailyQuests.length; i++) {
      final quest = dailyQuests[i];
      if (quest.type == type && !quest.isCompleted) {
        final newProgress = min(quest.progress + amount, quest.target);
        if (newProgress != quest.progress) {
          dailyQuests[i] = quest.copyWith(progress: newProgress);
          progressUpdated = true;

          // Check if just completed
          if (dailyQuests[i].isCompleted) {
            dailyQuestsCompleted++;
            learningPoints += quest.rewardPoints;
          }
        }
      }
    }

    // Check if all quests completed for bonus
    if (dailyQuestsCompleted >= 3 && !_allQuestsBonusGiven) {
      _allQuestsBonusGiven = true;
      learningPoints += 20; // Bonus points
      progressUpdated = true;
      // Could trigger a celebration here
    }

    // Always notify when progress changes
    if (progressUpdated) {
      notifyListeners();
    }
  }

  /// Reset daily quests (call when needed)
  void resetDailyQuests() {
    _initDailyQuests();
    notifyListeners();
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
