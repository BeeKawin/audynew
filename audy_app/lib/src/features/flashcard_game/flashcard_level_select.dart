import 'package:flutter/material.dart';

import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';
import 'flashcard_game_screen.dart';
import 'flashcard_levels.dart';
import 'flashcard_models.dart';

String _tr(BuildContext context, String key, {Map<String, String>? params}) {
  return AudyScope.of(context).tr(key, params: params);
}

class FlashCardLevelSelectScreen extends StatelessWidget {
  const FlashCardLevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final levels = FlashLevelDefinitions.allLevels();

    return AudyResponsivePage(
      scrollable: false,
      builder: (context, adaptive) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    width: adaptive.space(48),
                    height: adaptive.space(48),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      size: AudySpacing.iconMedium,
                    ),
                  ),
                ),
                SizedBox(width: adaptive.space(8)),
                Icon(
                  Icons.style_rounded,
                  size: adaptive.space(32),
                  color: AudyColors.skyBlue,
                ),
                SizedBox(width: adaptive.space(8)),
                Expanded(
                  child: Text(
                    _tr(context, 'flashcard_game'),
                    style: AudyTypography.displayMedium,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            SizedBox(height: adaptive.space(20)),
            Center(
              child: Text(
                _tr(context, 'choose_challenge'),
                style: AudyTypography.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: adaptive.space(20)),
            Expanded(
              child: ListView.separated(
                itemCount: levels.length,
                separatorBuilder: (_, _) =>
                    SizedBox(height: adaptive.space(12)),
                itemBuilder: (context, index) {
                  final level = levels[index];
                  return _LevelCard(
                    level: level,
                    adaptive: adaptive,
                    onTap: () {
                      SoundService.instance.playTap();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FlashCardGameScreen(level: level),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.adaptive,
    required this.onTap,
  });

  final FlashLevel level;
  final AudyAdaptive adaptive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = level.primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(adaptive.space(20)),
        decoration: BoxDecoration(
          color: AudyColors.backgroundCard,
          borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
          boxShadow: AudyShadows.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: adaptive.space(52),
              height: adaptive.space(52),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.style_rounded,
                size: adaptive.space(30),
                color: color,
              ),
            ),
            SizedBox(width: adaptive.space(14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _tr(context, level.difficulty.name),
                    style: AudyTypography.headingSmall,
                  ),
                  SizedBox(height: adaptive.space(4)),
                  Text(
                    _tr(context, 'rounds_format',
                        params: {'count': level.totalRounds.toString()}),
                    style: AudyTypography.bodySmall.copyWith(
                      fontSize: adaptive.space(14),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              color: color,
              size: adaptive.space(24),
            ),
          ],
        ),
      ),
    );
  }
}
