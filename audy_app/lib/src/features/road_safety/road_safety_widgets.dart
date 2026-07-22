import 'package:flutter/material.dart';

import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../state/audy_controller.dart';
import 'road_safety_controller.dart';
import 'road_safety_models.dart';

class RoadSafetyProgress extends StatelessWidget {
  const RoadSafetyProgress({
    super.key,
    required this.current,
    required this.total,
    required this.adaptive,
  });

  final int current;
  final int total;
  final AudyAdaptive adaptive;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (index) {
        final complete = index < current;
        return Expanded(
          child: AnimatedContainer(
            duration: AudyAnimation.normal,
            height: adaptive.space(12),
            margin: EdgeInsets.symmetric(horizontal: adaptive.space(3)),
            decoration: BoxDecoration(
              color: complete ? AudyColors.mintGreen : AudyColors.borderLight,
              borderRadius: BorderRadius.circular(AudySpacing.radiusCircular),
            ),
          ),
        );
      }),
    );
  }
}

class RoadScene extends StatelessWidget {
  const RoadScene({
    super.key,
    required this.controller,
    required this.adaptive,
  });

  final RoadSafetyController controller;
  final AudyAdaptive adaptive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: adaptive.isPhone ? 300 : 360),
      padding: EdgeInsets.all(adaptive.space(18)),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7F6),
        borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
        border: Border.all(color: AudyColors.skyBlue, width: 3),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: _RoadAndCrosswalk()),
          Positioned(
            top: adaptive.space(12),
            right: adaptive.space(12),
            child: WalkSignal(signalState: controller.signalState),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeInOutCubic,
            left: controller.isCrossing
                ? adaptive.space(250)
                : adaptive.space(40),
            bottom: controller.isCrossing
                ? adaptive.space(108)
                : adaptive.space(42),
            child: const _AudyWalker(),
          ),
          Positioned(
            left: adaptive.space(18),
            bottom: adaptive.space(24),
            child: const _CurbLabel(),
          ),
          if (controller.step == RoadSafetyStep.listen)
            Positioned(
              left: adaptive.space(90),
              top: adaptive.space(42),
              child: const _CalmCar(),
            ),
        ],
      ),
    );
  }
}

class WalkSignal extends StatelessWidget {
  const WalkSignal({super.key, required this.signalState});

  final TrafficSignalState signalState;

  @override
  Widget build(BuildContext context) {
    final isGreen = signalState == TrafficSignalState.green;
    return Container(
      width: 84,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AudyColors.textPrimary,
        borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SignalLight(
            color: AudyColors.error,
            isOn: !isGreen,
            icon: Icons.pan_tool_rounded,
          ),
          const SizedBox(height: 10),
          _SignalLight(
            color: AudyColors.mintGreen,
            isOn: isGreen,
            icon: Icons.directions_walk_rounded,
          ),
        ],
      ),
    );
  }
}

class RoadSafetyActionPanel extends StatelessWidget {
  const RoadSafetyActionPanel({
    super.key,
    required this.controller,
    required this.adaptive,
    required this.onAction,
    required this.onContinue,
  });

  final RoadSafetyController controller;
  final AudyAdaptive adaptive;
  final ValueChanged<RoadSafetyAction> onAction;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    if (controller.step == RoadSafetyStep.safe) {
      return _PrimaryActionButton(
        adaptive: adaptive,
        label: AudyScope.of(context).tr('continue'),
        icon: Icons.check_circle_rounded,
        color: AudyColors.mintGreen,
        onTap: onContinue,
      );
    }

    if (controller.step == RoadSafetyStep.intro) {
      return _PrimaryActionButton(
        adaptive: adaptive,
        label: AudyScope.of(context).tr('start'),
        icon: Icons.play_arrow_rounded,
        color: AudyColors.skyBlue,
        onTap: () => onAction(RoadSafetyAction.start),
      );
    }

    if (controller.step == RoadSafetyStep.lookLeft ||
        controller.step == RoadSafetyStep.lookRight ||
        controller.step == RoadSafetyStep.lookLeftAgain) {
      return Row(
        children: [
          Expanded(
            child: _PrimaryActionButton(
              adaptive: adaptive,
              label: AudyScope.of(context).tr('road_safety_left'),
              icon: Icons.keyboard_arrow_left_rounded,
              color: AudyColors.skyBlue,
              onTap: () => onAction(RoadSafetyAction.lookLeft),
            ),
          ),
          SizedBox(width: adaptive.space(12)),
          Expanded(
            child: _PrimaryActionButton(
              adaptive: adaptive,
              label: AudyScope.of(context).tr('road_safety_right'),
              icon: Icons.keyboard_arrow_right_rounded,
              color: AudyColors.skyBlue,
              onTap: () => onAction(RoadSafetyAction.lookRight),
            ),
          ),
        ],
      );
    }

    final action = _singleActionForStep(controller.step);
    return _PrimaryActionButton(
      adaptive: adaptive,
      label: AudyScope.of(context).tr(_labelForAction(action)),
      icon: _iconForAction(action),
      color: action == RoadSafetyAction.cross
          ? AudyColors.mintGreen
          : AudyColors.skyBlue,
      onTap: controller.isCrossing ? null : () => onAction(action),
    );
  }

  RoadSafetyAction _singleActionForStep(RoadSafetyStep step) {
    switch (step) {
      case RoadSafetyStep.stopAtCurb:
        return RoadSafetyAction.stop;
      case RoadSafetyStep.listen:
        return RoadSafetyAction.listen;
      case RoadSafetyStep.waitForSignal:
        return RoadSafetyAction.wait;
      case RoadSafetyStep.cross:
        return RoadSafetyAction.cross;
      case RoadSafetyStep.intro:
      case RoadSafetyStep.lookLeft:
      case RoadSafetyStep.lookRight:
      case RoadSafetyStep.lookLeftAgain:
      case RoadSafetyStep.safe:
      case RoadSafetyStep.complete:
        return RoadSafetyAction.start;
    }
  }

  String _labelForAction(RoadSafetyAction action) {
    switch (action) {
      case RoadSafetyAction.stop:
        return 'road_safety_stop_button';
      case RoadSafetyAction.listen:
        return 'road_safety_listen_button';
      case RoadSafetyAction.wait:
        return 'road_safety_wait_button';
      case RoadSafetyAction.cross:
        return 'road_safety_cross_button';
      case RoadSafetyAction.start:
      case RoadSafetyAction.lookLeft:
      case RoadSafetyAction.lookRight:
        return 'start';
    }
  }

  IconData _iconForAction(RoadSafetyAction action) {
    switch (action) {
      case RoadSafetyAction.stop:
        return Icons.pan_tool_rounded;
      case RoadSafetyAction.listen:
        return Icons.hearing_rounded;
      case RoadSafetyAction.wait:
        return Icons.traffic_rounded;
      case RoadSafetyAction.cross:
        return Icons.directions_walk_rounded;
      case RoadSafetyAction.start:
      case RoadSafetyAction.lookLeft:
      case RoadSafetyAction.lookRight:
        return Icons.play_arrow_rounded;
    }
  }
}

class RoadSafetyFeedbackBanner extends StatelessWidget {
  const RoadSafetyFeedbackBanner({
    super.key,
    required this.feedback,
    required this.adaptive,
  });

  final RoadSafetyFeedback feedback;
  final AudyAdaptive adaptive;

  @override
  Widget build(BuildContext context) {
    final isHint = feedback.type == RoadSafetyFeedbackType.hint;
    final color = isHint ? AudyColors.warning : AudyColors.mintGreen;

    return AnimatedContainer(
      duration: AudyAnimation.normal,
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 56),
      padding: EdgeInsets.symmetric(
        horizontal: adaptive.space(16),
        vertical: adaptive.space(12),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isHint ? 0.26 : 0.18),
        borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          Icon(
            isHint ? Icons.info_rounded : Icons.check_circle_rounded,
            color: isHint ? const Color(0xFF8A5B00) : Colors.green.shade700,
            size: adaptive.space(28),
          ),
          SizedBox(width: adaptive.space(10)),
          Expanded(
            child: Text(
              AudyScope.of(context).tr(feedback.messageKey),
              style: AudyTypography.labelMedium.copyWith(
                color: AudyColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.adaptive,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final AudyAdaptive adaptive;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: adaptive.space(30)),
        label: Text(
          label,
          style: AudyTypography.buttonText.copyWith(
            color: AudyColors.textPrimary,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: AudyColors.textPrimary,
          minimumSize: Size.fromHeight(adaptive.space(68)),
          elevation: 3,
        ),
      ),
    );
  }
}

class _SignalLight extends StatelessWidget {
  const _SignalLight({
    required this.color,
    required this.isOn,
    required this.icon,
  });

  final Color color;
  final bool isOn;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AudyAnimation.normal,
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: isOn ? color : color.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 32),
    );
  }
}

class _RoadAndCrosswalk extends StatelessWidget {
  const _RoadAndCrosswalk();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _RoadPainter());
  }
}

class _RoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()..color = const Color(0xFF5F6F7A);
    final curbPaint = Paint()..color = const Color(0xFFE8F2F0);
    final stripePaint = Paint()..color = Colors.white.withValues(alpha: 0.86);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height * 0.33, size.width, size.height * 0.43),
        const Radius.circular(24),
      ),
      roadPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.76, size.width, size.height * 0.24),
      curbPaint,
    );

    final stripeWidth = size.width * 0.10;
    for (var i = 0; i < 5; i++) {
      final left = size.width * 0.28 + (i * stripeWidth * 1.25);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            left,
            size.height * 0.38,
            stripeWidth,
            size.height * 0.32,
          ),
          const Radius.circular(6),
        ),
        stripePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AudyWalker extends StatelessWidget {
  const _AudyWalker();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AudyColors.blushPink.withValues(alpha: 0.92),
        shape: BoxShape.circle,
        border: Border.all(color: AudyColors.textOnColor, width: 4),
        boxShadow: AudyShadows.cardShadow,
      ),
      child: const Icon(
        Icons.child_care_rounded,
        color: AudyColors.textPrimary,
        size: 44,
      ),
    );
  }
}

class _CalmCar extends StatelessWidget {
  const _CalmCar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 48,
      decoration: BoxDecoration(
        color: AudyColors.softLavender.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
      ),
      child: const Icon(Icons.directions_car_rounded, size: 34),
    );
  }
}

class _CurbLabel extends StatelessWidget {
  const _CurbLabel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AudyColors.backgroundCard,
        borderRadius: BorderRadius.circular(AudySpacing.radiusCircular),
      ),
      child: Text(
        AudyScope.of(context).tr('road_safety_curb'),
        style: AudyTypography.labelMedium,
      ),
    );
  }
}
