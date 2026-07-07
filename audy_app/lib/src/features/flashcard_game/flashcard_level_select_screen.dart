import 'package:flutter/material.dart';

import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';
import 'flashcard_game_screen.dart';
import 'flashcard_models.dart';

String _tr(BuildContext context, String key, {Map<String, String>? params}) {
  return AudyScope.of(context).tr(key, params: params);
}

class FlashcardLevelSelectScreen extends StatelessWidget {
  const FlashcardLevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AudyResponsivePage(
      scrollable: false,
      builder: (context, adaptive) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: adaptive.space(8),
              runSpacing: adaptive.space(4),
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
                Icon(
                  Icons.style_rounded,
                  size: adaptive.space(34),
                  color: AudyColors.activityReading,
                ),
                Text(
                  _tr(context, 'flashcard_game'),
                  style: AudyTypography.headingLarge,
                ),
              ],
            ),
            SizedBox(height: adaptive.space(24)),
            Center(
              child: Text(
                _tr(context, 'choose_challenge'),
                style: AudyTypography.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: adaptive.space(24)),
            Expanded(
              child: ListView.separated(
                itemCount: FlashcardDifficulty.values.length,
                separatorBuilder: (_, _) =>
                    SizedBox(height: adaptive.space(12)),
                itemBuilder: (context, index) {
                  final difficulty = FlashcardDifficulty.values[index];
                  return _FlashcardLevelCard(
                    adaptive: adaptive,
                    difficulty: difficulty,
                    onTap: () {
                      SoundService.instance.playTap();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              FlashcardGameScreen(difficulty: difficulty),
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

class _FlashcardLevelCard extends StatelessWidget {
  const _FlashcardLevelCard({
    required this.adaptive,
    required this.difficulty,
    required this.onTap,
  });

  final AudyAdaptive adaptive;
  final FlashcardDifficulty difficulty;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (difficulty) {
      FlashcardDifficulty.easy => AudyColors.mintGreen,
      FlashcardDifficulty.medium => AudyColors.warning,
      FlashcardDifficulty.hard => AudyColors.blushPink,
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
        child: Ink(
          padding: EdgeInsets.all(adaptive.space(20)),
          decoration: BoxDecoration(
            color: AudyColors.backgroundCard,
            borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
            border: Border.all(color: color.withValues(alpha: 0.55), width: 2),
            boxShadow: AudyShadows.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                width: adaptive.space(56),
                height: adaptive.space(56),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.style_rounded,
                  color: AudyColors.textPrimary,
                  size: adaptive.space(32),
                ),
              ),
              SizedBox(width: adaptive.space(14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _tr(context, difficulty.apiValue),
                      style: AudyTypography.headingSmall,
                    ),
                    SizedBox(height: adaptive.space(4)),
                    Text(
                      _tr(
                        context,
                        'flashcard_word_count',
                        params: {'count': difficulty.wordCount.toString()},
                      ),
                      style: AudyTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: AudyColors.skyBlue,
                size: adaptive.space(28),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
