import 'package:flutter/material.dart';

import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';
import '../../widgets/point_celebration_dialog.dart';

// Helper function to get localized string
String _tr(BuildContext context, String key, {Map<String, String>? params}) {
  return AudyScope.of(context).tr(key, params: params);
}

class ReactionTimePage extends StatelessWidget {
  const ReactionTimePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AudyScope.of(context);

    if (controller.isReactionGameComplete) {
      return const ReactionTimeResultPage();
    }

    return AudyResponsivePage(
      builder: (context, adaptive) {
        Color containerColor;
        IconData containerIcon;
        Color iconColor;
        String topText;

        final state = controller.reactionState;
        switch (state) {
          case ReactionGameState.idle:
            containerColor = const Color(0xFFBDD8F2);
            containerIcon = Icons.bolt_rounded;
            iconColor = const Color(0xFF243A5A);
            topText = _tr(context, 'tap_to_start');
            break;
          case ReactionGameState.waiting:
            containerColor = const Color(0xFFFF8D91);
            containerIcon = Icons.hourglass_empty_rounded;
            iconColor = Colors.white;
            topText = _tr(context, 'wait');
            break;
          case ReactionGameState.ready:
            containerColor = const Color(0xFF69E0A0);
            containerIcon = Icons.touch_app_rounded;
            iconColor = Colors.white;
            topText = _tr(context, 'tap_now');
            break;
          case ReactionGameState.tooEarly:
            containerColor = const Color(0xFFFF5252);
            containerIcon = Icons.cancel_rounded;
            iconColor = Colors.white;
            topText = _tr(context, 'too_early');
            break;
          case ReactionGameState.result:
            containerColor = const Color(0xFFBDD8F2);
            containerIcon = Icons.timer_rounded;
            iconColor = const Color(0xFF243A5A);
            topText = '${controller.currentReactionTimeMs} ms';
            break;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopRow(
              adaptive: adaptive,
              leadingLabel: _tr(context, 'back_home'),
              trailingText: _tr(
                context,
                'round_format',
                params: {
                  'current': controller.reactionRound.toString(),
                  'total': controller.reactionTotalRounds.toString(),
                },
              ),
            ),
            SizedBox(height: adaptive.space(24)),
            Center(
              child: Column(
                children: [
                  Text(
                    _tr(context, 'reaction_time'),
                    style: TextStyle(
                      fontSize: adaptive.space(28),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF243A5A),
                    ),
                  ),
                  SizedBox(height: adaptive.space(8)),
                  Text(
                    _tr(context, 'tap_when_green'),
                    style: TextStyle(
                      fontSize: adaptive.space(15),
                      color: const Color(0xFF617691),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: adaptive.space(20)),
            Center(
              child: Text(
                topText,
                style: TextStyle(
                  fontSize: adaptive.space(32),
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF243A5A),
                ),
              ),
            ),
            SizedBox(height: adaptive.space(16)),
            SizedBox(
              height: adaptive.isPhone ? 260 : 420,
              child: InkWell(
                onTap: () {
                  SoundService.instance.playTap();
                  controller.handleReactionContainerTap();
                },
                borderRadius: BorderRadius.circular(adaptive.space(28)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: BorderRadius.circular(adaptive.space(28)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF99A9C0).withValues(alpha: 0.15),
                        blurRadius: 22,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      containerIcon,
                      size: adaptive.isPhone ? 72 : 96,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: adaptive.space(16)),
            Center(
              child: Text(
                controller.reactionFeedback,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: adaptive.space(14),
                  color: const Color(0xFF60758F),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ReactionTimeResultPage extends StatefulWidget {
  const ReactionTimeResultPage({super.key});

  @override
  State<ReactionTimeResultPage> createState() => _ReactionTimeResultPageState();
}

class _ReactionTimeResultPageState extends State<ReactionTimeResultPage> {
  bool _celebrationShown = false;

  late AudyController controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 2. Safely grab the controller here, during a valid lifecycle phase
    controller = AudyScope.of(context);
  }

  @override
  void initState() {
    super.initState();
    // Show celebration after widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showCelebration();
      }
    });
  }

  Future<void> _showCelebration() async {
    if (_celebrationShown) return;
    _celebrationShown = true;

    // final controller = AudyScope.of(context);
    final pointsEarned = controller.reactionPointsEarned;

    if (pointsEarned >= 0 && mounted) {
      // Calculate values BEFORE adding points
      final oldPoints = controller.learningPoints;
      final newPoints = oldPoints + pointsEarned;
      final oldLevel = _getLevelFromPoints(oldPoints);
      final newLevel = _getLevelFromPoints(newPoints);
      final isLevelUp = newLevel > oldLevel;

      // Add points
      await controller.addPoints(pointsEarned);

      // Show celebration dialog
      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => PointCelebrationDialog(
            points: pointsEarned,
            totalPoints: newPoints,
            currentLevel: newLevel,
            nextLevelThreshold: _getNextLevelThreshold(newLevel),
            nextLevelName: _getLevelName(dialogContext, newLevel + 1),
            isLevelUp: isLevelUp,
            newLevelName: isLevelUp
                ? _getLevelName(dialogContext, newLevel)
                : null,
            onClose: () {
              Navigator.of(dialogContext).pop();
            },
          ),
        );
      }
    }
  }

  int _getLevelFromPoints(int points) {
    if (points >= 1000) return 4;
    if (points >= 500) return 3;
    if (points >= 250) return 2;
    if (points >= 100) return 1;
    return 0;
  }

  int _getNextLevelThreshold(int level) {
    final thresholds = [100, 250, 500, 1000, 2000];
    if (level >= thresholds.length) return 2000;
    return thresholds[level];
  }

  String _getLevelName(BuildContext context, int level) {
    final keys = ['beginner', 'learner', 'explorer', 'expert', 'master'];
    if (level >= keys.length) return _tr(context, 'master');
    return _tr(context, keys[level]);
  }

  @override
  Widget build(BuildContext context) {
    final controller = AudyScope.of(context);

    return AudyResponsivePage(
      builder: (context, adaptive) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopRow(
              adaptive: adaptive,
              leadingLabel: _tr(context, 'back_home'),
            ),
            SizedBox(height: adaptive.space(24)),
            Center(
              child: Column(
                children: [
                  Text(
                    _tr(context, 'reaction_time'),
                    style: TextStyle(
                      fontSize: adaptive.space(28),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF243A5A),
                    ),
                  ),
                  SizedBox(height: adaptive.space(8)),
                  Text(
                    _tr(context, 'great_job_rounds'),
                    style: TextStyle(
                      fontSize: adaptive.space(15),
                      color: const Color(0xFF617691),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: adaptive.space(24)),
            AudyPanel(
              adaptive: adaptive,
              child: Column(
                children: [
                  Text(
                    _tr(context, 'average'),
                    style: TextStyle(
                      fontSize: adaptive.space(18),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF617691),
                    ),
                  ),
                  SizedBox(height: adaptive.space(8)),
                  Text(
                    '${controller.reactionAverageMs} ms',
                    style: TextStyle(
                      fontSize: adaptive.space(56),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF243A5A),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: adaptive.space(20)),
            AudyPanel(
              adaptive: adaptive,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _tr(context, 'round_times'),
                    style: TextStyle(
                      fontSize: adaptive.space(18),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF243A5A),
                    ),
                  ),
                  SizedBox(height: adaptive.space(12)),
                  ...List.generate(controller.reactionTimes.length, (i) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: adaptive.space(8)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_tr(context, 'round')} ${i + 1}',
                            style: TextStyle(
                              fontSize: adaptive.space(16),
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF617691),
                            ),
                          ),
                          Text(
                            '${controller.reactionTimes[i]} ms',
                            style: TextStyle(
                              fontSize: adaptive.space(16),
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF243A5A),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (controller.reactionMisses > 0)
                    Padding(
                      padding: EdgeInsets.only(top: adaptive.space(8)),
                      child: Text(
                        '${_tr(context, 'too_early_taps')} ${controller.reactionMisses}',
                        style: TextStyle(
                          fontSize: adaptive.space(14),
                          color: AudyColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: adaptive.space(32)),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      SoundService.instance.playTap();
                      controller.resetReactionGame();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AudyColors.skyBlue,
                      foregroundColor: AudyColors.textOnColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AudySpacing.radiusXLarge,
                        ),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      _tr(context, 'play_again'),
                      style: AudyTypography.buttonText,
                    ),
                  ),
                ),
                const SizedBox(width: AudySpacing.elementGap),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      SoundService.instance.playTap();
                      controller.resetReactionGame();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AudyColors.mintGreen,
                      foregroundColor: AudyColors.textOnColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AudySpacing.radiusXLarge,
                        ),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      _tr(context, 'done'),
                      style: AudyTypography.buttonText,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: adaptive.space(16)),
          ],
        );
      },
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow({
    required this.adaptive,
    required this.leadingLabel,
    this.trailingText,
  });

  final AudyAdaptive adaptive;
  final String leadingLabel;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AudyBackButton(
            label: leadingLabel,
            onPressed: () {
              SoundService.instance.playTap();
              Navigator.pop(context);
            },
          ),
        ),
        if (trailingText != null)
          Text(
            trailingText!,
            style: TextStyle(
              fontSize: adaptive.space(16),
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}
