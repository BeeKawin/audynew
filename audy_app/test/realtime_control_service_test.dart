import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:audy_app/src/services/bluetooth_service.dart';
import 'package:audy_app/src/services/interactive_input_service.dart';
import 'package:audy_app/src/services/realtime_control_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

    test('accepts the broadcast payload envelope', () {
      final event = RealtimeControlEvent.fromJson({
        'payload': {
          'id': 'remote-event',
          'action': 'tummy',
          'sent_at': '2026-07-22T10:30:00Z',
        },
      });
      expect(event?.action, RemoteControlAction.tummy);
    });
  });

  test('sends the original channel, event and action over HTTP', () async {
    final requests = <http.Request>[];
    final client = SupabaseClient(
      'https://example.supabase.co',
      'test-key',
      httpClient: MockClient((request) async {
        requests.add(request);
        return http.Response('', 202);
      }),
    );
    addTearDown(client.dispose);
    final service = RealtimeControlService(client: client);

    for (final action in RemoteControlAction.values) {
      await service.send(action);
      final body = jsonDecode(requests.last.body) as Map<String, dynamic>;
      final message = (body['messages'] as List).single as Map;
      expect(message['topic'], 'audy-interactive-controls-v1');
      expect(message['event'], 'control');
      expect(message['private'], false);
      final event = RealtimeControlEvent.fromJson(
        Map<String, dynamic>.from(message['payload'] as Map),
      );
      expect(event?.action, action);
    }
    expect(requests, hasLength(8));
    expect(client.getChannels(), hasLength(1));
  });

  test('propagates broadcast failure to the controls page', () async {
    final client = SupabaseClient(
      'https://example.supabase.co',
      'test-key',
      httpClient: MockClient((_) async => http.Response('{}', 503)),
    );
    addTearDown(client.dispose);
    await expectLater(
      RealtimeControlService(client: client).send(RemoteControlAction.nose),
      throwsException,
    );
  });

  test('keeps BLE and remote inputs after rapid screen changes', () async {
    final bluetooth = StreamController<AudyBleMessage>.broadcast();
    final realtime = StreamController<RealtimeControlEvent>.broadcast();
    addTearDown(bluetooth.close);
    addTearDown(realtime.close);
    final service = InteractiveInputService(
      bluetoothMessages: bluetooth.stream,
      realtimeEvents: realtime.stream,
    );
    final first = service.incomingMessages.listen((_) {});
    unawaited(first.cancel());
    final received = <AudyBleMessage>[];
    final second = service.incomingMessages.listen(received.add);
    addTearDown(second.cancel);
    await Future<void>.delayed(Duration.zero);

    bluetooth.add(
      AudyBleMessage(channel: 'ears', value: 1, receivedAt: DateTime.utc(2026)),
    );
    realtime.add(
      RealtimeControlEvent(
        id: 'remote',
        action: RemoteControlAction.rightArm,
        sentAt: DateTime.utc(2026),
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(received.map((message) => message.channel), ['ears', 'force']);
    expect(received.map((message) => message.value), [1, 2]);
    await second.cancel();
    await Future<void>.delayed(Duration.zero);
    expect(bluetooth.hasListener, isFalse);
    expect(realtime.hasListener, isFalse);
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
