enum RoadSafetyStep {
  intro,
  stopAtCurb,
  lookLeft,
  lookRight,
  lookLeftAgain,
  listen,
  waitForSignal,
  cross,
  safe,
  complete,
}

enum RoadSafetyAction { start, stop, lookLeft, lookRight, listen, wait, cross }

enum RoadSafetyFeedbackType { neutral, success, hint }

enum TrafficSignalState { red, green }

class RoadSafetyFeedback {
  const RoadSafetyFeedback({required this.messageKey, required this.type});

  final String messageKey;
  final RoadSafetyFeedbackType type;
}

class RoadSafetySessionData {
  const RoadSafetySessionData({
    required this.correctActions,
    required this.totalActions,
    required this.sessionStartedAt,
    required this.sessionEndedAt,
  });

  final int correctActions;
  final int totalActions;
  final DateTime sessionStartedAt;
  final DateTime sessionEndedAt;

  int get stars {
    if (totalActions <= 0) return 0;
    final accuracy = correctActions / totalActions;
    if (accuracy >= 0.95) return 3;
    if (accuracy >= 0.75) return 2;
    return 1;
  }
}

extension RoadSafetyStepDetails on RoadSafetyStep {
  String get instructionKey {
    switch (this) {
      case RoadSafetyStep.intro:
        return 'road_safety_intro';
      case RoadSafetyStep.stopAtCurb:
        return 'road_safety_stop';
      case RoadSafetyStep.lookLeft:
        return 'road_safety_look_left';
      case RoadSafetyStep.lookRight:
        return 'road_safety_look_right';
      case RoadSafetyStep.lookLeftAgain:
        return 'road_safety_look_left_again';
      case RoadSafetyStep.listen:
        return 'road_safety_listen';
      case RoadSafetyStep.waitForSignal:
        return 'road_safety_wait';
      case RoadSafetyStep.cross:
        return 'road_safety_cross';
      case RoadSafetyStep.safe:
      case RoadSafetyStep.complete:
        return 'road_safety_safe';
    }
  }

  int get progressIndex {
    switch (this) {
      case RoadSafetyStep.intro:
        return 0;
      case RoadSafetyStep.stopAtCurb:
        return 1;
      case RoadSafetyStep.lookLeft:
        return 2;
      case RoadSafetyStep.lookRight:
        return 3;
      case RoadSafetyStep.lookLeftAgain:
        return 4;
      case RoadSafetyStep.listen:
        return 5;
      case RoadSafetyStep.waitForSignal:
        return 6;
      case RoadSafetyStep.cross:
        return 7;
      case RoadSafetyStep.safe:
      case RoadSafetyStep.complete:
        return 8;
    }
  }
}
