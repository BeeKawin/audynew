import 'package:flutter/material.dart';

import '../state/audy_controller.dart';

final class AppRoutes {
  static final _pendingBreakChecks = <NavigatorState>{};
  static const caretaker = '/caretaker';
  static const caretakerChildren = '/caretaker/children';
  static const caretakerProfile = '/caretaker/profile';
  static const caretakerCustomization = '/caretaker/customization';
  static const caretakerEdit = '/caretaker/customization/edit';
  static const caretakerStudyPlan = '/caretaker/study-plan';
  static const caretakerGuide = '/caretaker/guide';
  static const caretakerAssignments = '/caretaker/assignments-rewards';
  static const caretakerLegacyHome = '/caretaker/legacy/home';
  static const caretakerLegacyProgress = '/caretaker/legacy/progress';
  static const caretakerLegacyProfile = '/caretaker/legacy/profile';
  static const login = '/login';
  static const dashboard = '/';
  static const games = '/games';
  static const emotionClassify = '/games/emotion-classify';
  static const emotionMimic = '/games/emotion-mimic';
  static const miniPuzzle = '/games/mini-puzzle';
  static const miniPuzzleLevel = '/games/mini-puzzle/level';
  static const miniPuzzleGame = '/games/mini-puzzle/play';
  static const miniPuzzleResult = '/games/mini-puzzle/result';
  static const flashcard = '/games/flashcard';
  static const roadSafety = '/games/road-safety';
  static const fruitCatchingBear = '/games/fruit-catching-bear';
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
  static const remoteControl = '/remote-control';

  /// Navigate after game completion, checking if meltdown protection should trigger.
  /// Uses the current Student account's configured game-count threshold.
  /// Otherwise, pops back to the games hub.
  static Future<void> navigateAfterGameCompletion(
    BuildContext context,
    AudyController controller,
  ) async {
    final navigator = Navigator.of(context);
    if (!_pendingBreakChecks.add(navigator)) return;
    try {
      final accountId = controller.currentUser?.id;
      await controller.refreshBreakSettings();
      if (!context.mounted || controller.currentUser?.id != accountId) return;
      if (controller.shouldTriggerMeltdown) {
        navigator.pushNamed(meltdown);
      } else {
        navigator.popUntil((route) => route.settings.name == games);
      }
    } finally {
      _pendingBreakChecks.remove(navigator);
    }
  }
}
