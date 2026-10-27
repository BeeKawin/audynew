import 'package:audy_app/src/features/flashcard/flashcard_api_service.dart';
import 'package:audy_app/src/features/flashcard/flashcard_controller.dart';
import 'package:audy_app/src/features/flashcard/flashcard_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final difficulty in FlashcardDifficulty.values) {
    test(
      '${difficulty.name} completes three generated and validated rounds',
      () async {
        final controller = FlashcardController(
          difficulty: difficulty,
          api: _CompleteFlashcardApi(),
        );
        await controller.startSession('en');
        for (var round = 0; round < FlashcardController.totalRounds; round++) {
          for (var card = 0; card < difficulty.cardCount; card++) {
            controller.advancePreview();
          }
          for (final id in controller.currentRound!.targetCardIds) {
            controller.selectCard(
              controller.handCards.firstWhere((card) => card.id == id),
            );
          }
          expect(controller.canSubmit, isTrue);
          await controller.submit();
          expect(controller.lastValidation!.isCorrect, isTrue);
          await controller.continueAfterFeedback();
        }
        expect(controller.phase, FlashcardGamePhase.complete);
        expect(controller.sessionCorrectCount, difficulty.cardCount * 3);
        controller.dispose();
      },
    );
  }
  test('reset returns every unlocked selected card to the hand', () async {
    final controller = FlashcardController(
      difficulty: FlashcardDifficulty.easy,
      api: _FakeFlashcardApiService(),
    );

    await controller.startSession('en');
    controller.advancePreview();
    controller.advancePreview();
    controller.advancePreview();

    final cardsToPlace = controller.handCards.take(2).toList();
    for (final card in cardsToPlace) {
      controller.selectCard(card);
    }

    expect(controller.selectedCards, hasLength(2));
    expect(controller.resetUnlockedSelectedCards(), isTrue);
    expect(controller.selectedCards, isEmpty);
    expect(controller.handCards, hasLength(3));
    expect(controller.resetUnlockedSelectedCards(), isFalse);
  });
}

class _CompleteFlashcardApi extends FlashcardApiService {
  @override
  Future<FlashcardRound> generateRound({
    required String language,
    required int wordCount,
    List<Map<String, dynamic>>? customCards,
  }) async {
    final cards = List.generate(
      wordCount,
      (i) => FlashcardCard(
        id: 'card-$i',
        category: FlashcardCategory.noun,
        displayText: 'Word $i',
        ttsText: 'Word $i',
        imageAsset: 'emoji:A',
        language: language,
      ),
    );
    return FlashcardRound(
      roundId: 'round',
      language: language,
      wordCount: wordCount,
      sentenceText: 'Example',
      cards: cards,
      targetCardIds: cards.map((card) => card.id).toList(),
      scenario: 'Example',
    );
  }

  @override
  Future<FlashcardValidation> validateRound({
    required String roundId,
    required String language,
    required List<String> targetCardIds,
    required List<String> selectedCardIds,
    List<Map<String, dynamic>>? customCards,
  }) async => FlashcardValidation(
    isCorrect: true,
    feedback: 'Correct',
    results: List.generate(
      selectedCardIds.length,
      (i) => FlashcardValidationItem(
        cardId: selectedCardIds[i],
        status: FlashcardValidationStatus.correct,
        currentIndex: i,
        targetIndex: i,
      ),
    ),
  );
}

class _FakeFlashcardApiService extends FlashcardApiService {
  @override
  Future<FlashcardRound> generateRound({
    required String language,
    required int wordCount,
    List<Map<String, dynamic>>? customCards,
  }) async {
    const cards = [
      FlashcardCard(
        id: 'left',
        category: FlashcardCategory.noun,
        displayText: 'I',
        ttsText: 'I',
        imageAsset: 'emoji:👧',
        language: 'en',
      ),
      FlashcardCard(
        id: 'middle',
        category: FlashcardCategory.verb,
        displayText: 'like',
        ttsText: 'like',
        imageAsset: 'emoji:❤️',
        language: 'en',
      ),
      FlashcardCard(
        id: 'right',
        category: FlashcardCategory.noun,
        displayText: 'fruit',
        ttsText: 'fruit',
        imageAsset: 'emoji:🍎',
        language: 'en',
      ),
    ];

    return const FlashcardRound(
      roundId: 'round-1',
      language: 'en',
      wordCount: 3,
      sentenceText: 'I like fruit',
      cards: cards,
      targetCardIds: ['left', 'middle', 'right'],
      scenario: 'Make the sentence',
    );
  }
}
