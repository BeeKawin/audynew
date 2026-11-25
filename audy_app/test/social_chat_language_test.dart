import 'dart:async';
import 'dart:convert';

import 'package:audy_app/src/features/social_chat/chat_service.dart';
import 'package:audy_app/src/features/social_chat/social_chat_page.dart';
import 'package:audy_app/src/services/bluetooth_service.dart';
import 'package:audy_app/src/services/interactive_input_service.dart';
import 'package:audy_app/src/state/audy_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'support/audy_test_environment.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(initializeAudyTestEnvironment);

  test(
    'language switches preserve separate replies and server sessions',
    () async {
      final controller = AudyController();
      addTearDown(controller.dispose);
      final englishRequest = Completer<void>();
      final englishResponse = Completer<http.Response>();
      final requests = <Map<String, dynamic>>[];
      controller.chatService = ChatService(
        baseUrl: 'https://example.test',
        client: MockClient((request) async {
          expect(request.url.path, '/api/social-chat');
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          requests.add(body);
          if (requests.length == 1) {
            englishRequest.complete();
            return englishResponse.future;
          }
          if (body['language'] == 'th') return _reply('thai-session', 'สวัสดี');
          return _reply('english-session', 'I like apples too.');
        }),
      );

      final pending = controller.submitSocialMessage('สวัสดี');
      await englishRequest.future;
      expect(requests.single, {'language': 'en', 'message': 'สวัสดี'});

      controller.setLanguage('th');
      expect(controller.socialMessages.first.text, contains('สวัสดี'));
      expect(await controller.submitSocialMessage('Hello'), 'สวัสดี');
      expect(requests.last, {'language': 'th', 'message': 'Hello'});
      englishResponse.complete(_reply('english-session', 'Hi there!'));
      await pending;
      expect(controller.socialMessages.last.text, 'สวัสดี');

      controller.setLanguage('en');
      expect(controller.socialMessages.last.text, 'Hi there!');
      await controller.submitSocialMessage('I like apples.');
      expect(requests.last['session_id'], 'english-session');
      expect(controller.chatMessagesSent, 3);
    },
  );

  testWidgets(
    'speech recognition changes locale when the app changes language',
    (tester) async {
      final calls = <MethodCall>[];
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(
        const MethodChannel('plugin.csdcorp.com/speech_to_text'),
        (call) async {
          calls.add(call);
          if (call.method == 'locales') return ['en_US:English', 'th_TH:Thai'];
          return true;
        },
      );
      final controller = AudyController();
      addTearDown(controller.dispose);
      final bear = StreamController<AudyBleMessage>();
      addTearDown(bear.close);
      await tester.pumpWidget(
        AudyScope(
          controller: controller,
          child: MaterialApp(
            home: SocialPracticePage(
              inputService: InteractiveInputService(
                bluetoothMessages: bear.stream,
                realtimeEvents: const Stream.empty(),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('What did you do today?'), findsOneWidget);
      bear.add(
        AudyBleMessage(channel: 'nose', value: 1, receivedAt: DateTime.now()),
      );
      await tester.pump();

      controller.setLanguage('th');
      await tester.pump();
      expect(find.text('วันนี้เธอทำอะไรมา?'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.mic_none_rounded));
      await tester.pump();

      expect(
        calls
            .where((call) => call.method == 'listen')
            .map((call) => call.arguments['localeId']),
        ['en_US', 'th_TH'],
      );
      expect(calls.where((call) => call.method == 'cancel'), isNotEmpty);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    },
  );
}

http.Response _reply(String session, String text) => http.Response(
  jsonEncode({
    'session_id': session,
    'response': text,
    'timestamp': '2026-11-25T00:00:00Z',
  }),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);
