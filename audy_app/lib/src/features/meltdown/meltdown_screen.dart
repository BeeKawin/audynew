import 'dart:async';
import 'dart:math' show pi, sin;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_routes.dart';
import '../../core/app_sounds.dart';
import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../state/audy_controller.dart';
import 'wave_painter.dart';

/// Meltdown protection screen
///
/// Provides a calm, soothing environment with:
/// - Animated colored waves background
/// - 5-minute countdown timer
/// - Relaxing frequency music
/// - Spinning mascot placeholder
/// - Return button after timer completes
///
/// Designed for autism-friendly sensory regulation.
class MeltdownScreen extends StatefulWidget {
  const MeltdownScreen({super.key});

  @override
  State<MeltdownScreen> createState() => _MeltdownScreenState();
}

class _MeltdownScreenState extends State<MeltdownScreen>
    with SingleTickerProviderStateMixin {
  // Timer state
  static const int _totalSeconds = 5 * 60; // 5 minutes
  int _remainingSeconds = _totalSeconds;
  Timer? _timer;

  // Audio
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Animation for spinning mascot
  late AnimationController _spinController;

  // Fade-in controller for the return button
  double _returnButtonOpacity = 0.0;

  @override
  void initState() {
    super.initState();

    // Set immersive mode (hide system UI for calm environment)
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );

    // Initialize spin controller - slow rotation (20 seconds per full rotation)
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Start timer
    _startTimer();

    // Initialize and play relaxing audio
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    try {
      // Set volume to 0 initially for fade-in effect
      await _audioPlayer.setVolume(0.0);

      // Set the audio source and wait for it to be ready
      await _audioPlayer.setSource(AssetSource(AppSounds.relaxingMusic));

      // Set release mode to loop
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);

      // Wait for the source to be fully loaded before resuming
      await _audioPlayer.resume();

      // Gradually fade in volume over 3 seconds
      await _fadeInVolume();
    } catch (e) {
      // Audio not available - continue without it
      debugPrint('Relaxing music not available: $e');
    }
  }

  Future<void> _fadeInVolume() async {
    const steps = 30; // 30 steps over 3 seconds
    const stepDuration = Duration(milliseconds: 100);
    const targetVolume = 0.5; // 50% volume (calm, not overwhelming)

    for (int i = 0; i <= steps; i++) {
      final volume = (i / steps) * targetVolume;
      await _audioPlayer.setVolume(volume);
      await Future.delayed(stepDuration);
    }
  }

  Future<void> _fadeOutVolume() async {
    const steps = 10; // Quick fade out
    const stepDuration = Duration(milliseconds: 100);

    final currentVolume = _audioPlayer.volume;

    for (int i = steps; i >= 0; i--) {
      final volume = (i / steps) * currentVolume;
      await _audioPlayer.setVolume(volume);
      await Future.delayed(stepDuration);
    }

    await _audioPlayer.stop();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        // Show return button with gentle fade-in
        _showReturnButton();
      }
    });
  }

  void _showReturnButton() {
    // Gentle 1-second fade-in
    Future.microtask(() async {
      const steps = 20;
      const stepDuration = Duration(milliseconds: 50);

      for (int i = 0; i <= steps; i++) {
        if (!mounted) return; // Stop if widget is disposed
        setState(() {
          _returnButtonOpacity = i / steps;
        });
        await Future.delayed(stepDuration);
      }
    });
  }

  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _onReturnToGames() async {
    // Get controller before async operations
    final controller = AudyScope.of(context);

    // Fade out audio (don't let audio errors block navigation)
    try {
      await _fadeOutVolume();
    } catch (e) {
      debugPrint('Audio fade out error: $e');
    }

    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    // Reset meltdown state so the cycle can start again
    try {
      await controller.resetMeltdownState();
    } catch (e) {
      debugPrint('Reset meltdown state error: $e');
    }

    if (mounted) {
      // Navigate back to games with gentle fade transition
      Navigator.of(context).pushReplacementNamed(AppRoutes.games);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    _spinController.dispose();

    // Restore system UI when leaving
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AudyBackground(
        child: Stack(
          children: [
            // Wave background
            const AnimatedWaveBackground(),

            // Main content
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Spinning mascot placeholder
                    _buildSpinningMascot(),

                    const SizedBox(height: 48),

                    // Timer display
                    _buildTimerDisplay(),

                    const SizedBox(height: 24),

                    // Calm text
                    Text(
                      'Take a break',
                      style: AudyTypography.headingMedium.copyWith(
                        color: AudyColors.textPrimary.withValues(alpha: 0.8),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Return button (appears after timer)
                    _buildReturnButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpinningMascot() {
    return AnimatedBuilder(
      animation: _spinController,
      builder: (context, child) {
        // Slow rotation combined with gentle floating effect
        final rotation = _spinController.value * 2 * pi;
        final floatOffset = sin(_spinController.value * 2 * pi) * 8.0;

        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: Transform.rotate(
            angle: rotation,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: AudyColors.skyBlue.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AudyColors.skyBlue.withValues(alpha: 0.4),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AudyColors.skyBlue.withValues(alpha: 0.15),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/mascot/Neutral.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to icon if image not found
                    return Center(
                      child: Icon(
                        Icons.sentiment_satisfied_rounded,
                        size: 80,
                        color: AudyColors.skyBlue,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimerDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AudySpacing.radiusXLarge),
        border: Border.all(color: AudyColors.borderLight, width: 2),
        boxShadow: AudyShadows.cardShadow,
      ),
      child: Text(
        _formattedTime,
        style: AudyTypography.displayLarge.copyWith(
          fontSize: 64,
          color: AudyColors.textPrimary,
          fontWeight: FontWeight.w300,
          letterSpacing: 4,
        ),
      ),
    );
  }

  Widget _buildReturnButton() {
    return AnimatedOpacity(
      opacity: _returnButtonOpacity,
      duration: const Duration(milliseconds: 100),
      child: GestureDetector(
        onTap: _returnButtonOpacity > 0.5 ? _onReturnToGames : null,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AudySpacing.cardPadding * 1.5,
            vertical: AudySpacing.elementGap,
          ),
          decoration: BoxDecoration(
            color: AudyColors.mintGreen,
            borderRadius: BorderRadius.circular(AudySpacing.radiusXLarge),
            boxShadow: [
              BoxShadow(
                color: AudyColors.mintGreen.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.games_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                'Return to Games',
                style: AudyTypography.buttonText.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
