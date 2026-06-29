import 'package:flutter/material.dart';

import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';
import '../../widgets/point_celebration_dialog.dart';
import '../sorting_game/sort_game_widgets.dart' show StarRewardDisplay;
import 'flashcard_models.dart';

String _tr(BuildContext context, String key, {Map<String, String>? params}) {
  return AudyScope.of(context).tr(key, params: params);
}

class FlashCardResultScreen extends StatefulWidget {
  const FlashCardResultScreen({
    super.key,
    required this.sessionData,
    required this.primaryColor,
    required this.levelName,
    required this.onPlayAgain,
    required this.onDone,
  });

  final FlashSessionData sessionData;
  final Color primaryColor;
  final String levelName;
  final VoidCallback onPlayAgain;
  final VoidCallback onDone;

  @override
  State<FlashCardResultScreen> createState() => _FlashCardResultScreenState();
}

class _FlashCardResultScreenState extends State<FlashCardResultScreen> {
  bool _celebrationShown = false;

  int get accuracyPercent {
    final total = widget.sessionData.totalActions;
    if (total == 0) return 0;
    return ((widget.sessionData.correctSubmits / total) * 100).round();
  }

  @override
  void initState() {
    super.initState();
    SoundService.instance.playGameComplete();
    SoundService.instance.playBearCompletionFeedback(
      score: widget.sessionData.totalStars,
      maxScore: widget.sessionData.maxStars,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showCelebration();
    });
  }

  Future<void> _showCelebration() async {
    if (_celebrationShown) return;
    _celebrationShown = true;

    final controller = AudyScope.of(context);
    final pointsEarned = widget.sessionData.correctSubmits * 5;

    if (pointsEarned > 0 && mounted) {
      final oldPoints = controller.learningPoints;
      final newPoints = oldPoints + pointsEarned;
      final oldLevel = _getLevelFromPoints(oldPoints);
      final newLevel = _getLevelFromPoints(newPoints);
      final isLevelUp = newLevel > oldLevel;

      await controller.addPoints(pointsEarned);

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
            newLevelName: isLevelUp ? _getLevelName(dialogContext, newLevel) : null,
            onClose: () => Navigator.of(dialogContext).pop(),
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
            Icon(
              Icons.celebration_rounded,
              size: adaptive.space(80),
              color: widget.primaryColor,
            ),
            SizedBox(height: adaptive.space(12)),
            Text(
              _tr(context, 'wonderful'),
              style: AudyTypography.displayLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: adaptive.space(4)),
            Text(
              _tr(context, 'level_complete', params: {'level': widget.levelName}),
              style: AudyTypography.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: adaptive.space(24)),
            _buildStarsCard(adaptive),
            SizedBox(height: adaptive.space(12)),
            _buildSummaryCard(adaptive),
            SizedBox(height: adaptive.space(24)),
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
                    style: _btnStyle(AudyColors.skyBlue, adaptive),
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
                    style: _btnStyle(AudyColors.mintGreen, adaptive),
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

  ButtonStyle _btnStyle(Color color, AudyAdaptive adaptive) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: AudyColors.textOnColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AudySpacing.radiusXLarge),
      ),
      elevation: 4,
      minimumSize: Size(double.infinity, adaptive.space(56)),
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
            starsEarned: widget.sessionData.totalStars,
            maxStars: widget.sessionData.maxStars,
            starSize: adaptive.space(40),
          ),
          SizedBox(height: adaptive.space(8)),
          Text(
            _tr(
              context,
              'stars_format',
              params: {
                'earned': widget.sessionData.totalStars.toString(),
                'max': widget.sessionData.maxStars.toString(),
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
          _row(_tr(context, 'accuracy'), '$accuracyPercent%',
              accuracyPercent >= 80 ? AudyColors.mintGreen : AudyColors.warning,
              adaptive),
          SizedBox(height: adaptive.space(6)),
          _row(_tr(context, 'flashcard_sentences_built'),
              '${widget.sessionData.correctSubmits}', AudyColors.mintGreen,
              adaptive),
          SizedBox(height: adaptive.space(6)),
          _row(_tr(context, 'try_again'), '${widget.sessionData.wrongSubmits}',
              AudyColors.warning, adaptive),
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color color, AudyAdaptive adaptive) {
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
