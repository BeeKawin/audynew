import 'dart:async';

import 'package:audy_app/src/core/app_strings.dart';
import 'package:audy_app/src/features/remote_control/remote_control_page.dart';
import 'package:audy_app/src/services/realtime_control_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final language in ['en', 'th']) {
    testWidgets('fits a narrow phone with large $language text', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final actions = <RemoteControlAction>[];
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: RemoteControlPage(
            sendControl: (action) async => actions.add(action),
            playTap: () {},
            translate: (key, params) =>
                AppStrings.format(AppStrings.get(key, language), params ?? {}),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final lastControl = find.text(
        AppStrings.get('control_incorrect_mimic', language),
      );
      await tester.ensureVisible(lastControl);
      await tester.pumpAndSettle();
      final button = find.ancestor(
        of: lastControl,
        matching: find.byType(InkWell),
      );
      expect(tester.getSize(button).width, greaterThanOrEqualTo(48));
      expect(tester.getSize(button).height, greaterThanOrEqualTo(48));
      await tester.tap(lastControl);
      await tester.pumpAndSettle();
      expect(actions, [RemoteControlAction.incorrectMimic]);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('prevents duplicate sends while a request is pending', (
    tester,
  ) async {
    final pending = Completer<void>();
    final actions = <RemoteControlAction>[];
    await tester.pumpWidget(
      MaterialApp(
        home: RemoteControlPage(
          sendControl: (action) {
            actions.add(action);
            return pending.future;
          },
          playTap: () {},
          translate: (key, _) => key,
        ),
      ),
    );
    await tester.tap(find.text('control_left_ear'));
    await tester.pump();
    await tester.tap(find.text('control_right_ear'));
    expect(actions, [RemoteControlAction.leftEar]);
    expect(find.text('control_sending'), findsOneWidget);
    pending.complete();
    await tester.pumpAndSettle();
    expect(find.text('control_sent'), findsOneWidget);
  });

  testWidgets('shows a friendly failure and allows retry', (tester) async {
    var attempts = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: RemoteControlPage(
          sendControl: (_) async {
            if (++attempts == 1) throw Exception('internal network details');
          },
          playTap: () {},
          translate: (key, _) => key,
        ),
      ),
    );
    await tester.tap(find.text('control_left_ear'));
    await tester.pumpAndSettle();
    expect(find.text('control_send_failed'), findsOneWidget);
    expect(find.textContaining('internal network details'), findsNothing);
    await tester.tap(find.text('control_left_ear'));
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(find.text('control_sent'), findsOneWidget);
  });

  testWidgets('can leave the page while a send completes', (tester) async {
    final pending = Completer<void>();
    await tester.pumpWidget(
      MaterialApp(
        home: RemoteControlPage(
          sendControl: (_) => pending.future,
          playTap: () {},
          translate: (key, _) => key,
        ),
      ),
    );
    await tester.tap(find.text('control_left_ear'));
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    pending.complete();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

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
