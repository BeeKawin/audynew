import 'package:audy_app/src/features/flashcard/flashcard_api_service.dart';
import 'package:audy_app/src/features/flashcard/flashcard_controller.dart';
import 'package:audy_app/src/features/flashcard/flashcard_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
