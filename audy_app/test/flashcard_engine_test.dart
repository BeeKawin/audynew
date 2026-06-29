import 'package:flutter_test/flutter_test.dart';
import 'package:audy_app/src/features/flashcard_game/flashcard_engine.dart';
import 'package:audy_app/src/features/flashcard_game/flashcard_levels.dart';
import 'package:audy_app/src/features/flashcard_game/flashcard_models.dart';
import 'package:audy_app/src/services/flashcard_ai_service.dart';

/// Fake AI service returning a fixed 2-card round and a scripted verdict, so the
/// engine can be tested without any network.
class _FakeAi extends FlashcardAiService {
  _FakeAi(this.verdict);

  final FlashValidation verdict;

  static const _he = FlashCard(
      id: 'he', word: 'He', pos: PartOfSpeech.pronoun, thirdSingular: true);
  static const _eats = FlashCard(
      id: 'eats', word: 'Eats', pos: PartOfSpeech.verb, thirdSingular: true);

  @override
  Future<FlashRound> generateRound(
          FlashLevel level, int roundIndex, String lang) async =>
      const FlashRound(
        sentence: [_he, _eats],
        distractors: [],
        hint: SlotHint.full,
      );

  @override
  Future<FlashValidation> validate(List<FlashCard> placed, String lang,
          {String? context}) async =>
      verdict;
}

/// Flush pending microtasks/timers so async _loadRound / submit settle.
Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 1));

void main() {
  final level = FlashLevelDefinitions.levelForDifficulty(FlashDifficulty.easy);

  test('clearAllSlots returns every placed card to the hand', () async {
    final engine =
        FlashCardEngine(aiService: _FakeAi(const FlashValidation(valid: true)));
    engine.startSession(level);
    await _settle();

    expect(engine.slots.length, 2);
    // Place both hand cards into the rail.
    engine.placeFromHand(engine.hand.first.id, 0);
    engine.placeFromHand(engine.hand.first.id, 1);
    expect(engine.hasPlacedCards, isTrue);
    expect(engine.hand, isEmpty);

    engine.clearAllSlots();
    expect(engine.hasPlacedCards, isFalse);
    expect(engine.slots.every((s) => s == null), isTrue);
    expect(engine.hand.length, 2);

    engine.dispose();
  });

  test('submit surfaces AI word-level error indices on a wrong answer',
      () async {
    final engine = FlashCardEngine(
      aiService: _FakeAi(
        const FlashValidation(valid: false, errorIndices: [1]),
      ),
    );
    engine.startSession(level);
    await _settle();

    engine.placeFromHand(engine.hand.first.id, 0);
    engine.placeFromHand(engine.hand.first.id, 1);

    await engine.submit();

    expect(engine.isCorrect, isFalse);
    expect(engine.errorIndices, [1]);
    expect(engine.hasVerdict, isTrue);

    // completeFeedback on a wrong answer clears feedback for a retry.
    engine.completeFeedback();
    expect(engine.showingFeedback, isFalse);
    expect(engine.errorIndices, isEmpty);

    engine.dispose();
  });

  test('correct submit awards stars and advances after completeFeedback',
      () async {
    final engine =
        FlashCardEngine(aiService: _FakeAi(const FlashValidation(valid: true)));
    engine.startSession(level);
    await _settle();

    engine.placeFromHand(engine.hand.first.id, 0);
    engine.placeFromHand(engine.hand.first.id, 1);
    await engine.submit();

    expect(engine.isCorrect, isTrue);
    expect(engine.totalStars, 3); // first try, no wrong attempts

    engine.completeFeedback();
    await _settle();
    expect(engine.roundNumber, 2); // advanced to next round

    engine.dispose();
  });
}
