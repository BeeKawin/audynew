import 'package:flutter_test/flutter_test.dart';
import 'package:audy_app/src/features/road_safety/road_safety_controller.dart';
import 'package:audy_app/src/features/road_safety/road_safety_models.dart';

void main() {
  test('road safety sequence reaches safe state', () {
    final controller = RoadSafetyController();

    controller.performAction(RoadSafetyAction.start);
    expect(controller.step, RoadSafetyStep.stopAtCurb);

    controller.performAction(RoadSafetyAction.stop);
    controller.performAction(RoadSafetyAction.lookLeft);
    controller.performAction(RoadSafetyAction.lookRight);
    controller.performAction(RoadSafetyAction.lookLeft);
    controller.performAction(RoadSafetyAction.listen);
    controller.performAction(RoadSafetyAction.wait);

    expect(controller.signalState, TrafficSignalState.green);
    expect(controller.step, RoadSafetyStep.cross);

    controller.performAction(RoadSafetyAction.cross);
    expect(controller.isCrossing, isTrue);

    controller.finishCrossing();
    expect(controller.step, RoadSafetyStep.safe);

    controller.completeSession();
    expect(controller.isComplete, isTrue);
    expect(controller.getSessionData().stars, 3);
  });

  test('wrong action stays on current step and records hint', () {
    final controller = RoadSafetyController();

    controller.performAction(RoadSafetyAction.start);
    controller.performAction(RoadSafetyAction.lookLeft);

    expect(controller.step, RoadSafetyStep.stopAtCurb);
    expect(controller.feedback.type, RoadSafetyFeedbackType.hint);
    expect(controller.totalActions, 1);
    expect(controller.correctActions, 0);
  });
}
