import 'dart:math';

import '../../core/audy_theme.dart';
import 'flashcard_models.dart';

const _n = PartOfSpeech.noun;
const _p = PartOfSpeech.pronoun;
const _v = PartOfSpeech.verb;
const _a = PartOfSpeech.adjective;
const _adv = PartOfSpeech.adverb;
const _prep = PartOfSpeech.preposition;

/// A verb lemma with both agreement forms.
class FlashVerb {
  const FlashVerb(this.lemma, this.base, this.third, this.glyph, this.th);
  final String lemma;
  final String base; // I/You/We/They form
  final String third; // He/She/It form
  final String glyph;
  final String th; // Thai display (no conjugation in Thai)
}

/// Word pools per part of speech. Rounds draw randomly so sentences vary every
/// play. Subjects and verbs carry agreement features so generated targets are
/// always grammatical.
class FlashWordPool {
  const FlashWordPool._();

  static const List<FlashCard> pronouns = [
    FlashCard(id: 'he', word: 'He', pos: _p, glyph: '🧒', thirdSingular: true, wordTh: 'เขา'),
    FlashCard(id: 'she', word: 'She', pos: _p, glyph: '👧', thirdSingular: true, wordTh: 'เธอ'),
    FlashCard(id: 'it', word: 'It', pos: _p, glyph: '🧸', thirdSingular: true, wordTh: 'มัน'),
    FlashCard(id: 'they', word: 'They', pos: _p, glyph: '👫', thirdSingular: false, wordTh: 'พวกเขา'),
    FlashCard(id: 'we', word: 'We', pos: _p, glyph: '👨‍👩‍👧', thirdSingular: false, wordTh: 'เรา'),
    FlashCard(id: 'i', word: 'I', pos: _p, glyph: '🙋', thirdSingular: false, wordTh: 'ฉัน'),
  ];

  static const List<FlashVerb> verbs = [
    FlashVerb('eat', 'Eat', 'Eats', '🍴', 'กิน'),
    FlashVerb('run', 'Run', 'Runs', '🏃', 'วิ่ง'),
    FlashVerb('see', 'See', 'Sees', '👀', 'เห็น'),
    FlashVerb('play', 'Play', 'Plays', '🎮', 'เล่น'),
    FlashVerb('sleep', 'Sleep', 'Sleeps', '😴', 'นอน'),
    FlashVerb('hold', 'Hold', 'Holds', '🤝', 'ถือ'),
    FlashVerb('read', 'Read', 'Reads', '📖', 'อ่าน'),
    FlashVerb('jump', 'Jump', 'Jumps', '🤸', 'กระโดด'),
    FlashVerb('sit', 'Sit', 'Sits', '🪑', 'นั่ง'),
    FlashVerb('sing', 'Sing', 'Sings', '🎵', 'ร้องเพลง'),
  ];

  static const List<FlashCard> nouns = [
    FlashCard(id: 'apple', word: 'Apple', pos: _n, glyph: '🍎', thirdSingular: true, wordTh: 'แอปเปิล'),
    FlashCard(id: 'ball', word: 'Ball', pos: _n, glyph: '⚽', thirdSingular: true, wordTh: 'ลูกบอล'),
    FlashCard(id: 'dog', word: 'Dog', pos: _n, glyph: '🐶', thirdSingular: true, wordTh: 'หมา'),
    FlashCard(id: 'cat', word: 'Cat', pos: _n, glyph: '🐱', thirdSingular: true, wordTh: 'แมว'),
    FlashCard(id: 'car', word: 'Car', pos: _n, glyph: '🚗', thirdSingular: true, wordTh: 'รถ'),
    FlashCard(id: 'bird', word: 'Bird', pos: _n, glyph: '🐦', thirdSingular: true, wordTh: 'นก'),
    FlashCard(id: 'cake', word: 'Cake', pos: _n, glyph: '🍰', thirdSingular: true, wordTh: 'เค้ก'),
    FlashCard(id: 'fish', word: 'Fish', pos: _n, glyph: '🐟', thirdSingular: true, wordTh: 'ปลา'),
    FlashCard(id: 'box', word: 'Box', pos: _n, glyph: '📦', thirdSingular: true, wordTh: 'กล่อง'),
    FlashCard(id: 'bed', word: 'Bed', pos: _n, glyph: '🛏️', thirdSingular: true, wordTh: 'เตียง'),
    FlashCard(id: 'tree', word: 'Tree', pos: _n, glyph: '🌳', thirdSingular: true, wordTh: 'ต้นไม้'),
    FlashCard(id: 'park', word: 'Park', pos: _n, glyph: '🏞️', thirdSingular: true, wordTh: 'สวน'),
  ];

  static const List<FlashCard> adjectives = [
    FlashCard(id: 'blue', word: 'Blue', pos: _a, glyph: '🔵', wordTh: 'สีน้ำเงิน'),
    FlashCard(id: 'red', word: 'Red', pos: _a, glyph: '🔴', wordTh: 'สีแดง'),
    FlashCard(id: 'big', word: 'Big', pos: _a, glyph: '🟦', wordTh: 'ใหญ่'),
    FlashCard(id: 'small', word: 'Small', pos: _a, glyph: '🤏', wordTh: 'เล็ก'),
    FlashCard(id: 'happy', word: 'Happy', pos: _a, glyph: '😊', wordTh: 'มีความสุข'),
    FlashCard(id: 'fast', word: 'Fast', pos: _a, glyph: '⚡', wordTh: 'เร็ว'),
    FlashCard(id: 'hot', word: 'Hot', pos: _a, glyph: '🔥', wordTh: 'ร้อน'),
    FlashCard(id: 'cold', word: 'Cold', pos: _a, glyph: '❄️', wordTh: 'เย็น'),
  ];

  static const List<FlashCard> adverbs = [
    FlashCard(id: 'quickly', word: 'Quickly', pos: _adv, glyph: '💨', wordTh: 'อย่างรวดเร็ว'),
    FlashCard(id: 'slowly', word: 'Slowly', pos: _adv, glyph: '🐌', wordTh: 'อย่างช้า ๆ'),
    FlashCard(id: 'happily', word: 'Happily', pos: _adv, glyph: '😄', wordTh: 'อย่างมีความสุข'),
    FlashCard(id: 'quietly', word: 'Quietly', pos: _adv, glyph: '🤫', wordTh: 'อย่างเงียบ ๆ'),
    FlashCard(id: 'loudly', word: 'Loudly', pos: _adv, glyph: '📢', wordTh: 'อย่างดัง'),
    FlashCard(id: 'softly', word: 'Softly', pos: _adv, glyph: '🍃', wordTh: 'อย่างนุ่มนวล'),
  ];

  static const List<FlashCard> prepositions = [
    FlashCard(id: 'in', word: 'In', pos: _prep, glyph: '📥', wordTh: 'ใน'),
    FlashCard(id: 'on', word: 'On', pos: _prep, glyph: '🔝', wordTh: 'บน'),
    FlashCard(id: 'under', word: 'Under', pos: _prep, glyph: '🔽', wordTh: 'ใต้'),
    FlashCard(id: 'near', word: 'Near', pos: _prep, glyph: '📍', wordTh: 'ใกล้'),
    FlashCard(id: 'behind', word: 'Behind', pos: _prep, glyph: '🚪', wordTh: 'ข้างหลัง'),
    FlashCard(id: 'by', word: 'By', pos: _prep, glyph: '🧱', wordTh: 'ข้าง'),
  ];

  static List<FlashCard> simplePool(PartOfSpeech pos) {
    switch (pos) {
      case _n:
        return nouns;
      case _a:
        return adjectives;
      case _adv:
        return adverbs;
      case _prep:
        return prepositions;
      case _p:
        return pronouns;
      case _v:
        return const []; // verbs handled via agreement
    }
  }
}

/// All flash card levels. Three difficulties, all selectable from the start.
class FlashLevelDefinitions {
  static List<FlashLevel> allLevels() => const [_easy, _medium, _hard];

  static FlashLevel levelForDifficulty(FlashDifficulty difficulty) =>
      allLevels().firstWhere((l) => l.difficulty == difficulty);

  /// VP "tails" (POS after the verb) per difficulty. Every tail is grammatical
  /// per [FlashCardGrammar]; variety here drives sentence diversity.
  static const Map<FlashDifficulty, List<List<PartOfSpeech>>> _tails = {
    FlashDifficulty.easy: [
      [],
      [_adv],
      [_n],
    ],
    FlashDifficulty.medium: [
      [_a, _n],
      [_prep, _n],
      [_n, _adv],
    ],
    FlashDifficulty.hard: [
      [_a, _a, _n],
      [_a, _n, _adv],
      [_prep, _a, _n],
      [_a, _n, _prep, _n],
    ],
  };

  /// Generate a fresh, randomized, grammatical round for [level].
  static FlashRound generateRound(
    FlashLevel level,
    Random random,
    int roundIndex,
  ) {
    final usedIds = <String>{};
    var counter = 0;

    FlashCard tag(FlashCard base) {
      return FlashCard(
        id: '${base.id}_${roundIndex}_${counter++}',
        word: base.word,
        pos: base.pos,
        glyph: base.glyph,
        thirdSingular: base.thirdSingular,
        lemma: base.lemma,
        wordTh: base.wordTh,
      );
    }

    FlashCard drawSimple(PartOfSpeech pos) {
      final pool = FlashWordPool.simplePool(pos);
      FlashCard base;
      do {
        base = pool[random.nextInt(pool.length)];
      } while (usedIds.contains(base.id) && usedIds.length < pool.length);
      usedIds.add(base.id);
      return tag(base);
    }

    FlashCard drawVerb(bool thirdSingular) {
      final v = FlashWordPool.verbs[random.nextInt(FlashWordPool.verbs.length)];
      usedIds.add(v.lemma);
      return tag(FlashCard(
        id: v.lemma,
        word: thirdSingular ? v.third : v.base,
        pos: _v,
        glyph: v.glyph,
        thirdSingular: thirdSingular,
        lemma: v.lemma,
        wordTh: v.th,
      ));
    }

    // 1. Subject (pronoun, or adj? + noun in hard) — sets agreement.
    final sentence = <FlashCard>[];
    final useNounSubject =
        level.difficulty == FlashDifficulty.hard && random.nextBool();
    final bool third;
    if (useNounSubject) {
      final noun = drawSimple(_n);
      sentence.add(noun);
      third = noun.thirdSingular ?? true;
    } else {
      final pron = drawSimple(_p);
      sentence.add(pron);
      third = pron.thirdSingular ?? false;
    }

    // 2. Verb in the agreeing form.
    sentence.add(drawVerb(third));

    // 3. A random grammatical tail.
    final tails = _tails[level.difficulty]!;
    final tail = tails[random.nextInt(tails.length)];
    for (final pos in tail) {
      sentence.add(drawSimple(pos));
    }

    // 4. Distractors: random cards (incl. a wrong-agreement verb sometimes).
    final distractors = <FlashCard>[];
    const distractorPos = [_p, _a, _adv, _prep, _n];
    for (var i = 0; i < level.distractorCount; i++) {
      if (random.nextInt(4) == 0) {
        distractors.add(drawVerb(!third)); // tempting wrong-agreement verb
      } else {
        distractors.add(drawSimple(distractorPos[random.nextInt(distractorPos.length)]));
      }
    }

    return FlashRound(
      sentence: sentence,
      distractors: distractors,
      hint: level.hint,
    );
  }

  static const _easy = FlashLevel(
    id: 'flash_easy',
    name: 'Easy',
    difficulty: FlashDifficulty.easy,
    primaryColor: AudyColors.mintGreen,
    instructionKey: 'flashcard_instruction_easy',
    roundCount: 4,
    distractorCount: 0,
    hint: SlotHint.full,
  );

  static const _medium = FlashLevel(
    id: 'flash_medium',
    name: 'Medium',
    difficulty: FlashDifficulty.medium,
    primaryColor: AudyColors.warning,
    instructionKey: 'flashcard_instruction_medium',
    roundCount: 4,
    distractorCount: 1,
    hint: SlotHint.dim,
  );

  static const _hard = FlashLevel(
    id: 'flash_hard',
    name: 'Hard',
    difficulty: FlashDifficulty.hard,
    primaryColor: AudyColors.error,
    instructionKey: 'flashcard_instruction_hard',
    roundCount: 5,
    distractorCount: 2,
    hint: SlotHint.none,
  );
}
