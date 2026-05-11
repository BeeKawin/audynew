import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../core/emotion_character_widget.dart';
import '../../services/bluetooth_service.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';
import '../../widgets/game_guide_box.dart';
import 'mimic_complete_screen.dart';
import 'selfie_capture_screen.dart';

/// "Make this emotion!" - Mimic game
/// Shows an emotion prompt and asks user to mimic it with selfie
class EmotionMimicScreen extends StatefulWidget {
  const EmotionMimicScreen({super.key});

  @override
  State<EmotionMimicScreen> createState() => _EmotionMimicScreenState();
}

class _EmotionMimicScreenState extends State<EmotionMimicScreen> {
  final DateTime _sessionStartedAt = DateTime.now();
  StreamSubscription<AudyBleMessage>? _bleInputSub;
  bool _isCaptureRouteOpen = false;
  bool _showGuide = true;

  @override
  void initState() {
    super.initState();
    SoundService.instance.playInstructionEmotionMimic();
    _bleInputSub = AudyBluetoothService.instance.incomingMessages.listen(
      _handleBleInput,
    );
  }

  void _handleBleInput(AudyBleMessage message) {
    if (!mounted) return;
    if (ModalRoute.of(context)?.isCurrent != true) return;
    if (message.channel != 'tummy' || message.value != 1) return;

    final controller = AudyScope.of(context);
    if (controller.isMimicGameComplete) return;
    if (_isCaptureRouteOpen) return;

    SoundService.instance.playTap();
    unawaited(_startSelfieCapture(controller.currentMimicTarget));
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
        return Column(
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
              ],
            ),
            const SizedBox(height: AudySpacing.sectionGap),
            if (_showGuide) ...[
              GameGuideBox(
                message: controller.tr('guide_emotion_mimic'),
                onDismissed: () => setState(() => _showGuide = false),
              ),
              const SizedBox(height: AudySpacing.elementGap),
            ],
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
                useHumanImage: false,
              ),
            ),
            const SizedBox(height: AudySpacing.sectionGap),
            Center(
              child: Text(targetEmotion, style: AudyTypography.headingLarge),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: AudySpacing.buttonHeight + 12,
              child: ElevatedButton(
                onPressed: () {
                  SoundService.instance.playTap();
                  unawaited(_startSelfieCapture(targetEmotion));
                },
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.camera_alt_rounded, size: 32),
                    const SizedBox(width: 12),
                    Text(
                      controller.tr('take_photo'),
                      style: AudyTypography.buttonText,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AudySpacing.sectionGap),
          ],
        );
      },
    );
  }

  Future<void> _startSelfieCapture(String targetEmotion) async {
    if (_isCaptureRouteOpen) return;

    _isCaptureRouteOpen = true;
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SelfieCaptureScreen(targetEmotion: targetEmotion),
        ),
      );
    } finally {
      if (mounted) {
        _isCaptureRouteOpen = false;
      }
    }
  }

  @override
  void dispose() {
    _bleInputSub?.cancel();
    super.dispose();
  }
}
