import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../features/social_chat/chat_models.dart';
import '../features/social_chat/chat_service.dart';
import 'speech_service.dart';

/// TTS service using the backend proxy or a matching device voice.
/// Calls the backend /api/tts endpoint which handles Gemini TTS securely
/// Falls back to device TTS if backend fails
class GeminiTTSService {
  GeminiTTSService._internal();

  static final GeminiTTSService _instance = GeminiTTSService._internal();
  static GeminiTTSService get instance => _instance;

  // Audio player for playing synthesized speech
  AudioPlayer? _audioPlayer;
  int _speechGeneration = 0;

  // Reference to fallback speech service
  SpeechService? _fallbackTts;

  /// Initialize the service
  void init({SpeechService? fallbackTts}) {
    _fallbackTts = fallbackTts;
    _audioPlayer ??= AudioPlayer();
  }

  Future<void> speakThai(String text) => speak(text, ChatLanguage.thai);

  Future<void> speak(String text, ChatLanguage language) async {
    if (text.isEmpty) return;
    final generation = ++_speechGeneration;
    await _stopPlayback();
    if (generation != _speechGeneration) return;

    try {
      final audio = await _generateAudio(text, language);
      if (generation != _speechGeneration) return;
      final player = _audioPlayer;
      if (player == null) return;
      await player.play(BytesSource(audio));
    } catch (e) {
      if (generation != _speechGeneration) return;
      debugPrint('Backend TTS failed, using device voice: ${e.runtimeType}');
      try {
        await _fallbackTts?.speak(text, language);
      } catch (_) {
        debugPrint('Device voice unavailable.');
      }
    }
  }

  Future<Uint8List> _generateAudio(String text, ChatLanguage language) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/tts');

    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'text': text, 'language': language.code}),
        )
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw Exception('TTS request timed out');
          },
        );

    if (response.statusCode != 200) {
      throw Exception('TTS API error: ${response.statusCode}');
    }

    return response.bodyBytes;
  }

  /// Stop any ongoing speech
  Future<void> stopSpeaking() async {
    _speechGeneration++;
    await _stopPlayback();
  }

  Future<void> _stopPlayback() async {
    // The web or device audio plugin may not be available.
    try {
      await _audioPlayer?.stop();
    } catch (_) {}
    try {
      await _fallbackTts?.stopSpeaking();
    } catch (_) {}
  }

  /// Dispose resources
  void dispose() {
    _audioPlayer?.dispose();
    _audioPlayer = null;
  }
}

/// Extension to create BytesSource for audioplayers
/// This allows playing audio directly from memory without saving to file
extension BytesSourceExtension on AudioPlayer {
  Future<void> playBytes(Uint8List bytes) async {
    // Create a data URI for the audio bytes
    final base64Data = base64Encode(bytes);
    final dataUri = 'data:audio/wav;base64,$base64Data';
    await setSource(UrlSource(dataUri));
    await resume();
  }
}

/// BytesSource implementation for audioplayers
/// Allows playing audio from Uint8List memory using data URI
class BytesSource extends Source {
  BytesSource(this.bytes);

  final Uint8List bytes;

  @override
  Future<void> setOnPlayer(AudioPlayer player) async {
    final base64Data = base64Encode(bytes);
    final dataUri = 'data:audio/wav;base64,$base64Data';
    await player.setSource(UrlSource(dataUri));
  }

  @override
  String? get mimeType => 'audio/wav';
}
