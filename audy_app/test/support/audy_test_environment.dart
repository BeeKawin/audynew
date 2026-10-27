import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initializeAudyTestEnvironment() async {
  SharedPreferences.setMockInitialValues({});
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  for (final channel in [
    'xyz.luan/audioplayers',
    'xyz.luan/audioplayers.global',
    'flutter_tts',
  ]) {
    messenger.setMockMethodCallHandler(MethodChannel(channel), (call) async {
      if (channel == 'xyz.luan/audioplayers' && call.method == 'create') {
        final id = (call.arguments as Map)['playerId'];
        messenger.setMockStreamHandler(
          EventChannel('xyz.luan/audioplayers/events/$id'),
          MockStreamHandler.inline(onListen: (_, sink) {}),
        );
      }
      return 1;
    });
  }
  messenger.setMockStreamHandler(
    const EventChannel('xyz.luan/audioplayers.global/events'),
    MockStreamHandler.inline(onListen: (_, sink) {}),
  );
  messenger.setMockMethodCallHandler(
    const MethodChannel('plugin.csdcorp.com/speech_to_text'),
    (_) async => true,
  );
  await Supabase.initialize(
    url: 'https://example.supabase.co',
    anonKey: 'test-key',
  );
}
