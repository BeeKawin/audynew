import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../services/auth_service.dart';
import 'flashcard_api_service.dart';
import 'flashcard_models.dart';

enum FlashcardGamePhase {
  loading,
  previewing,
  playing,
  validating,
  feedback,
  complete,
  error,
}

class FlashcardController extends ChangeNotifier {
  FlashcardController({
    required this.difficulty,
    FlashcardApiService? api,
  }) : _api = api ?? FlashcardApiService();

  /// Chosen difficulty. Drives sentence length and hint visibility.
  final FlashcardDifficulty difficulty;

  final FlashcardApiService _api;
  final Random _random = Random();

  /// A session plays this many sentences (rounds) at the chosen difficulty.
  static const int totalRounds = 3;

  FlashcardGamePhase phase = FlashcardGamePhase.loading;
  FlashcardRound? currentRound;
  FlashcardValidation? lastValidation;
  String errorMessage = '';
  int previewIndex = 0;

  /// Current round (0-based) within the session.
  int roundIndex = 0;

  /// Language for the session, captured so later rounds can load themselves.
  String _language = 'en';

  /// Wrong placements in the current round (drives the shake feedback).
  int mistakes = 0;

  /// Wrong placements across the whole session (accuracy / stars).
  int sessionMistakes = 0;

  /// Correctly placed cards across the whole session.
  int sessionCorrect = 0;

  /// Shuffled order in which preview cards are shown, so the preview never
  /// spells out the correct sentence order.
  final List<int> _previewOrder = [];

  final List<FlashcardCard> _handCards = [];
  final List<FlashcardCard> _selectedCards = [];
  final Set<String> _lockedCardIds = {};
  List<Map<String, dynamic>>? _customCards;

  List<FlashcardCard> get handCards => List.unmodifiable(_handCards);
  List<FlashcardCard> get selectedCards => List.unmodifiable(_selectedCards);

  int get cardCount => difficulty.cardCount;

  /// Cards locked into the deck as correct.
  int get lockedCount => _lockedCardIds.length;

  bool isLocked(String cardId) => _lockedCardIds.contains(cardId);

  /// Deck is full when every slot holds a card (locked or not).
  bool get isDeckFull => _selectedCards.length >= cardCount;

  bool get canSubmit =>
      phase == FlashcardGamePhase.playing &&
      isDeckFull &&
      _selectedCards.any((c) => !isLocked(c.id));

  /// Correct cards placed in the current round, out of the sentence length.
  int get correctCount => _lockedCardIds.length;
  int get totalCards => cardCount;

  /// Session-wide totals used for the completion screen and analytics.
  int get sessionCorrectCount => sessionCorrect;
  int get sessionTotalCards => totalRounds * cardCount;

  /// Human round number (1-based) for the header.
  int get roundNumber => roundIndex + 1;

  FlashcardCard? get previewCard {
    final round = currentRound;
    if (round == null || previewIndex >= _previewOrder.length) return null;
    return round.cards[_previewOrder[previewIndex]];
  }

  /// Target card for a given deck slot, used to render placement ghost hints.
  /// Returns null when hints are disabled or the target can't be resolved.
  FlashcardCard? hintCardForSlot(int index) {
    if (!difficulty.showHints) return null;
    final round = currentRound;
    if (round == null) return null;
    if (index < 0 || index >= round.targetCardIds.length) return null;
    final targetId = round.targetCardIds[index];
    for (final card in round.cards) {
      if (card.id == targetId) return card;
    }
    return null;
  }

  Future<void> startSession(String language, {String? teacherId}) async {
    _language = language;
    roundIndex = 0;
    sessionMistakes = 0;
    sessionCorrect = 0;
    _customCards = null;

    if (teacherId != null && teacherId.isNotEmpty) {
      try {
        final words = await AuthService().fetchClassWords(teacherId);
        _customCards = words.map((w) => {
          'id': w.id,
          'category': w.category ?? 'noun',
          'word': w.word,
          'image_url': w.imageUrl,
        }).toList();
      } catch (e) {
        debugPrint('Failed to load custom class cards: $e');
      }
    }

    await _loadRound();
  }

  Future<void> retry(String language) async {
    _language = language;
    await _loadRound();
  }

  Future<void> _loadRound() async {
    phase = FlashcardGamePhase.loading;
    errorMessage = '';
    lastValidation = null;
    mistakes = 0;
    _handCards.clear();
    _selectedCards.clear();
    _lockedCardIds.clear();
    _previewOrder.clear();
    previewIndex = 0;
    notifyListeners();

    try {
      final round = await _api.generateRound(
        language: _language,
        wordCount: difficulty.cardCount,
        customCards: _customCards,
      );
      currentRound = round;
      // Preview cards in a random order so the sequence isn't the answer.
      _previewOrder
        ..clear()
        ..addAll(List<int>.generate(round.cards.length, (i) => i)..shuffle(_random));
      phase = FlashcardGamePhase.previewing;
    } catch (e) {
      errorMessage = 'flashcard_error';
      phase = FlashcardGamePhase.error;
    }
    notifyListeners();
  }

  void advancePreview() {
    final round = currentRound;
    if (round == null || phase != FlashcardGamePhase.previewing) return;

    if (previewIndex + 1 >= round.cards.length) {
      _handCards
        ..clear()
        ..addAll(round.cards);
      _handCards.shuffle(_random);
      phase = FlashcardGamePhase.playing;
    } else {
      previewIndex += 1;
    }
    notifyListeners();
  }

  /// Tap a hand card to move it into the first open deck slot.
  void selectCard(FlashcardCard card) {
    if (phase != FlashcardGamePhase.playing) return;
    if (isDeckFull) return;
    _handCards.removeWhere((item) => item.id == card.id);
    _selectedCards.add(card);
    notifyListeners();
  }

  /// Tap a placed (non-locked) card to send it back to the hand.
  void removeSelectedCard(FlashcardCard card) {
    if (phase != FlashcardGamePhase.playing) return;
    if (isLocked(card.id)) return;
    _selectedCards.removeWhere((item) => item.id == card.id);
    _handCards.add(card);
    notifyListeners();
  }

  /// Return every unlocked card to the hand so the player can reorder them.
  bool resetUnlockedSelectedCards() {
    if (phase != FlashcardGamePhase.playing) return false;

    final cardsToReset = _selectedCards
        .where((card) => !isLocked(card.id))
        .toList(growable: false);
    if (cardsToReset.isEmpty) return false;

    final resetIds = cardsToReset.map((card) => card.id).toSet();
    _selectedCards.removeWhere((card) => resetIds.contains(card.id));
    _handCards.addAll(cardsToReset);
    notifyListeners();
    return true;
  }

  Future<void> submit() async {
    final round = currentRound;
    if (round == null || _selectedCards.isEmpty) return;

    phase = FlashcardGamePhase.validating;
    notifyListeners();

    try {
      lastValidation = await _api.validateRound(
        roundId: round.roundId,
        language: round.language,
        targetCardIds: round.targetCardIds,
        selectedCardIds: _selectedCards.map((card) => card.id).toList(),
        customCards: _customCards,
      );
      phase = FlashcardGamePhase.feedback;
    } catch (e) {
      errorMessage = 'flashcard_error';
      phase = FlashcardGamePhase.error;
    }
    notifyListeners();
  }

  /// After feedback: lock the correct cards in place, bounce the rest back to
  /// the hand for another try. When every card is locked, advance to the next
  /// round — or complete the session after [totalRounds].
  Future<void> continueAfterFeedback() async {
    final validation = lastValidation;
    if (validation == null) return;

    final wrongCards = <FlashcardCard>[];
    for (final result in validation.results) {
      if (result.status == FlashcardValidationStatus.correct) {
        _lockedCardIds.add(result.cardId);
      } else {
        final idx = _selectedCards.indexWhere((c) => c.id == result.cardId);
        if (idx != -1) {
          wrongCards.add(_selectedCards[idx]);
        }
      }
    }

    if (wrongCards.isNotEmpty) {
      mistakes += wrongCards.length;
      sessionMistakes += wrongCards.length;
      _selectedCards.removeWhere(
        (c) => wrongCards.any((w) => w.id == c.id),
      );
      _handCards.addAll(wrongCards);
    }

    lastValidation = null;

    if (_lockedCardIds.length >= cardCount) {
      sessionCorrect += cardCount;
      if (roundIndex < totalRounds - 1) {
        roundIndex += 1;
        await _loadRound();
      } else {
        phase = FlashcardGamePhase.complete;
        notifyListeners();
      }
    } else {
      phase = FlashcardGamePhase.playing;
      notifyListeners();
    }
  }

  FlashcardValidationStatus? statusForCard(String cardId) {
    if (_lockedCardIds.contains(cardId)) {
      return FlashcardValidationStatus.correct;
    }
    final validation = lastValidation;
    if (validation == null) return null;
    for (final result in validation.results) {
      if (result.cardId == cardId) return result.status;
    }
    return null;
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }
}
