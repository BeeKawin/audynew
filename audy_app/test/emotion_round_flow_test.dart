import 'dart:io';

import 'package:audy_app/src/core/app_sounds.dart';
import 'package:audy_app/src/features/emotion_mimic_game/mimic_result_screen.dart';
import 'package:audy_app/src/state/audy_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      anonKey: 'test-anon-key',
    );
  });

  testWidgets('correct mimic advances to the next classification round', (
    tester,
  ) async {
    final controller = AudyController();
    addTearDown(controller.dispose);

    await _pumpMimicResult(
      tester,
      controller: controller,
      detectedEmotion: 'Happy',
    );

    expect(controller.mimicCurrentRound, 2);
    expect(controller.classifyCurrentRound, 2);
    expect(controller.mimicScore, 1);
  });

  testWidgets(
    'incorrect mimic also advances to the next classification round',
    (tester) async {
      final controller = AudyController();
      addTearDown(controller.dispose);

      await _pumpMimicResult(
        tester,
        controller: controller,
        detectedEmotion: 'Sad',
      );

      expect(controller.mimicCurrentRound, 2);
      expect(controller.classifyCurrentRound, 2);
      expect(controller.mimicScore, 0);
    },
  );

  testWidgets('system back completes the mimic before advancing', (
    tester,
  ) async {
    final controller = AudyController();
    addTearDown(controller.dispose);

    await _pumpMimicResult(
      tester,
      controller: controller,
      detectedEmotion: 'Sad',
      useSystemBack: true,
    );

    expect(controller.mimicCurrentRound, 2);
    expect(controller.classifyCurrentRound, 2);
  });
}

Future<void> _pumpMimicResult(
  WidgetTester tester, {
  required AudyController controller,
  required String detectedEmotion,
  bool useSystemBack = false,
}) async {
  bool? didCompleteMimic;

  await tester.pumpWidget(
    AudyScope(
      controller: controller,
      child: MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    didCompleteMimic = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MimicResultScreen(
                          capturedImage: File('assets/images/happy1.jpg'),
                          expectedEmotion: 'Happy',
                          detectedEmotion: detectedEmotion,
                          confidence: 0.9,
                          successPraiseSoundPath:
                              AppSounds.emotionPraiseSounds.first,
                          playPraise: (_) {},
                          playWrong: () {},
                          playTap: () {},
                          sendRoundSignal: (_) async {},
                        ),
                      ),
                    );

                    if (didCompleteMimic == true) {
                      controller.advanceClassifyRound();
                    }
                  },
                  child: const Text('Open result'),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );

  await tester.tap(find.text('Open result'));
  await tester.pumpAndSettle();

  expect(find.text('Next Round'), findsOneWidget);
  if (useSystemBack) {
    await tester.binding.handlePopRoute();
  } else {
    await tester.ensureVisible(find.text('Next Round'));
    await tester.tap(find.text('Next Round'));
  }
  await tester.pumpAndSettle();

  expect(didCompleteMimic, isTrue);
  expect(find.text('Open result'), findsOneWidget);
}
