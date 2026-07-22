import 'package:flutter/material.dart';

import '../state/audy_controller.dart';

final class AppRoutes {
  static const login = '/login';
  static const dashboard = '/';
  static const games = '/games';
  static const emotionClassify = '/games/emotion-classify';
  static const emotionMimic = '/games/emotion-mimic';
  static const miniPuzzle = '/games/mini-puzzle';
  static const miniPuzzleLevel = '/games/mini-puzzle/level';
  static const miniPuzzleGame = '/games/mini-puzzle/play';
  static const miniPuzzleResult = '/games/mini-puzzle/result';
  static const sortingGame = '/games/sorting';
  static const flashcard = '/games/flashcard';
  static const roadSafety = '/games/road-safety';
  static const fruitCatchingBear = '/games/fruit-catching-bear';
  static const reactionTime = '/games/reaction-time';
  static const readingHub = '/reading';
  static const letters = '/reading/letters';
  static const words = '/reading/words';
  static const sentences = '/reading/sentences';
  static const social = '/social';
  static const rewards = '/rewards';
  static const profile = '/profile';
  static const preferences = '/preferences';
  static const meltdown = '/meltdown';
  static const device = '/device';
  static const assignments = '/assignments';
<<<<<<< HEAD
  static const remoteControl = '/remote-control';
=======
>>>>>>> origin/Kongnew

  /// Navigate after game completion, checking if meltdown protection should trigger.
  /// If 5 games have been played, navigates to meltdown screen.
  /// Otherwise, pops back to the games hub.
  static void navigateAfterGameCompletion(BuildContext context, AudyController controller) {
    if (controller.shouldTriggerMeltdown) {
      // Navigate to meltdown screen with gentle transition
      Navigator.of(context).pushNamed(meltdown);
    } else {
      // Pop back to games hub
      Navigator.of(context).popUntil((route) => route.settings.name == games);
    }
  }
}
