import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:audy_app/src/features/flashcard_game/flashcard_grammar.dart';
import 'package:audy_app/src/features/flashcard_game/flashcard_levels.dart';
import 'package:audy_app/src/features/flashcard_game/flashcard_models.dart';

FlashCard _card(PartOfSpeech pos, {bool? third}) => FlashCard(
      id: '${pos.name}_${third ?? ''}',
      word: pos.name,
      pos: pos,
      thirdSingular: third,
    );

void main() {
  group('FlashCardGrammar agreement', () {
    test('He + Eats (3sg) is valid; He + Eat is not', () {
      final he = _card(PartOfSpeech.pronoun, third: true);
      final eats = _card(PartOfSpeech.verb, third: true);
      final eat = _card(PartOfSpeech.verb, third: false);
      expect(FlashCardGrammar.isGrammatical([he, eats]), isTrue);
      expect(FlashCardGrammar.isGrammatical([he, eat]), isFalse);
    });

    test('They + Eat (base) is valid; They + Eats is not', () {
      final they = _card(PartOfSpeech.pronoun, third: false);
      final eats = _card(PartOfSpeech.verb, third: true);
      final eat = _card(PartOfSpeech.verb, third: false);
      expect(FlashCardGrammar.isGrammatical([they, eat]), isTrue);
      expect(FlashCardGrammar.isGrammatical([they, eats]), isFalse);
    });
  });

  group('FlashCardGrammar structures', () {
    final he = _card(PartOfSpeech.pronoun, third: true);
    final eats = _card(PartOfSpeech.verb, third: true);
    final adj = _card(PartOfSpeech.adjective);
    final noun = _card(PartOfSpeech.noun, third: true);
    final adv = _card(PartOfSpeech.adverb);
    final prep = _card(PartOfSpeech.preposition);

    test('object + adverb + preposition shapes parse', () {
      expect(FlashCardGrammar.isGrammatical([he, eats, adj, noun]), isTrue);
      expect(FlashCardGrammar.isGrammatical([he, eats, adv]), isTrue);
      expect(FlashCardGrammar.isGrammatical([he, eats, prep, noun]), isTrue);
      expect(FlashCardGrammar.isGrammatical([he, eats, adj, noun, adv]), isTrue);
      expect(FlashCardGrammar.isGrammatical([he, adv, eats]), isTrue); // pre-verb adverb
    });

    test('garbage orderings are rejected', () {
      expect(FlashCardGrammar.isGrammatical([noun, adj]), isFalse); // "noun adjective"
      expect(FlashCardGrammar.isGrammatical([eats, he]), isFalse); // verb-first
      expect(FlashCardGrammar.isGrammatical([he, adj, noun]), isFalse); // no verb
      expect(FlashCardGrammar.isGrammatical([prep, noun]), isFalse); // PP alone
    });
  });

  test('every generated round is grammatical (1000 samples/difficulty)', () {
    final random = Random(42);
    for (final level in FlashLevelDefinitions.allLevels()) {
      for (var i = 0; i < 1000; i++) {
        final round = FlashLevelDefinitions.generateRound(level, random, i);
        expect(
          FlashCardGrammar.isGrammatical(round.sentence),
          isTrue,
          reason: '${level.difficulty} sample $i: '
              '${round.sentence.map((c) => "${c.word}(${c.pos.name})").join(" ")}',
        );
        expect(round.sentence.length, greaterThanOrEqualTo(2));
      }
    }
  });
}
