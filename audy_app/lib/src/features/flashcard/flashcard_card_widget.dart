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
    this.width,
    this.height,
  });

  final FlashcardCard card;
  final VoidCallback? onTap;
  final FlashcardValidationStatus? status;
  final bool isPreview;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final defaultWidth = isPreview ? 250.0 : 132.0;
    final defaultHeight = isPreview ? 320.0 : 172.0;
    final cardWidth = width ?? defaultWidth;
    final cardHeight = height ?? defaultHeight;

    final color = _categoryColor(card.category);
    final glow = _glowForStatus(status);
    final shadows = List<BoxShadow>.of(AudyShadows.cardShadow);
    if (glow != null) shadows.insert(0, glow);

    // Responsive scaling variables based on width
    final paddingVal = cardWidth * 0.09;
    final categoryFontSize = cardWidth * 0.1;
    final textFontSize = cardWidth * 0.14;
    final circleSize = cardWidth * 0.55;
    final borderThickness = isPreview ? 4.0 : 3.0;

    final borderColor = status == null
        ? color
        : (status == FlashcardValidationStatus.correct
            ? AudyColors.success
            : (status == FlashcardValidationStatus.move
                ? AudyColors.warning
                : AudyColors.error));

    return AnimatedContainer(
      duration: AudyAnimation.slow,
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
        boxShadow: shadows,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
                child: Ink(
                  padding: EdgeInsets.all(paddingVal),
                  decoration: BoxDecoration(
                    color: AudyColors.backgroundCard,
                    borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
                    border: Border.all(color: borderColor, width: borderThickness),
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
                          fontSize: categoryFontSize,
                        ),
                      ),
                      SizedBox(height: cardWidth * 0.08),
                      Expanded(
                        child: Center(
                          child: Container(
                            width: circleSize,
                            height: circleSize,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.16),
                              shape: BoxShape.circle,
                            ),
                            padding: card.imageAsset.startsWith('emoji:')
                                ? EdgeInsets.zero
                                : EdgeInsets.all(cardWidth * 0.07),
                            child: card.imageAsset.startsWith('emoji:')
                                ? Center(
                                    child: Text(
                                      card.imageAsset.substring(6),
                                      style: TextStyle(
                                        fontSize: cardWidth * 0.42,
                                      ),
                                    ),
                                  )
                                : Image.asset(
                                    card.imageAsset,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => Icon(
                                      Icons.style_rounded,
                                      color: color,
                                      size: cardWidth * 0.32,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: cardWidth * 0.06),
                      Text(
                        card.displayText,
                        textAlign: TextAlign.center,
                        maxLines: isPreview ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                        style: AudyTypography.headingSmall.copyWith(
                          fontSize: textFontSize,
                          color: AudyColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (status != null)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                decoration: BoxDecoration(
                  color: borderColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(4),
                child: Icon(
                  status == FlashcardValidationStatus.correct
                      ? Icons.check_rounded
                      : (status == FlashcardValidationStatus.move
                          ? Icons.swap_horiz_rounded
                          : Icons.close_rounded),
                  color: Colors.white,
                  size: isPreview ? 24 : 16,
                ),
              ),
            ),
        ],
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
      case FlashcardCategory.preposition:
        return const Color(0xFFC7D2FE); // Soft indigo
      case FlashcardCategory.determiner:
        return const Color(0xFFFDE68A); // Soft amber
      case FlashcardCategory.conjunction:
        return const Color(0xFFA7F3D0); // Soft emerald
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
      case FlashcardCategory.preposition:
        return 'Preposition';
      case FlashcardCategory.determiner:
        return 'Determiner';
      case FlashcardCategory.conjunction:
        return 'Conjunction';
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
        return BoxShadow(
          color: AudyColors.warning.withValues(alpha: 0.34),
          blurRadius: 24,
          spreadRadius: 5,
        );
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
