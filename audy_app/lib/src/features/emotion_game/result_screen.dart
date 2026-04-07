import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/audy_theme.dart';
import '../../core/emotion_character_widget.dart';
import '../../state/audy_controller.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.capturedImage,
    required this.expectedEmotion,
    required this.detectedEmotion,
    required this.confidence,
  });

  final File capturedImage;
  final String expectedEmotion;
  final String detectedEmotion;
  final double confidence;

  bool get isMatch {
    return detectedEmotion.toLowerCase() == expectedEmotion.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AudyScope.of(context);

    return Scaffold(
      backgroundColor: AudyColors.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AudySpacing.screenPadding),
          child: Column(
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(
                      AudySpacing.radiusMedium,
                    ),
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
              const SizedBox(height: AudySpacing.elementGap),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AudySpacing.radiusXLarge),
                  boxShadow: AudyShadows.cardShadow,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AudySpacing.radiusXLarge),
                  child: Image.file(capturedImage, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: AudySpacing.sectionGap),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AudySpacing.cardPadding,
                  vertical: AudySpacing.elementGap,
                ),
                decoration: BoxDecoration(
                  color: AudyColors.backgroundCard,
                  borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
                  boxShadow: [AudyShadows.soft],
                ),
                child: Column(
                  children: [
                    _EmotionRow(label: 'Expected', emotion: expectedEmotion),
                    const SizedBox(height: AudySpacing.elementGap),
                    _EmotionRow(label: 'You showed', emotion: detectedEmotion),
                    const SizedBox(height: AudySpacing.smallGap),
                    Text(
                      'Confidence: ${(confidence * 100).round()}%',
                      style: AudyTypography.bodySmall.copyWith(
                        color: AudyColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AudySpacing.sectionGap),
              _FeedbackSection(
                isMatch: isMatch,
                expectedEmotion: expectedEmotion,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: AudySpacing.buttonHeight + 12,
                child: ElevatedButton(
                  onPressed: () {
                    if (isMatch) {
                      controller.emotionScore += 1;
                      controller.learningPoints += 5;
                    }
                    controller.gamesPlayed += 1;
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isMatch
                        ? AudyColors.mintGreen
                        : AudyColors.skyBlue,
                    foregroundColor: AudyColors.textOnColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AudySpacing.radiusXLarge,
                      ),
                    ),
                    elevation: 4,
                  ),
                  child: Text('Continue', style: AudyTypography.buttonText),
                ),
              ),
              const SizedBox(height: AudySpacing.sectionGap),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmotionRow extends StatelessWidget {
  const _EmotionRow({required this.label, required this.emotion});

  final String label;
  final String emotion;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        EmotionCharacterWidget(emotion: emotion, size: 56),
        const SizedBox(width: AudySpacing.elementGap),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AudyTypography.bodySmall.copyWith(
                color: AudyColors.textLight,
              ),
            ),
            Text(emotion, style: AudyTypography.headingSmall),
          ],
        ),
      ],
    );
  }
}

class _FeedbackSection extends StatelessWidget {
  const _FeedbackSection({
    required this.isMatch,
    required this.expectedEmotion,
  });

  final bool isMatch;
  final String expectedEmotion;

  @override
  Widget build(BuildContext context) {
    if (isMatch) {
      return Column(
        children: [
          Icon(
            Icons.celebration_rounded,
            size: 64,
            color: AudyColors.mintGreen,
          ),
          const SizedBox(height: AudySpacing.smallGap),
          Text(
            'Amazing!',
            style: AudyTypography.displayMedium.copyWith(
              color: AudyColors.mintGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'That looks like $expectedEmotion!',
            style: AudyTypography.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return Column(
      children: [
        Icon(
          Icons.sentiment_satisfied_alt_rounded,
          size: 64,
          color: AudyColors.warning,
        ),
        const SizedBox(height: AudySpacing.smallGap),
        Text(
          'Almost!',
          style: AudyTypography.displayMedium.copyWith(
            color: AudyColors.warning,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Let\'s try again next time!',
          style: AudyTypography.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
