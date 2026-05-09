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
  Completer<String?>? _activeListenCompleter;
  Timer? _listenTimeoutTimer;
  String _lastRecognizedWords = '';
  void Function(String status)? _statusListener;
  void Function(String words)? _partialResultListener;

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

    _sttAvailable = await _initializeStt();
  }

  Future<bool> ensureSTTAvailable() async {
    if (_sttAvailable) return true;
    _sttAvailable = await _initializeStt();
    return _sttAvailable;
  }

  Future<bool> _initializeStt() {
    return _stt.initialize(
      onStatus: (status) {
        _statusListener?.call(status);
        if (!_isListening) return;
        if (status == 'done' || status == 'notListening') {
          _completeListeningWithLastWords();
        }
      },
      onError: (error) {
        _statusListener?.call('error: ${error.errorMsg}');
        if (_isListening) {
          _completeListeningWithLastWords();
        }
      },
    );
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

  Future<String?> listen({
    String? localeId,
    void Function(String status)? onStatusChanged,
    void Function(String words)? onPartialResult,
  }) async {
    _statusListener = onStatusChanged;
    _partialResultListener = onPartialResult;

    if (!await ensureSTTAvailable()) {
      _statusListener?.call('initialize failed');
      return null;
    }
    if (_isListening) {
      final activeCompleter = _activeListenCompleter;
      if (activeCompleter == null) return null;
      return activeCompleter.future;
    }

    final available = await _stt.hasPermission;
    _statusListener?.call('permission: $available');
    if (!available) return null;

    final selectedLocaleId = await _resolveLocaleId(localeId);

    _lastRecognizedWords = '';
    _activeListenCompleter = Completer<String?>();
    _isListening = true;
    _statusListener?.call(
      selectedLocaleId == null
          ? 'starting default locale'
          : 'starting $selectedLocaleId',
    );

    await _stt.listen(
      localeId: selectedLocaleId,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      listenOptions: SpeechListenOptions(partialResults: true),
      onResult: (result) {
        _lastRecognizedWords = result.recognizedWords;
        _partialResultListener?.call(_lastRecognizedWords);
        if (result.finalResult) {
          _completeListeningWithLastWords();
        }
      },
    );

    _statusListener?.call(
      selectedLocaleId == null
          ? 'listening default locale'
          : 'listening $selectedLocaleId',
    );

    _listenTimeoutTimer?.cancel();
    _listenTimeoutTimer = Timer(const Duration(seconds: 32), () {
      if (_isListening) {
        _stt.stop();
        _completeListeningWithLastWords();
      }
    });

    final activeCompleter = _activeListenCompleter;
    if (activeCompleter == null) return null;
    return activeCompleter.future;
  }

  Future<String?> _resolveLocaleId(String? requestedLocaleId) async {
    if (requestedLocaleId == null || requestedLocaleId.trim().isEmpty) {
      return null;
    }

    try {
      final locales = await _stt.locales();
      final requested = requestedLocaleId.trim();
      final exactMatch = locales.any((locale) => locale.localeId == requested);
      if (exactMatch) return requested;

      final languageCode = requested.split('_').first.toLowerCase();
      String? languageMatch;
      for (final locale in locales) {
        final localeLanguage = locale.localeId.split('_').first.toLowerCase();
        if (localeLanguage == languageCode) {
          languageMatch = locale.localeId;
          break;
        }
      }
      if (languageMatch != null) {
        _statusListener?.call('fallback locale: $languageMatch');
        return languageMatch;
      }

      final systemLocale = await _stt.systemLocale();
      _statusListener?.call(
        systemLocale == null
            ? 'locale fallback: default'
            : 'locale fallback: ${systemLocale.localeId}',
      );
      return systemLocale?.localeId;
    } catch (e) {
      _statusListener?.call('locale check failed: $e');
      return null;
    }
  }

  void _completeListeningWithLastWords() {
    _isListening = false;
    _listenTimeoutTimer?.cancel();
    _listenTimeoutTimer = null;

    final completer = _activeListenCompleter;
    _activeListenCompleter = null;
    if (completer == null || completer.isCompleted) return;

    final trimmed = _lastRecognizedWords.trim();
    _statusListener?.call('completed');
    completer.complete(trimmed.isEmpty ? null : trimmed);
  }

  void stopSpeaking() async {
    if (_isSpeaking) {
      await _tts.stop();
      _isSpeaking = false;
    }
  }

  Future<String?> stopListening() async {
    final activeCompleter = _activeListenCompleter;
    if (_isListening) {
      await _stt.stop();
      _completeListeningWithLastWords();
    }

    if (activeCompleter != null) {
      return activeCompleter.future;
    }

    final trimmed = _lastRecognizedWords.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void dispose() {
    _listenTimeoutTimer?.cancel();
    _statusListener = null;
    _partialResultListener = null;
    _tts.stop();
    _stt.stop();
  }
}
