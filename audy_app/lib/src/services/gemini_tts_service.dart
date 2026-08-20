import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../features/social_chat/chat_service.dart';
import 'speech_service.dart';

/// Thai TTS Service using backend proxy
/// Calls the backend /api/tts endpoint which handles Gemini TTS securely
/// Falls back to device TTS if backend fails
class GeminiTTSService {
  GeminiTTSService._internal();

  static final GeminiTTSService _instance = GeminiTTSService._internal();
  static GeminiTTSService get instance => _instance;

  // Audio player for playing synthesized speech
  AudioPlayer? _audioPlayer;

  // Reference to fallback speech service
  SpeechService? _fallbackTts;

  /// Initialize the service
  void init({SpeechService? fallbackTts}) {
    _fallbackTts = fallbackTts;
    _audioPlayer = AudioPlayer();
  }

  /// Generate and play Thai TTS using backend API
  /// Falls back to device TTS if backend fails
  Future<void> speakThai(String text) async {
    if (text.isEmpty) return;

    try {
      await _generateAndPlayAudio(text);
    } catch (e) {
      debugPrint('Backend TTS failed, using fallback: $e');
      // Fallback to device TTS
      await _fallbackTts?.speakThai(text);
    }
  }

  /// Call backend TTS API to generate audio and play it
  Future<void> _generateAndPlayAudio(String text) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/tts');

    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: '{"text": ${jsonEncode(text)}}',
        )
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw Exception('TTS request timed out');
          },
        );

    if (response.statusCode != 200) {
      throw Exception(
        'TTS API error: ${response.statusCode} - ${response.body}',
      );
    }

    // Response is already WAV bytes from backend
    final wavBytes = response.bodyBytes;

    // Play the audio
    await _playAudioBytes(wavBytes);
  }

  /// Play audio from bytes and wait until playback actually finishes.
  ///
  /// `AudioPlayer.play()` only awaits playback *starting*, not finishing —
  /// callers (e.g. Flashcard's submit flow) need to know when the word has
  /// actually been spoken, so we also wait for the completion event.
  Future<void> _playAudioBytes(Uint8List audioBytes) async {
    final player = _audioPlayer;
    if (player == null) {
      throw Exception('Audio player not initialized');
    }

    await player.stop();
    final completion = player.onPlayerComplete.first;
    await player.play(BytesSource(audioBytes));
    await completion;
  }

  /// Stop any ongoing speech
  Future<void> stopSpeaking() async {
    await _audioPlayer?.stop();
    _fallbackTts?.stopSpeaking();
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
