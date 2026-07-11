import 'dart:math';

import 'package:flutter/foundation.dart';

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

  FlashcardGamePhase phase = FlashcardGamePhase.loading;
  FlashcardRound? currentRound;
  FlashcardValidation? lastValidation;
  String errorMessage = '';
  int previewIndex = 0;

  /// Number of wrong placements across the session (used for accuracy/stars).
  int mistakes = 0;

  final List<FlashcardCard> _handCards = [];
  final List<FlashcardCard> _selectedCards = [];
  final Set<String> _lockedCardIds = {};

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

  /// How many correct cards the player placed, out of the sentence length.
  int get correctCount => _lockedCardIds.length;
  int get totalCards => cardCount;

  FlashcardCard? get previewCard {
    final round = currentRound;
    if (round == null || previewIndex >= round.cards.length) return null;
    return round.cards[previewIndex];
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

  Future<void> startSession(String language) async {
    await _loadRound(language);
  }

  Future<void> retry(String language) async {
    await _loadRound(language);
  }

  Future<void> _loadRound(String language) async {
    phase = FlashcardGamePhase.loading;
    errorMessage = '';
    lastValidation = null;
    mistakes = 0;
    _handCards.clear();
    _selectedCards.clear();
    _lockedCardIds.clear();
    previewIndex = 0;
    notifyListeners();

    try {
      currentRound = await _api.generateRound(
        language: language,
        wordCount: difficulty.cardCount,
      );
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
      );
      phase = FlashcardGamePhase.feedback;
    } catch (e) {
      errorMessage = 'flashcard_error';
      phase = FlashcardGamePhase.error;
    }
    notifyListeners();
  }

  /// After feedback: lock the correct cards in place, bounce the rest back to
  /// the hand for another try. Completes when every card is locked.
  void continueAfterFeedback() {
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
      _selectedCards.removeWhere(
        (c) => wrongCards.any((w) => w.id == c.id),
      );
      _handCards.addAll(wrongCards);
    }

    lastValidation = null;

    if (_lockedCardIds.length >= cardCount) {
      phase = FlashcardGamePhase.complete;
    } else {
      phase = FlashcardGamePhase.playing;
    }
    notifyListeners();
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
