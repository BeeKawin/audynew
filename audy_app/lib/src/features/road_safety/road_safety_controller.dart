import 'package:flutter/foundation.dart';

import 'road_safety_models.dart';

class RoadSafetyController extends ChangeNotifier {
  static const int totalLearningSteps = 8;

  RoadSafetyStep _step = RoadSafetyStep.intro;
  TrafficSignalState _signalState = TrafficSignalState.red;
  RoadSafetyFeedback _feedback = const RoadSafetyFeedback(
    messageKey: 'road_safety_intro_feedback',
    type: RoadSafetyFeedbackType.neutral,
  );
  int _correctActions = 0;
  int _totalActions = 0;
  bool _isCrossing = false;
  DateTime? _sessionStartedAt;
  DateTime? _sessionEndedAt;

  RoadSafetyStep get step => _step;
  TrafficSignalState get signalState => _signalState;
  RoadSafetyFeedback get feedback => _feedback;
  int get correctActions => _correctActions;
  int get totalActions => _totalActions;
  bool get isCrossing => _isCrossing;
  bool get isComplete => _step == RoadSafetyStep.complete;
  bool get canCross =>
      _step == RoadSafetyStep.cross &&
      _signalState == TrafficSignalState.green &&
      !_isCrossing;

  int get progressCurrent => _step.progressIndex.clamp(0, totalLearningSteps);

  void startSession() {
    _sessionStartedAt = DateTime.now();
    _sessionEndedAt = null;
    _correctActions = 0;
    _totalActions = 0;
    _signalState = TrafficSignalState.red;
    _isCrossing = false;
    _moveTo(
      RoadSafetyStep.stopAtCurb,
      feedbackKey: 'road_safety_stop_feedback',
      type: RoadSafetyFeedbackType.neutral,
    );
  }

  void performAction(RoadSafetyAction action) {
    if (_step == RoadSafetyStep.intro && action == RoadSafetyAction.start) {
      startSession();
      return;
    }

    if (_step == RoadSafetyStep.complete) return;

    _totalActions++;
    final expected = _expectedActionForStep(_step);
    if (action != expected) {
      _feedback = RoadSafetyFeedback(
        messageKey: _hintForStep(_step),
        type: RoadSafetyFeedbackType.hint,
      );
      notifyListeners();
      return;
    }

    _correctActions++;
    switch (_step) {
      case RoadSafetyStep.stopAtCurb:
        _moveTo(RoadSafetyStep.lookLeft, feedbackKey: 'road_safety_good_stop');
        break;
      case RoadSafetyStep.lookLeft:
        _moveTo(RoadSafetyStep.lookRight, feedbackKey: 'road_safety_good_look');
        break;
      case RoadSafetyStep.lookRight:
        _moveTo(
          RoadSafetyStep.lookLeftAgain,
          feedbackKey: 'road_safety_good_look',
        );
        break;
      case RoadSafetyStep.lookLeftAgain:
        _moveTo(RoadSafetyStep.listen, feedbackKey: 'road_safety_good_look');
        break;
      case RoadSafetyStep.listen:
        _moveTo(
          RoadSafetyStep.waitForSignal,
          feedbackKey: 'road_safety_good_listen',
        );
        break;
      case RoadSafetyStep.waitForSignal:
        _signalState = TrafficSignalState.green;
        _moveTo(RoadSafetyStep.cross, feedbackKey: 'road_safety_green_ready');
        break;
      case RoadSafetyStep.cross:
        _isCrossing = true;
        _feedback = const RoadSafetyFeedback(
          messageKey: 'road_safety_crossing_feedback',
          type: RoadSafetyFeedbackType.success,
        );
        notifyListeners();
        break;
      case RoadSafetyStep.intro:
      case RoadSafetyStep.safe:
      case RoadSafetyStep.complete:
        break;
    }
  }

  void finishCrossing() {
    if (_step != RoadSafetyStep.cross || !_isCrossing) return;
    _isCrossing = false;
    _moveTo(RoadSafetyStep.safe, feedbackKey: 'road_safety_safe_feedback');
  }

  void completeSession() {
    if (_step != RoadSafetyStep.safe) return;
    _sessionEndedAt = DateTime.now();
    _step = RoadSafetyStep.complete;
    _feedback = const RoadSafetyFeedback(
      messageKey: 'road_safety_complete_feedback',
      type: RoadSafetyFeedbackType.success,
    );
    notifyListeners();
  }

  void reset() {
    _step = RoadSafetyStep.intro;
    _signalState = TrafficSignalState.red;
    _feedback = const RoadSafetyFeedback(
      messageKey: 'road_safety_intro_feedback',
      type: RoadSafetyFeedbackType.neutral,
    );
    _correctActions = 0;
    _totalActions = 0;
    _isCrossing = false;
    _sessionStartedAt = null;
    _sessionEndedAt = null;
    notifyListeners();
  }

  RoadSafetySessionData getSessionData() {
    final endedAt = _sessionEndedAt ?? DateTime.now();
    return RoadSafetySessionData(
      correctActions: _correctActions,
      totalActions: _totalActions,
      sessionStartedAt: _sessionStartedAt ?? endedAt,
      sessionEndedAt: endedAt,
    );
  }

  void _moveTo(
    RoadSafetyStep nextStep, {
    required String feedbackKey,
    RoadSafetyFeedbackType type = RoadSafetyFeedbackType.success,
  }) {
    _step = nextStep;
    _feedback = RoadSafetyFeedback(messageKey: feedbackKey, type: type);
    notifyListeners();
  }

  RoadSafetyAction? _expectedActionForStep(RoadSafetyStep step) {
    switch (step) {
      case RoadSafetyStep.stopAtCurb:
        return RoadSafetyAction.stop;
      case RoadSafetyStep.lookLeft:
        return RoadSafetyAction.lookLeft;
      case RoadSafetyStep.lookRight:
        return RoadSafetyAction.lookRight;
      case RoadSafetyStep.lookLeftAgain:
        return RoadSafetyAction.lookLeft;
      case RoadSafetyStep.listen:
        return RoadSafetyAction.listen;
      case RoadSafetyStep.waitForSignal:
        return RoadSafetyAction.wait;
      case RoadSafetyStep.cross:
        return RoadSafetyAction.cross;
      case RoadSafetyStep.intro:
      case RoadSafetyStep.safe:
      case RoadSafetyStep.complete:
        return null;
    }
  }

  String _hintForStep(RoadSafetyStep step) {
    switch (step) {
      case RoadSafetyStep.stopAtCurb:
        return 'road_safety_hint_stop';
      case RoadSafetyStep.lookLeft:
        return 'road_safety_hint_left';
      case RoadSafetyStep.lookRight:
        return 'road_safety_hint_right';
      case RoadSafetyStep.lookLeftAgain:
        return 'road_safety_hint_left_again';
      case RoadSafetyStep.listen:
        return 'road_safety_hint_listen';
      case RoadSafetyStep.waitForSignal:
        return 'road_safety_hint_wait';
      case RoadSafetyStep.cross:
        return 'road_safety_hint_cross';
      case RoadSafetyStep.intro:
      case RoadSafetyStep.safe:
      case RoadSafetyStep.complete:
        return 'road_safety_intro_feedback';
    }
  }
}
