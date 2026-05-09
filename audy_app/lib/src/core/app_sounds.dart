/// Sound effect constants for AUDY app
/// All sound files should be placed in assets/sounds/
class AppSounds {
  const AppSounds._();

  // Game feedback sounds
  static const String correct = 'assets/sounds/correct.mp3';
  static const String wrong = 'assets/sounds/wrong.mp3';
  static const String tap = 'assets/sounds/tap.mp3';
  static const String soundtrack = 'assets/sounds/soundtrack.mp3';

  // Camera sounds
  static const String cameraShutter = 'assets/sounds/camera_shutter.mp3';

  // Progress sounds
  static const String roundComplete = 'assets/sounds/round_complete.mp3';
  static const String gameComplete = 'assets/sounds/game_complete.mp3';
  static const String points = 'assets/sounds/points.mp3';

  // Reaction game sounds
  static const String go = 'assets/sounds/go.mp3';
  static const String error = 'assets/sounds/error.mp3';

  // Reading/pronunciation sounds
  static const String tryAgain = 'assets/sounds/try_again.mp3';

  // Achievement sounds
  static const String achievement = 'assets/sounds/achievement.mp3';
  static const String levelUp = 'assets/sounds/level_up.mp3';

  // Meltdown screen sound uses audioplayers.AssetSource, which is relative
  // to the assets directory rather than Flutter's full asset key.
  static const String relaxingMusic = 'sounds/relaxing.mp3';

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
    soundtrack,
  ];
}
