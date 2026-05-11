import 'package:flutter/material.dart';

import '../core/audy_theme.dart';
import '../services/sound_service.dart';

class GameGuideBox extends StatelessWidget {
  const GameGuideBox({
    super.key,
    required this.message,
    required this.onDismissed,
  });

  final String message;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        color: AudyColors.backgroundCard,
        borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
        border: Border.all(color: AudyColors.skyBlue, width: 2),
        boxShadow: AudyShadows.cardShadow,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_rounded,
            color: AudyColors.skyBlue,
            size: AudySpacing.iconMedium,
          ),
          const SizedBox(width: AudySpacing.elementGap),
          Expanded(
            child: Text(
              message,
              style: AudyTypography.bodyMedium.copyWith(
                color: AudyColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AudySpacing.smallGap),
          InkWell(
            onTap: () {
              SoundService.instance.playTap();
              onDismissed();
            },
            borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
            child: const SizedBox(
              width: AudySpacing.touchTargetMin,
              height: AudySpacing.touchTargetMin,
              child: Icon(
                Icons.close_rounded,
                color: AudyColors.textSecondary,
                size: AudySpacing.iconSmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
