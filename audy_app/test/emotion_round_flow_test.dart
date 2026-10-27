import 'package:audy_app/src/state/audy_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final channel in [
      'xyz.luan/audioplayers',
      'xyz.luan/audioplayers.global',
      'flutter_tts',
    ]) {
      messenger.setMockMethodCallHandler(
        MethodChannel(channel),
        (_) async => 1,
      );
    }
    messenger.setMockStreamHandler(
      const EventChannel('xyz.luan/audioplayers.global/events'),
      MockStreamHandler.inline(onListen: (_, sink) {}),
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugin.csdcorp.com/speech_to_text'),
          (_) async => true,
        );
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

  test('completing an emotion round advances both games together', () {
    final controller = AudyController();
    addTearDown(controller.dispose);

    controller.completeEmotionRound(isMatch: true, confidence: 0.9);

    expect(controller.mimicCurrentRound, 2);
    expect(controller.classifyCurrentRound, 2);
    expect(controller.mimicScore, 1);
  });

  test('incorrect mimic still advances the combined emotion round', () {
    final controller = AudyController();
    addTearDown(controller.dispose);

    controller.completeEmotionRound(isMatch: false, confidence: 0.4);

    expect(controller.mimicCurrentRound, 2);
    expect(controller.classifyCurrentRound, 2);
    expect(controller.mimicScore, 0);
  });

  test('combined rounds stay synchronized until completion', () {
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
}
