import 'package:flutter_tts/flutter_tts.dart';

/// Lightweight TTS used by the flash-card game for sequential card narration.
///
/// Unlike [SpeechService]/[ReadPronounceService], this enables
/// `awaitSpeakCompletion(true)` so [speak] resolves only when the audio has
/// finished — required to queue card dealing and left→right submit feedback.
class GameTtsService {
  final FlutterTts _tts = FlutterTts();
  bool _ready = false;

  // Child-friendly voice (matches the other speech services).
  static const double _pitch = 1.2;
  static const double _rate = 0.45;

  Future<void> _ensure() async {
    if (_ready) return;
    await _tts.awaitSpeakCompletion(true);
    _ready = true;
  }

  /// Speak [text]; resolves when playback completes. [thai] picks the voice
  /// locale to follow the app's language setting.
  Future<void> speak(String text, {required bool thai}) async {
    if (text.trim().isEmpty) return;
    try {
      await _ensure();
      await _tts.setLanguage(thai ? 'th-TH' : 'en-US');
      await _tts.setPitch(_pitch);
      await _tts.setSpeechRate(_rate);
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {
      // Never let a TTS hiccup break the game sequence.
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }

  void dispose() {
    _tts.stop();
  }
}
