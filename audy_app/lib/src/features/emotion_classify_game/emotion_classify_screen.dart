import 'package:flutter/material.dart';

import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../core/emotion_character_widget.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';
import 'emotion_classify_complete_screen.dart';

/// "What is this emotion?" - Classification game
/// Shows a human face image and asks user to classify the emotion
class EmotionClassifyScreen extends StatefulWidget {
  const EmotionClassifyScreen({super.key});

  @override
  State<EmotionClassifyScreen> createState() => _EmotionClassifyScreenState();
}

class _EmotionClassifyScreenState extends State<EmotionClassifyScreen> {
  String? _selectedAnswer;
  bool _showingFeedback = false;
  bool _isCorrect = false;

  @override
  Widget build(BuildContext context) {
    final controller = AudyScope.of(context);
    final question = controller.currentClassifyQuestion;

    const palette = {
      'Happy': Color(0xFFFFF2A8),
      'Sad': Color(0xFFBDD8F2),
      'Angry': Color(0xFFFFDAC7),
      'Surprised': Color(0xFFF8C7DF),
      'Scared': Color(0xFFDDD0F4),
    };

    if (controller.isClassifyGameComplete) {
      return EmotionClassifyCompleteScreen(controller: controller);
    }

    return AudyResponsivePage(
      scrollable: false,
      builder: (context, adaptive) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      SoundService.instance.playTap();
                      controller.resetClassifyGame();
                      Navigator.pop(context);
                    },
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
                ),
                Text(
                  controller.tr(
                    'round_format',
                    params: {
                      'current': controller.classifyCurrentRound.toString(),
                      'total': controller.classifyTotalRounds.toString(),
                    },
                  ),
                  style: AudyTypography.labelLarge,
                ),
                const SizedBox(width: AudySpacing.elementGap),
                Text(
                  controller.tr(
                    'score_format',
                    params: {'score': controller.classifyScore.toString()},
                  ),
                  style: AudyTypography.labelLarge.copyWith(
                    color: AudyColors.mintGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AudySpacing.sectionGap),
            Center(
              child: Text(
                controller.tr('what_emotion'),
                style: AudyTypography.displayMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AudySpacing.sectionGap),
            Center(
              child: EmotionCharacterWidget(
                emotion: question.correctAnswer,
                size: 180,
                useHumanImage: true,
              ),
            ),
            const SizedBox(height: AudySpacing.sectionGap),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: AudySpacing.elementGap,
                    crossAxisSpacing: AudySpacing.elementGap,
                    childAspectRatio: 2.2,
                    children: question.options.map((option) {
                      final isSelected = _selectedAnswer == option;
                      final isAnswered = _showingFeedback;
                      final correctOption = option == question.correctAnswer;

                      Color cardColor =
                          palette[option] ?? const Color(0xFFE7D8FA);
                      if (isAnswered) {
                        if (correctOption) {
                          cardColor = AudyColors.mintGreen;
                        } else if (isSelected && !_isCorrect) {
                          cardColor = AudyColors.error.withValues(alpha: 0.3);
                        }
                      }

                      return InkWell(
                        onTap: isAnswered
                            ? null
                            : () {
                                SoundService.instance.playTap();
                                _handleAnswer(option, controller);
                              },
                        borderRadius: BorderRadius.circular(
                          AudySpacing.radiusLarge,
                        ),
                        child: AnimatedContainer(
                          duration: AudyAnimation.normal,
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(
                              AudySpacing.radiusLarge,
                            ),
                            boxShadow: AudyShadows.cardShadow,
                            border: isSelected
                                ? Border.all(
                                    color: AudyColors.skyBlue,
                                    width: 3,
                                  )
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              option,
                              style: AudyTypography.headingSmall.copyWith(
                                color: AudyColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            if (_showingFeedback) ...[
              const SizedBox(height: AudySpacing.elementGap),
              Center(
                child: Text(
                  controller.classifyFeedback,
                  textAlign: TextAlign.center,
                  style: AudyTypography.bodyLarge,
                ),
              ),
            ],
            const SizedBox(height: AudySpacing.smallGap),
          ],
        );
      },
    );
  }

  void _handleAnswer(String answer, AudyController controller) {
    if (_showingFeedback) return;

    final isCorrect =
        answer == controller.currentClassifyQuestion.correctAnswer;
    _selectedAnswer = answer;
    _isCorrect = isCorrect;
    _showingFeedback = true;

    // Play sound for correct/wrong answer
    if (isCorrect) {
      SoundService.instance.playCorrect();
    } else {
      SoundService.instance.playWrong();
    }

    controller.submitClassifyAnswer(answer);

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        controller.advanceClassifyRound();
        setState(() {
          _selectedAnswer = null;
          _showingFeedback = false;
          _isCorrect = false;
        });
      }
    });
  }
}
