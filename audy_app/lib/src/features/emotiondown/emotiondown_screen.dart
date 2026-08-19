import 'dart:math' show pi, sin;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_routes.dart';
import '../../core/audy_theme.dart';
import '../../state/audy_controller.dart';
import '../meltdown/wave_painter.dart';

/// EmotionDown protection screen
///
/// Shown when anger/frustration is detected during play, restricting the
/// child from continuing until a parent or teacher unlocks the screen via
/// the Passcode Bypass screen. There is no self-serve return — unlike
/// Meltdown's calming timer — because the point is to hand the device to an
/// adult.
///
/// Emotion recognition is mocked/deferred for this phase: the screen is
/// currently triggered manually (background tap in the FlashCard game). A
/// later phase should push here from a real anger-detection signal instead.
class EmotionDownScreen extends StatefulWidget {
  const EmotionDownScreen({super.key});

  @override
  State<EmotionDownScreen> createState() => _EmotionDownScreenState();
}

class _EmotionDownScreenState extends State<EmotionDownScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _spinController.dispose();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    super.dispose();
  }

  void _onStop() {
    Navigator.of(context).pushNamed(AppRoutes.passcodeBypass);
  }

  @override
  Widget build(BuildContext context) {
    final isThai = AudyScope.of(context).currentLanguage == 'th';

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          color: AudyColors.backgroundPrimary,
          child: Stack(
            children: [
              const AnimatedWaveBackground(),
              SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AudySpacing.screenPadding,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildMascot(),
                        const SizedBox(height: 40),
                        _buildMessageCard(isThai),
                        const SizedBox(height: 56),
                        _buildStopButton(isThai),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMascot() {
    return AnimatedBuilder(
      animation: _spinController,
      builder: (context, child) {
        final floatOffset = sin(_spinController.value * 2 * pi) * 8.0;
        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: AudyColors.blushPink.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: AudyColors.blushPink.withValues(alpha: 0.4),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AudyColors.blushPink.withValues(alpha: 0.15),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/mascot/Neutral.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.sentiment_neutral_rounded,
                      size: 80,
                      color: AudyColors.blushPink,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageCard(bool isThai) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AudySpacing.cardPadding,
        vertical: AudySpacing.elementGap,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(AudySpacing.radiusXLarge),
        border: Border.all(color: AudyColors.borderLight, width: 2),
        boxShadow: AudyShadows.cardShadow,
      ),
      child: Column(
        children: [
          Text(
            'เอาหน้าจอพี่มีไปให้ครูหน่อย',
            style: AudyTypography.headingMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AudySpacing.smallGap),
          Text(
            isThai
                ? 'รอผู้ปกครองหรือครูมาช่วยปลดล็อกหน้าจอนะ'
                : 'Please show this screen to a teacher or parent',
            style: AudyTypography.bodyMedium.copyWith(
              color: AudyColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStopButton(bool isThai) {
    return GestureDetector(
      onTap: _onStop,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AudySpacing.cardPadding * 1.5,
          vertical: AudySpacing.elementGap,
        ),
        decoration: BoxDecoration(
          color: AudyColors.textPrimary,
          borderRadius: BorderRadius.circular(AudySpacing.radiusXLarge),
          boxShadow: [
            BoxShadow(
              color: AudyColors.textPrimary.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 26),
            const SizedBox(width: 12),
            Text(
              isThai ? 'หยุด' : 'Stop',
              style: AudyTypography.buttonText.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
