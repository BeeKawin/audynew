import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:flutter/foundation.dart';

import '../core/app_sounds.dart';
import 'bluetooth_service.dart';

/// Centralized sound management service for AUDY app
/// Handles preloading, playing, and disposing of sound effects
class SoundService {
  SoundService._internal();

  static final SoundService _instance = SoundService._internal();
  static SoundService get instance => _instance;

  // Device settings must remain usable when the native audio engine is unavailable.
  SoLoud get _soloud => SoLoud.instance;
  bool _enabled = true;
  bool _initialized = false;
  late final AudioPlayer _webEffects = AudioPlayer();
  late final AudioPlayer _webMusic = AudioPlayer();

  /// Browser audio is loaded on demand after a pointer gesture.
  void unlockBrowserAudio() {
    if (kIsWeb) _initialized = true;
  }

  String _assetKey(String path) => path.replaceFirst(RegExp(r'^assets/'), '');
  static const double _bgmVolume = 0.3;
  static const double _sfxVolume = 1.0;
  static const Duration _bearCompletionDelay = Duration(milliseconds: 900);

  /// Preloaded audio sources keyed by asset path
  final Map<String, AudioSource> _sources = {};

  SoundHandle? _bgmHandle;

  /// Whether sounds are enabled
  bool get isEnabled => _enabled;

  /// Whether sound service is initialized
  bool get isInitialized => _initialized;

  /// Initialize SoLoud engine and preload all SFX assets
  Future<void> initialize() async {
    if (kIsWeb) return;
    if (_initialized) {
      debugPrint('SoundService: Already initialized');
      return;
    }

    try {
      debugPrint('SoundService: Initializing SoLoud...');

      // Initialize SoLoud with mobile-friendly settings
      await _soloud.init(
        sampleRate: 44100,
        bufferSize: 2048,
        channels: Channels.stereo,
        automaticCleanup: true,
      );

      debugPrint('SoundService: SoLoud initialized successfully');

      // Preload all sounds
      await _loadAll();

      _initialized = true;
      debugPrint(
        'SoundService: Initialization complete. Loaded ${_sources.length} sounds',
      );
    } catch (e, stackTrace) {
      debugPrint('SoundService: Failed to initialize SoLoud - $e');
      debugPrint('Stack trace: $stackTrace');
      _initialized = false;
    }
  }

  /// Preload all known sound assets into memory
  Future<void> _loadAll() async {
    final paths = AppSounds.allSounds;

    int loadedCount = 0;
    int failedCount = 0;

    for (final path in paths) {
      try {
        debugPrint('SoundService: Loading $path...');
        _sources[path] = await _soloud.loadAsset(path);
        loadedCount++;
        debugPrint('SoundService: Loaded $path successfully');
      } catch (e) {
        failedCount++;
        debugPrint('SoundService: Failed to preload $path - $e');
      }
    }

    debugPrint(
      'SoundService: Loading complete. $loadedCount loaded, $failedCount failed',
    );
  }

  /// Play a sound by its path
  /// Returns true if played successfully, false otherwise
  bool play(String soundPath) {
    if (kIsWeb) {
      if (!_enabled || !_initialized) return false;
      unawaited(
        _webEffects
            .play(AssetSource(_assetKey(soundPath)))
            .catchError((Object _) {}),
      );
      return true;
    }
    if (!_enabled) {
      debugPrint('SoundService: Sound disabled, not playing $soundPath');
      return false;
    }

    if (!_initialized) {
      debugPrint('SoundService: Not initialized, cannot play $soundPath');
      return false;
    }

    final source = _sources[soundPath];
    if (source == null) {
      debugPrint('SoundService: Sound not preloaded - $soundPath');
      return false;
    }

    try {
      _soloud.play(source, volume: _sfxVolume);
      debugPrint('SoundService: Playing $soundPath');
      return true;
    } catch (e) {
      debugPrint('SoundService: Failed to play $soundPath - $e');
      return false;
    }
  }

  /// Play correct answer sound
  void playCorrect() => play(AppSounds.correct);

  /// Play wrong answer sound
  void playWrong() => play(AppSounds.wrong);

  /// Play button tap sound
  void playTap() => play(AppSounds.tap);

  /// Play camera shutter sound
  void playCameraShutter() => play(AppSounds.cameraShutter);

  /// Play round complete sound
  void playRoundComplete() => play(AppSounds.roundComplete);

  /// Play game complete sound
  void playGameComplete() => play(AppSounds.gameComplete);

  /// Play Bluetooth-gated bear feedback after the generic completion sound.
  void playBearCompletionFeedback({required int score, required int maxScore}) {
    if (!_enabled ||
        maxScore <= 0 ||
        !AudyBluetoothService.instance.isConnected) {
      return;
    }

    final isSuccessful = score / maxScore >= 2 / 3;
    final soundPath = isSuccessful
        ? AppSounds.bearCongrats
        : AppSounds.bearTryAgain;

    unawaited(
      Future.delayed(_bearCompletionDelay, () {
        play(soundPath);
      }),
    );
  }

  /// Play points earned sound
  void playPoints() => play(AppSounds.points);

  /// Play level up sound
  void playLevelUp() => play(AppSounds.levelUp);

  /// Play try again sound
  void playTryAgain() => play(AppSounds.tryAgain);

  bool _playInstruction(String soundPath) {
    if (!AudyBluetoothService.instance.isConnected) {
      debugPrint(
        'SoundService: Bluetooth disconnected, not playing instruction sound',
      );
      return false;
    }

    return play(soundPath);
  }

  /// Play emotion classify instruction sound
  void playInstructionEmotionClassify() =>
      _playInstruction(AppSounds.instructionEmotionClassify);

  /// Play emotion mimic instruction sound
  void playInstructionEmotionMimic() =>
      _playInstruction(AppSounds.instructionEmotionMimic);

  /// Play MiniPuzzle pattern instruction sound
  void playInstructionMiniPuzzlePattern() =>
      _playInstruction(AppSounds.instructionMiniPuzzlePattern);

  /// Play MiniPuzzle odd-one-out instruction sound
  void playInstructionMiniPuzzleOddOneOut() =>
      _playInstruction(AppSounds.instructionMiniPuzzleOddOneOut);

  /// Play MiniPuzzle puzzle instruction sound
  void playInstructionMiniPuzzlePuzzle() =>
      _playInstruction(AppSounds.instructionMiniPuzzlePuzzle);

  /// Play read and speak instruction sound
  void playInstructionReadPronounce() =>
      _playInstruction(AppSounds.instructionReadPronounce);

  /// Play Flashcard instruction sound
  void playFlashcardInstruction() =>
      _playInstruction(AppSounds.flashcardInstruction);

  /// Play Flashcard transition sound
  void playFlashcardTransition() => play(AppSounds.flashcardTransition);

  /// Play Fruit Catch intro sound
  void playFruitCatchIntro() => _playInstruction(AppSounds.fruitCatchIntro);

  /// Play background music (soundtrack) on loop at low volume
  void playBGM() {
    if (kIsWeb) {
      if (!_enabled || !_initialized) return;
      unawaited(() async {
        try {
          await _webMusic.setReleaseMode(ReleaseMode.loop);
          await _webMusic.play(
            AssetSource(_assetKey(AppSounds.soundtrack)),
            volume: _bgmVolume,
          );
        } catch (_) {}
      }());
      return;
    }
    if (!_initialized) {
      debugPrint('SoundService: Not initialized, cannot play BGM');
      return;
    }

    final source = _sources[AppSounds.soundtrack];
    if (source == null) {
      debugPrint('SoundService: BGM source not preloaded');
      return;
    }

    try {
      stopBGM(); // Stop any existing BGM first
      _bgmHandle = _soloud.play(source, volume: _bgmVolume, looping: true);
      debugPrint('SoundService: BGM started');
    } catch (e) {
      debugPrint('SoundService: Failed to play BGM - $e');
    }
  }

  /// Pause background music
  void pauseBGM() {
    if (kIsWeb) {
      unawaited(_webMusic.pause().catchError((Object _) {}));
      return;
    }
    final handle = _bgmHandle;
    if (handle == null) return;
    try {
      _soloud.setPause(handle, true);
    } catch (e) {
      debugPrint('SoundService: Failed to pause BGM - $e');
    }
  }

  /// Resume background music
  void resumeBGM() {
    if (kIsWeb) {
      unawaited(_webMusic.resume().catchError((Object _) {}));
      return;
    }
    final handle = _bgmHandle;
    if (handle == null) return;
    try {
      _soloud.setPause(handle, false);
    } catch (e) {
      debugPrint('SoundService: Failed to resume BGM - $e');
    }
  }

  /// Stop background music
  void stopBGM() {
    if (kIsWeb) {
      unawaited(_webMusic.stop().catchError((Object _) {}));
      return;
    }
    final handle = _bgmHandle;
    if (handle == null) return;
    try {
      _soloud.stop(handle);
      _bgmHandle = null;
    } catch (e) {
      debugPrint('SoundService: Failed to stop BGM - $e');
    }
  }

  /// Enable or disable all sounds
  void setEnabled(bool enabled) {
    _enabled = enabled;
    if (!enabled) stopBGM();
  }

  /// Toggle sound on/off
  void toggle() => setEnabled(!_enabled);

  /// Dispose BGM player
  Future<void> dispose() async {
    if (kIsWeb) {
      await _webEffects.dispose();
      await _webMusic.dispose();
      _initialized = false;
      return;
    }
    if (!_initialized) return;
    stopBGM();
    for (final source in _sources.values) {
      try {
        _soloud.disposeSource(source);
      } catch (_) {}
    }
    _sources.clear();
    _soloud.deinit();
    _initialized = false;
  }
}
