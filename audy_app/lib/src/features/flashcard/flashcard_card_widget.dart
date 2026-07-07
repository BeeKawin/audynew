import 'package:flutter/material.dart';

import '../../core/audy_theme.dart';
import 'flashcard_models.dart';

class FlashcardWordCard extends StatelessWidget {
  const FlashcardWordCard({
    super.key,
    required this.card,
    this.onTap,
    this.status,
    this.isPreview = false,
  });

  final FlashcardCard card;
  final VoidCallback? onTap;
  final FlashcardValidationStatus? status;
  final bool isPreview;

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(card.category);
    final glow = _glowForStatus(status);
    final shadows = List<BoxShadow>.of(AudyShadows.cardShadow);
    if (glow != null) shadows.insert(0, glow);
    final width = isPreview ? 250.0 : 132.0;
    final height = isPreview ? 320.0 : 172.0;

    return AnimatedContainer(
      duration: AudyAnimation.slow,
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
        boxShadow: shadows,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
          child: Ink(
            padding: EdgeInsets.all(isPreview ? 22 : 12),
            decoration: BoxDecoration(
              color: AudyColors.backgroundCard,
              borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
              border: Border.all(color: color, width: isPreview ? 4 : 3),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _categoryLabel(card.category),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AudyTypography.labelMedium.copyWith(
                    color: color,
                    fontSize: isPreview ? 18 : 13,
                  ),
                ),
                SizedBox(height: isPreview ? 18 : 10),
                Expanded(
                  child: Center(
                    child: Container(
                      width: isPreview ? 132 : 74,
                      height: isPreview ? 132 : 74,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(isPreview ? 18 : 10),
                      child: Image.asset(
                        card.imageAsset,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.style_rounded,
                          color: color,
                          size: isPreview ? 72 : 42,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isPreview ? 16 : 8),
                Text(
                  card.displayText,
                  textAlign: TextAlign.center,
                  maxLines: isPreview ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: AudyTypography.headingSmall.copyWith(
                    fontSize: isPreview ? 34 : 18,
                    color: AudyColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _categoryColor(FlashcardCategory category) {
    switch (category) {
      case FlashcardCategory.noun:
        return AudyColors.skyBlue;
      case FlashcardCategory.pronoun:
        return AudyColors.blushPink;
      case FlashcardCategory.verb:
        return AudyColors.softLavender;
      case FlashcardCategory.adverb:
        return AudyColors.mintGreen;
      case FlashcardCategory.adjective:
        return AudyColors.activityRewards;
    }
  }

  String _categoryLabel(FlashcardCategory category) {
    switch (category) {
      case FlashcardCategory.noun:
        return 'Noun';
      case FlashcardCategory.pronoun:
        return 'Pronoun';
      case FlashcardCategory.verb:
        return 'Verb';
      case FlashcardCategory.adverb:
        return 'Adverb';
      case FlashcardCategory.adjective:
        return 'Adjective';
    }
  }

  BoxShadow? _glowForStatus(FlashcardValidationStatus? status) {
    switch (status) {
      case FlashcardValidationStatus.correct:
        return BoxShadow(
          color: AudyColors.success.withValues(alpha: 0.34),
          blurRadius: 24,
          spreadRadius: 5,
        );
      case FlashcardValidationStatus.move:
      case FlashcardValidationStatus.remove:
        return BoxShadow(
          color: AudyColors.error.withValues(alpha: 0.34),
          blurRadius: 24,
          spreadRadius: 5,
        );
      case null:
        return null;
    }
  }
}
