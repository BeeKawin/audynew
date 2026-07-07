enum FlashcardDifficulty {
  easy('easy', 3),
  medium('medium', 5),
  hard('hard', 7);

  const FlashcardDifficulty(this.apiValue, this.wordCount);

  final String apiValue;
  final int wordCount;
}

enum FlashcardCategory {
  noun,
  pronoun,
  verb,
  adverb,
  adjective;

  static FlashcardCategory fromJson(String value) {
    return FlashcardCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => FlashcardCategory.noun,
    );
  }
}

enum FlashcardValidationStatus {
  correct,
  swap,
  remove;

  static FlashcardValidationStatus fromJson(String value) {
    return FlashcardValidationStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => FlashcardValidationStatus.remove,
    );
  }
}

class FlashcardWord {
  const FlashcardWord({
    required this.id,
    required this.category,
    required this.en,
    required this.th,
  });

  final String id;
  final FlashcardCategory category;
  final String en;
  final String th;

  String labelFor(String language) => language == 'th' ? th : en;

  factory FlashcardWord.fromJson(Map<String, dynamic> json) {
    return FlashcardWord(
      id: json['id'] as String,
      category: FlashcardCategory.fromJson(json['category'] as String),
      en: json['en'] as String,
      th: json['th'] as String,
    );
  }
}

class FlashcardSession {
  const FlashcardSession({
    required this.sessionId,
    required this.language,
    required this.difficulty,
    required this.wordCount,
    required this.sentenceText,
    required this.targetCardIds,
    required this.handCards,
  });

  final String sessionId;
  final String language;
  final FlashcardDifficulty difficulty;
  final int wordCount;
  final String sentenceText;
  final List<String> targetCardIds;
  final List<FlashcardWord> handCards;

  factory FlashcardSession.fromJson(Map<String, dynamic> json) {
    final difficultyValue = json['difficulty'] as String;
    return FlashcardSession(
      sessionId: json['session_id'] as String,
      language: json['language'] as String,
      difficulty: FlashcardDifficulty.values.firstWhere(
        (difficulty) => difficulty.apiValue == difficultyValue,
        orElse: () => FlashcardDifficulty.easy,
      ),
      wordCount: json['word_count'] as int,
      sentenceText: json['sentence_text'] as String,
      targetCardIds: (json['target_card_ids'] as List<dynamic>).cast<String>(),
      handCards: (json['hand_cards'] as List<dynamic>)
          .map((item) => FlashcardWord.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class FlashcardCardFeedback {
  const FlashcardCardFeedback({required this.cardId, required this.status});

  final String cardId;
  final FlashcardValidationStatus status;

  factory FlashcardCardFeedback.fromJson(Map<String, dynamic> json) {
    return FlashcardCardFeedback(
      cardId: json['card_id'] as String,
      status: FlashcardValidationStatus.fromJson(json['status'] as String),
    );
  }
}

class FlashcardValidationResult {
  const FlashcardValidationResult({
    required this.isValid,
    required this.feedback,
    required this.message,
    required this.correctedCardIds,
  });

  final bool isValid;
  final List<FlashcardCardFeedback> feedback;
  final String message;
  final List<String> correctedCardIds;

  factory FlashcardValidationResult.fromJson(Map<String, dynamic> json) {
    return FlashcardValidationResult(
      isValid: json['is_valid'] as bool,
      feedback: (json['feedback'] as List<dynamic>)
          .map(
            (item) =>
                FlashcardCardFeedback.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      message: json['message'] as String,
      correctedCardIds: ((json['corrected_card_ids'] as List<dynamic>?) ?? [])
          .cast<String>(),
    );
  }
}
