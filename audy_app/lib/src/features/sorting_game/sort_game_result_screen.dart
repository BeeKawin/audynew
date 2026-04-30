import 'package:flutter/material.dart';

import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';
import '../../widgets/point_celebration_dialog.dart';
import 'sorting_game_models.dart';
import 'sort_game_widgets.dart';

// Helper function to get localized string
String _tr(BuildContext context, String key, {Map<String, String>? params}) {
  return AudyScope.of(context).tr(key, params: params);
}

class SortGameResultScreen extends StatefulWidget {
  const SortGameResultScreen({
    super.key,
    required this.sessionData,
    required this.theme,
    required this.levelName,
    required this.onPlayAgain,
    required this.onDone,
  });

  final SortGameSessionData sessionData;
  final SortTheme theme;
  final String levelName;
  final VoidCallback onPlayAgain;
  final VoidCallback onDone;

  @override
  State<SortGameResultScreen> createState() => _SortGameResultScreenState();
}

class _SortGameResultScreenState extends State<SortGameResultScreen> {
  bool _celebrationShown = false;

  int get accuracyPercent {
    if (widget.sessionData.totalActions == 0) return 0;
    return ((widget.sessionData.correctActions /
                widget.sessionData.totalActions) *
            100)
        .round();
  }

  int get totalStarsEarned => widget.sessionData.totalStars;
  int get maxStars => widget.sessionData.roundResults.fold<int>(
      0, (sum, r) => sum + r.correctCount + r.incorrectCount);

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

    final controller = AudyScope.of(context);

    // Calculate points: 3 points per correct action
    final pointsEarned = widget.sessionData.correctActions * 3;

    if (pointsEarned > 0 && mounted) {
      // Calculate values BEFORE adding points
      final oldPoints = controller.learningPoints;
      final newPoints = oldPoints + pointsEarned;
      final oldLevel = _getLevelFromPoints(oldPoints);
      final newLevel = _getLevelFromPoints(newPoints);
      final isLevelUp = newLevel > oldLevel;

      // Track sorting game completion for quests
      controller.trackSortingCompleted();

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
    } else {
      // Still track completion even if no points
      controller.trackSortingCompleted();
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
    return AudyResponsivePage(
      scrollable: true,
      builder: (context, adaptive) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () {
                    SoundService.instance.playTap();
                    widget.onDone();
                  },
                  borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
                  child: SizedBox(
                    width: adaptive.space(48),
                    height: adaptive.space(48),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      size: AudySpacing.iconMedium,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: adaptive.space(24)),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.celebration_rounded,
                    size: adaptive.space(80),
                    color: widget.theme.primaryColor,
                  ),
                  SizedBox(height: adaptive.space(12)),
                  Text(
                    _tr(context, 'wonderful'),
                    style: AudyTypography.displayLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: adaptive.space(4)),
                  Text(
                    _tr(
                      context,
                      'level_complete',
                      params: {'level': widget.levelName},
                    ),
                    style: AudyTypography.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: adaptive.space(24)),
            // Expanded(
            //   child: ListView(
            //     children: [
            _buildStarsCard(adaptive),
            SizedBox(height: adaptive.space(12)),
            _buildSummaryCard(adaptive),
            SizedBox(height: adaptive.space(12)),
            _buildRoundBreakdownCard(adaptive),
            SizedBox(height: adaptive.space(12)),
            _buildAdaptiveInsightCard(adaptive),
            //     ],
            //   ),
            // ),
            SizedBox(height: adaptive.space(12)),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: adaptive.space(12),
              runSpacing: adaptive.space(8),
              children: [
                SizedBox(
                  width: adaptive.space(160),
                  child: ElevatedButton(
                    onPressed: () {
                      SoundService.instance.playTap();
                      widget.onPlayAgain();
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
                      minimumSize: Size(double.infinity, adaptive.space(56)),
                    ),
                    child: Text(
                      _tr(context, 'play_again'),
                      style: AudyTypography.buttonText,
                    ),
                  ),
                ),
                SizedBox(
                  width: adaptive.space(160),
                  child: ElevatedButton(
                    onPressed: () {
                      SoundService.instance.playTap();
                      widget.onDone();
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
                      minimumSize: Size(double.infinity, adaptive.space(56)),
                    ),
                    child: Text(
                      _tr(context, 'done'),
                      style: AudyTypography.buttonText,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: adaptive.space(24)),
          ],
        );
      },
    );
  }

  Widget _buildStarsCard(AudyAdaptive adaptive) {
    return Container(
      padding: EdgeInsets.all(adaptive.space(20)),
      decoration: BoxDecoration(
        color: AudyColors.backgroundCard,
        borderRadius: BorderRadius.circular(AudySpacing.radiusXLarge),
        boxShadow: AudyShadows.cardShadow,
      ),
      child: Column(
        children: [
          Text(
            _tr(context, 'your_score'),
            style: AudyTypography.headingSmall,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: adaptive.space(12)),
          StarRewardDisplay(
            starsEarned: totalStarsEarned,
            maxStars: maxStars,
            starSize: adaptive.space(48),
          ),
          SizedBox(height: adaptive.space(8)),
          Text(
            _tr(
              context,
              'stars_format',
              params: {
                'earned': totalStarsEarned.toString(),
                'max': maxStars.toString(),
              },
            ),
            style: AudyTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(AudyAdaptive adaptive) {
    return Container(
      padding: EdgeInsets.all(adaptive.space(20)),
      decoration: BoxDecoration(
        color: AudyColors.backgroundCard,
        borderRadius: BorderRadius.circular(AudySpacing.radiusXLarge),
        boxShadow: AudyShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_tr(context, 'summary'), style: AudyTypography.headingSmall),
          SizedBox(height: adaptive.space(12)),
          _SummaryRow(
            label: _tr(context, 'accuracy'),
            value: '$accuracyPercent%',
            color: accuracyPercent >= 80
                ? AudyColors.mintGreen
                : accuracyPercent >= 60
                ? AudyColors.skyBlue
                : AudyColors.warning,
            adaptive: adaptive,
          ),
          SizedBox(height: adaptive.space(6)),
          _SummaryRow(
            label: _tr(context, 'correct'),
            value: '${widget.sessionData.correctActions}',
            color: AudyColors.mintGreen,
            adaptive: adaptive,
          ),
          SizedBox(height: adaptive.space(6)),
          _SummaryRow(
            label: _tr(context, 'try_again'),
            value: '${widget.sessionData.incorrectActions}',
            color: AudyColors.warning,
            adaptive: adaptive,
          ),
          SizedBox(height: adaptive.space(6)),
          _SummaryRow(
            label: _tr(context, 'hints_used'),
            value: '${widget.sessionData.hintsUsed}',
            color: AudyColors.warning,
            adaptive: adaptive,
          ),
        ],
      ),
    );
  }

  Widget _buildRoundBreakdownCard(AudyAdaptive adaptive) {
    return Container(
      padding: EdgeInsets.all(adaptive.space(20)),
      decoration: BoxDecoration(
        color: AudyColors.backgroundCard,
        borderRadius: BorderRadius.circular(AudySpacing.radiusXLarge),
        boxShadow: AudyShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tr(context, 'round_breakdown'),
            style: AudyTypography.headingSmall,
          ),
          SizedBox(height: adaptive.space(12)),
          ...widget.sessionData.roundResults.map((round) {
            final roundAccuracy = round.correctCount + round.incorrectCount > 0
                ? ((round.correctCount /
                              (round.correctCount + round.incorrectCount)) *
                          100)
                      .round()
                : 0;

            return Padding(
              padding: EdgeInsets.only(bottom: adaptive.space(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    runAlignment: WrapAlignment.center,
                    spacing: adaptive.space(8),
                    runSpacing: adaptive.space(4),
                    children: [
                      Text(
                        '${_tr(context, 'round')} ${round.roundIndex + 1}',
                        style: AudyTypography.labelMedium,
                      ),
                      Wrap(
                        alignment: WrapAlignment.end,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: adaptive.space(8),
                        runSpacing: adaptive.space(4),
                        children: [
                          Text(
                            '${round.correctCount}/${round.correctCount + round.incorrectCount}',
                            style: AudyTypography.bodyMedium,
                          ),
                          Text(
                            '$roundAccuracy%',
                            style: TextStyle(
                              fontSize: adaptive.space(16),
                              fontWeight: FontWeight.w700,
                              color: roundAccuracy >= 80
                                  ? AudyColors.mintGreen
                                  : AudyColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: adaptive.space(4)),
                  Wrap(
                    spacing: 2,
                    children: List.generate(
                      round.correctCount + round.incorrectCount,
                      (i) {
                        return Icon(
                          Icons.star_rounded,
                          size: adaptive.space(20),
                          color: i < round.starsEarned
                              ? AudyColors.starGold
                              : AudyColors.starSilver,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAdaptiveInsightCard(AudyAdaptive adaptive) {
    String insight;
    IconData insightIcon;
    Color insightColor;

    if (accuracyPercent >= 90) {
      insight = _tr(context, 'insight_harder_levels');
      insightIcon = Icons.trending_up_rounded;
      insightColor = AudyColors.mintGreen;
    } else if (accuracyPercent >= 60) {
      insight = _tr(context, 'insight_good_progress');
      insightIcon = Icons.thumb_up_rounded;
      insightColor = AudyColors.skyBlue;
    } else {
      insight = _tr(context, 'insight_easier_levels');
      insightIcon = Icons.lightbulb_rounded;
      insightColor = AudyColors.warning;
    }

    return Container(
      padding: EdgeInsets.all(adaptive.space(20)),
      decoration: BoxDecoration(
        color: insightColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AudySpacing.radiusXLarge),
        border: Border.all(
          color: insightColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: adaptive.space(8),
        children: [
          Icon(insightIcon, size: adaptive.space(32), color: insightColor),
          Flexible(
            child: Text(
              insight,
              style: TextStyle(
                fontSize: adaptive.space(16),
                fontWeight: FontWeight.w600,
                color: insightColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.color,
    required this.adaptive,
  });

  final String label;
  final String value;
  final Color color;
  final AudyAdaptive adaptive;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      runAlignment: WrapAlignment.center,
      spacing: adaptive.space(8),
      runSpacing: adaptive.space(4),
      children: [
        Text(label, style: AudyTypography.bodyMedium),
        Text(
          value,
          style: TextStyle(
            fontSize: adaptive.space(18),
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
