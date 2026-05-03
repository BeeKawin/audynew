import 'dart:math' show sin;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/sound_service.dart';

/// Callback type for point celebration events
typedef PointCelebrationCallback =
    void Function(int points, int totalPoints, int level, bool isLevelUp);

/// Celebration dialog shown when points are earned
/// Features sparkle animation, point display, and level progress
class PointCelebrationDialog extends StatefulWidget {
  final int points;
  final int totalPoints;
  final int currentLevel;
  final int nextLevelThreshold;
  final String nextLevelName;
  final bool isLevelUp;
  final String? newLevelName;
  final VoidCallback onClose;

  const PointCelebrationDialog({
    super.key,
    required this.points,
    required this.totalPoints,
    required this.currentLevel,
    required this.nextLevelThreshold,
    required this.nextLevelName,
    required this.isLevelUp,
    this.newLevelName,
    required this.onClose,
  });

  @override
  State<PointCelebrationDialog> createState() => _PointCelebrationDialogState();
}

class _PointCelebrationDialogState extends State<PointCelebrationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();
    // Play points earned sound
    SoundService.instance.playPoints();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: widget.onClose,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFCDD2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Color(0xFFC62828),
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Wiggle mascot animation
            SizedBox(
              height: 200,
              child: AnimatedBuilder(
                animation: _sparkleController,
                builder: (context, child) {
                  // Continuous wiggle: rotate ±10 degrees using sine wave
                  final wiggleAngle =
                      sin(_sparkleController.value * 2 * 3.14159) *
                      0.1745; // ±10 degrees in radians
              return Transform.rotate(
                  angle: wiggleAngle,
                  child: Image.asset(
                    'assets/mascot/Heart.png',
                    width: 200,
                    height: 200,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF2A8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.celebration_rounded,
                          size: 100,
                          color: Color(0xFFF5C532),
                        ),
                      );
                    },
                  ),
                );
                },
              ),
            ),
            // Points display or Level Up display
            if (widget.isLevelUp) ...[
              const Icon(
                Icons.workspace_premium,
                size: 64,
                color: Color(0xFFF5C532),
              ),
              const SizedBox(height: 16),
              Text(
                'LEVEL UP!',
                style: GoogleFonts.fredoka(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF243A5A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You reached ${widget.newLevelName ?? widget.nextLevelName}!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF60758F),
                ),
              ),
              const SizedBox(height: 16),
              // Full progress bar for new level
              _LevelProgressBar(
                progress: 0.0,
                currentPoints: widget.totalPoints,
                nextLevelThreshold: _getNextLevelThreshold(
                  widget.currentLevel + 1,
                ),
                nextLevelName: _getNextLevelName(widget.currentLevel + 1),
              ),
            ] else ...[
              Text(
                '+${widget.points} Points!',
                style: GoogleFonts.fredoka(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF243A5A),
                ),
              ),
              const SizedBox(height: 16),
              // Level progress bar
              _LevelProgressBar(
                progress:
                    (widget.totalPoints -
                        _getLevelThreshold(widget.currentLevel)) /
                    (widget.nextLevelThreshold -
                        _getLevelThreshold(widget.currentLevel)),
                currentPoints: widget.totalPoints,
                nextLevelThreshold: widget.nextLevelThreshold,
                nextLevelName: widget.nextLevelName,
              ),
            ],
            const SizedBox(height: 24),
            // Continue button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isLevelUp
                      ? const Color(0xFFF5C532)
                      : const Color(0xFF69E0A0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  widget.isLevelUp ? 'Awesome!' : 'Continue',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getLevelThreshold(int level) {
    if (level >= 4) return 1000;
    if (level >= 3) return 500;
    if (level >= 2) return 250;
    if (level >= 1) return 100;
    return 0;
  }

  int _getNextLevelThreshold(int level) {
    if (level >= 4) return 2000;
    if (level >= 3) return 1000;
    if (level >= 2) return 500;
    if (level >= 1) return 250;
    return 100;
  }

  String _getNextLevelName(int level) {
    final names = ['Beginner', 'Learner', 'Explorer', 'Expert', 'Master'];
    if (level >= names.length) return 'Max Level';
    return names[level];
  }
}

class _LevelProgressBar extends StatelessWidget {
  final double progress;
  final int currentPoints;
  final int nextLevelThreshold;
  final String nextLevelName;

  const _LevelProgressBar({
    required this.progress,
    required this.currentPoints,
    required this.nextLevelThreshold,
    required this.nextLevelName,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final pointsNeeded = nextLevelThreshold - currentPoints;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: clampedProgress,
            minHeight: 16,
            backgroundColor: const Color(0xFFE2E5EA),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF69E0A0)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          pointsNeeded <= 0
              ? 'Max Level!'
              : '$currentPoints / $nextLevelThreshold to $nextLevelName',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF60758F),
          ),
        ),
      ],
    );
  }
}
