import 'dart:convert';

enum CaretakerGame { socialChat, flashcard, miniPuzzle, emotion, fruitCatch }

extension CaretakerGameKey on CaretakerGame {
  String get key => const [
    'social_chat',
    'flashcard',
    'minipuzzle',
    'emotion',
    'fruit_catching_bear',
  ][index];
  String get title => const [
    'Social Chat',
    'FlashCard',
    'MiniPuzzle',
    'Emotion',
    'Fruit Catch',
  ][index];
}

/// An immutable snapshot. Editors use a deep copy; previews never own a save API.
class GameConfiguration {
  GameConfiguration(this.game, Map<String, dynamic> values)
    : _encoded = jsonEncode(values);
  final CaretakerGame game;
  final String _encoded;
  Map<String, dynamic> toJson() => jsonDecode(_encoded) as Map<String, dynamic>;
  factory GameConfiguration.defaults(CaretakerGame game) =>
      GameConfiguration(game, switch (game) {
        CaretakerGame.socialChat => {
          'input_mode': 'text_and_voice',
          'reply_speech': 'automatic',
          'listen_seconds': 30,
          'pause_seconds': 3,
          'starter_phrases': <String>[],
        },
        CaretakerGame.flashcard => {
          'difficulty': 'child_choice',
          'language': 'app',
          'preview_pace': '2_seconds',
          'auto_speak': true,
          'use_custom_cards': false,
          'custom_cards': <dynamic>[],
        },
        CaretakerGame.miniPuzzle => {
          'enabled_types': ['pattern', 'oddOneOut', 'puzzle'],
          'pattern_difficulty': 'child_choice',
          'odd_one_out_difficulty': 'child_choice',
          'puzzle_difficulty': 'child_choice',
          'advance_mode': 'automatic_900ms',
          'show_guide': true,
        },
        CaretakerGame.emotion => {
          'target_emotions': ['happy', 'sad', 'angry', 'scared'],
          'choice_count': 4,
          'round_count': 3,
          'image_mode': 'varied',
          'advance_mode': 'automatic_1500ms',
          'show_guide': true,
        },
        CaretakerGame.fruitCatch => {
          'fall_speed': 'standard',
          'spawn_interval_ms': 900,
          'bomb_probability': 0.2,
          'bomb_grace_count': 2,
          'duration_seconds': null,
          'fruit_ids': ['4', '5', '6', '7', '8', '9'],
          'show_guide': true,
        },
      });

  List<String> validate() {
    final v = toJson();
    final errors = <String>[];
    final expectedKeys = GameConfiguration.defaults(game).toJson().keys.toSet();
    if (v.keys.any((key) => !expectedKeys.contains(key))) {
      errors.add('These settings need a newer app version.');
    }
    void choice(String field, List<dynamic> allowed) {
      final value = v[field];
      final integerOnly =
          allowed.whereType<int>().isNotEmpty &&
          allowed.whereType<double>().isEmpty;
      if (!v.containsKey(field) ||
          !allowed.contains(value) ||
          (integerOnly && value != null && value is! int)) {
        errors.add('Invalid $field');
      }
    }

    void subset(String field, List<String> allowed, int minimum) {
      final items = v[field];
      if (items is! List ||
          items.length < minimum ||
          items.toSet().length != items.length ||
          items.any((x) => !allowed.contains(x))) {
        errors.add('Choose valid $field');
      }
    }

    void flag(String field) {
      if (v[field] is! bool) errors.add('Invalid $field');
    }

    const levels = ['child_choice', 'easy', 'medium', 'hard'];
    switch (game) {
      case CaretakerGame.socialChat:
        choice('input_mode', ['text_and_voice', 'text_only']);
        choice('reply_speech', ['automatic', 'on_tap']);
        choice('listen_seconds', [15, 30, 45]);
        choice('pause_seconds', [3, 5, 8]);
        final phrases = v['starter_phrases'];
        if (phrases is! List ||
            phrases.length > 6 ||
            phrases.any(
              (x) =>
                  x is! String ||
                  x.trim().isEmpty ||
                  x.length > 80 ||
                  x != x.trim(),
            ) ||
            phrases.toSet().length != phrases.length) {
          errors.add('Use up to six unique starter phrases (1–80 characters).');
        }
      case CaretakerGame.flashcard:
        choice('difficulty', levels);
        choice('language', ['app', 'en', 'th']);
        choice('preview_pace', [
          '2_seconds',
          '3_seconds',
          '5_seconds',
          'manual',
        ]);
        flag('auto_speak');
        flag('use_custom_cards');
        final cards = v['custom_cards'];
        if (cards is! List || cards.length > 20) {
          errors.add('Use up to 20 custom cards.');
          break;
        }
        final ids = <String>{};
        final words = <String>{};
        for (final card in cards) {
          if (card is! Map ||
              card['id'] is! String ||
              (card['id'] as String).isEmpty ||
              !ids.add(card['id'] as String) ||
              card['word'] is! String ||
              (card['word'] as String).trim().isEmpty ||
              (card['word'] as String).length > 40 ||
              ![
                'noun',
                'pronoun',
                'verb',
                'adjective',
                'adverb',
              ].contains(card['category']) ||
              !words.add(
                '${card['category']}:${card['word'].toString().trim().toLowerCase()}',
              )) {
            errors.add(
              'Each card needs a unique ID, word (1–40 characters), and word type.',
            );
            continue;
          }
          final image = card['image_url'];
          if (image != null && image is! String) {
            errors.add('Invalid card image.');
            continue;
          }
          if (image is String && image.isNotEmpty) {
            if (image.startsWith('data:image/jpeg;base64,') ||
                image.startsWith('data:image/png;base64,')) {
              try {
                if (base64Decode(image.split(',').last).length > 131072) {
                  errors.add('Card pictures must be at most 128 KiB.');
                }
              } catch (_) {
                errors.add('Invalid card image.');
              }
            } else if (!RegExp(
              r'^assets/images/games/flashcard/[a-zA-Z0-9_/-]+\.png$',
            ).hasMatch(image)) {
              errors.add('Choose a bundled picture or upload a picture.');
            }
          }
        }
        if (v['use_custom_cards'] == true && cards.isEmpty) {
          errors.add('Add a card before enabling custom cards.');
        }
      case CaretakerGame.miniPuzzle:
        subset('enabled_types', ['pattern', 'oddOneOut', 'puzzle'], 1);
        for (final field in [
          'pattern_difficulty',
          'odd_one_out_difficulty',
          'puzzle_difficulty',
        ]) {
          choice(field, levels);
        }
        choice('advance_mode', [
          'automatic_900ms',
          'automatic_1800ms',
          'manual',
        ]);
        flag('show_guide');
      case CaretakerGame.emotion:
        subset('target_emotions', ['happy', 'sad', 'angry', 'scared'], 2);
        choice('choice_count', [2, 4]);
        choice('round_count', [1, 3, 5]);
        choice('image_mode', ['varied', 'consistent']);
        choice('advance_mode', [
          'automatic_1500ms',
          'automatic_3000ms',
          'manual',
        ]);
        flag('show_guide');
        if (v['target_emotions'] is List &&
            v['choice_count'] is int &&
            (v['target_emotions'] as List).length <
                (v['choice_count'] as int)) {
          errors.add('Select at least as many emotions as answer choices.');
        }
      case CaretakerGame.fruitCatch:
        choice('fall_speed', ['slow', 'standard', 'fast']);
        choice('spawn_interval_ms', [900, 1200, 1500]);
        choice('bomb_probability', [0, 0.1, 0.2]);
        choice('bomb_grace_count', [2, 5, 10]);
        choice('duration_seconds', [null, 30, 60, 120]);
        subset('fruit_ids', ['4', '5', '6', '7', '8', '9'], 1);
        flag('show_guide');
        if (v['bomb_probability'] == 0 && v['duration_seconds'] == null) {
          errors.add('Choose a session duration when bombs are disabled.');
        }
    }
    if (utf8.encode(_encoded).length > 2097152) {
      errors.add('Configuration must be at most 2 MiB.');
    }
    return errors;
  }
}

class SavedGameConfiguration {
  const SavedGameConfiguration(
    this.config,
    this.revision, {
    this.schemaVersion = 1,
  });
  final GameConfiguration config;
  final int revision;
  final int schemaVersion;
  bool get editable => schemaVersion == 1;
}

class SocialChatConfig extends GameConfiguration {
  SocialChatConfig(Map<String, dynamic> values)
    : super(CaretakerGame.socialChat, values);
}

class FlashcardConfig extends GameConfiguration {
  FlashcardConfig(Map<String, dynamic> values)
    : super(CaretakerGame.flashcard, values);
}

class MiniPuzzleCustomizationConfig extends GameConfiguration {
  MiniPuzzleCustomizationConfig(Map<String, dynamic> values)
    : super(CaretakerGame.miniPuzzle, values);
}

class EmotionConfig extends GameConfiguration {
  EmotionConfig(Map<String, dynamic> values)
    : super(CaretakerGame.emotion, values);
}

class FruitCatchConfig extends GameConfiguration {
  FruitCatchConfig(Map<String, dynamic> values)
    : super(CaretakerGame.fruitCatch, values);
}
