import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Speech service for Thai voice features
/// Handles STT (Speech-to-Text) and TTS (Text-to-Speech)
class SpeechService {
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _stt = SpeechToText();

  bool _isSpeaking = false;
  bool _isListening = false;
  bool _sttAvailable = false;

  bool get isSpeaking => _isSpeaking;
  bool get isListening => _isListening;
  bool get isSTTAvailable => _sttAvailable;

  // Child-friendly voice settings
  static const double childPitch = 1.2;
  static const double childRate = 0.5;

  /// Initialize speech services
  Future<void> init() async {
    _sttAvailable = await _stt.initialize();

    _tts.setCompletionHandler(() {
      _isSpeaking = false;
    });

    _tts.setErrorHandler((_) {
      _isSpeaking = false;
    });
  }

  /// Speak Thai text aloud using TTS
  Future<void> speakThai(String text) async {
    if (_isSpeaking || text.isEmpty) return;

    await _tts.setLanguage('th-TH');
    await _tts.setPitch(childPitch);
    await _tts.setSpeechRate(childRate);

    _isSpeaking = true;
    await _tts.speak(text);
    _isSpeaking = false;
  }

  /// Listen for Thai speech and return transcribed text using STT
  Future<String?> listenThai() async {
    if (!_sttAvailable || _isListening) return null;

    final available = await _stt.hasPermission;
    if (!available) return null;

    final completer = Completer<String?>();
    String lastWords = '';

    _isListening = true;

    final started = await _stt.listen(
      localeId: 'th_TH',
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      listenOptions: SpeechListenOptions(partialResults: true),
      onResult: (result) {
        lastWords = result.recognizedWords;
        if (result.finalResult) {
          _isListening = false;
          if (!completer.isCompleted) {
            completer.complete(
              lastWords.trim().isEmpty ? null : lastWords.trim(),
            );
          }
        }
      },
    );

    if (!started) {
      _isListening = false;
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    }

    return completer.future;
  }

  /// Stop TTS speaking
  void stopSpeaking() async {
    if (_isSpeaking) {
      await _tts.stop();
      _isSpeaking = false;
    }
  }

  /// Stop STT listening
  void stopListening() async {
    if (_isListening) {
      await _stt.stop();
      _isListening = false;
    }
  }

  /// Dispose resources
  void dispose() {
    _tts.stop();
    _stt.stop();
  }
}
