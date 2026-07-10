enum FlashcardCategory { noun, pronoun, verb, adverb, adjective, preposition, determiner, conjunction }

enum FlashcardValidationStatus { correct, move, remove }

class FlashcardCard {
  const FlashcardCard({
    required this.id,
    required this.category,
    required this.displayText,
    required this.ttsText,
    required this.imageAsset,
    required this.language,
  });

  final String id;
  final FlashcardCategory category;
  final String displayText;
  final String ttsText;
  final String imageAsset;
  final String language;

  factory FlashcardCard.fromJson(Map<String, dynamic> json) {
    return FlashcardCard(
      id: json['id'] as String,
      category: _categoryFromApi(json['category'] as String),
      displayText: json['display_text'] as String,
      ttsText: json['tts_text'] as String,
      imageAsset: json['image_asset'] as String,
      language: json['language'] as String,
    );
  }
}

class FlashcardRound {
  const FlashcardRound({
    required this.roundId,
    required this.language,
    required this.wordCount,
    required this.sentenceText,
    required this.cards,
    required this.targetCardIds,
  });

  final String roundId;
  final String language;
  final int wordCount;
  final String sentenceText;
  final List<FlashcardCard> cards;
  final List<String> targetCardIds;

  factory FlashcardRound.fromJson(Map<String, dynamic> json) {
    return FlashcardRound(
      roundId: json['round_id'] as String,
      language: json['language'] as String,
      wordCount: json['word_count'] as int,
      sentenceText: json['sentence_text'] as String,
      cards: (json['cards'] as List<dynamic>)
          .map((item) => FlashcardCard.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      targetCardIds: (json['target_card_ids'] as List<dynamic>)
          .map((item) => item as String)
          .toList(growable: false),
    );
  }
}

class FlashcardValidationItem {
  const FlashcardValidationItem({
    required this.cardId,
    required this.status,
    required this.currentIndex,
    this.targetIndex,
  });

  final String cardId;
  final FlashcardValidationStatus status;
  final int currentIndex;
  final int? targetIndex;

  factory FlashcardValidationItem.fromJson(Map<String, dynamic> json) {
    return FlashcardValidationItem(
      cardId: json['card_id'] as String,
      status: _statusFromApi(json['status'] as String),
      currentIndex: json['current_index'] as int,
      targetIndex: json['target_index'] as int?,
    );
  }
}

class FlashcardValidation {
  const FlashcardValidation({
    required this.isCorrect,
    required this.feedback,
    required this.results,
  });

  final bool isCorrect;
  final String feedback;
  final List<FlashcardValidationItem> results;

  factory FlashcardValidation.fromJson(Map<String, dynamic> json) {
    return FlashcardValidation(
      isCorrect: json['is_correct'] as bool,
      feedback: json['feedback'] as String,
      results: (json['results'] as List<dynamic>)
          .map(
            (item) =>
                FlashcardValidationItem.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
    );
  }
}

FlashcardCategory _categoryFromApi(String value) {
  return FlashcardCategory.values.firstWhere(
    (category) => category.name == value,
    orElse: () => FlashcardCategory.noun,
  );
}

FlashcardValidationStatus _statusFromApi(String value) {
  return FlashcardValidationStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => FlashcardValidationStatus.remove,
  );
}
