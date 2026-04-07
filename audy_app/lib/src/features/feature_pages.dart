import 'package:flutter/material.dart';

import '../core/app_routes.dart';
import '../core/audy_theme.dart';
import '../core/audy_ui.dart';
import '../core/emotion_character_widget.dart';
import '../state/audy_controller.dart';
import 'emotion_game/selfie_capture_screen.dart';

class GamesHubPage extends StatelessWidget {
  const GamesHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _RouteCard(
        'Emotion Game',
        'Name the feeling',
        Icons.sentiment_satisfied_alt_rounded,
        const Color(0xFFF8C7DF),
        AppRoutes.emotionGame,
      ),
      _RouteCard(
        'MiniPuzzle',
        'Cognitive training',
        Icons.extension_rounded,
        const Color(0xFFBDD8F2),
        AppRoutes.miniPuzzle,
      ),
      _RouteCard(
        'Sorting Game',
        'Sort & learn',
        Icons.sort_rounded,
        const Color(0xFFFFF3A6),
        AppRoutes.sortingGame,
      ),
      _RouteCard(
        'Reaction Time',
        'Tap quickly',
        Icons.bolt_rounded,
        const Color(0xFFFFDAC7),
        AppRoutes.reactionTime,
      ),
    ];

    return AudyFeaturePage(
      title: 'Games',
      subtitle: 'Play and learn with fun activities!',
      leadingLabel: 'Back to Home',
      mascot: const AudyMascot(size: 132),
      childBuilder: (context, adaptive) {
        return AudyAdaptiveGrid(
          adaptive: adaptive,
          phoneColumns: 1,
          tabletColumns: 2,
          desktopColumns: 2,
          items: cards
              .map(
                (card) => AudyActionCard(
                  title: card.title,
                  subtitle: card.subtitle,
                  icon: card.icon,
                  color: card.color,
                  adaptive: adaptive,
                  onTap: () => Navigator.pushNamed(context, card.route),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class EmotionGamePage extends StatefulWidget {
  const EmotionGamePage({super.key});

  @override
  State<EmotionGamePage> createState() => _EmotionGamePageState();
}

class _EmotionGamePageState extends State<EmotionGamePage> {
  String? _selectedAnswer;
  bool _showingFeedback = false;
  bool _isCorrect = false;

  @override
  Widget build(BuildContext context) {
    final controller = AudyScope.of(context);
    final question = controller.currentEmotionQuestion;
    const palette = {
      'Happy': Color(0xFFFFF2A8),
      'Sad': Color(0xFFBDD8F2),
      'Angry': Color(0xFFFFDAC7),
      'Surprised': Color(0xFFF8C7DF),
      'Scared': Color(0xFFDDD0F4),
      'Calm': Color(0xFFC9E8C1),
      'Proud': Color(0xFFE7D8FA),
    };

    if (controller.isEmotionGameComplete) {
      return _FinalScoreScreen(controller: controller);
    }

    return Scaffold(
      backgroundColor: AudyColors.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AudySpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: InkWell(
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
                  ),
                  Text(
                    'Round ${controller.emotionCurrentRound} / ${controller.emotionTotalRounds}',
                    style: AudyTypography.labelLarge,
                  ),
                  const SizedBox(width: AudySpacing.elementGap),
                  Text(
                    'Score: ${controller.emotionScore}',
                    style: AudyTypography.labelLarge.copyWith(
                      color: AudyColors.mintGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AudySpacing.sectionGap),
              Center(
                child: Text(
                  'What is this emotion?',
                  style: AudyTypography.displayMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AudySpacing.sectionGap),
              Center(
                child: EmotionCharacterWidget(
                  emotion: question.correctAnswer,
                  size: 180,
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
                              : () => _handleAnswer(option, controller),
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
                    controller.emotionFeedback,
                    textAlign: TextAlign.center,
                    style: AudyTypography.bodyLarge,
                  ),
                ),
              ],
              const SizedBox(height: AudySpacing.smallGap),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAnswer(String answer, AudyController controller) {
    if (_showingFeedback) return;

    final isCorrect = answer == controller.currentEmotionQuestion.correctAnswer;
    _selectedAnswer = answer;
    _isCorrect = isCorrect;
    _showingFeedback = true;

    if (isCorrect) {
      controller.submitEmotionAnswer(answer);

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SelfieCaptureScreen(
                targetEmotion: controller.currentEmotionQuestion.correctAnswer,
              ),
            ),
          ).then((_) {
            if (mounted) {
              controller.advanceEmotionRound();
              setState(() {
                _selectedAnswer = null;
                _showingFeedback = false;
                _isCorrect = false;
              });
            }
          });
        }
      });
    } else {
      controller.emotionFeedback =
          'Nice try. The answer is ${controller.currentEmotionQuestion.correctAnswer}.';
      controller.gamesPlayed += 1;

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          controller.advanceEmotionRound();
          setState(() {
            _selectedAnswer = null;
            _showingFeedback = false;
            _isCorrect = false;
          });
        }
      });
    }
  }
}

class _FinalScoreScreen extends StatelessWidget {
  const _FinalScoreScreen({required this.controller});

  final AudyController controller;

  int get stars {
    final ratio = controller.emotionScore / controller.emotionTotalRounds;
    if (ratio >= 0.75) return 3;
    if (ratio >= 0.4) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: AudySpacing.sectionGap),
              const Icon(
                Icons.celebration_rounded,
                size: 80,
                color: AudyColors.mintGreen,
              ),
              const SizedBox(height: AudySpacing.elementGap),
              Text('Wonderful!', style: AudyTypography.displayLarge),
              const SizedBox(height: AudySpacing.sectionGap),
              Container(
                padding: const EdgeInsets.all(AudySpacing.cardPadding),
                decoration: BoxDecoration(
                  color: AudyColors.backgroundCard,
                  borderRadius: BorderRadius.circular(AudySpacing.radiusXLarge),
                  boxShadow: AudyShadows.cardShadow,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        final filled = index < stars;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            Icons.star_rounded,
                            size: 56,
                            color: filled
                                ? AudyColors.starGold
                                : AudyColors.starSilver,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: AudySpacing.elementGap),
                    Text(
                      'Score: ${controller.emotionScore} / ${controller.emotionTotalRounds}',
                      style: AudyTypography.headingLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Emotion practice complete!',
                      style: AudyTypography.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.resetEmotionGame();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AudyColors.skyBlue,
                        foregroundColor: AudyColors.textOnColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AudySpacing.radiusXLarge,
                          ),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        'Play Again',
                        style: AudyTypography.buttonText,
                      ),
                    ),
                  ),
                  const SizedBox(width: AudySpacing.elementGap),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AudyColors.mintGreen,
                        foregroundColor: AudyColors.textOnColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AudySpacing.radiusXLarge,
                          ),
                        ),
                        elevation: 4,
                      ),
                      child: Text('Done', style: AudyTypography.buttonText),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AudySpacing.sectionGap),
            ],
          ),
        ),
      ),
    );
  }
}

class ColorSortingPage extends StatefulWidget {
  const ColorSortingPage({super.key});

  @override
  State<ColorSortingPage> createState() => _ColorSortingPageState();
}

class _ColorSortingPageState extends State<ColorSortingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = AudyScope.of(context);
      controller.resetColorSortGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = AudyScope.of(context);

    if (controller.isColorSortComplete) {
      return ColorSortResultPage(controller: controller);
    }

    if (controller.colorRoundComplete) {
      return _ColorSortRoundOverlay(controller: controller);
    }

    final pieces = controller.colorPieces;
    final baskets = pieces.map((p) => p.colorName).toSet().toList();

    return AudyResponsivePage(
      builder: (context, adaptive) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopRow(
              adaptive: adaptive,
              leadingLabel: 'Back to Home',
              trailingText: controller.colorRoundLabel,
            ),
            SizedBox(height: adaptive.space(24)),
            Center(
              child: Column(
                children: [
                  Text(
                    'Color Sorting',
                    style: TextStyle(
                      fontSize: adaptive.space(28),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF243A5A),
                    ),
                  ),
                  SizedBox(height: adaptive.space(8)),
                  Text(
                    'Drag each piece to the matching basket.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: adaptive.space(15),
                      color: const Color(0xFF617691),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: adaptive.space(18)),
            AudyPanel(
              adaptive: adaptive,
              child: Column(
                children: [
                  Text(
                    'Drag from here:',
                    style: TextStyle(
                      fontSize: adaptive.space(16),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: adaptive.space(14)),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: adaptive.space(16),
                    runSpacing: adaptive.space(16),
                    children: pieces.map((piece) {
                      if (piece.shape == SortShape.triangle) {
                        return Draggable<ColorPiece>(
                          data: piece,
                          feedback: Material(
                            color: Colors.transparent,
                            child: _TriangleChip(
                              color: piece.color,
                              selected: false,
                              onTap: null,
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.3,
                            child: _TriangleChip(
                              color: piece.color,
                              selected: false,
                              onTap: null,
                            ),
                          ),
                          child: _TriangleChip(
                            color: piece.color,
                            selected: false,
                            onTap: null,
                          ),
                        );
                      }
                      return Draggable<ColorPiece>(
                        data: piece,
                        feedback: Material(
                          color: Colors.transparent,
                          child: _ShapeChip(
                            shape: piece.shape == SortShape.circle
                                ? BoxShape.circle
                                : BoxShape.rectangle,
                            color: piece.color,
                            selected: false,
                            onTap: null,
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: _ShapeChip(
                            shape: piece.shape == SortShape.circle
                                ? BoxShape.circle
                                : BoxShape.rectangle,
                            color: piece.color,
                            selected: false,
                            onTap: null,
                          ),
                        ),
                        child: _ShapeChip(
                          shape: piece.shape == SortShape.circle
                              ? BoxShape.circle
                              : BoxShape.rectangle,
                          color: piece.color,
                          selected: false,
                          onTap: null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            SizedBox(height: adaptive.space(18)),
            AudyAdaptiveGrid(
              adaptive: adaptive,
              phoneColumns: 2,
              tabletColumns: 2,
              desktopColumns: 4,
              items: baskets
                  .map(
                    (basket) => _ColorBasketDropTarget(
                      label: basket,
                      color: _basketColorFor(basket),
                      adaptive: adaptive,
                      onDrop: (piece) =>
                          controller.handleColorDrop(piece, basket),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: adaptive.space(14)),
            Center(
              child: Text(
                controller.colorFeedback,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: adaptive.space(14),
                  color: const Color(0xFF60758F),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

Color _basketColorFor(String name) {
  switch (name.toLowerCase()) {
    case 'red':
      return const Color(0xFFFF8D91);
    case 'blue':
      return const Color(0xFF8FBCEC);
    case 'yellow':
      return const Color(0xFFFFF68C);
    case 'green':
      return const Color(0xFF90F48A);
    case 'purple':
      return const Color(0xFFDDD0F4);
    default:
      return const Color(0xFFE7D8FA);
  }
}

class _ColorSortRoundOverlay extends StatelessWidget {
  const _ColorSortRoundOverlay({required this.controller});

  final AudyController controller;

  @override
  Widget build(BuildContext context) {
    return AudyResponsivePage(
      builder: (context, adaptive) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopRow(adaptive: adaptive, leadingLabel: 'Back to Home'),
            SizedBox(height: adaptive.space(24)),
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 80,
                    color: AudyColors.mintGreen,
                  ),
                  SizedBox(height: adaptive.space(16)),
                  Text('Round Complete!', style: AudyTypography.displayLarge),
                  SizedBox(height: adaptive.space(24)),
                  AudyPanel(
                    adaptive: adaptive,
                    child: Column(
                      children: [
                        Text(
                          controller.colorRoundLabel,
                          style: TextStyle(
                            fontSize: adaptive.space(18),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF617691),
                          ),
                        ),
                        SizedBox(height: adaptive.space(12)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatBlock(
                              label: 'Correct',
                              value:
                                  '${controller.colorRoundResults.last['correct']}',
                              color: AudyColors.mintGreen,
                            ),
                            _StatBlock(
                              label: 'Misses',
                              value:
                                  '${controller.colorRoundResults.last['misses']}',
                              color: AudyColors.error,
                            ),
                            _StatBlock(
                              label: 'Time',
                              value:
                                  '${controller.colorRoundResults.last['timeMs']} ms',
                              color: AudyColors.skyBlue,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => controller.advanceColorSortRound(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AudyColors.skyBlue,
                foregroundColor: AudyColors.textOnColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AudySpacing.radiusXLarge),
                ),
                elevation: 4,
                minimumSize: const Size(
                  double.infinity,
                  AudySpacing.buttonHeight,
                ),
              ),
              child: Text(
                controller.isColorSortComplete ? 'See Results' : 'Next Round',
                style: AudyTypography.buttonText,
              ),
            ),
            SizedBox(height: adaptive.space(16)),
          ],
        );
      },
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF617691),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class ColorSortResultPage extends StatelessWidget {
  const ColorSortResultPage({required this.controller, super.key});

  final AudyController controller;

  @override
  Widget build(BuildContext context) {
    return AudyResponsivePage(
      builder: (context, adaptive) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopRow(adaptive: adaptive, leadingLabel: 'Back to Home'),
            SizedBox(height: adaptive.space(24)),
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.celebration_rounded,
                    size: 80,
                    color: AudyColors.mintGreen,
                  ),
                  SizedBox(height: adaptive.space(12)),
                  Text('All Done!', style: AudyTypography.displayLarge),
                  SizedBox(height: adaptive.space(8)),
                  Text(
                    'You completed all 3 rounds!',
                    style: TextStyle(
                      fontSize: adaptive.space(15),
                      color: const Color(0xFF617691),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: adaptive.space(24)),
            AudyPanel(
              adaptive: adaptive,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(9, (index) {
                      final filled = index < controller.colorTotalStars;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          Icons.star_rounded,
                          size: 36,
                          color: filled
                              ? AudyColors.starGold
                              : AudyColors.starSilver,
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: adaptive.space(12)),
                  Text(
                    'Accuracy: ${controller.colorTotalAccuracy}%',
                    style: TextStyle(
                      fontSize: adaptive.space(22),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF243A5A),
                    ),
                  ),
                  SizedBox(height: adaptive.space(4)),
                  Text(
                    'Avg: ${controller.colorAverageSortTimeMs} ms',
                    style: TextStyle(
                      fontSize: adaptive.space(14),
                      color: const Color(0xFF617691),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: adaptive.space(20)),
            AudyPanel(
              adaptive: adaptive,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Round Breakdown',
                    style: TextStyle(
                      fontSize: adaptive.space(18),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF243A5A),
                    ),
                  ),
                  SizedBox(height: adaptive.space(12)),
                  ...List.generate(controller.colorRoundResults.length, (i) {
                    final result = controller.colorRoundResults[i];
                    final roundNames = [
                      'Round 1: Color',
                      'Round 2: Color & Shape',
                      'Round 3: With Fakes',
                    ];
                    return Padding(
                      padding: EdgeInsets.only(bottom: adaptive.space(10)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              roundNames[i],
                              style: TextStyle(
                                fontSize: adaptive.space(14),
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF617691),
                              ),
                            ),
                          ),
                          Text(
                            '${result['correct']}/${(result['correct'] as int) + (result['misses'] as int)}',
                            style: TextStyle(
                              fontSize: adaptive.space(14),
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF243A5A),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${result['timeMs']} ms',
                            style: TextStyle(
                              fontSize: adaptive.space(14),
                              fontWeight: FontWeight.w700,
                              color: AudyColors.skyBlue,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (controller.colorMisses > 0)
                    Padding(
                      padding: EdgeInsets.only(top: adaptive.space(8)),
                      child: Text(
                        'Total misses: ${controller.colorMisses}',
                        style: TextStyle(
                          fontSize: adaptive.space(14),
                          color: AudyColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      controller.resetColorSortGame();
                      controller.startColorSortRound();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AudyColors.skyBlue,
                      foregroundColor: AudyColors.textOnColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AudySpacing.radiusXLarge,
                        ),
                      ),
                      elevation: 4,
                    ),
                    child: Text('Play Again', style: AudyTypography.buttonText),
                  ),
                ),
                const SizedBox(width: AudySpacing.elementGap),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AudyColors.mintGreen,
                      foregroundColor: AudyColors.textOnColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AudySpacing.radiusXLarge,
                        ),
                      ),
                      elevation: 4,
                    ),
                    child: Text('Done', style: AudyTypography.buttonText),
                  ),
                ),
              ],
            ),
            SizedBox(height: adaptive.space(16)),
          ],
        );
      },
    );
  }
}

class ReactionTimePage extends StatelessWidget {
  const ReactionTimePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AudyScope.of(context);

    if (controller.isReactionGameComplete) {
      return ReactionTimeResultPage(controller: controller);
    }

    return AudyResponsivePage(
      builder: (context, adaptive) {
        Color containerColor;
        IconData containerIcon;
        Color iconColor;
        String topText;

        final state = controller.reactionState;
        switch (state) {
          case ReactionGameState.idle:
            containerColor = const Color(0xFFBDD8F2);
            containerIcon = Icons.bolt_rounded;
            iconColor = const Color(0xFF243A5A);
            topText = 'Tap to start';
            break;
          case ReactionGameState.waiting:
            containerColor = const Color(0xFFFF8D91);
            containerIcon = Icons.hourglass_empty_rounded;
            iconColor = Colors.white;
            topText = 'Wait...';
            break;
          case ReactionGameState.ready:
            containerColor = const Color(0xFF69E0A0);
            containerIcon = Icons.touch_app_rounded;
            iconColor = Colors.white;
            topText = 'Tap now!';
            break;
          case ReactionGameState.tooEarly:
            containerColor = const Color(0xFFFF5252);
            containerIcon = Icons.cancel_rounded;
            iconColor = Colors.white;
            topText = 'Too early!';
            break;
          case ReactionGameState.result:
            containerColor = const Color(0xFFBDD8F2);
            containerIcon = Icons.timer_rounded;
            iconColor = const Color(0xFF243A5A);
            topText = '${controller.currentReactionTimeMs} ms';
            break;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopRow(
              adaptive: adaptive,
              leadingLabel: 'Back to Home',
              trailingText: controller.reactionRoundLabel,
            ),
            SizedBox(height: adaptive.space(24)),
            Center(
              child: Column(
                children: [
                  Text(
                    'Reaction Time',
                    style: TextStyle(
                      fontSize: adaptive.space(28),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF243A5A),
                    ),
                  ),
                  SizedBox(height: adaptive.space(8)),
                  Text(
                    'Tap the container when it turns green.',
                    style: TextStyle(
                      fontSize: adaptive.space(15),
                      color: const Color(0xFF617691),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: adaptive.space(20)),
            Center(
              child: Text(
                topText,
                style: TextStyle(
                  fontSize: adaptive.space(32),
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF243A5A),
                ),
              ),
            ),
            SizedBox(height: adaptive.space(16)),
            SizedBox(
              height: adaptive.isPhone ? 260 : 420,
              child: InkWell(
                onTap: controller.handleReactionContainerTap,
                borderRadius: BorderRadius.circular(adaptive.space(28)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: BorderRadius.circular(adaptive.space(28)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF99A9C0).withValues(alpha: 0.15),
                        blurRadius: 22,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      containerIcon,
                      size: adaptive.isPhone ? 72 : 96,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: adaptive.space(16)),
            Center(
              child: Text(
                controller.reactionFeedback,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: adaptive.space(14),
                  color: const Color(0xFF60758F),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ReactionTimeResultPage extends StatelessWidget {
  const ReactionTimeResultPage({required this.controller, super.key});

  final AudyController controller;

  @override
  Widget build(BuildContext context) {
    return AudyResponsivePage(
      builder: (context, adaptive) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopRow(adaptive: adaptive, leadingLabel: 'Back to Home'),
            SizedBox(height: adaptive.space(24)),
            Center(
              child: Column(
                children: [
                  Text(
                    'Reaction Time',
                    style: TextStyle(
                      fontSize: adaptive.space(28),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF243A5A),
                    ),
                  ),
                  SizedBox(height: adaptive.space(8)),
                  Text(
                    'Great job completing all rounds!',
                    style: TextStyle(
                      fontSize: adaptive.space(15),
                      color: const Color(0xFF617691),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: adaptive.space(24)),
            AudyPanel(
              adaptive: adaptive,
              child: Column(
                children: [
                  Text(
                    'Average',
                    style: TextStyle(
                      fontSize: adaptive.space(18),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF617691),
                    ),
                  ),
                  SizedBox(height: adaptive.space(8)),
                  Text(
                    '${controller.reactionAverageMs} ms',
                    style: TextStyle(
                      fontSize: adaptive.space(56),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF243A5A),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: adaptive.space(20)),
            AudyPanel(
              adaptive: adaptive,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Round Times',
                    style: TextStyle(
                      fontSize: adaptive.space(18),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF243A5A),
                    ),
                  ),
                  SizedBox(height: adaptive.space(12)),
                  ...List.generate(controller.reactionTimes.length, (i) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: adaptive.space(8)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Round ${i + 1}',
                            style: TextStyle(
                              fontSize: adaptive.space(16),
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF617691),
                            ),
                          ),
                          Text(
                            '${controller.reactionTimes[i]} ms',
                            style: TextStyle(
                              fontSize: adaptive.space(16),
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF243A5A),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (controller.reactionMisses > 0)
                    Padding(
                      padding: EdgeInsets.only(top: adaptive.space(8)),
                      child: Text(
                        'Too early taps: ${controller.reactionMisses}',
                        style: TextStyle(
                          fontSize: adaptive.space(14),
                          color: AudyColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: adaptive.space(32)),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      controller.resetReactionGame();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AudyColors.skyBlue,
                      foregroundColor: AudyColors.textOnColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AudySpacing.radiusXLarge,
                        ),
                      ),
                      elevation: 4,
                    ),
                    child: Text('Play Again', style: AudyTypography.buttonText),
                  ),
                ),
                const SizedBox(width: AudySpacing.elementGap),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AudyColors.mintGreen,
                      foregroundColor: AudyColors.textOnColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AudySpacing.radiusXLarge,
                        ),
                      ),
                      elevation: 4,
                    ),
                    child: Text('Done', style: AudyTypography.buttonText),
                  ),
                ),
              ],
            ),
            SizedBox(height: adaptive.space(16)),
          ],
        );
      },
    );
  }
}

class SocialPracticePage extends StatefulWidget {
  const SocialPracticePage({super.key});

  @override
  State<SocialPracticePage> createState() => _SocialPracticePageState();
}

class _SocialPracticePageState extends State<SocialPracticePage> {
  late final TextEditingController messageController;

  @override
  void initState() {
    super.initState();
    messageController = TextEditingController();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AudyScope.of(context);
    return AudyResponsivePage(
      builder: (context, adaptive) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AudyBackButton(
                        label: 'Back to Home',
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(height: adaptive.space(28)),
                      Text(
                        'Social Practice',
                        style: TextStyle(
                          fontSize: adaptive.space(28),
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF243A5A),
                        ),
                      ),
                      SizedBox(height: adaptive.space(8)),
                      Text(
                        'Let\'s have a friendly conversation.',
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
            SizedBox(height: adaptive.space(20)),
            AudyPanel(
              adaptive: adaptive,
              padding: EdgeInsets.symmetric(
                horizontal: adaptive.space(18),
                vertical: adaptive.space(16),
              ),
              child: Row(
                children: [
                  Text(
                    'Confidence:',
                    style: TextStyle(
                      fontSize: adaptive.space(16),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: adaptive.space(12)),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: controller.socialConfidence,
                        minHeight: adaptive.space(12),
                        backgroundColor: const Color(0xFFE1E5EB),
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF69E0A0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: adaptive.space(12)),
                  Text(
                    '${(controller.socialConfidence * 100).round()}%',
                    style: TextStyle(
                      fontSize: adaptive.space(16),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: adaptive.space(20)),
            AudyPanel(
              adaptive: adaptive,
              child: SizedBox(
                height: adaptive.isPhone ? 320 : 420,
                child: ListView(
                  children: controller.socialMessages
                      .map(
                        (message) => _ChatBubble(
                          text: message.text,
                          isUser: message.isUser,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            SizedBox(height: adaptive.space(18)),
            AudyPanel(
              adaptive: adaptive,
              padding: EdgeInsets.all(adaptive.space(14)),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: adaptive.isPhone ? 22 : 26,
                    backgroundColor: const Color(0xFFF8C7DF),
                    child: Icon(
                      Icons.mic_none_rounded,
                      color: const Color(0xFF243A5A),
                      size: adaptive.space(20),
                    ),
                  ),
                  SizedBox(width: adaptive.space(12)),
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        filled: true,
                        fillColor: const Color(0xFFF3F6F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: adaptive.space(18),
                          vertical: adaptive.space(16),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: adaptive.space(12)),
                  InkWell(
                    onTap: () {
                      controller.submitSocialMessage(messageController.text);
                      if (controller.validateChatMessage(
                            messageController.text,
                          ) ==
                          null) {
                        messageController.clear();
                      }
                    },
                    child: CircleAvatar(
                      radius: adaptive.isPhone ? 22 : 26,
                      backgroundColor: const Color(0xFFC9E8C1),
                      child: Icon(
                        Icons.send_outlined,
                        color: const Color(0xFF243A5A),
                        size: adaptive.space(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: adaptive.space(12)),
            Center(
              child: Text(
                controller.socialFeedback,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: adaptive.space(13),
                  color: const Color(0xFF60758F),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow({
    required this.adaptive,
    required this.leadingLabel,
    this.trailingText,
  });

  final AudyAdaptive adaptive;
  final String leadingLabel;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AudyBackButton(
            label: leadingLabel,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        if (trailingText != null)
          Text(
            trailingText!,
            style: TextStyle(
              fontSize: adaptive.space(16),
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}

class _ShapeChip extends StatelessWidget {
  const _ShapeChip({
    required this.shape,
    required this.color,
    this.selected = false,
    this.onTap,
  });

  final BoxShape shape;
  final Color color;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: color,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(10)
            : null,
      ),
    );

    final selectedContent = Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB1C9F5), width: 3),
      ),
      child: content,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: selected ? selectedContent : content,
    );
  }
}

class _TriangleChip extends StatelessWidget {
  const _TriangleChip({required this.color, this.selected = false, this.onTap});

  final Color color;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final triangle = SizedBox(
      width: 56,
      height: 56,
      child: CustomPaint(painter: _TrianglePainter(color)),
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: selected
          ? Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFB1C9F5), width: 3),
              ),
              child: triangle,
            )
          : triangle,
    );
  }
}

class _TrianglePainter extends CustomPainter {
  const _TrianglePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _ColorBasketDropTarget extends StatelessWidget {
  const _ColorBasketDropTarget({
    required this.label,
    required this.color,
    required this.adaptive,
    required this.onDrop,
  });

  final String label;
  final Color color;
  final AudyAdaptive adaptive;
  final void Function(ColorPiece piece) onDrop;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: adaptive.isPhone ? 150 : 200,
      child: DragTarget<ColorPiece>(
        onAcceptWithDetails: (details) => onDrop(details.data),
        builder: (context, candidateData, rejectedData) {
          final isHovering = candidateData.isNotEmpty;
          return Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(adaptive.space(24)),
              border: isHovering
                  ? Border.all(color: Colors.white, width: 4)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFA5B4C7).withValues(alpha: 0.20),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: adaptive.space(18),
                fontWeight: FontWeight.w800,
                color: const Color(0xFF243A5A),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.text, required this.isUser});

  final String text;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFFBDD8F2) : const Color(0xFFDDD0F4),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, color: Color(0xFF243A5A)),
        ),
      ),
    );
  }
}

class _RouteCard {
  const _RouteCard(
    this.title,
    this.subtitle,
    this.icon,
    this.color,
    this.route,
  );

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;
}
