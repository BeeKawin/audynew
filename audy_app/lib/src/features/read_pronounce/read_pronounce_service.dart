import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ReadPronounceService {
  ReadPronounceService() {
    _init();
  }

  final FlutterTts _tts = FlutterTts();
  final SpeechToText _stt = SpeechToText();

  bool _isSpeaking = false;
  bool _isListening = false;
  bool _sttAvailable = false;

  bool get isSpeaking => _isSpeaking;
  bool get isListening => _isListening;
  bool get isSTTAvailable => _sttAvailable;

  static const double childPitch = 1.2;
  static const double childRate = 0.4;

  Future<void> _init() async {
    _tts.setCompletionHandler(() {
      _isSpeaking = false;
    });

    _tts.setErrorHandler((_) {
      _isSpeaking = false;
    });

    _sttAvailable = await _stt.initialize();
  }

  Future<void> speak(String text, {String language = 'en-US'}) async {
    if (_isSpeaking) return;

    await _tts.setLanguage(language);
    await _tts.setPitch(childPitch);
    await _tts.setSpeechRate(childRate);

    _isSpeaking = true;
    await _tts.speak(text);
    _isSpeaking = false;
  }

  Future<void> speakThai(String text) async {
    if (_isSpeaking) return;

    await _tts.setLanguage('th-TH');
    await _tts.setPitch(childPitch);
    await _tts.setSpeechRate(childRate);

    _isSpeaking = true;
    await _tts.speak(text);
    _isSpeaking = false;
  }

  Future<String?> listen() async {
    if (!_sttAvailable) return null;
    if (_isListening) return null;

    final available = await _stt.hasPermission;
    if (!available) return null;

    final completer = Completer<String?>();
    String lastWords = '';

    _isListening = true;

    final started = await _stt.listen(
      localeId: 'en_US',
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

  void stopSpeaking() async {
    if (_isSpeaking) {
      await _tts.stop();
      _isSpeaking = false;
    }
  }

  void stopListening() async {
    if (_isListening) {
      await _stt.stop();
      _isListening = false;
    }
  }

  void dispose() {
    _tts.stop();
    _stt.stop();
  }
}
