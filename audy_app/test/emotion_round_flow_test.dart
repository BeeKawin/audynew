import 'dart:io';

import 'package:audy_app/src/core/app_sounds.dart';
import 'package:audy_app/src/features/emotion_mimic_game/mimic_result_screen.dart';
import 'package:audy_app/src/state/audy_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugin.csdcorp.com/speech_to_text'),
          (_) async => true,
        );
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      anonKey: 'test-anon-key',
    );
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugin.csdcorp.com/speech_to_text'),
          null,
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

  test('combined rounds stay synchronized until the game is complete', () {
    final controller = AudyController();
    addTearDown(controller.dispose);

    for (var completedRound = 1; completedRound <= 3; completedRound += 1) {
      controller.completeEmotionRound(isMatch: true, confidence: 0.9);

      expect(controller.mimicCurrentRound, completedRound + 1);
      expect(controller.classifyCurrentRound, completedRound + 1);
    }

    expect(controller.isMimicGameComplete, isTrue);
    expect(controller.isClassifyGameComplete, isTrue);

    controller.completeEmotionRound(isMatch: true, confidence: 0.9);
    expect(controller.mimicCurrentRound, 4);
    expect(controller.classifyCurrentRound, 4);
  });

  testWidgets('repeated taps complete the round only once', (tester) async {
    final controller = AudyController();
    addTearDown(controller.dispose);

    await _pumpMimicResult(
      tester,
      controller: controller,
      detectedEmotion: 'Happy',
      tapNextRoundTwice: true,
    );

    expect(controller.mimicCurrentRound, 2);
    expect(controller.classifyCurrentRound, 2);
    expect(controller.mimicScore, 1);
  });
}

Future<void> _pumpMimicResult(
  WidgetTester tester, {
  required AudyController controller,
  required String detectedEmotion,
  bool useSystemBack = false,
  bool tapNextRoundTwice = false,
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
    if (tapNextRoundTwice) {
      await tester.tap(find.text('Next Round'), warnIfMissed: false);
    }
  }
  await tester.pumpAndSettle();

  expect(didCompleteMimic, isTrue);
  expect(find.text('Open result'), findsOneWidget);
}
