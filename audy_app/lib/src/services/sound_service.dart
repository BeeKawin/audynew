import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../core/app_sounds.dart';

/// Centralized sound management service for AUDY app
/// Handles preloading, playing, and disposing of sound effects
class SoundService {
  SoundService._internal();

  static final SoundService _instance = SoundService._internal();
  static SoundService get instance => _instance;

  final AudioPlayer _bgmPlayer = AudioPlayer();
  bool _enabled = true;
  bool _initialized = false;
  static const double _bgmVolume = 0.3;

  /// Whether sounds are enabled
  bool get isEnabled => _enabled;

  /// Initialize sound service - lazy-loads SFX only, BGM not started
  Future<void> initialize() async {
    if (_initialized) return;

    // BGM startup removed - will be added later
    _initialized = true;
  }

  /// Play a sound by its path (creates new player each time for reliability)
  Future<void> play(String soundPath) async {
    if (!_enabled) return;

    try {
      final player = AudioPlayer();
      await player.play(AssetSource(soundPath));
      // Auto-dispose after playback
      player.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.completed) {
          player.dispose();
        }
      });
    } catch (e) {
      debugPrint('Failed to play sound: $soundPath - $e');
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
    try {
      await _bgmPlayer.setSource(AssetSource(AppSounds.soundtrack));
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.setVolume(_bgmVolume);
      await _bgmPlayer.resume();
    } catch (e) {
      debugPrint('Failed to play BGM: $e');
    }
  }

  /// Pause background music
  Future<void> pauseBGM() async {
    try {
      await _bgmPlayer.pause();
    } catch (e) {
      debugPrint('Failed to pause BGM: $e');
    }
  }

  /// Resume background music
  Future<void> resumeBGM() async {
    try {
      await _bgmPlayer.resume();
    } catch (e) {
      debugPrint('Failed to resume BGM: $e');
    }
  }

  /// Stop background music
  Future<void> stopBGM() async {
    try {
      await _bgmPlayer.stop();
    } catch (e) {
      debugPrint('Failed to stop BGM: $e');
    }
  }

  /// Enable or disable all sounds
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Toggle sound on/off
  void toggle() {
    _enabled = !_enabled;
  }

  /// Dispose BGM player
  void dispose() {
    _bgmPlayer.dispose();
  }
}
