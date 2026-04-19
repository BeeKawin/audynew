import 'package:flutter/material.dart';
import '../../core/app_routes.dart';
import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';
import 'minipuzzle_controller.dart';
import 'minipuzzle_models.dart';
import 'games/pattern_game_widget.dart';
import 'games/sorting_game_widget.dart';
import 'games/puzzle_game_widget.dart';

// Helper function to get localized string
String _tr(BuildContext context, String key, {Map<String, String>? params}) {
  return AudyScope.of(context).tr(key, params: params);
}

/// Main game screen for MiniPuzzle
/// Displays the selected game with progress tracking
class MiniPuzzleGameScreen extends StatefulWidget {
  final MiniPuzzleType gameType;
  final MiniPuzzleDifficulty difficulty;

  const MiniPuzzleGameScreen({
    super.key,
    required this.gameType,
    required this.difficulty,
  });

  @override
  State<MiniPuzzleGameScreen> createState() => _MiniPuzzleGameScreenState();
}

class _MiniPuzzleGameScreenState extends State<MiniPuzzleGameScreen> {
  late MiniPuzzleController _controller;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _controller = MiniPuzzleController();
    _controller.startGame(widget.gameType, widget.difficulty);
    _controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    setState(() {}); // Just rebuild UI, no auto-navigation
  }

  Color _getGameColor() {
    switch (widget.gameType) {
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
          children: [
            // Header with round indicator
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
                const Spacer(),
                // Round indicator
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: adaptive.space(16),
                    vertical: adaptive.space(8),
                  ),
                  decoration: BoxDecoration(
                    color: gameColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _tr(
                      context,
                      'minipuzzle_round',
                      params: {'n': _controller.currentRound.toString()},
                    ),
                    style: TextStyle(
                      fontSize: adaptive.space(16),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF243A5A),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: adaptive.space(24)),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: _controller.currentRound / _controller.totalRounds,
                minHeight: adaptive.space(12),
                backgroundColor: const Color(0xFFE2E7EE),
                valueColor: AlwaysStoppedAnimation(gameColor),
              ),
            ),
            SizedBox(height: adaptive.space(32)),

            // Game content
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: adaptive.space(16)),
                child: _buildGameContent(adaptive, gameColor),
              ),
            ),

            // Feedback area
            if (_controller.showingFeedback)
              _buildFeedback(adaptive, gameColor),
          ],
        );
      },
    );
  }

  Widget _buildGameContent(AudyAdaptive adaptive, Color gameColor) {
    switch (widget.gameType) {
      case MiniPuzzleType.pattern:
        return PatternGameWidget(
          controller: _controller,
          adaptive: adaptive,
          gameColor: gameColor,
        );
      case MiniPuzzleType.sorting:
        return SortingGameWidget(
          controller: _controller,
          adaptive: adaptive,
          gameColor: gameColor,
        );
      case MiniPuzzleType.puzzle:
        return PuzzleGameWidget(
          controller: _controller,
          adaptive: adaptive,
          gameColor: gameColor,
        );
    }
  }

  Widget _buildFeedback(AudyAdaptive adaptive, Color gameColor) {
    final isCorrect = _controller.isCorrect;
    final bgColor = isCorrect ? AudyColors.mintGreen : AudyColors.warning;
    final isRoundComplete = _controller.roundComplete;
    final isLastRound = _controller.currentRound >= _controller.totalRounds;
    return Container(
      margin: EdgeInsets.only(top: adaptive.space(16)),
      padding: EdgeInsets.all(adaptive.space(16)),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
        border: Border.all(color: bgColor, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Feedback message
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.info_rounded,
                color: bgColor,
                size: adaptive.space(28),
              ),
              SizedBox(width: adaptive.space(12)),
              Text(
                _tr(context, _controller.feedbackKey),
                style: TextStyle(
                  fontSize: adaptive.space(18),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF243A5A),
                ),
              ),
            ],
          ),

          // Continue button (only show when round is complete)
          if (isRoundComplete) ...[
            SizedBox(height: adaptive.space(16)),
            ElevatedButton(
              onPressed: () {
                SoundService.instance.playTap();
                _handleContinue();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: gameColor,
                foregroundColor: AudyColors.textOnColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AudySpacing.radiusXLarge),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: adaptive.space(24),
                  vertical: adaptive.space(12),
                ),
              ),
              child: Text(
                isLastRound
                    ? _tr(context, 'see_results') // "See Results"
                    : _tr(context, 'continue'), // "Continue"
                style: TextStyle(
                  fontSize: adaptive.space(16),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _handleContinue() {
    if (_isNavigating) return;

    if (_controller.isSessionComplete) {
      // Navigate to results screen
      _isNavigating = true;
      final controller = AudyScope.of(context);
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.miniPuzzleResult,
        arguments: {
          'sessionData': _controller.getSessionData(),
          'controller': controller,
        },
      );
    } else {
      // Move to next round
      _controller.nextRound();
    }
  }
}
