import 'flashcard_models.dart';

/// Agreement-aware grammar recognizer for the flash card sentences.
///
/// Rather than matching a flat list of POS templates, this parses the placed
/// cards against a small feature context-free grammar and enforces real
/// constraints, so only sentences that genuinely *sound correct* pass:
///
///   S        → SubjectNP  VP
///   SubjectNP→ Pronoun | Adjective* Noun
///   VP       → (Adverb)? Verb[agr] (ObjectNP)? (PP)? (Adverb)?   (≤ 1 adverb)
///   ObjectNP → Adjective* Noun
///   PP       → Preposition  ObjectNP
///
/// Key constraint: subject–verb agreement. A 3rd-person-singular subject
/// (He/She/It, singular noun) requires the "-s" verb form ("eats"); I/You/We/
/// They require the base form ("eat"). This rejects "He eat apple" and
/// "They eats apple" while still accepting every valid word ordering, which
/// keeps generated sentences diverse without being sloppy.
class FlashCardGrammar {
  const FlashCardGrammar._();

  static bool isGrammatical(List<FlashCard> tokens) {
    final n = tokens.length;
    if (n < 2) return false;
    for (final subject in _parseSubject(tokens)) {
      for (final end in _parseVP(tokens, subject.$1, subject.$2)) {
        if (end == n) return true;
      }
    }
    return false;
  }

  /// Subject NP starting at 0. Returns (endIndex, isThirdSingular) options.
  static List<(int, bool)> _parseSubject(List<FlashCard> t) {
    final res = <(int, bool)>[];
    if (t.isNotEmpty && t[0].pos == PartOfSpeech.pronoun) {
      res.add((1, t[0].thirdSingular ?? false));
    }
    for (final j in _parseAdjs(t, 0)) {
      if (j < t.length && t[j].pos == PartOfSpeech.noun) {
        res.add((j + 1, t[j].thirdSingular ?? true));
      }
    }
    return res;
  }

  /// Zero or more adjectives from [i]. Returns every reachable end index.
  static List<int> _parseAdjs(List<FlashCard> t, int i) {
    final res = <int>[i];
    var k = i;
    while (k < t.length && t[k].pos == PartOfSpeech.adjective) {
      k++;
      res.add(k);
    }
    return res;
  }

  /// ObjectNP → Adjective* Noun.
  static List<int> _parseObjectNP(List<FlashCard> t, int i) {
    final res = <int>[];
    for (final j in _parseAdjs(t, i)) {
      if (j < t.length && t[j].pos == PartOfSpeech.noun) res.add(j + 1);
    }
    return res;
  }

  /// PP → Preposition ObjectNP.
  static List<int> _parsePP(List<FlashCard> t, int i) {
    if (i >= t.length || t[i].pos != PartOfSpeech.preposition) return const [];
    return _parseObjectNP(t, i + 1);
  }

  /// VP from [i] given the subject's agreement feature. Returns all end indices.
  static Set<int> _parseVP(List<FlashCard> t, int i, bool subjThird) {
    final n = t.length;
    final ends = <int>{};

    for (final preAdv in const [false, true]) {
      var vi = i;
      if (preAdv) {
        if (vi < n && t[vi].pos == PartOfSpeech.adverb) {
          vi++;
        } else {
          continue;
        }
      }
      if (vi >= n || t[vi].pos != PartOfSpeech.verb) continue;
      if ((t[vi].thirdSingular ?? false) != subjThird) continue; // agreement

      final afterVerb = vi + 1;
      for (final takeObject in const [false, true]) {
        final objectEnds =
            takeObject ? _parseObjectNP(t, afterVerb) : <int>[afterVerb];
        for (final k2 in objectEnds) {
          for (final takePP in const [false, true]) {
            final ppEnds = takePP ? _parsePP(t, k2) : <int>[k2];
            for (final k3 in ppEnds) {
              ends.add(k3);
              // Trailing adverb, only if one wasn't used before the verb.
              if (!preAdv && k3 < n && t[k3].pos == PartOfSpeech.adverb) {
                ends.add(k3 + 1);
              }
            }
          }
        }
      }
    }
    return ends;
  }
}
