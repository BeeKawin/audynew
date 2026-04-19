import 'package:flutter/material.dart';
import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';
import 'minipuzzle_game_screen.dart';
import 'minipuzzle_models.dart';

// Helper function to get localized string
String _tr(BuildContext context, String key, {Map<String, String>? params}) {
  return AudyScope.of(context).tr(key, params: params);
}

/// Level selection screen for MiniPuzzle
/// User selects difficulty level for the chosen game
class MiniPuzzleLevelSelect extends StatelessWidget {
  final MiniPuzzleType gameType;

  const MiniPuzzleLevelSelect({super.key, required this.gameType});

  static const List<MiniPuzzleDifficulty> _levels = [
    MiniPuzzleDifficulty.easy,
    MiniPuzzleDifficulty.medium,
    MiniPuzzleDifficulty.hard,
  ];

  Color _getGameColor() {
    switch (gameType) {
      case MiniPuzzleType.pattern:
        return const Color(0xFF9EC8F2);
      case MiniPuzzleType.sorting:
        return const Color(0xFFF6B9D7);
      case MiniPuzzleType.puzzle:
        return const Color(0xFFB8E8C4);
    }
  }

  IconData _getGameIcon() {
    switch (gameType) {
      case MiniPuzzleType.pattern:
        return Icons.auto_fix_high_rounded;
      case MiniPuzzleType.sorting:
        return Icons.category_rounded;
      case MiniPuzzleType.puzzle:
        return Icons.extension_rounded;
    }
  }

  String _getGameTitleKey() {
    switch (gameType) {
      case MiniPuzzleType.pattern:
        return 'minipuzzle_pattern';
      case MiniPuzzleType.sorting:
        return 'minipuzzle_sorting';
      case MiniPuzzleType.puzzle:
        return 'minipuzzle_puzzle';
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
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AudyBackButton(
                        label: _tr(context, 'back'),
                        onPressed: () {
                          SoundService.instance.playTap();
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(height: adaptive.space(28)),
                      Row(
                        children: [
                          Icon(
                            _getGameIcon(),
                            size: adaptive.space(32),
                            color: gameColor,
                          ),
                          SizedBox(width: adaptive.space(12)),
                          Text(
                            _tr(context, _getGameTitleKey()),
                            style: TextStyle(
                              fontSize: adaptive.space(28),
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF243A5A),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: adaptive.space(8)),
                      Text(
                        _tr(context, 'minipuzzle_select_level'),
                        style: TextStyle(
                          fontSize: adaptive.space(16),
                          color: const Color(0xFF60758F),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: adaptive.space(32)),

            // Level selection cards
            ..._levels.map(
              (level) => Padding(
                padding: EdgeInsets.only(bottom: adaptive.space(16)),
                child: _LevelCard(
                  level: level,
                  gameColor: gameColor,
                  adaptive: adaptive,
                  onTap: () {
                    SoundService.instance.playTap();
                    _selectLevel(context, level);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _selectLevel(BuildContext context, MiniPuzzleDifficulty level) {
    debugPrint('Selecting level: $level for game: $gameType');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            MiniPuzzleGameScreen(gameType: gameType, difficulty: level),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final MiniPuzzleDifficulty level;
  final Color gameColor;
  final AudyAdaptive adaptive;
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.gameColor,
    required this.adaptive,
    required this.onTap,
  });

  String _getLevelKey() {
    switch (level) {
      case MiniPuzzleDifficulty.easy:
        return 'minipuzzle_easy';
      case MiniPuzzleDifficulty.medium:
        return 'minipuzzle_medium';
      case MiniPuzzleDifficulty.hard:
        return 'minipuzzle_hard';
    }
  }

  String _getDescriptionKey() {
    switch (level) {
      case MiniPuzzleDifficulty.easy:
        return 'minipuzzle_easy_desc';
      case MiniPuzzleDifficulty.medium:
        return 'minipuzzle_medium_desc';
      case MiniPuzzleDifficulty.hard:
        return 'minipuzzle_hard_desc';
    }
  }

  IconData _getLevelIcon() {
    switch (level) {
      case MiniPuzzleDifficulty.easy:
        return Icons.sentiment_satisfied_rounded;
      case MiniPuzzleDifficulty.medium:
        return Icons.sentiment_neutral_rounded;
      case MiniPuzzleDifficulty.hard:
        return Icons.sentiment_very_satisfied_rounded;
    }
  }

  Color _getLevelColor() {
    switch (level) {
      case MiniPuzzleDifficulty.easy:
        return const Color(0xFFB8E8C4);
      case MiniPuzzleDifficulty.medium:
        return const Color(0xFFFFF2A8);
      case MiniPuzzleDifficulty.hard:
        return const Color(0xFFFFB3BA);
    }
  }

  @override
  Widget build(BuildContext context) {
    final levelColor = _getLevelColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(adaptive.space(20)),
        decoration: BoxDecoration(
          color: AudyColors.backgroundCard,
          borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
          border: Border.all(color: gameColor.withValues(alpha: 0.4), width: 3),
          boxShadow: AudyShadows.cardShadow,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: adaptive.space(64),
              height: adaptive.space(64),
              decoration: BoxDecoration(
                color: levelColor.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getLevelIcon(),
                size: adaptive.space(32),
                color: const Color(0xFF243A5A),
              ),
            ),
            SizedBox(width: adaptive.space(20)),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _tr(context, _getLevelKey()),
                    style: TextStyle(
                      fontSize: adaptive.space(20),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF243A5A),
                    ),
                  ),
                  SizedBox(height: adaptive.space(4)),
                  Text(
                    _tr(context, _getDescriptionKey()),
                    style: TextStyle(
                      fontSize: adaptive.space(14),
                      color: const Color(0xFF60758F),
                    ),
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: gameColor,
              size: adaptive.space(24),
            ),
          ],
        ),
      ),
    );
  }
}
