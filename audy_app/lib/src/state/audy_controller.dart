import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../core/app_strings.dart';
import '../data/models/game_session_model.dart';
import '../data/models/progress_model.dart';
import '../data/repositories/storage_repository.dart';
import '../data/database/database.dart';
import '../data/datasources/local_data_source.dart' show LocalDataSource;
import '../data/repositories/break_settings_repository.dart';
import 'student_break_settings.dart';
import '../features/social_chat/chat_service.dart';
import '../services/auth_service.dart';
import '../services/web_stats_sync.dart';
import '../services/sound_service.dart';
import 'app_settings.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthChangeEvent, AuthState, Supabase;
import '../services/bluetooth_service.dart';
import '../services/gemini_tts_service.dart';
import '../services/speech_service.dart';

// Callbacks for UI notifications
typedef LevelUpCallback = void Function(int newLevel);

enum RewardCondition {
  emotionClassify,
  emotionMimic,
  miniPuzzle,
  sortingGame,
  reactionTime,
  reading,
  socialChat,
}

extension RewardConditionAvailability on RewardCondition {
  bool get isRetired =>
      this == RewardCondition.sortingGame ||
      this == RewardCondition.reactionTime;
}

class UserReward {
  final int id;
  final String? remoteId;
  final String prize;
  final RewardCondition condition;
  final int targetCount;
  final int currentProgress;
  final bool isCompleted;
  final bool isClaimed;
  final DateTime createdAt;

  const UserReward({
    required this.id,
    this.remoteId,
    required this.prize,
    required this.condition,
    required this.targetCount,
    this.currentProgress = 0,
    this.isCompleted = false,
    this.isClaimed = false,
    required this.createdAt,
  });

  UserReward copyWith({
    int? currentProgress,
    bool? isCompleted,
    bool? isClaimed,
  }) {
    return UserReward(
      id: id,
      remoteId: remoteId,
      prize: prize,
      condition: condition,
      targetCount: targetCount,
      currentProgress: currentProgress ?? this.currentProgress,
      isCompleted: isCompleted ?? this.isCompleted,
      isClaimed: isClaimed ?? this.isClaimed,
      createdAt: createdAt,
    );
  }

  double get progressRatio => currentProgress / targetCount;

  bool get isCloudReward => remoteId != null;
}

class SkinVariant {
  final int id;
  final String label;
  final int price;

  const SkinVariant({
    required this.id,
    required this.label,
    required this.price,
  });
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

class AudyController extends ChangeNotifier {
  final StorageRepository? _nativeStorage;
  StorageRepository? _webStorage;
  StorageRepository? get storage => kIsWeb ? _webStorage : _nativeStorage;
  AppDatabase? _webDatabase;
  String? _webAccountId;
  int _webAccountRevision = 0;
  Future<void> _webAccountLoad = Future.value();
  bool isPreparingWebAccount = false;
  String? webStorageMessage;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AuthService _authService;

  // Callbacks for UI notifications
  LevelUpCallback? onLevelUp;

  // Auth state
  UserProfile? _currentUser;
  int _authRevision = 0;
  Future<void>? _logoutPending;
  StreamSubscription<AuthState>? _authSubscription;
  bool get isLoggingOut => _logoutPending != null;
  UserProfile? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  final List<UserProfile> _parentChildren = [];
  List<UserProfile> get parentChildren => List.unmodifiable(_parentChildren);
  String? _selectedParentChildId;
  String? get selectedParentChildId => _selectedParentChildId;
  UserProfile? get selectedParentChild {
    for (final child in _parentChildren) {
      if (child.id == _selectedParentChildId) return child;
    }
    return null;
  }

  bool _isLoadingParentChildren = false;
  bool get isLoadingParentChildren => _isLoadingParentChildren;
  String? _parentChildrenError;
  String? get parentChildrenError => _parentChildrenError;

  final List<UserProfile> _teacherStudents = [];
  List<UserProfile> get teacherStudents => List.unmodifiable(_teacherStudents);
  String? _selectedTeacherStudentId;
  String? get selectedTeacherStudentId => _selectedTeacherStudentId;
  UserProfile? get selectedTeacherStudent {
    for (final student in _teacherStudents) {
      if (student.id == _selectedTeacherStudentId) return student;
    }
    return null;
  }

  bool _isLoadingTeacherStudents = false;
  bool get isLoadingTeacherStudents => _isLoadingTeacherStudents;
  String? _teacherStudentsError;
  String? get teacherStudentsError => _teacherStudentsError;

  // Initialization state for splash screen
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  bool _isDisposed = false;
  final StudentBreakSettings breakSettings;
  AudyController({
    StorageRepository? storage,
    BreakSettingsRepository? breakSettingsRepository,
    AuthService? authService,
  }) : _nativeStorage = storage,
       _authService = authService ?? AuthService(),
       breakSettings = StudentBreakSettings(
         breakSettingsRepository ??
             BreakSettingsRepository(Supabase.instance.client),
       ) {
    breakSettings.addListener(notifyListeners);
    _seedState();
    _initThaiChat();
  }

  /// Initialize the controller - load storage and check auth
  /// Call this during app startup before showing any UI
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      appSettings = await AppSettings.load();
      currentLanguage = appSettings.language;
      SoundService.instance.setEnabled(appSettings.soundEffects);
    } catch (_) {
      // Keep the original defaults if device storage is unavailable.
    }

    // Load local progress first
    await _loadFromStorage();

    // Check for existing Supabase session
    await _initAuth();

    _isInitialized = true;
    notifyListeners();
  }

  /// Initialize auth state from current Supabase session
  Future<void> _initAuth() async {
    // Check for existing session first
    await _loadCurrentUser();

    // Listen for auth state changes
    _authSubscription = _authService.authStateStream.listen((state) async {
      if (state.event == AuthChangeEvent.signedOut) {
        clearUser();
      } else if (state.event == AuthChangeEvent.signedIn &&
          state.session != null) {
        await _loadCurrentUser();
      }
    });
  }

  /// Load current user profile from Supabase
  Future<void> _loadCurrentUser() async {
    if (isLoggingOut) return;
    final revision = _authRevision;
    final profile = await _authService.getCurrentProfile();
    if (!_isDisposed &&
        !isLoggingOut &&
        revision == _authRevision &&
        profile != null) {
      _currentUser = profile;
      breakSettings.useAccount(profile.role == 'child' ? profile.id : null);
      if (kIsWeb) await _prepareWebAccount(profile);
      if (_isDisposed || _currentUser?.id != profile.id) return;
      await _loadRoleData(profile);
      if (!_isDisposed && revision == _authRevision) notifyListeners();
    }
  }

  /// Set user after login (called from LoginPage after successful auth)
  Future<void> setUser(UserProfile profile) async {
    _authRevision++;
    _currentUser = profile;
    breakSettings.useAccount(profile.role == 'child' ? profile.id : null);
    if (kIsWeb) await _prepareWebAccount(profile);
    if (_isDisposed || _currentUser?.id != profile.id) return;
    notifyListeners();
    unawaited(_loadRoleData(profile));
  }

  /// Clear user on logout
  void clearUser() {
    _authRevision++;
    _currentUser = null;
    if (kIsWeb) {
      _webAccountRevision++;
      _webAccountId = null;
      _webStorage = null;
      isPreparingWebAccount = false;
      webStorageMessage = null;
      _resetWebAccountState();
    }
    breakSettings.useAccount(null);
    _parentChildren.clear();
    _selectedParentChildId = null;
    _parentChildrenError = null;
    _teacherStudents.clear();
    _selectedTeacherStudentId = null;
    _teacherStudentsError = null;
    notifyListeners();
  }

  Future<void> _loadRoleData(UserProfile profile) async {
    if (profile.role == 'parent') {
      await loadParentChildren(force: true);
    } else if (profile.role == 'teacher') {
      await loadTeacherStudents(force: true);
    } else if (profile.role == 'child') {
      await breakSettings.refresh();
      if (_isDisposed || _currentUser?.id != profile.id) return;
      await refreshCloudChildData();
    }
  }

  Future<void> loadParentChildren({bool force = false}) async {
    final user = _currentUser;
    if (user == null || user.role != 'parent') return;
    if (_isLoadingParentChildren || (!force && _parentChildren.isNotEmpty)) {
      return;
    }

    _isLoadingParentChildren = true;
    _parentChildrenError = null;
    notifyListeners();

    try {
      final children = await _authService.fetchChildren(user.id);
      children.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      _parentChildren
        ..clear()
        ..addAll(children);

      final selectedStillExists = _parentChildren.any(
        (child) => child.id == _selectedParentChildId,
      );
      if (!selectedStillExists) {
        _selectedParentChildId = _parentChildren.isEmpty
            ? null
            : _parentChildren.first.id;
      }
    } catch (e) {
      _parentChildrenError =
          'Child profiles could not be loaded. Please try again.';
    } finally {
      _isLoadingParentChildren = false;
      notifyListeners();
    }
  }

  void selectParentChild(String childId) {
    if (_selectedParentChildId == childId ||
        !_parentChildren.any((child) => child.id == childId)) {
      return;
    }
    _selectedParentChildId = childId;
    notifyListeners();
  }

  Future<void> loadTeacherStudents({bool force = false}) async {
    final user = _currentUser;
    if (user == null || user.role != 'teacher') return;
    if (_isLoadingTeacherStudents || (!force && _teacherStudents.isNotEmpty)) {
      return;
    }

    _isLoadingTeacherStudents = true;
    _teacherStudentsError = null;
    notifyListeners();

    try {
      final students = await _authService.fetchStudents(user.id);
      students.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      _teacherStudents
        ..clear()
        ..addAll(students);

      final selectedStillExists = _teacherStudents.any(
        (student) => student.id == _selectedTeacherStudentId,
      );
      if (!selectedStillExists) {
        _selectedTeacherStudentId = _teacherStudents.isEmpty
            ? null
            : _teacherStudents.first.id;
      }
    } catch (e) {
      _teacherStudentsError =
          'Student profiles could not be loaded. Please try again.';
    } finally {
      _isLoadingTeacherStudents = false;
      notifyListeners();
    }
  }

  void selectTeacherStudent(String studentId) {
    if (_selectedTeacherStudentId == studentId ||
        !_teacherStudents.any((student) => student.id == studentId)) {
      return;
    }
    _selectedTeacherStudentId = studentId;
    notifyListeners();
  }

  Future<void> refreshCloudChildData() async {
    final user = _currentUser;
    if (user == null || user.role != 'child') return;

    final remoteRewards = await _authService.fetchChildRewards(user.id);
    if (_isDisposed || _currentUser?.id != user.id) return;
    final localRewards = userRewards.where((reward) => !reward.isCloudReward);
    userRewards = [
      ...localRewards,
      ...remoteRewards.indexed.map((entry) {
        final reward = entry.$2;
        return UserReward(
          id: -(entry.$1 + 1),
          remoteId: reward.id,
          prize: reward.prize,
          condition: RewardCondition.values.firstWhere(
            (condition) => condition.name == reward.conditionType,
            orElse: () => RewardCondition.emotionClassify,
          ),
          targetCount: reward.targetCount,
          currentProgress: reward.currentProgress,
          isCompleted: reward.isCompleted,
          isClaimed: reward.isClaimed,
          createdAt: reward.createdAt,
        );
      }),
    ];

    notifyListeners();
  }

  /// Logout the current user
  Future<void> logout() {
    if (_logoutPending != null) return _logoutPending!;
    final completion = Completer<void>();
    _logoutPending = completion.future;
    clearUser();
    unawaited(() async {
      try {
        await _authService.signOut();
        completion.complete();
      } catch (error, stack) {
        completion.completeError(error, stack);
      } finally {
        _logoutPending = null;
        if (!_isDisposed) notifyListeners();
      }
    }());
    return completion.future;
  }

  // User rewards - max 3 active at a time
  late List<UserReward> userRewards;

  List<UserReward> get activeRewards => userRewards
      .where((r) => !r.isCompleted && !r.condition.isRetired)
      .toList();

  List<UserReward> get completedRewards =>
      userRewards.where((r) => r.isCompleted && !r.isClaimed).toList();

  List<UserReward> get claimedRewards =>
      userRewards.where((r) => r.isClaimed).toList();

  bool get canAddReward => activeRewards.length < 3;

  // Level tracking
  int _currentLevel = 0;
  int get currentLevel => _currentLevel;

  // Language settings - default to English
  AppSettings appSettings = const AppSettings();
  String currentLanguage = 'en'; // 'en' or 'th'

  /// Set current language
  void setLanguage(String lang) {
    if (lang != 'en' && lang != 'th') return;
    currentLanguage = lang;
    appSettings = appSettings.copyWith(language: lang);
    unawaited(appSettings.save().catchError((Object _) {}));
    notifyListeners();
  }

  Future<void> saveAppSettings(AppSettings value) async {
    await value.save();
    appSettings = value;
    currentLanguage = value.language;
    SoundService.instance.setEnabled(value.soundEffects);
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

  // ==================== EMOTION CLASSIFY GAME ====================
  late final List<EmotionQuestion> _classifyQuestionPool;
  late List<EmotionQuestion> _classifyQuestions;
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
    await addPoints(isCorrect ? 5 : 0);
    notifyListeners();
  }

  void advanceClassifyRound() {
    _advanceClassifyRoundState();
    notifyListeners();
  }

  void _advanceClassifyRoundState() {
    classifyCurrentRound += 1;
    classifyQuestionIndex =
        (classifyQuestionIndex + 1) % _classifyQuestions.length;
  }

  void resetClassifyGame() {
    classifyCurrentRound = 1;
    classifyScore = 0;
    classifyQuestionIndex = 0;
    _classifyQuestions = _buildShuffledClassifyQuestions();
    classifyFeedback = 'Choose the matching emotion.';
    mimicCurrentRound = 1;
    mimicScore = 0;
    _mimicEmotionIndex = 0;
    _mimicEmotions = _buildShuffledMimicEmotions();
    mimicLastConfidence = 0.0;
    notifyListeners();
  }

  // ==================== EMOTION MIMIC GAME ====================
  static const List<String> _mimicEmotionPool = [
    'Happy',
    'Sad',
    'Surprised',
    'Scared',
    'Angry',
    'Calm',
    'Disgust',
  ];
  late List<String> _mimicEmotions;

  int mimicCurrentRound = 1;
  int mimicTotalRounds = 3;
  int mimicScore = 0;
  int _mimicEmotionIndex = 0;
  double mimicLastConfidence = 0.0;

  String get currentMimicTarget => _mimicEmotions[_mimicEmotionIndex];
  List<String> get mimicEmotionPool => List.unmodifiable(_mimicEmotionPool);

  bool get isMimicGameComplete => mimicCurrentRound > mimicTotalRounds;

  void advanceMimicRound() {
    _advanceMimicRoundState();
    notifyListeners();
  }

  void _advanceMimicRoundState() {
    mimicCurrentRound += 1;
    _mimicEmotionIndex = (_mimicEmotionIndex + 1) % _mimicEmotions.length;
    mimicLastConfidence = 0.0;
  }

  void resetMimicGame() {
    mimicCurrentRound = 1;
    mimicScore = 0;
    _mimicEmotionIndex = 0;
    _mimicEmotions = _buildShuffledMimicEmotions();
    mimicLastConfidence = 0.0;
    notifyListeners();
  }

  void recordMimicResult({required bool isMatch, required double confidence}) {
    _recordMimicResultState(isMatch: isMatch, confidence: confidence);
    notifyListeners();
  }

  void _recordMimicResultState({
    required bool isMatch,
    required double confidence,
  }) {
    mimicLastConfidence = confidence;
    if (isMatch) {
      mimicScore += 1;
    }
  }

  /// Complete one combined emotion round in a single state update.
  ///
  /// Each round consists of classification followed by facial mimicry. Keeping
  /// both counters in lockstep prevents returning to a question that the child
  /// has already completed.
  void completeEmotionRound({
    required bool isMatch,
    required double confidence,
  }) {
    if (isClassifyGameComplete || isMimicGameComplete) return;

    _recordMimicResultState(isMatch: isMatch, confidence: confidence);
    _advanceMimicRoundState();
    _advanceClassifyRoundState();
    notifyListeners();
  }

  /// Track classify game completion
  Future<void> trackClassifyGameCompleted({
    required int durationSeconds,
  }) async {
    gamesPlayed += 1;
    _trackGameInSession();
    _updateRewardProgress(RewardCondition.emotionClassify);
    await _saveProgress();
    notifyListeners();
  }

  /// Track mimic game completion
  Future<void> trackMimicGameCompleted({required int durationSeconds}) async {
    gamesPlayed += 1;
    _trackGameInSession();
    _updateRewardProgress(RewardCondition.emotionMimic);
    await _saveProgress();
    notifyListeners();
  }

  // Retained only for legacy report compatibility; no playable Reaction state.
  final List<int> reactionTimes = [];
  int get reactionAverageMs => reactionTimes.isEmpty
      ? 0
      : reactionTimes.reduce((a, b) => a + b) ~/ reactionTimes.length;

  double socialConfidence = 0.20;
  String socialFeedback = 'Start a conversation with a short message.';

  // Thai Chat Services
  late final SpeechService speechService;
  late final ChatService chatService;
  late final GeminiTTSService geminiTtsService;

  // Thai voice messages
  final List<SocialMessage> thaiSocialMessages = [];

  // Persisted in ProgressData.learningPoints.
  int learningPoints = 0;

  // Persisted in ProgressData.spentLearningPoints.
  int spentLearningPoints = 0;
  int get availableLearningPoints =>
      max(0, learningPoints - spentLearningPoints);

  // Persisted in ProgressData.gamesPlayed.
  int gamesPlayed = 0;

  // Persisted in ProgressData.dayStreak.
  int dayStreak = 1;
  int totalStars = 3;

  // Persisted in ProgressData.puzzleGamesCompleted.
  int puzzleGamesCompleted = 0;

  // Persisted in ProgressData.readingExercisesCompleted.
  int readingExercisesCompleted = 0;

  // Persisted in ProgressData.chatMessagesSent.
  int chatMessagesSent = 0;

  // Persisted in ProgressData.sortingGamesCompleted.
  int sortingGamesCompleted = 0;

  // Persisted in ProgressData.emotionsRecognized.
  int emotionsRecognized = 0;

  // Persisted in ProgressData.gamesInCurrentSession.
  int get gamesInCurrentSession => breakSettings.games;
  set gamesInCurrentSession(int value) => breakSettings.setGames(value);

  // Runtime-only session timestamp. ProgressData persists lastPlayedAt instead.
  DateTime? sessionStartTime;

  int get meltdownThreshold => breakSettings.threshold;
  bool get shouldTriggerMeltdown => gamesInCurrentSession >= meltdownThreshold;
  Future<void> refreshBreakSettings() => breakSettings.refresh();

  /// Reset meltdown state after cooldown completes
  /// Call this when returning from meltdown screen to games
  Future<void> resetMeltdownState() async {
    gamesInCurrentSession = 0;
    sessionStartTime = null;
    notifyListeners();
    // Persist the reset immediately
    await _saveProgress();
  }

  /// Temporary dashboard cheat to bypass meltdown testing.
  Future<void> resetGamesPlayedCheat() async {
    gamesInCurrentSession = 0;
    sessionStartTime = null;
    notifyListeners();
    await _saveProgress();
  }

  // Persisted in ProgressData.sortGameUnlockedLevel.
  // 0 means only the first sorting level is unlocked.
  int sortGameUnlockedLevel = 0;

  // User preferences for autism-related personalization
  UserPreferences userPreferences = const UserPreferences();
  Set<int> ownedSkinIds = {0};
  int selectedSkinId = 0;
  static const int skinPrice = 50;

  static const List<SkinVariant> skinVariants = [
    SkinVariant(id: 0, label: 'Ears off / Arms off / Tummy white', price: 0),
    SkinVariant(id: 1, label: 'All red / Tummy cyan', price: skinPrice),
    SkinVariant(id: 2, label: 'All green / Tummy magenta', price: skinPrice),
    SkinVariant(id: 3, label: 'All blue / Tummy yellow', price: skinPrice),
    SkinVariant(id: 4, label: 'All yellow / Tummy blue', price: skinPrice),
    SkinVariant(id: 5, label: 'All cyan / Tummy red', price: skinPrice),
    SkinVariant(id: 6, label: 'All magenta / Tummy green', price: skinPrice),
    SkinVariant(id: 7, label: 'All white / Tummy off', price: skinPrice),
    SkinVariant(
      id: 8,
      label: 'Ears dim red / Arms green / Tummy yellow',
      price: skinPrice,
    ),
    SkinVariant(
      id: 9,
      label: 'Ears dim green / Arms blue / Tummy blue',
      price: skinPrice,
    ),
    SkinVariant(
      id: 10,
      label: 'Ears dim blue / Arms yellow / Tummy red',
      price: skinPrice,
    ),
    SkinVariant(
      id: 11,
      label: 'Ears dim yellow / Arms cyan / Tummy green',
      price: skinPrice,
    ),
    SkinVariant(
      id: 12,
      label: 'Ears dim cyan / Arms magenta / Tummy off',
      price: skinPrice,
    ),
    SkinVariant(
      id: 13,
      label: 'Ears dim magenta / Arms white / Tummy cyan',
      price: skinPrice,
    ),
    SkinVariant(
      id: 14,
      label: 'Ears dim white / Arms red / Tummy magenta',
      price: skinPrice,
    ),
    SkinVariant(
      id: 15,
      label: 'Split ears / Split arms / Tummy white',
      price: skinPrice,
    ),
    SkinVariant(
      id: 16,
      label: 'Ears split / Arms off / Tummy green',
      price: skinPrice,
    ),
    SkinVariant(
      id: 17,
      label: 'Ears split / Arms off / Tummy white',
      price: skinPrice,
    ),
    SkinVariant(id: 18, label: 'Rainbow', price: skinPrice),
    SkinVariant(id: 19, label: 'All off', price: skinPrice),
  ];

  // ==================== USER REWARDS ====================

  /// Add a new user reward
  Future<void> addReward(
    String prize,
    RewardCondition condition,
    int targetCount,
  ) async {
    if (!canAddReward || condition.isRetired) return;

    final now = DateTime.now();
    final newId = userRewards.isEmpty
        ? 1
        : userRewards.map((r) => r.id).reduce((a, b) => a > b ? a : b) + 1;

    final newReward = UserReward(
      id: newId,
      prize: prize,
      condition: condition,
      targetCount: targetCount,
      createdAt: now,
    );

    userRewards.add(newReward);

    // Save to storage
    if (storage != null) {
      await storage!.addReward(prize, condition.name, targetCount);
    }

    notifyListeners();
  }

  /// Update reward progress when a game is completed
  void _updateRewardProgress(RewardCondition completedCondition) {
    bool progressUpdated = false;

    for (var i = 0; i < userRewards.length; i++) {
      final reward = userRewards[i];
      if (reward.condition == completedCondition && !reward.isCompleted) {
        final newProgress = reward.currentProgress + 1;
        if (newProgress >= reward.targetCount) {
          // Reward completed!
          userRewards[i] = reward.copyWith(
            currentProgress: newProgress,
            isCompleted: true,
          );
        } else {
          userRewards[i] = reward.copyWith(currentProgress: newProgress);
        }
        progressUpdated = true;

        if (reward.remoteId != null) {
          unawaited(
            _authService.updateChildRewardProgress(
              rewardId: reward.remoteId!,
              currentProgress: newProgress,
              isCompleted: newProgress >= reward.targetCount,
            ),
          );
        } else if (storage != null) {
          storage!.updateRewardProgress(reward.id, newProgress);
          if (newProgress >= reward.targetCount) {
            storage!.markRewardCompleted(reward.id);
          }
        }
      }
    }

    if (progressUpdated) {
      notifyListeners();
    }
  }

  /// Claim a completed reward
  Future<void> claimReward(UserReward selectedReward) async {
    final index = userRewards.indexWhere((reward) {
      if (selectedReward.remoteId != null) {
        return reward.remoteId == selectedReward.remoteId;
      }
      return reward.remoteId == null && reward.id == selectedReward.id;
    });
    if (index == -1) return;

    final reward = userRewards[index];
    if (!reward.isCompleted || reward.isClaimed) return;

    userRewards[index] = reward.copyWith(isClaimed: true);

    if (reward.remoteId != null) {
      await _authService.claimChildReward(reward.remoteId!);
    } else if (storage != null) {
      await storage!.claimReward(reward.id);
    }

    notifyListeners();
  }

  /// Delete a reward
  Future<void> deleteReward(int rewardId) async {
    userRewards.removeWhere((r) => r.id == rewardId);

    // Save to storage
    if (storage != null) {
      await storage!.deleteReward(rewardId);
    }

    notifyListeners();
  }

  bool isSkinOwned(int skinId) => ownedSkinIds.contains(skinId);

  Future<bool> buySkin(int skinId) async {
    final variant = _skinVariantForId(skinId);
    if (variant == null) return false;

    if (isSkinOwned(skinId)) {
      return selectSkin(skinId);
    }

    if (availableLearningPoints < variant.price) {
      return false;
    }

    spentLearningPoints += variant.price;
    ownedSkinIds = {...ownedSkinIds, skinId, 0};
    selectedSkinId = skinId;
    userPreferences = userPreferences.copyWith(
      ownedSkinIds: _encodeOwnedSkinIds(),
      selectedSkinId: selectedSkinId,
    );

    await _saveProgress();
    await _saveSkinPreferences();

    notifyListeners();
    return true;
  }

  Future<bool> selectSkin(int skinId) async {
    if (!isSkinOwned(skinId) || _skinVariantForId(skinId) == null) {
      return false;
    }

    selectedSkinId = skinId;
    userPreferences = userPreferences.copyWith(selectedSkinId: skinId);
    await _saveSkinPreferences();

    notifyListeners();
    return true;
  }

  SkinVariant? _skinVariantForId(int skinId) {
    for (final variant in skinVariants) {
      if (variant.id == skinId) return variant;
    }
    return null;
  }

  String _encodeOwnedSkinIds() {
    final ids = ownedSkinIds.toList()..sort();
    return ids.join(',');
  }

  Future<void> _saveSkinPreferences() async {
    if (storage == null) return;

    try {
      await storage!.saveUserPreferences(userPreferences);
    } catch (e) {
      debugPrint('Save skin preferences error: $e');
    }
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

  /// Get real skill trends from database for the past N days
  /// Returns a map of game type to list of daily accuracy values
  Future<Map<String, List<double>>> getRealSkillTrends({
    int daysBack = 7,
  }) async {
    if (storage == null) {
      return {};
    }

    try {
      return await storage!.getSkillTrends(daysBack: daysBack);
    } catch (e) {
      debugPrint('Failed to get skill trends: $e');
      return {};
    }
  }

  Future<ParentAnalyticsData> getParentAnalytics({int daysBack = 7}) async {
    final now = DateTime.now();
    final rangeStart = now.subtract(Duration(days: daysBack));
    final featureTitles = _analyticsFeatureTitles;

    if (storage == null) {
      return ParentAnalyticsData(
        rangeStart: rangeStart,
        rangeEnd: now,
        totalSessions: 0,
        totalMinutes: 0,
        averageScoredAccuracy: null,
        latestSession: null,
        features: _emptyFeatureAnalytics(featureTitles),
        dailyActivityValues: const [],
        recentSessions: const [],
      );
    }

    try {
      final sessions = await storage!.getGameSessions(daysBack: daysBack);
      sessions.sort((a, b) => b.sessionEndedAt.compareTo(a.sessionEndedAt));

      final features = <ParentFeatureAnalytics>[];
      var scoredCorrect = 0;
      var scoredTotal = 0;
      var totalSeconds = 0;

      for (final entry in featureTitles.entries) {
        final typeSessions = sessions
            .where((session) => session.gameType == entry.key)
            .toList();
        final correct = typeSessions.fold<int>(
          0,
          (sum, session) => sum + session.correctActions,
        );
        final total = typeSessions.fold<int>(
          0,
          (sum, session) => sum + session.totalActions,
        );
        final seconds = typeSessions.fold<int>(
          0,
          (sum, session) => sum + session.durationSeconds,
        );

        scoredCorrect += correct;
        scoredTotal += total;
        totalSeconds += seconds;

        features.add(
          ParentFeatureAnalytics(
            gameType: entry.key,
            title: entry.value,
            sessions: typeSessions.length,
            totalSeconds: seconds,
            correctActions: correct,
            totalActions: total,
            latestSessionAt: typeSessions.isEmpty
                ? null
                : typeSessions.first.sessionEndedAt,
          ),
        );
      }

      final recentSessions = sessions
          .take(8)
          .map(_toParentRecentSession)
          .toList();

      return ParentAnalyticsData(
        rangeStart: rangeStart,
        rangeEnd: now,
        totalSessions: sessions.length,
        totalMinutes: (totalSeconds / 60).ceil(),
        averageScoredAccuracy: scoredTotal > 0
            ? scoredCorrect / scoredTotal
            : null,
        latestSession: recentSessions.isEmpty ? null : recentSessions.first,
        features: features,
        dailyActivityValues: _buildDailyActivityValues(sessions, daysBack),
        recentSessions: recentSessions,
      );
    } catch (e) {
      debugPrint('Failed to get parent analytics: $e');
      return ParentAnalyticsData(
        rangeStart: rangeStart,
        rangeEnd: now,
        totalSessions: 0,
        totalMinutes: 0,
        averageScoredAccuracy: null,
        latestSession: null,
        features: _emptyFeatureAnalytics(featureTitles),
        dailyActivityValues: const [],
        recentSessions: const [],
      );
    }
  }

  static const Map<String, String> _analyticsFeatureTitles = {
    'emotion_classify': 'Emotion Classify',
    'emotion_mimic': 'Emotion Mimicking',
    'minipuzzle': 'MiniPuzzle',
    'sorting': 'Sorting',
    'reaction_time': 'Reaction Time',
    'flashcard': 'Flashcard Game',
    'fruit_catching_bear': 'Fruit Catching Bear',
    'reading': 'Read & Speak',
    'social_chat': 'Social Chat',
  };

  List<ParentFeatureAnalytics> _emptyFeatureAnalytics(
    Map<String, String> featureTitles,
  ) {
    return featureTitles.entries
        .map(
          (entry) => ParentFeatureAnalytics(
            gameType: entry.key,
            title: entry.value,
            sessions: 0,
            totalSeconds: 0,
            correctActions: 0,
            totalActions: 0,
          ),
        )
        .toList();
  }

  ParentRecentSession _toParentRecentSession(GameSessionData session) {
    return ParentRecentSession(
      gameType: session.gameType,
      title: _analyticsFeatureTitles[session.gameType] ?? session.gameType,
      endedAt: session.sessionEndedAt,
      durationSeconds: session.durationSeconds,
      correctActions: session.correctActions,
      totalActions: session.totalActions,
      starsEarned: session.starsEarned,
    );
  }

  List<double> _buildDailyActivityValues(
    List<GameSessionData> sessions,
    int daysBack,
  ) {
    if (sessions.isEmpty) return const [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final counts = List<int>.filled(daysBack, 0);

    for (final session in sessions) {
      final sessionDay = DateTime(
        session.sessionStartedAt.year,
        session.sessionStartedAt.month,
        session.sessionStartedAt.day,
      );
      final dayDifference = today.difference(sessionDay).inDays;

      if (dayDifference >= 0 && dayDifference < daysBack) {
        counts[daysBack - dayDifference - 1] += 1;
      }
    }

    final maxCount = counts.reduce(max);
    if (maxCount == 0) return const [];
    return counts.map((count) => count / maxCount).toList();
  }

  /// Generate weekly report data using real database data
  Future<WeeklyReportData> getWeeklyReport() async {
    final now = DateTime.now();
    final weekStart = now.subtract(const Duration(days: 7));

    int totalPlayTimeMinutes = gamesPlayed * 5; // Fallback estimate
    int weeklyGamesPlayed = gamesPlayed;

    if (storage != null) {
      try {
        final sessions = await storage!.getGameSessions(daysBack: 7);
        weeklyGamesPlayed = sessions.length;
        final totalSeconds = await storage!.getTotalPlayTimeSeconds(
          daysBack: 7,
        );
        totalPlayTimeMinutes = (totalSeconds / 60).round();
      } catch (e) {
        debugPrint('Failed to get real play time: $e');
      }
    }

    return WeeklyReportData(
      gamesPlayed: weeklyGamesPlayed,
      pointsEarned: learningPoints,
      currentStreak: dayStreak,
      weekStart: weekStart,
      weekEnd: now,
      skillProgress: skillPercentages,
      totalPlayTimeMinutes: totalPlayTimeMinutes,
    );
  }

  /// Get current child profile data for institution panel
  /// Uses authenticated user data or defaults if not logged in
  ChildProfileData get currentChildProfile {
    final user = _currentUser;
    return ChildProfileData(
      id: user?.id ?? 'child-001',
      name: user?.name ?? 'User',
      age: user?.age ?? 10,
      joinedDate: user?.createdAt ?? DateTime.now(),
      gamesPlayed: gamesPlayed,
      learningPoints: learningPoints,
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
      reportGeneratedAt: DateTime.now(),
    );
  }

  /// Reset progress but keep owned accessories
  Future<void> resetProgress() async {
    learningPoints = 0;
    spentLearningPoints = 0;
    gamesPlayed = 0;
    dayStreak = 1;
    classifyScore = 0;
    mimicScore = 0;
    reactionTimes.clear();
    _currentLevel = 0;
    sortGameUnlockedLevel = 0;

    // Reset in storage
    if (storage != null) {
      await storage!.resetProgress();
    }

    notifyListeners();
  }

  // ==================== STORAGE INTEGRATION ====================

  void _resetWebAccountState() {
    learningPoints = 0;
    spentLearningPoints = 0;
    gamesPlayed = 0;
    dayStreak = 1;
    _currentLevel = _getLevelFromPoints(0);
    puzzleGamesCompleted = 0;
    readingExercisesCompleted = 0;
    sortingGamesCompleted = 0;
    emotionsRecognized = 0;
    chatMessagesSent = 0;
    sortGameUnlockedLevel = 0;
    userRewards = [];
    userPreferences = const UserPreferences();
    ownedSkinIds = {0};
    selectedSkinId = 0;
    thaiSocialMessages.clear();
    _seedThaiMessages();
  }

  Future<void> _prepareWebAccount(UserProfile profile) {
    if (_webAccountId == profile.id) return _webAccountLoad;
    _webAccountId = profile.id;
    final revision = ++_webAccountRevision;
    isPreparingWebAccount = true;
    webStorageMessage = null;
    _webStorage = null;
    _resetWebAccountState();
    notifyListeners();
    final previous = _webAccountLoad;
    _webAccountLoad = () async {
      try {
        await previous;
      } catch (_) {
        /* A failed open must not block the next account. */
      }
      if (_isDisposed || revision != _webAccountRevision) return;
      try {
        await _webDatabase?.close();
      } catch (_) {}
      _webDatabase = null;
      try {
        // UUIDs remain distinct; never reuse the native or anonymous database.
        final name = Uri.encodeComponent(profile.id);
        final database = AppDatabase(
          name: 'audy_web_$name',
          onWebStorageWarning: (message) {
            if (!_isDisposed && revision == _webAccountRevision) {
              webStorageMessage = message;
              notifyListeners();
            }
          },
        );
        _webDatabase = database;
        final repository = StorageRepository(LocalDataSource(database));
        await repository.seedInitialData().timeout(const Duration(seconds: 20));
        if (_isDisposed || revision != _webAccountRevision) return;
        _webStorage = repository;
        await _loadFromStorage();
      } catch (_) {
        if (revision == _webAccountRevision) {
          webStorageMessage =
              'Browser storage is unavailable. Progress on this device may not persist.';
        }
      }
      if (_isDisposed || revision != _webAccountRevision) return;
      if (profile.role == 'child') {
        final stats = await _authService
            .fetchStudentStats(profile.id)
            .timeout(const Duration(seconds: 10), onTimeout: () => null);
        if (_isDisposed || revision != _webAccountRevision) return;
        if (stats != null) {
          learningPoints = max(
            learningPoints,
            (stats['learning_points'] as num?)?.toInt() ?? 0,
          );
          gamesPlayed = max(
            gamesPlayed,
            (stats['games_played'] as num?)?.toInt() ?? 0,
          );
          dayStreak = webDayStreak(stats);
          _currentLevel = _getLevelFromPoints(learningPoints);
          await _saveProgress();
        }
      }
      if (!_isDisposed && revision == _webAccountRevision) {
        isPreparingWebAccount = false;
        notifyListeners();
      }
    }();
    return _webAccountLoad;
  }

  /// Load data from local storage
  /// Loads all progress including learning points and game counters
  Future<void> _loadFromStorage() async {
    final repository = storage;
    if (repository == null) return;

    try {
      // Load progress (keep learning points across sessions)
      final progress = await repository.getProgress();
      if (kIsWeb && repository != storage) return;
      if (progress != null) {
        // ProgressData fields mapped back into controller runtime state.
        learningPoints = progress.learningPoints;
        spentLearningPoints = progress.spentLearningPoints;
        gamesPlayed = progress.gamesPlayed;
        dayStreak = progress.dayStreak;
        _currentLevel = _getLevelFromPoints(learningPoints);

        // Load persisted gameplay counters for progress reporting
        puzzleGamesCompleted = progress.puzzleGamesCompleted;
        readingExercisesCompleted = progress.readingExercisesCompleted;
        sortingGamesCompleted = progress.sortingGamesCompleted;
        emotionsRecognized = progress.emotionsRecognized;
        chatMessagesSent = progress.chatMessagesSent;
        sortGameUnlockedLevel = progress.sortGameUnlockedLevel;

        // Load meltdown session counter
        gamesInCurrentSession = progress.gamesInCurrentSession;

        // Update streak based on last play date
        await _updateDayStreak();
      }

      // Load user preferences
      final prefs = await repository.getUserPreferences();
      if (kIsWeb && repository != storage) return;
      if (prefs != null) {
        userPreferences = prefs;
        ownedSkinIds = prefs.ownedSkinIdSet;
        selectedSkinId = ownedSkinIds.contains(prefs.selectedSkinId)
            ? prefs.selectedSkinId
            : 0;
      }

      // Load user rewards
      final rewardData = await repository.getUserRewards();
      if (kIsWeb && repository != storage) return;
      userRewards = rewardData
          .map(
            (r) => UserReward(
              id: r.id,
              prize: r.prize,
              condition: RewardCondition.values.firstWhere(
                (c) => c.name == r.conditionType,
                orElse: () => RewardCondition.emotionClassify,
              ),
              targetCount: r.targetCount,
              currentProgress: r.currentProgress,
              isCompleted: r.isCompleted,
              isClaimed: r.isClaimed,
              createdAt: r.createdAt,
            ),
          )
          .toList();

      notifyListeners();
    } catch (e) {
      // Ignore storage errors, use defaults
      debugPrint('Storage load error: $e');
    }
  }

  /// Save progress to storage (internal use)
  Future<void> _saveProgress() async {
    if (storage == null) return;

    try {
      await storage!.saveProgress(
        // Controller runtime state persisted through ProgressData.
        ProgressData(
          learningPoints: learningPoints,
          spentLearningPoints: spentLearningPoints,
          gamesPlayed: gamesPlayed,
          dayStreak: dayStreak,
          lastPlayedAt: DateTime.now(),
          puzzleGamesCompleted: puzzleGamesCompleted,
          readingExercisesCompleted: readingExercisesCompleted,
          sortingGamesCompleted: sortingGamesCompleted,
          emotionsRecognized: emotionsRecognized,
          chatMessagesSent: chatMessagesSent,
          sortGameUnlockedLevel: sortGameUnlockedLevel,
          gamesInCurrentSession: gamesInCurrentSession,
        ),
      );
    } catch (e) {
      debugPrint('Storage save error: $e');
    }
  }

  /// Public method to save progress to storage
  /// Used by UI components that need to persist progress changes
  Future<void> saveProgress() async {
    await _saveProgress();
    final user = _currentUser;
    if (user != null) {
      try {
        await _authService.syncStudentStats(
          user.id,
          learningPoints: learningPoints,
          gamesPlayed: gamesPlayed,
          dayStreak: dayStreak,
        );
      } catch (e) {
        debugPrint('Online stats sync error: $e');
      }
    }
    notifyListeners();
  }

  /// Save user preferences to storage
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    if (storage == null) return;

    try {
      userPreferences = preferences.copyWith(
        ownedSkinIds: _encodeOwnedSkinIds(),
        selectedSkinId: selectedSkinId,
      );
      await storage!.saveUserPreferences(userPreferences);
      notifyListeners();
    } catch (e) {
      debugPrint('Save user preferences error: $e');
    }
  }

  /// Record analytics only.
  ///
  /// Progress counters such as gamesPlayed, quests, and meltdown
  /// session count are handled by the trackXCompleted methods.
  Future<void> recordAnalyticsSession(GameSessionData session) async {
    if (storage == null) return;

    try {
      await storage!.saveGameSession(session);
      final user = _currentUser;
      if (user != null) {
        try {
          await _authService.syncStudentStats(
            user.id,
            learningPoints: learningPoints,
            gamesPlayed: gamesPlayed,
            dayStreak: dayStreak,
          );
        } catch (e) {
          debugPrint('Online stats sync error: $e');
        }
        // Per-session analytics for parent/teacher dashboard graphs.
        await _authService.syncGameSession(user.id, session);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to record analytics session: $e');
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

  /// Track puzzle game completion
  Future<void> trackPuzzleCompleted() async {
    puzzleGamesCompleted++;
    gamesPlayed += 1;
    _trackGameInSession();
    _updateRewardProgress(RewardCondition.miniPuzzle);
    await _saveProgress();
    notifyListeners();
  }

  /// Track reading exercise completion
  Future<void> trackReadingCompleted() async {
    readingExercisesCompleted++;
    gamesPlayed += 1;
    _trackGameInSession();
    _updateRewardProgress(RewardCondition.reading);
    await _saveProgress();
    notifyListeners();
  }

  /// Track chat message sent
  Future<void> trackMessageSent() async {
    chatMessagesSent++;
    _updateRewardProgress(RewardCondition.socialChat);
    await _saveProgress();
    notifyListeners();
  }

  /// Track flashcard game completion.
  Future<void> trackFlashcardCompleted() async {
    gamesPlayed += 1;
    _trackGameInSession();
    await _saveProgress();
    notifyListeners();
  }

  /// Track road safety game completion.
  Future<void> trackRoadSafetyCompleted() async {
    gamesPlayed += 1;
    _trackGameInSession();
    await _saveProgress();
    notifyListeners();
  }

  /// Track emotion recognized correctly
  Future<void> trackEmotionRecognized() async {
    emotionsRecognized++;
    await _saveProgress();
    notifyListeners();
  }

  /// Track emotion game completion
  Future<void> trackEmotionGameCompleted({required int durationSeconds}) async {
    gamesPlayed += 1;
    _trackGameInSession();
    await _saveProgress();
    notifyListeners();
  }

  /// Track games in the current session for break protection
  void _trackGameInSession() {
    sessionStartTime ??= DateTime.now();
    gamesInCurrentSession++;
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
  ///
  /// To use Railway backend (default): Just use ApiConfig.baseUrl
  /// To use local backend: Run with --dart-define=USE_LOCAL=true
  String get _backendBaseUrl => ApiConfig.baseUrl;

  /// Initialize Thai chat services
  void _initThaiChat() {
    speechService = SpeechService();
    speechService.init();
    geminiTtsService = GeminiTTSService.instance;
    geminiTtsService.init(fallbackTts: speechService);
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
    final sessionStartedAt = DateTime.now();
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

    // Count the student's accepted message once, independently of the AI reply.
    await trackMessageSent();

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

      // Add points
      await addPoints(2);

      final sessionEndedAt = DateTime.now();
      final durationSeconds = max(
        1,
        sessionEndedAt.difference(sessionStartedAt).inSeconds,
      );
      await recordAnalyticsSession(
        GameSessionData(
          gameType: 'social_chat',
          correctActions: 0,
          totalActions: 0,
          accuracyPercent: 0,
          durationSeconds: durationSeconds,
          sessionStartedAt: sessionStartedAt,
          sessionEndedAt: sessionEndedAt,
        ),
      );

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

  /// Speak bot response (Thai TTS) using Gemini TTS with fallback
  Future<void> speakThaiResponse(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    try {
      await AudyBluetoothService.instance.setEmotion(1);
    } catch (e) {
      debugPrint('Social Chat BLE emotion signal failed: $e');
    }

    await geminiTtsService.speakThai(trimmed);
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

    // Save to storage
    await _saveProgress();

    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    if (kIsWeb) {
      unawaited(_webAccountLoad.whenComplete(() => _webDatabase?.close()));
    }
    _authSubscription?.cancel();
    breakSettings.removeListener(notifyListeners);
    breakSettings.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  List<EmotionQuestion> _buildShuffledClassifyQuestions() {
    final questions = _classifyQuestionPool.map((question) {
      final shuffledOptions = List<String>.from(question.options)
        ..shuffle(_random);
      return EmotionQuestion(
        prompt: question.prompt,
        correctAnswer: question.correctAnswer,
        options: shuffledOptions,
      );
    }).toList()..shuffle(_random);
    return questions;
  }

  List<String> _buildShuffledMimicEmotions() {
    return List<String>.from(_mimicEmotionPool)..shuffle(_random);
  }

  void _seedState() {
    _classifyQuestionPool = const [
      EmotionQuestion(
        prompt: 'What emotion is this?',
        correctAnswer: 'Happy',
        options: ['Happy', 'Sad', 'Angry', 'Scared'],
      ),
      EmotionQuestion(
        prompt: 'How does this person feel?',
        correctAnswer: 'Sad',
        options: ['Happy', 'Sad', 'Angry', 'Scared'],
      ),
      EmotionQuestion(
        prompt: 'Identify this emotion',
        correctAnswer: 'Angry',
        options: ['Happy', 'Sad', 'Angry', 'Scared'],
      ),
      EmotionQuestion(
        prompt: 'What feeling do you see?',
        correctAnswer: 'Scared',
        options: ['Happy', 'Sad', 'Angry', 'Scared'],
      ),
    ];
    _classifyQuestions = _buildShuffledClassifyQuestions();
    _mimicEmotions = _buildShuffledMimicEmotions();

    userRewards = [];
  }
}

class AudyScope extends InheritedNotifier<AudyController> {
  const AudyScope({
    super.key,
    required AudyController controller,
    required super.child,
  }) : super(notifier: controller);

  static AudyController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AudyScope>()?.notifier;

  static AudyController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AudyScope>();
    assert(scope != null, 'AudyScope is missing above this widget.');
    return scope!.notifier!;
  }
}
