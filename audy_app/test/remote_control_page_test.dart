import 'package:audy_app/src/features/remote_control/remote_control_page.dart';
import 'package:audy_app/src/services/realtime_control_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows eight controls and confirms a sent action', (
    tester,
  ) async {
    final sentActions = <RemoteControlAction>[];
    const labels = <String, String>{
      'back': 'Back',
      'control_page_title': 'App Controls',
      'control_page_instruction': 'Tap a button.',
      'control_robot_section': 'Robot controls',
      'control_mimic_section': 'Mimic emotion',
      'control_left_ear': 'Left Ear',
      'control_right_ear': 'Right Ear',
      'control_nose': 'Nose',
      'control_left_arm': 'Left Arm',
      'control_right_arm': 'Right Arm',
      'control_tummy': 'Tummy',
      'control_correct_mimic': 'Correct Mimic Emotion',
      'control_incorrect_mimic': 'Incorrect Mimic Emotion',
      'control_ready': 'Ready to send a control.',
      'control_sending': 'Sending…',
      'control_sent': 'Sent: {action}',
      'control_send_failed': 'Could not send.',
    };

    await tester.pumpWidget(
      MaterialApp(
        home: RemoteControlPage(
          sendControl: (action) async => sentActions.add(action),
          playTap: () {},
          translate: (key, params) {
            var value = labels[key] ?? key;
            params?.forEach((name, replacement) {
              value = value.replaceAll('{$name}', replacement);
            });
            return value;
          },
        ),
      ),
    );

    expect(find.text('Left Ear'), findsOneWidget);
    expect(find.text('Right Ear'), findsOneWidget);
    expect(find.text('Nose'), findsOneWidget);
    expect(find.text('Left Arm'), findsOneWidget);
    expect(find.text('Right Arm'), findsOneWidget);
    expect(find.text('Tummy'), findsOneWidget);
    expect(find.text('Correct Mimic Emotion'), findsOneWidget);
    expect(find.text('Incorrect Mimic Emotion'), findsOneWidget);

    await tester.tap(find.text('Left Ear'));
    await tester.pumpAndSettle();

    expect(sentActions, [RemoteControlAction.leftEar]);
    expect(find.text('Sent: Left Ear'), findsOneWidget);
  });
}
