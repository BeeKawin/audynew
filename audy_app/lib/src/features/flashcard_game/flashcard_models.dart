import 'package:flutter/material.dart';

import '../../core/audy_theme.dart';

/// Part of speech for a flash card. Drives color coding and grammar validation.
enum PartOfSpeech { noun, pronoun, verb, adjective, adverb, preposition }

extension PartOfSpeechX on PartOfSpeech {
  /// Soft, distinct color per category (reuses / extends the app palette).
  Color get color {
    switch (this) {
      case PartOfSpeech.noun:
        return AudyColors.skyBlue;
      case PartOfSpeech.verb:
        return AudyColors.mintGreen;
      case PartOfSpeech.adjective:
        return AudyColors.softLavender;
      case PartOfSpeech.pronoun:
        return AudyColors.blushPink;
      case PartOfSpeech.adverb:
        return const Color(0xFFB39DDB); // soft purple
      case PartOfSpeech.preposition:
        return const Color(0xFF80CBC4); // soft teal
    }
  }

  /// Localization key for the category label shown on the card / ghost slot.
  String get labelKey {
    switch (this) {
      case PartOfSpeech.noun:
        return 'pos_noun';
      case PartOfSpeech.pronoun:
        return 'pos_pronoun';
      case PartOfSpeech.verb:
        return 'pos_verb';
      case PartOfSpeech.adjective:
        return 'pos_adjective';
      case PartOfSpeech.adverb:
        return 'pos_adverb';
      case PartOfSpeech.preposition:
        return 'pos_preposition';
    }
  }
}

/// Difficulty level for the flash card game.
/// Higher levels have longer sentences, more distractor cards, fewer hints.
enum FlashDifficulty { easy, medium, hard }

/// How much placement help the player gets in the sentence rail.
enum SlotHint {
  full, // Ghost POS label clearly shown in each slot.
  dim, // Faint POS label.
  none, // Empty numbered slots, free placement.
}

/// A single draggable flash card: a word tagged with its part of speech plus
/// grammatical features used for agreement-aware validation.
class FlashCard {
  const FlashCard({
    required this.id,
    required this.word,
    required this.pos,
    this.glyph,
    this.thirdSingular,
    this.lemma,
  });

  final String id;
  final String word;
  final PartOfSpeech pos;

  /// Optional emoji shown as the word's picture. Null → word-only card.
  final String? glyph;

  /// Number/person agreement feature.
  /// - Pronoun / Noun: true if the subject takes a 3rd-person-singular verb
  ///   (He/She/It, and singular nouns); false for I/You/We/They.
  /// - Verb: true if this is the "-s" 3rd-singular form ("eats"), false if base
  ///   ("eat").
  /// - Other POS: null (irrelevant).
  final bool? thirdSingular;

  /// Verb lemma id grouping base/-s forms (e.g. 'eat' for both eat/eats).
  final String? lemma;

  Color get color => pos.color;
}

/// A single round: cards dealt for one sentence, generated fresh (randomized)
/// each round so sentences never repeat.
class FlashRound {
  const FlashRound({
    required this.sentence,
    required this.distractors,
    required this.hint,
  });

  /// The target cards in a valid order (drives ghost slot hints + slot count).
  final List<FlashCard> sentence;

  /// Extra wrong cards mixed into the hand.
  final List<FlashCard> distractors;

  final SlotHint hint;

  /// Number of slots in the sentence rail.
  int get length => sentence.length;

  /// POS order of the target, used for ghost-slot hints.
  List<PartOfSpeech> get structure => sentence.map((c) => c.pos).toList();

  /// All cards dealt into the hand for this round (target + distractors).
  List<FlashCard> get dealtCards => [...sentence, ...distractors];

  /// Max stars a player can earn this round (3 = solved first try).
  int get maxStars => 3;
}

/// A difficulty level. Rounds are generated dynamically from grammar templates
/// + [distractorCount] each play (no fixed authored sentences).
class FlashLevel {
  const FlashLevel({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.primaryColor,
    required this.instructionKey,
    required this.roundCount,
    required this.distractorCount,
    required this.hint,
  });

  final String id;
  final String name;
  final FlashDifficulty difficulty;
  final Color primaryColor;
  final String instructionKey;
  final int roundCount;
  final int distractorCount;
  final SlotHint hint;

  int get totalRounds => roundCount;
  int get maxStars => roundCount * 3;
}

/// Per-round outcome, kept for the result screen and analytics.
class FlashRoundResult {
  const FlashRoundResult({
    required this.roundIndex,
    required this.wrongAttempts,
    required this.starsEarned,
  });

  final int roundIndex;
  final int wrongAttempts;
  final int starsEarned;
}

/// Complete session summary for the result screen + analytics recording.
class FlashSessionData {
  const FlashSessionData({
    required this.levelId,
    required this.levelName,
    required this.difficulty,
    required this.roundResults,
    required this.totalStars,
    required this.maxStars,
    required this.correctSubmits,
    required this.wrongSubmits,
    required this.completionStatus,
    required this.sessionStartedAt,
    required this.sessionEndedAt,
  });

  final String levelId;
  final String levelName;
  final String difficulty;
  final List<FlashRoundResult> roundResults;
  final int totalStars;
  final int maxStars;
  final int correctSubmits;
  final int wrongSubmits;

  /// 'completed' or 'abandoned'.
  final String completionStatus;
  final DateTime sessionStartedAt;
  final DateTime sessionEndedAt;

  int get totalActions => correctSubmits + wrongSubmits;
}
