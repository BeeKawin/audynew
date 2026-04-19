import 'package:flutter/material.dart';
import '../../core/app_routes.dart';
import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';
import '../../widgets/point_celebration_dialog.dart';
import 'minipuzzle_models.dart';

// Helper function to get localized string
String _tr(BuildContext context, String key, {Map<String, String>? params}) {
  return AudyScope.of(context).tr(key, params: params);
}

/// Result screen shown after completing a MiniPuzzle session
/// Displays stars, stats, and celebration dialog
class MiniPuzzleResultScreen extends StatefulWidget {
  final MiniPuzzleSessionData sessionData;
  final AudyController controller;

  const MiniPuzzleResultScreen({
    super.key,
    required this.sessionData,
    required this.controller,
  });

  @override
  State<MiniPuzzleResultScreen> createState() => _MiniPuzzleResultScreenState();
}

class _MiniPuzzleResultScreenState extends State<MiniPuzzleResultScreen> {
  bool _hasShownCelebration = false;
  late final int _pointsEarned;
  late final int _initialPoints;
  late final int _newPoints;
  late final int _newLevel;
  late final bool _isLevelUp;

  @override
  void initState() {
    super.initState();

    // Calculate all values SYNCHRONOUSLY before widget builds
    final controller = widget.controller;
    _pointsEarned = widget.sessionData.pointsEarned;

    // Track puzzle completion (may add quest rewards)
    controller.trackPuzzleCompleted();

    // Get points and calculate values immediately (sync)
    _initialPoints = controller.learningPoints;
    _newPoints = _initialPoints + _pointsEarned;
    final oldLevel = _getLevelFromPoints(_initialPoints);
    _newLevel = _getLevelFromPoints(_newPoints);
    _isLevelUp = _newLevel > oldLevel;

    // Show celebration dialog after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showCelebrationIfNeeded();
    });
  }

  Future<void> _showCelebrationIfNeeded() async {
    if (_hasShownCelebration || !mounted || _pointsEarned == 0) return;

    // Add points first
    await widget.controller.addPoints(_pointsEarned);

    if (!mounted) return;

    setState(() => _hasShownCelebration = true);

    // Store context before async gap
    final currentContext = context;
    await showDialog(
      // ignore: use_build_context_synchronously
      context: currentContext,
      barrierDismissible: false,
      builder: (dialogContext) => PointCelebrationDialog(
        points: _pointsEarned,
        totalPoints: _newPoints,
        currentLevel: _newLevel,
        nextLevelThreshold: _getNextLevelThreshold(_newLevel),
        nextLevelName: _getLevelNameEnglish(_newLevel + 1),
        isLevelUp: _isLevelUp,
        newLevelName: _isLevelUp ? _getLevelNameEnglish(_newLevel) : null,
        onClose: () {
          Navigator.of(dialogContext).pop();
        },
      ),
    );
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

  String _getLevelNameEnglish(int level) {
    final names = ['Beginner', 'Learner', 'Explorer', 'Expert', 'Master'];
    if (level >= names.length) return 'Max Level';
    return names[level];
  }

  String _getGameTitleKey() {
    switch (widget.sessionData.gameType) {
      case MiniPuzzleType.pattern:
        return 'minipuzzle_pattern';
      case MiniPuzzleType.sorting:
        return 'minipuzzle_sorting';
      case MiniPuzzleType.puzzle:
        return 'minipuzzle_puzzle';
    }
  }

  Color _getGameColor() {
    switch (widget.sessionData.gameType) {
      case MiniPuzzleType.pattern:
        return const Color(0xFF9EC8F2);
      case MiniPuzzleType.sorting:
        return const Color(0xFFF6B9D7);
      case MiniPuzzleType.puzzle:
        return const Color(0xFFB8E8C4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameColor = _getGameColor();

    return AudyResponsivePage(
      builder: (context, adaptive) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                InkWell(
                  onTap: () {
                    SoundService.instance.playTap();
                    Navigator.of(context).popUntil(
                      (route) => route.settings.name == AppRoutes.games,
                    );
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
            SizedBox(height: adaptive.space(16)),

            // Celebration content
            // Stars display
            Center(
              child: Icon(
                Icons.celebration_rounded,
                size: adaptive.space(80),
                color: gameColor,
              ),
            ),
            SizedBox(height: adaptive.space(16)),

            // Title
            Text(
              _tr(context, 'wonderful'),
              style: AudyTypography.displayLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: adaptive.space(8)),
            Text(
              _tr(context, _getGameTitleKey()),
              style: AudyTypography.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: adaptive.space(32)),

            // Stars earned
            Container(
              padding: EdgeInsets.all(adaptive.space(24)),
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
                  ),
                  SizedBox(height: adaptive.space(16)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final filled = index < widget.sessionData.stars;
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: adaptive.space(8),
                        ),
                        child: Icon(
                          Icons.star_rounded,
                          size: adaptive.space(56),
                          color: filled
                              ? AudyColors.starGold
                              : AudyColors.starSilver,
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: adaptive.space(8)),
                  Text(
                    '${widget.sessionData.totalCorrect} / ${widget.sessionData.totalRounds} ${_tr(context, 'correct').toLowerCase()}',
                    style: AudyTypography.bodyMedium,
                  ),
                ],
              ),
            ),
            SizedBox(height: adaptive.space(24)),

            // Stats
            Container(
              padding: EdgeInsets.all(adaptive.space(20)),
              decoration: BoxDecoration(
                color: AudyColors.backgroundCard,
                borderRadius: BorderRadius.circular(AudySpacing.radiusXLarge),
                boxShadow: AudyShadows.cardShadow,
              ),
              child: Column(
                children: [
                  _StatRow(
                    label: _tr(context, 'correct'),
                    value: '${widget.sessionData.totalCorrect}',
                    color: AudyColors.mintGreen,
                  ),
                  SizedBox(height: adaptive.space(12)),
                  _StatRow(
                    label: _tr(context, 'attempts'),
                    value: '${widget.sessionData.totalAttempts}',
                    color: AudyColors.skyBlue,
                  ),
                ],
              ),
            ),
            SizedBox(height: adaptive.space(32)),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      SoundService.instance.playTap();
                      // Replay same game
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.miniPuzzleGame,
                        arguments: {
                          'gameType': widget.sessionData.gameType,
                          'difficulty': widget.sessionData.difficulty,
                        },
                      );
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
                      minimumSize: Size(double.infinity, adaptive.space(60)),
                    ),
                    child: Text(
                      _tr(context, 'play_again'),
                      style: AudyTypography.buttonText,
                    ),
                  ),
                ),
                SizedBox(width: adaptive.space(16)),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      SoundService.instance.playTap();
                      Navigator.of(context).popUntil(
                        (route) => route.settings.name == AppRoutes.games,
                      );
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
                      minimumSize: Size(double.infinity, adaptive.space(60)),
                    ),
                    child: Text(
                      _tr(context, 'done'),
                      style: AudyTypography.buttonText,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AudyTypography.bodyLarge),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
