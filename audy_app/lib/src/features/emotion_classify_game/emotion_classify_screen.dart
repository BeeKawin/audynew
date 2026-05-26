import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../core/emotion_character_widget.dart';
import '../../core/emotion_images.dart';
import '../../services/bluetooth_service.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';
import '../../widgets/game_guide_box.dart';
import '../../widgets/robot_panel_layout.dart';
import '../../widgets/virtual_robot_panel.dart';
import 'emotion_classify_complete_screen.dart';

/// "What is this emotion?" - Classification game
/// Shows a human face image and asks user to classify the emotion
class EmotionClassifyScreen extends StatefulWidget {
  const EmotionClassifyScreen({super.key});

  @override
  State<EmotionClassifyScreen> createState() => _EmotionClassifyScreenState();
}

class _EmotionClassifyScreenState extends State<EmotionClassifyScreen> {
  static const List<String> _fixedChoiceOrder = [
    'Happy',
    'Sad',
    'Angry',
    'Scared',
  ];

  static const Map<String, Color> _choicePalette = {
    'Happy': Color(0xFFFFF2A8),
    'Sad': Color(0xFFBDD8F2),
    'Angry': Color.fromARGB(255, 223, 171, 206),
    'Scared': Color.fromARGB(255, 114, 196, 126),
  };

  String? _selectedAnswer;
  bool _showingFeedback = false;
  bool _isCorrect = false;
  bool _showGuide = true;
  final Map<int, String> _roundImagePaths = {};
  final DateTime _sessionStartedAt = DateTime.now();

  StreamSubscription<AudyBleMessage>? _bleInputSub;
  @override
  void initState() {
    super.initState();

    unawaited(_sendGameEnterBleState());
    SoundService.instance.playInstructionEmotionClassify();
    _bleInputSub = AudyBluetoothService.instance.incomingMessages.listen(
      _handleBleInput,
    );
  }

  Future<void> _sendGameEnterBleState() async {
    try {
      final bluetooth = AudyBluetoothService.instance;
      await bluetooth.setArms(3);
      await bluetooth.setLed(15);
    } catch (e) {
      debugPrint('EmotionClassifyScreen: Entry BLE state skipped - $e');
    }
  }

  void _handleBleInput(AudyBleMessage message) {
    if (!mounted) return;
    if (_showingFeedback) return;

    final answerIndex = _answerIndexFromBle(message);
    if (answerIndex == null) return;

    final controller = AudyScope.of(context);

    if (controller.isClassifyGameComplete) return;

    final options = _orderedOptionsFor(controller.currentClassifyQuestion);

    if (answerIndex < 0 || answerIndex >= options.length) return;

    final selectedAnswer = options[answerIndex];

    SoundService.instance.playTap();
    _handleAnswer(selectedAnswer, controller);
  }

  void _triggerVirtualInput(String channel, int value) {
    _handleBleInput(
      AudyBleMessage(
        channel: channel,
        value: value,
        receivedAt: DateTime.now(),
      ),
    );
  }

  int? _answerIndexFromBle(AudyBleMessage message) {
    switch (message.channel) {
      case 'ears':
        if (message.value == 1) {
          return 0; // Left Top
        }
        if (message.value == 2) {
          return 1; // Right Top
        }
        return null;

      case 'force':
        if (message.value == 1) {
          return 2; // Left Bottom
        }
        if (message.value == 2) {
          return 3; // Right Bottom
        }
        return null;

      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AudyScope.of(context);

    if (controller.isClassifyGameComplete) {
      return EmotionClassifyCompleteScreen(
        controller: controller,
        sessionStartedAt: _sessionStartedAt,
      );
    }

    final question = controller.currentClassifyQuestion;
    final orderedOptions = _orderedOptionsFor(question);
    final imagePath = _imagePathForRound(
      controller.classifyCurrentRound,
      question.correctAnswer,
    );

    return AudyResponsivePage(
      scrollable: false,
      builder: (context, adaptive) {
        return ValueListenableBuilder<bool>(
          valueListenable: AudyBluetoothService.instance.connectionNotifier,
          builder: (context, isConnected, _) {
            return RobotPanelLayout(
              adaptive: adaptive,
              showPanel: !isConnected,
              panelBuilder: (isHorizontal) => VirtualRobotPanel(
                adaptive: adaptive,
                isHorizontal: isHorizontal,
                onEarsLeftTap: () => _triggerVirtualInput('ears', 1),
                onEarsRightTap: () => _triggerVirtualInput('ears', 2),
                onForceLeftTap: () => _triggerVirtualInput('force', 1),
                onForceRightTap: () => _triggerVirtualInput('force', 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
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
                      const SizedBox(width: AudySpacing.elementGap),
                      Text(
                        controller.tr(
                          'round_format',
                          params: {
                            'current': controller.classifyCurrentRound
                                .toString(),
                            'total': controller.classifyTotalRounds.toString(),
                          },
                        ),
                        style: AudyTypography.labelLarge,
                      ),
                      const SizedBox(width: AudySpacing.elementGap),
                      Text(
                        controller.tr(
                          'score_format',
                          params: {
                            'score': controller.classifyScore.toString(),
                          },
                        ),
                        style: AudyTypography.labelLarge.copyWith(
                          color: AudyColors.mintGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AudySpacing.sectionGap),
                  if (_showGuide) ...[
                    GameGuideBox(
                      message: controller.tr('guide_emotion_classify'),
                      onDismissed: () => setState(() => _showGuide = false),
                    ),
                    const SizedBox(height: AudySpacing.elementGap),
                  ],
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
                      imagePath: imagePath,
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
                          children: orderedOptions.map((option) {
                            final isSelected = _selectedAnswer == option;
                            final isAnswered = _showingFeedback;
                            final correctOption =
                                option == question.correctAnswer;

                            Color cardColor =
                                _choicePalette[option] ??
                                const Color(0xFFE7D8FA);
                            if (isAnswered) {
                              if (correctOption) {
                                cardColor = AudyColors.mintGreen;
                              } else if (isSelected && !_isCorrect) {
                                cardColor = AudyColors.error.withValues(
                                  alpha: 0.3,
                                );
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
              ),
            );
          },
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
      final isFinalRound =
          controller.classifyCurrentRound >= controller.classifyTotalRounds;
      unawaited(_sendCorrectAnswerBleSignal(isFinalRound: isFinalRound));
    } else {
      SoundService.instance.playWrong();
    }

    controller.submitClassifyAnswer(answer);

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        // Clear error state BEFORE advancing to prevent red card from showing
        // during the transition to completion screen
        setState(() {
          _selectedAnswer = null;
          _showingFeedback = false;
          _isCorrect = false;
        });
        controller.advanceClassifyRound();
      }
    });
  }

  List<String> _orderedOptionsFor(EmotionQuestion question) {
    final fixedOptions = _fixedChoiceOrder
        .where(question.options.contains)
        .toList(growable: false);
    final extraOptions = question.options
        .where((option) => !_fixedChoiceOrder.contains(option))
        .toList(growable: false);

    return [...fixedOptions, ...extraOptions];
  }

  String? _imagePathForRound(int round, String emotion) {
    if (!EmotionImages.hasImages(emotion)) return null;
    return _roundImagePaths.putIfAbsent(
      round,
      () => EmotionImages.getRandomPath(emotion),
    );
  }

  Future<void> _sendCorrectAnswerBleSignal({required bool isFinalRound}) async {
    try {
      final bluetooth = AudyBluetoothService.instance;
      await bluetooth.pulseEmotion(isFinalRound ? 2 : 1);
      if (isFinalRound) {
        await bluetooth.setLed(11);
      }
    } catch (e) {
      debugPrint(
        'EmotionClassifyScreen: Correct answer BLE signal skipped - $e',
      );
    }
  }

  Future<void> _resetGameBleState() async {
    try {
      final bluetooth = AudyBluetoothService.instance;
      await bluetooth.setArms(0);
      await bluetooth.setLed(0);
    } catch (e) {
      debugPrint('EmotionClassifyScreen: Exit BLE reset skipped - $e');
    }
  }

  @override
  void dispose() {
    unawaited(_resetGameBleState());
    _bleInputSub?.cancel();
    super.dispose();
  }
}
