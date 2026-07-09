import 'dart:math';

import 'package:flutter/foundation.dart';

import 'flashcard_api_service.dart';
import 'flashcard_models.dart';

/// Extra distractor cards so the hand has more cards than needed.
/// Maps category to extra entries the child must ignore.
const _distractorPool = <String, List<Map<String, String>>>{
  'noun': [
    {'id': 'noun_table', 'en': 'table', 'th': 'โต๊ะ', 'image': 'emoji:🪵'},
    {'id': 'noun_chair', 'en': 'chair', 'th': 'เก้าอี้', 'image': 'emoji:🪑'},
    {'id': 'noun_spoon', 'en': 'spoon', 'th': 'ช้อน', 'image': 'emoji:🥄'},
    {'id': 'noun_glass', 'en': 'glass', 'th': 'แก้ว', 'image': 'emoji:🥛'},
    {'id': 'noun_home', 'en': 'home', 'th': 'บ้าน', 'image': 'emoji:🏠'},
    {'id': 'noun_shop', 'en': 'shop', 'th': 'ร้านค้า', 'image': 'emoji:🏪'},
  ],
  'verb': [
    {'id': 'verb_wash', 'en': 'wash', 'th': 'ล้าง', 'image': 'emoji:🧼'},
    {'id': 'verb_open', 'en': 'open', 'th': 'เปิด', 'image': 'emoji:🔓'},
    {'id': 'verb_close', 'en': 'close', 'th': 'ปิด', 'image': 'emoji:🔒'},
    {'id': 'verb_write', 'en': 'write', 'th': 'เขียน', 'image': 'emoji:📝'},
  ],
  'adjective': [
    {'id': 'adj_hot', 'en': 'hot', 'th': 'ร้อน', 'image': 'emoji:🥵'},
    {'id': 'adj_cold', 'en': 'cold', 'th': 'หนาว', 'image': 'emoji:🥶'},
    {'id': 'adj_sad', 'en': 'sad', 'th': 'เศร้า', 'image': 'emoji:😢'},
  ],
};

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
  FlashcardController({FlashcardApiService? api})
    : _api = api ?? FlashcardApiService();

  static const List<int> wordCounts = [3, 5, 7];

  final FlashcardApiService _api;
  final Random _random = Random();

  FlashcardGamePhase phase = FlashcardGamePhase.loading;
  FlashcardRound? currentRound;
  FlashcardValidation? lastValidation;
  String errorMessage = '';
  int roundIndex = 0;
  int previewIndex = 0;
  int correctRounds = 0;

  final List<FlashcardCard> _handCards = [];
  final List<FlashcardCard> _selectedCards = [];

  List<FlashcardCard> get handCards => List.unmodifiable(_handCards);
  List<FlashcardCard> get selectedCards => List.unmodifiable(_selectedCards);
  int get totalRounds => wordCounts.length;
  int get currentRoundNumber => roundIndex + 1;
  bool get canSubmit =>
      phase == FlashcardGamePhase.playing &&
      _selectedCards.length == (currentRound?.wordCount ?? 0);
  bool get isLastRound => roundIndex >= wordCounts.length - 1;

  FlashcardCard? get previewCard {
    final round = currentRound;
    if (round == null || previewIndex >= round.cards.length) return null;
    return round.cards[previewIndex];
  }

  Future<void> startSession(String language) async {
    roundIndex = 0;
    correctRounds = 0;
    await _loadRound(language);
  }

  Future<void> retry(String language) async {
    await _loadRound(language);
  }

  Future<void> _loadRound(String language) async {
    phase = FlashcardGamePhase.loading;
    errorMessage = '';
    lastValidation = null;
    _handCards.clear();
    _selectedCards.clear();
    previewIndex = 0;
    notifyListeners();

    try {
      currentRound = await _api.generateRound(
        language: language,
        wordCount: wordCounts[roundIndex],
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
      // Add distractor cards so the hand is larger than word count
      _addDistractors(round);
      _handCards.shuffle(_random);
      phase = FlashcardGamePhase.playing;
    } else {
      previewIndex += 1;
    }
    notifyListeners();
  }

  void _addDistractors(FlashcardRound round) {
    final targetIds = round.targetCardIds.toSet();
    final lang = round.language;
    final distractorCount = (round.wordCount <= 3) ? 2 : 3;
    final allDistractors = <FlashcardCard>[];

    for (final entry in _distractorPool.entries) {
      for (final d in entry.value) {
        if (!targetIds.contains(d['id']!)) {
          allDistractors.add(FlashcardCard(
            id: d['id']!,
            category: _categoryFromString(entry.key),
            displayText: lang == 'th' ? d['th']! : d['en']!,
            ttsText: lang == 'th' ? d['th']! : d['en']!,
            imageAsset: d['image']!,
            language: lang,
          ));
        }
      }
    }

    allDistractors.shuffle(_random);
    _handCards.addAll(allDistractors.take(distractorCount));
  }

  static FlashcardCategory _categoryFromString(String value) {
    return FlashcardCategory.values.firstWhere(
      (c) => c.name == value,
      orElse: () => FlashcardCategory.noun,
    );
  }

  void selectCard(FlashcardCard card) {
    if (phase != FlashcardGamePhase.playing) return;
    _handCards.removeWhere((item) => item.id == card.id);
    _selectedCards.add(card);
    notifyListeners();
  }



  void removeSelectedCard(FlashcardCard card) {
    if (phase != FlashcardGamePhase.playing) return;
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
      if (lastValidation?.isCorrect == true) correctRounds++;
      phase = FlashcardGamePhase.feedback;
    } catch (e) {
      errorMessage = 'flashcard_error';
      phase = FlashcardGamePhase.error;
    }
    notifyListeners();
  }

  Future<void> continueAfterFeedback(String language) async {
    if (lastValidation?.isCorrect == true && isLastRound) {
      phase = FlashcardGamePhase.complete;
      notifyListeners();
      return;
    }

    if (lastValidation?.isCorrect == true) {
      roundIndex += 1;
      await _loadRound(language);
      return;
    }

    lastValidation = null;
    phase = FlashcardGamePhase.playing;
    notifyListeners();
  }

  FlashcardValidationStatus? statusForCard(String cardId) {
    final validation = lastValidation;
    if (validation == null) return null;
    for (final result in validation.results) {
      if (result.cardId == cardId) return result.status;
    }
    return null;
  }
}
