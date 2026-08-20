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
  static const String bearCongrats = 'assets/sounds/bear_congrats.mp3';
  static const String bearTryAgain = 'assets/sounds/bear_tryagain.mp3';

  // Reaction game sounds
  static const String go = 'assets/sounds/go.mp3';
  static const String error = 'assets/sounds/error.mp3';

  // Reading/pronunciation sounds
  static const String tryAgain = 'assets/sounds/try_again.mp3';

  // Game instruction sounds
  static const String instructionEmotionClassify =
      'assets/sounds/instruction_emotion_classify.mp3';
  static const String instructionEmotionMimic =
      'assets/sounds/instruction_emotion_mimic.mp3';
  static const String instructionReactionTime =
      'assets/sounds/instruction_reaction_time.mp3';
  static const String instructionSortingGame =
      'assets/sounds/instruction_sorting_game.mp3';
  static const String instructionMiniPuzzlePattern =
      'assets/sounds/instruction_minipuzzle_pattern.mp3';
  static const String instructionMiniPuzzleOddOneOut =
      'assets/sounds/instruction_minipuzzle_odd_one_out.mp3';
  static const String instructionMiniPuzzlePuzzle =
      'assets/sounds/instruction_minipuzzle_puzzle.mp3';
  static const String instructionReadPronounce =
      'assets/sounds/instruction_read_pronounce.mp3';

  // Achievement sounds
  static const String achievement = 'assets/sounds/achievement.mp3';
  static const String levelUp = 'assets/sounds/level_up.mp3';

  // Meltdown screen sound uses audioplayers.AssetSource, which is relative
  // to the assets directory rather than Flutter's full asset key.
  static const String relaxingMusic = 'sounds/relaxing.mp3';

  // Same track, loaded through SoLoud (SoundService.playBGM) for the
  // EmotionDown screen's ambient loop — SoLoud needs the full asset key.
  static const String emotionDownAmbient = 'assets/sounds/relaxing.mp3';

  /// All sounds that should be preloaded at app start
  static const List<String> allSounds = [
    correct,
    wrong,
    tap,
    cameraShutter,
    roundComplete,
    gameComplete,
    bearCongrats,
    bearTryAgain,
    points,
    go,
    error,
    tryAgain,
    instructionEmotionClassify,
    instructionEmotionMimic,
    instructionReactionTime,
    instructionSortingGame,
    instructionMiniPuzzlePattern,
    instructionMiniPuzzleOddOneOut,
    instructionMiniPuzzlePuzzle,
    instructionReadPronounce,
    achievement,
    levelUp,
    soundtrack,
    emotionDownAmbient,
  ];
}
