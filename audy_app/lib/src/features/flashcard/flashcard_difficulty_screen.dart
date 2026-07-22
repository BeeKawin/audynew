import 'package:flutter/material.dart';

import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';
import 'flashcard_models.dart';
import 'flashcard_screen.dart';

/// Pre-game difficulty picker for the flashcard sentence game.
///
/// Calm, high-contrast, three consistent tap targets. No timer, no pressure —
/// tuned for autistic players.
class FlashcardDifficultyScreen extends StatelessWidget {
  const FlashcardDifficultyScreen({super.key});

  static const List<FlashcardDifficulty> _levels = [
    FlashcardDifficulty.easy,
    FlashcardDifficulty.medium,
    FlashcardDifficulty.hard,
  ];

  @override
  Widget build(BuildContext context) {
    final isThai = AudyScope.of(context).currentLanguage == 'th';

    return AudyResponsivePage(
      builder: (context, adaptive) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AudyBackButton(
              label: isThai ? 'กลับ' : 'Back',
              onPressed: () {
                SoundService.instance.playTap();
                Navigator.pop(context);
              },
            ),
            SizedBox(height: adaptive.space(28)),
            Row(
              children: [
                Icon(
                  Icons.style_rounded,
                  size: adaptive.space(32),
                  color: AudyColors.skyBlue,
                ),
                SizedBox(width: adaptive.space(12)),
                Text(
                  isThai ? 'เลือกระดับ' : 'Choose a Level',
                  style: TextStyle(
                    fontSize: adaptive.space(28),
                    fontWeight: FontWeight.w800,
                    color: AudyColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: adaptive.space(8)),
            Text(
              isThai
                  ? 'เรียงการ์ดให้เป็นประโยค'
                  : 'Build the sentence, one card at a time.',
              style: TextStyle(
                fontSize: adaptive.space(16),
                color: AudyColors.textLight,
              ),
            ),
            SizedBox(height: adaptive.space(32)),
            ..._levels.map(
              (level) => Padding(
                padding: EdgeInsets.only(bottom: adaptive.space(16)),
                child: _DifficultyCard(
                  level: level,
                  isThai: isThai,
                  adaptive: adaptive,
                  onTap: () {
                    SoundService.instance.playTap();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FlashcardScreen(difficulty: level),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  const _DifficultyCard({
    required this.level,
    required this.isThai,
    required this.adaptive,
    required this.onTap,
  });

  final FlashcardDifficulty level;
  final bool isThai;
  final AudyAdaptive adaptive;
  final VoidCallback onTap;

  Color get _color {
    switch (level) {
      case FlashcardDifficulty.easy:
        return AudyColors.mintGreen;
      case FlashcardDifficulty.medium:
        return AudyColors.skyBlue;
      case FlashcardDifficulty.hard:
        return AudyColors.blushPink;
    }
  }

  IconData get _icon {
    switch (level) {
      case FlashcardDifficulty.easy:
        return Icons.sentiment_satisfied_rounded;
      case FlashcardDifficulty.medium:
        return Icons.sentiment_neutral_rounded;
      case FlashcardDifficulty.hard:
        return Icons.sentiment_very_satisfied_rounded;
    }
  }

  String get _title {
    switch (level) {
      case FlashcardDifficulty.easy:
        return isThai ? 'ง่าย' : 'Easy';
      case FlashcardDifficulty.medium:
        return isThai ? 'ปานกลาง' : 'Medium';
      case FlashcardDifficulty.hard:
        return isThai ? 'ยาก' : 'Hard';
    }
  }

  String get _subtitle {
    final count = level.cardCount;
    if (isThai) {
      final hint = level.showHints ? ' • มีตัวช่วย' : ' • ไม่มีตัวช่วย';
      return '$count การ์ด$hint';
    }
    final hint = level.showHints ? ' • with hints' : ' • no hints';
    return '$count cards$hint';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(adaptive.space(20)),
        decoration: BoxDecoration(
          color: AudyColors.backgroundCard,
          borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
          border: Border.all(color: _color.withValues(alpha: 0.5), width: 3),
          boxShadow: AudyShadows.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: adaptive.space(64),
              height: adaptive.space(64),
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _icon,
                size: adaptive.space(32),
                color: AudyColors.textPrimary,
              ),
            ),
            SizedBox(width: adaptive.space(20)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title,
                    style: TextStyle(
                      fontSize: adaptive.space(20),
                      fontWeight: FontWeight.w800,
                      color: AudyColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: adaptive.space(4)),
                  Text(
                    _subtitle,
                    style: TextStyle(
                      fontSize: adaptive.space(14),
                      color: AudyColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: _color,
              size: adaptive.space(24),
            ),
          ],
        ),
      ),
    );
  }
}
