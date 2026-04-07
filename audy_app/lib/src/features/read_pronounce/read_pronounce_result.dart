import 'package:flutter/material.dart';

import 'read_pronounce_controller.dart';

class ReadPronounceResultScreen extends StatelessWidget {
  const ReadPronounceResultScreen({
    super.key,
    required this.result,
    required this.moduleName,
  });

  final ReadPronounceSessionResult result;
  final String moduleName;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final adaptive = _AudyAdaptive(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
        );

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: adaptive.isPhone ? 20 : adaptive.space(28),
                vertical: adaptive.isPhone ? 24 : adaptive.space(32),
              ),
              child: Column(
                children: [
                  _CelebrationHeader(adaptive: adaptive),
                  SizedBox(height: adaptive.space(24)),
                  _ModuleNameCard(adaptive: adaptive, moduleName: moduleName),
                  SizedBox(height: adaptive.space(20)),
                  _StarsDisplay(adaptive: adaptive, stars: result.stars),
                  SizedBox(height: adaptive.space(20)),
                  _AccuracyPanel(
                    adaptive: adaptive,
                    accuracyPercent: result.accuracyPercent,
                    correct: result.correctAttempts,
                    total: result.totalAttempts,
                  ),
                  SizedBox(height: adaptive.space(20)),
                  _SessionTimePanel(
                    adaptive: adaptive,
                    durationMs: result.sessionDurationMs,
                  ),
                  SizedBox(height: adaptive.space(32)),
                  _ActionButtons(
                    adaptive: adaptive,
                    onPlayAgain: () {
                      Navigator.pop(context);
                    },
                    onDone: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CelebrationHeader extends StatelessWidget {
  const _CelebrationHeader({required this.adaptive});

  final _AudyAdaptive adaptive;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: adaptive.space(100),
          height: adaptive.space(100),
          decoration: BoxDecoration(
            color: const Color(0xFF90F48A).withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.celebration_rounded,
            size: adaptive.space(52),
            color: const Color(0xFF69E0A0),
          ),
        ),
        SizedBox(height: adaptive.space(16)),
        Text(
          'All Done!',
          style: TextStyle(
            fontSize: adaptive.space(32),
            fontWeight: FontWeight.w900,
            color: const Color(0xFF243A5A),
          ),
        ),
        SizedBox(height: adaptive.space(8)),
        Text(
          'You completed the session!',
          style: TextStyle(
            fontSize: adaptive.space(16),
            color: const Color(0xFF617691),
          ),
        ),
      ],
    );
  }
}

class _ModuleNameCard extends StatelessWidget {
  const _ModuleNameCard({required this.adaptive, required this.moduleName});

  final _AudyAdaptive adaptive;
  final String moduleName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: adaptive.space(24),
        vertical: adaptive.space(12),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFBDD8F2).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(adaptive.space(16)),
        border: Border.all(color: const Color(0xFFBDD8F2), width: 2),
      ),
      child: Text(
        moduleName,
        style: TextStyle(
          fontSize: adaptive.space(18),
          fontWeight: FontWeight.w700,
          color: const Color(0xFF243A5A),
        ),
      ),
    );
  }
}

class _StarsDisplay extends StatelessWidget {
  const _StarsDisplay({required this.adaptive, required this.stars});

  final _AudyAdaptive adaptive;
  final int stars;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final filled = index < stars;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: adaptive.space(8)),
          child: Icon(
            Icons.star_rounded,
            size: adaptive.space(56),
            color: filled ? const Color(0xFFFFD700) : const Color(0xFFD0D8E0),
          ),
        );
      }),
    );
  }
}

class _AccuracyPanel extends StatelessWidget {
  const _AccuracyPanel({
    required this.adaptive,
    required this.accuracyPercent,
    required this.correct,
    required this.total,
  });

  final _AudyAdaptive adaptive;
  final int accuracyPercent;
  final int correct;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(adaptive.space(24)),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FC),
        borderRadius: BorderRadius.circular(adaptive.space(24)),
        border: Border.all(
          color: const Color(0xFFBDD8F2).withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF99A9C0).withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Accuracy',
            style: TextStyle(
              fontSize: adaptive.space(18),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF617691),
            ),
          ),
          SizedBox(height: adaptive.space(8)),
          Text(
            '$accuracyPercent%',
            style: TextStyle(
              fontSize: adaptive.space(56),
              fontWeight: FontWeight.w900,
              color: const Color(0xFF243A5A),
            ),
          ),
          SizedBox(height: adaptive.space(8)),
          Text(
            '$correct / $total correct',
            style: TextStyle(
              fontSize: adaptive.space(16),
              color: const Color(0xFF617691),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionTimePanel extends StatelessWidget {
  const _SessionTimePanel({required this.adaptive, required this.durationMs});

  final _AudyAdaptive adaptive;
  final int durationMs;

  @override
  Widget build(BuildContext context) {
    final seconds = (durationMs / 1000).round();
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    final timeLabel = minutes > 0
        ? '${minutes}m ${remainingSeconds}s'
        : '${remainingSeconds}s';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(adaptive.space(20)),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FC),
        borderRadius: BorderRadius.circular(adaptive.space(20)),
        border: Border.all(
          color: const Color(0xFFBDD8F2).withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer_rounded,
            size: adaptive.space(28),
            color: const Color(0xFF617691),
          ),
          SizedBox(width: adaptive.space(12)),
          Text(
            'Time: $timeLabel',
            style: TextStyle(
              fontSize: adaptive.space(18),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF243A5A),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.adaptive,
    required this.onPlayAgain,
    required this.onDone,
  });

  final _AudyAdaptive adaptive;
  final VoidCallback onPlayAgain;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onPlayAgain,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8FBCEC),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: adaptive.space(18)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adaptive.space(16)),
              ),
              elevation: 4,
            ),
            child: Text(
              'Play Again',
              style: TextStyle(
                fontSize: adaptive.space(18),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        SizedBox(width: adaptive.space(16)),
        Expanded(
          child: ElevatedButton(
            onPressed: onDone,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF69E0A0),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: adaptive.space(18)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(adaptive.space(16)),
              ),
              elevation: 4,
            ),
            child: Text(
              'Done',
              style: TextStyle(
                fontSize: adaptive.space(18),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AudyAdaptive {
  const _AudyAdaptive({required this.width, required this.height});

  final double width;
  final double height;

  bool get isPhone => width < 600;
  bool get isTablet => width >= 600 && width < 1024;
  bool get isDesktop => width >= 1024;

  double get scale => (width / 390).clamp(0.92, 1.35);
  double space(double value) => value * scale;
}
