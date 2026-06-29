import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../features/social_chat/chat_service.dart' show ApiConfig;
import '../features/flashcard_game/flashcard_grammar.dart';
import '../features/flashcard_game/flashcard_levels.dart';
import '../features/flashcard_game/flashcard_models.dart';

/// Result of an AI sentence validation: meaning-equivalent verdict plus the
/// word indices the model flagged as misplaced/wrong (drive the red glow).
class FlashValidation {
  const FlashValidation({
    required this.valid,
    this.errorIndices = const [],
    this.swapIndex,
    this.feedback = '',
  });

  final bool valid;
  final List<int> errorIndices;

  /// The single card the child should move/swap to fix the sentence, if any.
  final int? swapIndex;
  final String feedback;
}

/// HTTP client for the flashcard AI backend (Gemma 4 E4B). Mirrors the pattern
/// of [ChatService]: talks to [ApiConfig.baseUrl], and degrades gracefully to
/// the existing local generators/grammar when the backend is unreachable so the
/// game stays fully playable offline.
class FlashcardAiService {
  FlashcardAiService({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? ApiConfig.baseUrl,
        _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;
  final Random _random = Random();

  static const Duration _timeout = Duration(seconds: 8);

  // word (lowercased) -> emoji / Thai, built once from the existing word pools so
  // AI sentences render the same glyphs and Thai text the local game uses.
  static final Map<String, String> _glyphByWord = _buildLookups().$1;
  static final Map<String, String> _thaiByWord = _buildLookups().$2;

  static (Map<String, String>, Map<String, String>) _buildLookups() {
    final glyphs = <String, String>{};
    final thai = <String, String>{};
    void add(FlashCard c) {
      final key = c.word.toLowerCase();
      if (c.glyph != null) glyphs[key] = c.glyph!;
      if (c.wordTh != null) thai[key] = c.wordTh!;
    }

    FlashWordPool.pronouns.forEach(add);
    FlashWordPool.nouns.forEach(add);
    FlashWordPool.adjectives.forEach(add);
    FlashWordPool.adverbs.forEach(add);
    FlashWordPool.prepositions.forEach(add);
    for (final v in FlashWordPool.verbs) {
      glyphs[v.base.toLowerCase()] = v.glyph;
      glyphs[v.third.toLowerCase()] = v.glyph;
      thai[v.base.toLowerCase()] = v.th;
      thai[v.third.toLowerCase()] = v.th;
    }
    return (glyphs, thai);
  }

  /// Generate a round via the backend; falls back to the local generator.
  Future<FlashRound> generateRound(
    FlashLevel level,
    int roundIndex,
    String lang,
  ) async {
    try {
      final resp = await _client
          .post(
            Uri.parse('$baseUrl/api/flashcard/generate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'difficulty': level.difficulty.name,
              'language': lang,
            }),
          )
          .timeout(_timeout);
      if (resp.statusCode != 200) {
        throw Exception('generate failed: ${resp.statusCode}');
      }
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final round = _roundFromJson(data, level, roundIndex);
      if (round.sentence.isEmpty) throw Exception('empty sentence');
      return round;
    } catch (_) {
      return FlashLevelDefinitions.generateRound(level, _random, roundIndex);
    }
  }

  /// Validate the placed cards. On failure, falls back to local grammar (which
  /// yields a whole-sentence verdict with no per-word flags).
  Future<FlashValidation> validate(
    List<FlashCard> placed,
    String lang, {
    String? context,
  }) async {
    try {
      final resp = await _client
          .post(
            Uri.parse('$baseUrl/api/flashcard/validate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'words': placed.map((c) => c.word).toList(),
              'pos_tags': placed.map((c) => c.pos.name).toList(),
              'target_context': context,
              'language': lang,
            }),
          )
          .timeout(_timeout);
      if (resp.statusCode != 200) {
        throw Exception('validate failed: ${resp.statusCode}');
      }
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final errors = <int>[];
      for (final e in (data['errors'] as List? ?? const [])) {
        final idx = (e is Map) ? e['index'] : null;
        if (idx is int && idx >= 0 && idx < placed.length) errors.add(idx);
      }
      final rawSwap = data['swap_index'];
      final swap = (rawSwap is int && rawSwap >= 0 && rawSwap < placed.length)
          ? rawSwap
          : null;
      return FlashValidation(
        valid: data['valid'] == true,
        errorIndices: errors,
        swapIndex: swap,
        feedback: (data['feedback'] ?? '').toString(),
      );
    } catch (_) {
      final ok = FlashCardGrammar.isGrammatical(placed);
      return FlashValidation(valid: ok);
    }
  }

  FlashRound _roundFromJson(
    Map<String, dynamic> data,
    FlashLevel level,
    int roundIndex,
  ) {
    var counter = 0;
    FlashCard cardFromJson(Map<String, dynamic> j) {
      final word = (j['word'] ?? '').toString();
      final pos = _posFromString((j['pos'] ?? '').toString());
      final glyph =
          (j['glyph'] as String?) ?? _glyphByWord[word.toLowerCase()];
      final wordTh = (j['word_th'] as String?) ?? _thaiByWord[word.toLowerCase()];
      return FlashCard(
        id: 'ai_${roundIndex}_${counter++}',
        word: word,
        pos: pos,
        glyph: glyph,
        wordTh: wordTh,
      );
    }

    List<FlashCard> parseList(dynamic raw) => (raw as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(cardFromJson)
        .where((c) => c.word.isNotEmpty)
        .toList();

    return FlashRound(
      sentence: parseList(data['sentence']),
      distractors: parseList(data['distractors']),
      hint: level.hint,
    );
  }

  PartOfSpeech _posFromString(String s) {
    switch (s.toLowerCase()) {
      case 'noun':
        return PartOfSpeech.noun;
      case 'pronoun':
        return PartOfSpeech.pronoun;
      case 'verb':
        return PartOfSpeech.verb;
      case 'adjective':
        return PartOfSpeech.adjective;
      case 'adverb':
        return PartOfSpeech.adverb;
      case 'preposition':
        return PartOfSpeech.preposition;
      default:
        return PartOfSpeech.noun;
    }
  }

  void dispose() => _client.close();
}
