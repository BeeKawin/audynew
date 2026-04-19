import 'package:flutter/material.dart';
import '../../core/app_routes.dart';
import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';
import 'minipuzzle_models.dart';

// Helper function to get localized string
String _tr(BuildContext context, String key, {Map<String, String>? params}) {
  return AudyScope.of(context).tr(key, params: params);
}

/// Game selection screen for MiniPuzzle
/// User selects which mini-game to play
class MiniPuzzleGameSelection extends StatelessWidget {
  const MiniPuzzleGameSelection({super.key});

  static const List<MiniPuzzleGameInfo> _games = [
    MiniPuzzleGameInfo(
      type: MiniPuzzleType.pattern,
      titleKey: 'minipuzzle_pattern',
      icon: Icons.auto_fix_high_rounded,
      color: Color(0xFF9EC8F2),
      descriptionKey: 'minipuzzle_pattern_desc',
    ),
    MiniPuzzleGameInfo(
      type: MiniPuzzleType.sorting,
      titleKey: 'minipuzzle_sorting',
      icon: Icons.category_rounded,
      color: Color(0xFFF6B9D7),
      descriptionKey: 'minipuzzle_sorting_desc',
    ),
    MiniPuzzleGameInfo(
      type: MiniPuzzleType.puzzle,
      titleKey: 'minipuzzle_puzzle',
      icon: Icons.extension_rounded,
      color: Color(0xFFB8E8C4),
      descriptionKey: 'minipuzzle_puzzle_desc',
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
                        label: _tr(context, 'back_home'),
                        onPressed: () {
                          SoundService.instance.playTap();
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(height: adaptive.space(28)),
                      Text(
                        _tr(context, 'minipuzzle_title'),
                        style: TextStyle(
                          fontSize: adaptive.space(30),
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF243A5A),
                        ),
                      ),
                      SizedBox(height: adaptive.space(8)),
                      Text(
                        _tr(context, 'minipuzzle_select_game'),
                        style: TextStyle(
                          fontSize: adaptive.space(16),
                          color: const Color(0xFF60758F),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!adaptive.isPhone) const AudyMascot(size: 110),
              ],
            ),
            SizedBox(height: adaptive.space(32)),

            // Game selection cards
            ..._games.map(
              (game) => Padding(
                padding: EdgeInsets.only(bottom: adaptive.space(16)),
                child: _GameCard(
                  game: game,
                  adaptive: adaptive,
                  onTap: () {
                    SoundService.instance.playTap();
                    _selectGame(context, game.type);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _selectGame(BuildContext context, MiniPuzzleType type) {
    debugPrint('Selecting game: $type');
    Navigator.pushNamed(context, AppRoutes.miniPuzzleLevel, arguments: type);
  }
}

class _GameCard extends StatelessWidget {
  final MiniPuzzleGameInfo game;
  final AudyAdaptive adaptive;
  final VoidCallback onTap;

  const _GameCard({
    required this.game,
    required this.adaptive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(adaptive.space(20)),
        decoration: BoxDecoration(
          color: AudyColors.backgroundCard,
          borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
          border: Border.all(
            color: game.color.withValues(alpha: 0.4),
            width: 3,
          ),
          boxShadow: AudyShadows.cardShadow,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: adaptive.space(72),
              height: adaptive.space(72),
              decoration: BoxDecoration(
                color: game.color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                game.icon,
                size: adaptive.space(40),
                color: game.color,
              ),
            ),
            SizedBox(width: adaptive.space(20)),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _tr(context, game.titleKey),
                    style: TextStyle(
                      fontSize: adaptive.space(20),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF243A5A),
                    ),
                  ),
                  SizedBox(height: adaptive.space(4)),
                  Text(
                    _tr(context, game.descriptionKey),
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
              color: game.color,
              size: adaptive.space(24),
            ),
          ],
        ),
      ),
    );
  }
}
