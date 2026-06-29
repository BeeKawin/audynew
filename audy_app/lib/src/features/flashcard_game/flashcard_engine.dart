import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../services/flashcard_ai_service.dart';
import '../sorting_game/sort_game_engine.dart' show ABAGameFeedback;
import 'flashcard_levels.dart';
import 'flashcard_models.dart';

/// Core flash-card game engine: deals cards, tracks the sentence rail, runs
/// AI-backed validation (with local fallback), and manages round/session
/// progression.
/// Mirrors the [ChangeNotifier] + AnimatedBuilder pattern used by the sorting game.
class FlashCardEngine extends ChangeNotifier {
  FlashCardEngine({
    FlashcardAiService? aiService,
    String Function()? languageProvider,
  })  : _aiService = aiService ?? FlashcardAiService(),
        _languageProvider = languageProvider ?? (() => 'en');

  final FlashcardAiService _aiService;
  final String Function() _languageProvider;

  final Random _random = Random();

  FlashLevel? _level;
  int _roundIndex = 0;
  FlashRound? _round;

  final List<FlashCard> _hand = [];
  List<FlashCard?> _slots = [];

  int _wrongAttemptsThisRound = 0;
  int _correctSubmits = 0;
  int _wrongSubmits = 0;
  int _totalStars = 0;
  final List<FlashRoundResult> _roundResults = [];

  bool _showingFeedback = false;
  bool _isCorrect = false;
  List<int> _errorIndices = const [];
  String _feedbackKey = '';
  bool _roundComplete = false;
  bool _sessionComplete = false;
  bool _loading = false;

  DateTime? _sessionStart;
  DateTime? _sessionEnd;

  // ─── Public state ───
  FlashLevel? get level => _level;
  int get roundIndex => _roundIndex;
  int get roundNumber => _roundIndex + 1;
  int get totalRounds => _level?.totalRounds ?? 0;
  List<FlashCard> get hand => List.unmodifiable(_hand);
  List<FlashCard?> get slots => List.unmodifiable(_slots);
  SlotHint get hint => _round?.hint ?? SlotHint.none;
  bool get showingFeedback => _showingFeedback;
  bool get isCorrect => _isCorrect;

  /// Slot indices the validator flagged as wrong (drive the red glow). Empty on
  /// a correct answer, or when running on the local fallback (no per-word data).
  List<int> get errorIndices => List.unmodifiable(_errorIndices);

  /// True while a round is being generated (AI round-trip) — show a loader.
  bool get loading => _loading;

  /// True once the validator returned a verdict (vs. still evaluating).
  bool get hasVerdict => _showingFeedback && _feedbackKey.isNotEmpty;

  /// Any card currently placed in the rail (enables the Clear Answer button).
  bool get hasPlacedCards => _slots.any((s) => s != null);

  String get feedbackKey => _feedbackKey;
  bool get roundComplete => _roundComplete;
  bool get sessionComplete => _sessionComplete;
  int get totalStars => _totalStars;
  int get maxStars => _level?.maxStars ?? 0;

  /// The POS order of the drawn target, used to drive ghost slot hints.
  List<PartOfSpeech> get hintPattern => _round?.structure ?? const [];

  /// Current round's dealt cards (target + distractors) — for deal animation.
  FlashRound? get round => _round;

  bool get canSubmit =>
      _slots.isNotEmpty &&
      _slots.every((s) => s != null) &&
      !_showingFeedback &&
      !_loading;

  List<FlashLevel> getLevels() => FlashLevelDefinitions.allLevels();

  void startSession(FlashLevel level) {
    _level = level;
    _roundIndex = 0;
    _correctSubmits = 0;
    _wrongSubmits = 0;
    _totalStars = 0;
    _roundResults.clear();
    _sessionComplete = false;
    _sessionStart = DateTime.now();
    _sessionEnd = null;
    _loadRound();
  }

  Future<void> _loadRound() async {
    _loading = true;
    _hand.clear();
    _slots = [];
    _showingFeedback = false;
    _isCorrect = false;
    _errorIndices = const [];
    _feedbackKey = '';
    _roundComplete = false;
    notifyListeners();

    final round = await _aiService.generateRound(
      _level!,
      _roundIndex,
      _languageProvider(),
    );

    // Guard against a session reset/dispose landing mid-request.
    if (_level == null) return;

    _round = round;
    _hand
      ..clear()
      ..addAll(round.dealtCards.toList()..shuffle(_random));
    _slots = List<FlashCard?>.filled(round.length, null);
    _wrongAttemptsThisRound = 0;
    _loading = false;
    notifyListeners();
  }

  // ─── Card movement ───
  void placeFromHand(String cardId, int slotIndex) {
    if (_showingFeedback) return;
    final idx = _hand.indexWhere((c) => c.id == cardId);
    if (idx < 0) return;
    final card = _hand.removeAt(idx);
    final occupant = _slots[slotIndex];
    if (occupant != null) _hand.add(occupant);
    _slots[slotIndex] = card;
    notifyListeners();
  }

  void moveBetweenSlots(int fromSlot, int toSlot) {
    if (_showingFeedback || fromSlot == toSlot) return;
    final a = _slots[fromSlot];
    final b = _slots[toSlot];
    _slots[toSlot] = a;
    _slots[fromSlot] = b;
    notifyListeners();
  }

  void returnToHand(int fromSlot) {
    if (_showingFeedback) return;
    final card = _slots[fromSlot];
    if (card == null) return;
    _slots[fromSlot] = null;
    _hand.add(card);
    notifyListeners();
  }

  /// Clear Answer: return every placed card to the hand in one action.
  void clearAllSlots() {
    if (_showingFeedback || _loading) return;
    var changed = false;
    for (var i = 0; i < _slots.length; i++) {
      final card = _slots[i];
      if (card != null) {
        _slots[i] = null;
        _hand.add(card);
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  // ─── Validation (AI meaning-equivalence + per-word flags, local fallback) ───
  /// Runs validation and records scoring, then leaves [showingFeedback] true so
  /// the screen can play the left→right speak + glow sequence. The screen calls
  /// [completeFeedback] when that sequence finishes to advance or retry.
  Future<void> submit() async {
    if (!canSubmit) return;
    final cards = _slots.map((s) => s!).toList();

    // Lock the rail while the verdict is pending (feedbackKey stays empty so no
    // overlay shows until [hasVerdict] is true).
    _showingFeedback = true;
    _isCorrect = false;
    _errorIndices = const [];
    _feedbackKey = '';
    notifyListeners();

    final result = await _aiService.validate(
      cards,
      _languageProvider(),
      context: _level?.difficulty.name,
    );
    if (_level == null) return;

    _isCorrect = result.valid;
    _errorIndices = result.errorIndices;

    if (result.valid) {
      _correctSubmits++;
      _feedbackKey = ABAGameFeedback.getPositiveMessageKey();
      final stars = _starsFor(_wrongAttemptsThisRound);
      _totalStars += stars;
      _roundResults.add(
        FlashRoundResult(
          roundIndex: _roundIndex,
          wrongAttempts: _wrongAttemptsThisRound,
          starsEarned: stars,
        ),
      );
    } else {
      _wrongSubmits++;
      _wrongAttemptsThisRound++;
      _feedbackKey = ABAGameFeedback.getCorrectionMessageKey();
    }
    notifyListeners();
  }

  /// Called by the screen after the feedback animation finishes: advance to the
  /// next round on a correct answer, or clear feedback to let the child retry.
  void completeFeedback() {
    if (!_showingFeedback) return;
    if (_isCorrect) {
      _advanceAfterCorrect();
    } else {
      _showingFeedback = false;
      _errorIndices = const [];
      _feedbackKey = '';
      notifyListeners();
    }
  }

  int _starsFor(int wrongAttempts) {
    if (wrongAttempts == 0) return 3;
    if (wrongAttempts == 1) return 2;
    return 1;
  }

  void _advanceAfterCorrect() {
    if (_roundIndex + 1 >= totalRounds) {
      _finishSession();
      return;
    }
    _roundIndex++;
    _loadRound();
  }

  void _finishSession() {
    _sessionComplete = true;
    _sessionEnd = DateTime.now();
    notifyListeners();
  }

  FlashSessionData getSessionData() {
    return FlashSessionData(
      levelId: _level?.id ?? 'unknown',
      levelName: _level?.name ?? 'Unknown',
      difficulty: _level?.difficulty.name ?? 'unknown',
      roundResults: List.from(_roundResults),
      totalStars: _totalStars,
      maxStars: maxStars,
      correctSubmits: _correctSubmits,
      wrongSubmits: _wrongSubmits,
      completionStatus: _sessionComplete ? 'completed' : 'abandoned',
      sessionStartedAt: _sessionStart ?? DateTime.now(),
      sessionEndedAt: _sessionEnd ?? DateTime.now(),
    );
  }

  void reset() {
    _level = null;
    _roundIndex = 0;
    _round = null;
    _hand.clear();
    _slots = [];
    _wrongAttemptsThisRound = 0;
    _correctSubmits = 0;
    _wrongSubmits = 0;
    _totalStars = 0;
    _roundResults.clear();
    _showingFeedback = false;
    _isCorrect = false;
    _errorIndices = const [];
    _feedbackKey = '';
    _roundComplete = false;
    _sessionComplete = false;
    _loading = false;
    _sessionStart = null;
    _sessionEnd = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _aiService.dispose();
    super.dispose();
  }
}
