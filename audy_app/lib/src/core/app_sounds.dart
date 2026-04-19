/// Sound effect constants for AUDY app
/// All sound files should be placed in assets/sounds/
class AppSounds {
  const AppSounds._();

  // Game feedback sounds
  static const String correct = 'sounds/correct.mp3';
  static const String wrong = 'sounds/wrong.mp3';
  static const String tap = 'sounds/tap.mp3';
  static const String soundtrack = 'sounds/soundtrack.mp3';

  // Camera sounds
  static const String cameraShutter = 'sounds/camera_shutter.mp3';

  // Progress sounds
  static const String roundComplete = 'sounds/round_complete.mp3';
  static const String gameComplete = 'sounds/game_complete.mp3';
  static const String points = 'sounds/points.mp3';

  // Reaction game sounds
  static const String go = 'sounds/go.mp3';
  static const String error = 'sounds/error.mp3';

  // Reading/pronunciation sounds
  static const String tryAgain = 'sounds/try_again.mp3';

  // Achievement sounds
  static const String achievement = 'sounds/achievement.mp3';
  static const String levelUp = 'sounds/level_up.mp3';

  /// All sounds that should be preloaded at app start
  static const List<String> allSounds = [
    correct,
    wrong,
    tap,
    cameraShutter,
    roundComplete,
    gameComplete,
    points,
    go,
    error,
    tryAgain,
    achievement,
    levelUp,
  ];
}
