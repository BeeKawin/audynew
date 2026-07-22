import 'dart:math' show pi, sin;

import 'package:flutter/material.dart';

/// Animated wave painter for meltdown screen
/// Creates gentle, overlapping sine waves in calming colors
/// Perfect for autism-friendly visual soothing
class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter({required this.animationValue}) : super(repaint: null);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw 4 overlapping waves with different properties
    // Each wave: color, amplitude, frequency, speed offset
    final waves = [
      _WaveConfig(
        color: const Color(0xFF7FDBDA).withValues(alpha: 0.3), // SkyBlue
        amplitude: 25.0,
        frequency: 0.015,
        speed: 1.0,
        yOffset: size.height * 0.65,
      ),
      _WaveConfig(
        color: const Color(0xFF98E07B).withValues(alpha: 0.25), // MintGreen
        amplitude: 35.0,
        frequency: 0.012,
        speed: 0.7,
        yOffset: size.height * 0.7,
      ),
      _WaveConfig(
        color: const Color(0xFFF1B4D3).withValues(alpha: 0.28), // BlushPink
        amplitude: 20.0,
        frequency: 0.018,
        speed: 1.3,
        yOffset: size.height * 0.6,
      ),
      _WaveConfig(
        color: const Color(0xFFE5D0F4).withValues(alpha: 0.22), // SoftLavender
        amplitude: 30.0,
        frequency: 0.01,
        speed: 0.5,
        yOffset: size.height * 0.75,
      ),
    ];

    for (final wave in waves) {
      _drawWave(canvas, size, wave);
    }
  }

  void _drawWave(Canvas canvas, Size size, _WaveConfig wave) {
    final path = Path();
    final paint = Paint()
      ..color = wave.color
      ..style = PaintingStyle.fill
      ..strokeWidth = 0;

    // Start from top-left
    path.moveTo(0, wave.yOffset);

    // Draw sine wave across the screen
    for (double x = 0; x <= size.width; x += 5) {
      final phase = (x * wave.frequency * 2 * pi) - 
                    (animationValue * 2 * pi * wave.speed);
      final y = wave.yOffset - (sin(phase) * wave.amplitude);
      path.lineTo(x, y);
    }

    // Close the path to bottom-right, bottom-left, and back to start
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

/// Configuration for a single wave
class _WaveConfig {
  final Color color;
  final double amplitude;
  final double frequency;
  final double speed;
  final double yOffset;

  _WaveConfig({
    required this.color,
    required this.amplitude,
    required this.frequency,
    required this.speed,
    required this.yOffset,
  });
}

/// Widget that displays animated waves for the meltdown screen
class AnimatedWaveBackground extends StatefulWidget {
  const AnimatedWaveBackground({super.key});

  @override
  State<AnimatedWaveBackground> createState() => _AnimatedWaveBackgroundState();
}

class _AnimatedWaveBackgroundState extends State<AnimatedWaveBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Very slow animation: 10 seconds for a full cycle
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: WavePainter(animationValue: _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}
