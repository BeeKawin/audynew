import 'game_configuration.dart';

class StudentFlashcardOptions {
  StudentFlashcardOptions(GameConfiguration config) : _values = config.toJson();
  final Map<String, dynamic> _values;

  String get difficulty => _values['difficulty'] as String;
  String language(String appLanguage) => _values['language'] == 'app'
      ? appLanguage
      : _values['language'] as String;
  bool get autoSpeak => _values['auto_speak'] as bool;
  Duration? get previewDelay => switch (_values['preview_pace']) {
    'manual' => null,
    '3_seconds' => const Duration(seconds: 3),
    '5_seconds' => const Duration(seconds: 5),
    _ => const Duration(seconds: 2),
  };

  List<Map<String, dynamic>> get customCards =>
      _values['use_custom_cards'] == true
      ? List.unmodifiable(
          (_values['custom_cards'] as List).map(
            (card) => Map<String, dynamic>.unmodifiable(card as Map),
          ),
        )
      : const [];
}

class StudentMiniPuzzleOptions {
  StudentMiniPuzzleOptions(GameConfiguration config)
    : _values = config.toJson();
  final Map<String, dynamic> _values;

  bool allows(String type) => (_values['enabled_types'] as List).contains(type);
  String difficulty(String type) =>
      _values[switch (type) {
            'pattern' => 'pattern_difficulty',
            'oddOneOut' => 'odd_one_out_difficulty',
            _ => 'puzzle_difficulty',
          }]
          as String;
  bool get showGuide => _values['show_guide'] == true;
  Duration? get advanceDelay => switch (_values['advance_mode']) {
    'manual' => null,
    'automatic_1800ms' => const Duration(milliseconds: 1800),
    _ => const Duration(milliseconds: 900),
  };
}

class StudentEmotionOptions {
  StudentEmotionOptions(GameConfiguration config) : _values = config.toJson();
  final Map<String, dynamic> _values;

  List<String> get targets => List.unmodifiable(
    (_values['target_emotions'] as List).cast<String>().map(
      (value) => '${value[0].toUpperCase()}${value.substring(1)}',
    ),
  );
  int get choiceCount => _values['choice_count'] as int;
  int get roundCount => _values['round_count'] as int;
  bool get consistentImage => _values['image_mode'] == 'consistent';
  bool get showGuide => _values['show_guide'] == true;
  Duration? get advanceDelay => switch (_values['advance_mode']) {
    'manual' => null,
    'automatic_3000ms' => const Duration(seconds: 3),
    _ => const Duration(milliseconds: 1500),
  };
}

class StudentFruitCatchOptions {
  StudentFruitCatchOptions(GameConfiguration config)
    : _values = config.toJson();
  final Map<String, dynamic> _values;

  double get fallSpeed => switch (_values['fall_speed']) {
    'slow' => .0032,
    'fast' => .0064,
    _ => .0048,
  };
  Duration get spawnInterval =>
      Duration(milliseconds: _values['spawn_interval_ms'] as int);
  double get bombProbability => (_values['bomb_probability'] as num).toDouble();
  int get bombGraceCount => _values['bomb_grace_count'] as int;
  Duration? get duration {
    final seconds = _values['duration_seconds'] as int?;
    return seconds == null ? null : Duration(seconds: seconds);
  }

  List<String> get fruitIds =>
      List.unmodifiable((_values['fruit_ids'] as List).cast<String>());
  bool get showGuide => _values['show_guide'] == true;
}
