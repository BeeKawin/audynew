import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:flutter/foundation.dart';

import '../core/app_sounds.dart';

/// Centralized sound management service for AUDY app
/// Handles preloading, playing, and disposing of sound effects
class SoundService {
  SoundService._internal();

  static final SoundService _instance = SoundService._internal();
  static SoundService get instance => _instance;

  final SoLoud _soloud = SoLoud.instance;
  bool _enabled = true;
  bool _initialized = false;
  static const double _bgmVolume = 0.3;
  static const double _sfxVolume = 1.0;

  /// Preloaded audio sources keyed by asset path
  final Map<String, AudioSource> _sources = {};

  SoundHandle? _bgmHandle;

  /// Whether sounds are enabled
  bool get isEnabled => _enabled;

  /// Initialize SoLoud engine and preload all SFX assets
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await _soloud.init();
      await _loadAll();
      _initialized = true;
    } catch (e) {
      debugPrint('SoundService: Failed to initialize SoLoud - $e');
    }
  }

  /// Preload all known sound assets into memory
  Future<void> _loadAll() async {
    final paths = [
      AppSounds.correct,
      AppSounds.wrong,
      AppSounds.tap,
      AppSounds.cameraShutter,
      AppSounds.roundComplete,
      AppSounds.gameComplete,
      AppSounds.points,
      AppSounds.achievement,
      AppSounds.levelUp,
      AppSounds.go,
      AppSounds.error,
      AppSounds.tryAgain,
      AppSounds.soundtrack,
    ];

    for (final path in paths) {
      try {
        _sources[path] = await _soloud.loadAsset(path);
      } catch (e) {
        debugPrint('SoundService: Failed to preload $path - $e');
      }
    }
  }

  /// Play a sound by its path
  /// SoLoud sources can be played multiple times; no need to dispose/recreate
  Future<void> play(String soundPath) async {
    if (!_enabled || !_initialized) return;

    final source = _sources[soundPath];
    if (source == null) {
      debugPrint('SoundService: Sound not preloaded - $soundPath');
      return;
    }

    try {
      _soloud.play(source, volume: _sfxVolume);
    } catch (e) {
      debugPrint('SoundService: Failed to play $soundPath - $e');
    }
  }

  /// Play correct answer sound
  Future<void> playCorrect() => play(AppSounds.correct);

  /// Play wrong answer sound
  Future<void> playWrong() => play(AppSounds.wrong);

  /// Play button tap sound
  Future<void> playTap() => play(AppSounds.tap);

  /// Play camera shutter sound
  Future<void> playCameraShutter() => play(AppSounds.cameraShutter);

  /// Play round complete sound
  Future<void> playRoundComplete() => play(AppSounds.roundComplete);

  /// Play game complete sound
  Future<void> playGameComplete() => play(AppSounds.gameComplete);

  /// Play points earned sound
  Future<void> playPoints() => play(AppSounds.points);

  /// Play achievement unlocked sound
  Future<void> playAchievement() => play(AppSounds.achievement);

  /// Play level up sound
  Future<void> playLevelUp() => play(AppSounds.levelUp);

  /// Play go signal (for reaction game)
  Future<void> playGo() => play(AppSounds.go);

  /// Play error sound
  Future<void> playError() => play(AppSounds.error);

  /// Play try again sound
  Future<void> playTryAgain() => play(AppSounds.tryAgain);

  /// Play background music (soundtrack) on loop at low volume
  Future<void> playBGM() async {
    if (!_initialized) return;

    final source = _sources[AppSounds.soundtrack];
    if (source == null) {
      debugPrint('SoundService: BGM source not preloaded');
      return;
    }

    try {
      await stopBGM(); // Stop any existing BGM first
      _bgmHandle = _soloud.play(
        source,
        volume: _bgmVolume,
        looping: true,
      );
    } catch (e) {
      debugPrint('SoundService: Failed to play BGM - $e');
    }
  }

  /// Pause background music
  Future<void> pauseBGM() async {
    final handle = _bgmHandle;
    if (handle == null) return;
    try {
      _soloud.setPause(handle, true);
    } catch (e) {
      debugPrint('SoundService: Failed to pause BGM - $e');
    }
  }

  /// Resume background music
  Future<void> resumeBGM() async {
    final handle = _bgmHandle;
    if (handle == null) return;
    try {
      _soloud.setPause(handle, false);
    } catch (e) {
      debugPrint('SoundService: Failed to resume BGM - $e');
    }
  }

  /// Stop background music
  Future<void> stopBGM() async {
    final handle = _bgmHandle;
    if (handle == null) return;
    try {
      await _soloud.stop(handle);
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
    await stopBGM();
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
