import 'package:flutter/material.dart';

import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../core/emotion_character_widget.dart';
import '../../services/bluetooth_service.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';
import '../../widgets/game_guide_box.dart';
import '../../widgets/robot_panel_layout.dart';
import '../../widgets/virtual_robot_panel.dart';
import 'mimic_complete_screen.dart';

/// "Make this emotion!" - Mimic game
/// Shows a real facial expression photo as a prompt and invites the child
/// to mimic it, using a friendly mascot avatar instead of their own camera
/// feed so the experience stays comfortable for autistic children.
class EmotionMimicScreen extends StatefulWidget {
  const EmotionMimicScreen({super.key});

  @override
  State<EmotionMimicScreen> createState() => _EmotionMimicScreenState();
}

class _EmotionMimicScreenState extends State<EmotionMimicScreen> {
  final DateTime _sessionStartedAt = DateTime.now();
  bool _showGuide = true;

  @override
  void initState() {
    super.initState();
    SoundService.instance.playInstructionEmotionMimic();
  }

  void _triggerVirtualInput(String channel, int value) {
    // UI only: no functional input is processed for the preview screen.
  }

  @override
  Widget build(BuildContext context) {
    final controller = AudyScope.of(context);
    final targetEmotion = controller.currentMimicTarget;

    if (controller.isMimicGameComplete) {
      return MimicCompleteScreen(
        controller: controller,
        sessionStartedAt: _sessionStartedAt,
      );
    }

    return AudyResponsivePage(
      scrollable: false,
      builder: (context, adaptive) {
        final headerGap = adaptive.space(10);
        final guideMaxWidth = adaptive.isPhone
            ? adaptive.space(300)
            : adaptive.space(420);

        return ValueListenableBuilder<bool>(
          valueListenable: AudyBluetoothService.instance.connectionNotifier,
          builder: (context, isConnected, _) {
            return RobotPanelLayout(
              adaptive: adaptive,
              showPanel: !isConnected,
              panelBuilder: (isHorizontal) => VirtualRobotPanel(
                adaptive: adaptive,
                isHorizontal: isHorizontal,
                onTummyTap: () => _triggerVirtualInput('tummy', 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          SoundService.instance.playTap();
                          controller.resetMimicGame();
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
                            'current': controller.mimicCurrentRound.toString(),
                            'total': controller.mimicTotalRounds.toString(),
                          },
                        ),
                        style: AudyTypography.labelLarge,
                      ),
                      const SizedBox(width: AudySpacing.elementGap),
                      Text(
                        controller.tr(
                          'score_format',
                          params: {'score': controller.mimicScore.toString()},
                        ),
                        style: AudyTypography.labelLarge.copyWith(
                          color: AudyColors.mintGreen,
                        ),
                      ),
                      if (_showGuide) ...[
                        SizedBox(width: headerGap),
                        Flexible(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: guideMaxWidth,
                              ),
                              child: GameGuideBox(
                                message: controller.tr('guide_emotion_mimic'),
                                onDismissed: () =>
                                    setState(() => _showGuide = false),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AudySpacing.sectionGap),
                  Center(
                    child: Text(
                      controller.tr('make_this_face'),
                      style: AudyTypography.displayMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AudySpacing.sectionGap),
                  Center(
                    child: EmotionCharacterWidget(
                      emotion: targetEmotion,
                      size: 180,
                      useHumanImage: true,
                    ),
                  ),
                  const SizedBox(height: AudySpacing.sectionGap),
                  Center(
                    child: Text(
                      targetEmotion,
                      style: AudyTypography.headingLarge,
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxWidth: adaptive.space(320),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: adaptive.space(20),
                        horizontal: adaptive.space(16),
                      ),
                      decoration: BoxDecoration(
                        color: AudyColors.backgroundSoft,
                        borderRadius: BorderRadius.circular(
                          AudySpacing.radiusXLarge,
                        ),
                        boxShadow: AudyShadows.cardShadow,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            controller.tr('your_turn'),
                            style: AudyTypography.headingSmall,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: adaptive.space(12)),
                          const AudyMascot(size: 130),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AudySpacing.sectionGap),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
