import 'dart:convert';
import 'package:audy_app/src/data/models/game_configuration.dart';
import 'package:audy_app/src/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final game in CaretakerGame.values) {
    test('${game.key} defaults validate and survive JSON roundtrip', () {
      final config = GameConfiguration.defaults(game);
      expect(config.validate(), isEmpty);
      expect(
        GameConfiguration(
          game,
          jsonDecode(jsonEncode(config.toJson())) as Map<String, dynamic>,
        ).toJson(),
        config.toJson(),
      );
    });
  }
  test('draft changes cannot mutate a snapshot used by preview', () {
    final draft = GameConfiguration.defaults(CaretakerGame.emotion).toJson();
    final config = GameConfiguration(CaretakerGame.emotion, draft);
    (draft['target_emotions'] as List).clear();
    (config.toJson()['target_emotions'] as List).clear();
    expect(config.validate(), isEmpty);
  });
  test('reject four emotion choices with two selected emotions', () {
    final v = GameConfiguration.defaults(CaretakerGame.emotion).toJson()
      ..['target_emotions'] = ['happy', 'sad'];
    expect(GameConfiguration(CaretakerGame.emotion, v).validate(), isNotEmpty);
  });
  test('bomb-free fruit game requires a finite duration', () {
    final v = GameConfiguration.defaults(CaretakerGame.fruitCatch).toJson()
      ..['bomb_probability'] = 0;
    expect(
      GameConfiguration(CaretakerGame.fruitCatch, v).validate(),
      isNotEmpty,
    );
    v['duration_seconds'] = 30;
    expect(GameConfiguration(CaretakerGame.fruitCatch, v).validate(), isEmpty);
  });
  test('legacy FlashCard word types survive the customization merge', () {
    final v = GameConfiguration.defaults(CaretakerGame.flashcard).toJson()
      ..['custom_cards'] = [
        for (final type in ['noun', 'pronoun', 'verb', 'adjective', 'adverb'])
          {'id': type, 'word': type, 'category': type, 'image_url': null},
      ]
      ..['use_custom_cards'] = true;
    expect(GameConfiguration(CaretakerGame.flashcard, v).validate(), isEmpty);
  });
  test('reject duplicate and oversized custom cards', () {
    final card = {
      'id': 'a',
      'word': 'apple',
      'category': 'noun',
      'image_url': null,
    };
    final v = GameConfiguration.defaults(CaretakerGame.flashcard).toJson()
      ..['custom_cards'] = [card, card];
    expect(
      GameConfiguration(CaretakerGame.flashcard, v).validate(),
      isNotEmpty,
    );
    v['custom_cards'] = [
      {
        ...card,
        'image_url':
            'data:image/jpeg;base64,${base64Encode(List.filled(131073, 0))}',
      },
    ];
    expect(
      GameConfiguration(CaretakerGame.flashcard, v).validate(),
      isNotEmpty,
    );
  });
  test(
    'reject duplicate conversation starters and empty activity selection',
    () {
      final social = GameConfiguration.defaults(
        CaretakerGame.socialChat,
      ).toJson()..['starter_phrases'] = ['hello', 'hello'];
      expect(
        GameConfiguration(CaretakerGame.socialChat, social).validate(),
        isNotEmpty,
      );
      final mini = GameConfiguration.defaults(CaretakerGame.miniPuzzle).toJson()
        ..['enabled_types'] = [];
      expect(
        GameConfiguration(CaretakerGame.miniPuzzle, mini).validate(),
        isNotEmpty,
      );
    },
  );
  test('adult role aliases normalize without rewriting stored role', () {
    for (final role in ['parent', 'teacher', 'caretaker']) {
      final profile = UserProfile(
        id: 'a',
        name: 'A',
        age: 0,
        createdAt: DateTime(2026),
        role: role,
      );
      expect(profile.mode, AppMode.caretaker);
      expect(profile.role, role);
    }
    expect(
      UserProfile(
        id: 'a',
        name: 'A',
        age: 0,
        createdAt: DateTime(2026),
        role: 'unknown',
      ).mode,
      AppMode.unknown,
    );
  });
}
