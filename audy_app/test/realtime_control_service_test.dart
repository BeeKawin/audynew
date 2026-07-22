import 'dart:math';

import 'package:audy_app/src/services/interactive_input_service.dart';
import 'package:audy_app/src/services/realtime_control_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RealtimeControlEvent', () {
    test('round-trips every action', () {
      for (final action in RemoteControlAction.values) {
        final original = RealtimeControlEvent(
          id: 'event-${action.wireName}',
          action: action,
          sentAt: DateTime.utc(2026, 7, 22, 10, 30),
        );

        final decoded = RealtimeControlEvent.fromJson(original.toJson());

        expect(decoded, isNotNull);
        expect(decoded!.id, original.id);
        expect(decoded.action, action);
        expect(decoded.sentAt, original.sentAt);
      }
    });

    test('rejects malformed events', () {
      expect(RealtimeControlEvent.fromJson({'action': 'nose'}), isNull);
      expect(
        RealtimeControlEvent.fromJson({
          'id': 'event',
          'action': 'unknown',
          'sent_at': '2026-07-22T10:30:00Z',
        }),
        isNull,
      );
    });
  });

  test('maps remote controls to existing game input channels', () {
    final expected = <RemoteControlAction, (String, int)>{
      RemoteControlAction.leftEar: ('ears', 1),
      RemoteControlAction.rightEar: ('ears', 2),
      RemoteControlAction.nose: ('nose', 1),
      RemoteControlAction.leftArm: ('force', 1),
      RemoteControlAction.rightArm: ('force', 2),
      RemoteControlAction.tummy: ('tummy', 1),
    };

    for (final entry in expected.entries) {
      final message = InteractiveInputService.messageFor(
        RealtimeControlEvent(
          id: 'event',
          action: entry.key,
          sentAt: DateTime.utc(2026, 7, 22),
        ),
      );

      expect(message, isNotNull);
      expect(message!.channel, entry.value.$1);
      expect(message.value, entry.value.$2);
    }
  });

  test('does not convert mimic controls into hardware input', () {
    for (final action in [
      RemoteControlAction.correctMimic,
      RemoteControlAction.incorrectMimic,
    ]) {
      final message = InteractiveInputService.messageFor(
        RealtimeControlEvent(
          id: 'event',
          action: action,
          sentAt: DateTime.utc(2026, 7, 22),
        ),
      );

      expect(message, isNull);
    }
  });

  group('selectMimicEmotion', () {
    const emotions = ['Happy', 'Sad', 'Angry', 'Calm'];

    test('returns the target for a correct mimic', () {
      expect(
        selectMimicEmotion(
          correctEmotion: 'Happy',
          isCorrect: true,
          availableEmotions: emotions,
        ),
        'Happy',
      );
    });

    test('never returns the target for an incorrect mimic', () {
      final random = Random(42);

      for (var index = 0; index < 100; index++) {
        expect(
          selectMimicEmotion(
            correctEmotion: 'Happy',
            isCorrect: false,
            availableEmotions: emotions,
            random: random,
          ),
          isNot('Happy'),
        );
      }
    });
  });
}
