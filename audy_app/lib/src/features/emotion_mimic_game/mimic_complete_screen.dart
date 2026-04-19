import 'package:flutter/material.dart';

import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';
import '../../widgets/point_celebration_dialog.dart';

/// Final score screen shown when emotion mimic game is complete.
class MimicCompleteScreen extends StatefulWidget {
  const MimicCompleteScreen({super.key, required this.controller});

  final AudyController controller;

  @override
  State<MimicCompleteScreen> createState() => _MimicCompleteScreenState();
}

class _MimicCompleteScreenState extends State<MimicCompleteScreen> {
  bool _hasShownCelebration = false;

  int get stars {
    return widget.controller.mimicScore.clamp(0, 3);
  }

  int _getNextLevelThreshold(int level) {
    final thresholds = [100, 250, 500, 1000, 2000];
    if (level >= thresholds.length) return 2000;
    return thresholds[level];
  }

  String _getLevelName(int level) {
    final names = ['Beginner', 'Learner', 'Explorer', 'Expert', 'Master'];
    if (level >= names.length) return 'Master';
    return names[level];
  }

  int _getLevelFromPoints(int points) {
    if (points >= 1000) return 4;
    if (points >= 500) return 3;
    if (points >= 250) return 2;
    if (points >= 100) return 1;
    return 0;
  }

  @override
  void initState() {
    super.initState();
    // Track quest completion for mimic game
    widget.controller.trackMimicGameCompleted(durationSeconds: 0);
    // Play game complete sound
    SoundService.instance.playGameComplete();
    // Show celebration after first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showCelebrationIfNeeded();
      }
    });
  }

  Future<void> _showCelebrationIfNeeded() async {
    if (_hasShownCelebration || !mounted) return;

    // Calculate points earned during this game (5 points per correct answer)
    final pointsEarned = widget.controller.mimicScore * 5;

    if (pointsEarned > 0) {
      final oldPoints = widget.controller.learningPoints - pointsEarned;
      final oldLevel = _getLevelFromPoints(oldPoints);
      final newLevel = _getLevelFromPoints(widget.controller.learningPoints);
      final isLevelUp = newLevel > oldLevel;

      setState(() => _hasShownCelebration = true);

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => PointCelebrationDialog(
          points: pointsEarned,
          totalPoints: widget.controller.learningPoints,
          currentLevel: newLevel,
          nextLevelThreshold: _getNextLevelThreshold(newLevel),
          nextLevelName: _getLevelName(newLevel + 1),
          isLevelUp: isLevelUp,
          newLevelName: isLevelUp ? _getLevelName(newLevel) : null,
          onClose: () {
            Navigator.of(dialogContext).pop();
          },
        ),
      );
    } else {
      setState(() => _hasShownCelebration = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AudyResponsivePage(
      scrollable: false,
      builder: (context, adaptive) {
        return Column(
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () {
                    SoundService.instance.playTap();
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
                  child: SizedBox(
                    width: AudySpacing.touchTargetMin,
                    height: AudySpacing.touchTargetMin,
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      size: AudySpacing.iconMedium,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AudySpacing.sectionGap),
            const Icon(
              Icons.celebration_rounded,
              size: 80,
              color: AudyColors.mintGreen,
            ),
            const SizedBox(height: AudySpacing.elementGap),
            Text(
              widget.controller.tr('wonderful'),
              style: AudyTypography.displayLarge,
            ),
            const SizedBox(height: AudySpacing.sectionGap),
            Container(
              padding: const EdgeInsets.all(AudySpacing.cardPadding),
              decoration: BoxDecoration(
                color: AudyColors.backgroundCard,
                borderRadius: BorderRadius.circular(AudySpacing.radiusXLarge),
                boxShadow: AudyShadows.cardShadow,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final filled = index < stars;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          Icons.star_rounded,
                          size: 56,
                          color: filled
                              ? AudyColors.starGold
                              : AudyColors.starSilver,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AudySpacing.elementGap),
                  Text(
                    widget.controller.tr(
                      'score_format',
                      params: {
                        'score':
                            '${widget.controller.mimicScore} / ${widget.controller.mimicTotalRounds}',
                      },
                    ),
                    style: AudyTypography.headingLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.controller.tr('emotion_practice_complete'),
                    style: AudyTypography.bodyMedium,
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      SoundService.instance.playTap();
                      widget.controller.resetMimicGame();
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
                      widget.controller.tr('play_again'),
                      style: AudyTypography.buttonText,
                    ),
                  ),
                ),
                const SizedBox(width: AudySpacing.elementGap),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      SoundService.instance.playTap();
                      widget.controller.resetMimicGame();
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
                      widget.controller.tr('done'),
                      style: AudyTypography.buttonText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AudySpacing.sectionGap),
          ],
        );
      },
    );
  }
}
