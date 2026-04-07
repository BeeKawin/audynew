import 'package:flutter/material.dart';
import 'audy_theme.dart';

/// Large, clear button with high contrast and tactile feedback
class AudyButton extends StatelessWidget {
  const AudyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color,
    this.isSecondary = false,
    this.isFullWidth = true,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? color;
  final bool isSecondary;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final bgColor =
        color ?? (isSecondary ? AudyColors.mintGreen : AudyColors.skyBlue);

    return SizedBox(
      height: AudySpacing.buttonHeight,
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: AudyColors.textOnColor,
          elevation: 4,
          shadowColor: bgColor.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AudySpacing.radiusXLarge),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AudySpacing.cardPadding,
            vertical: AudySpacing.smallGap,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: AudySpacing.iconMedium),
              const SizedBox(width: AudySpacing.smallGap),
            ],
            Text(label, style: AudyTypography.buttonText),
          ],
        ),
      ),
    );
  }
}

/// Colorful game card with clear visual identity
class AudyGameCard extends StatelessWidget {
  const AudyGameCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.gradient,
    required this.onTap,
    this.badge,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Gradient gradient;
  final VoidCallback onTap;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AudySpacing.cardPadding),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(AudySpacing.smallGap),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(
                      AudySpacing.radiusMedium,
                    ),
                  ),
                  child: Icon(icon, size: AudySpacing.iconLarge, color: color),
                ),
                ...(badge == null ? const <Widget>[] : <Widget>[badge!]),
              ],
            ),
            const SizedBox(height: AudySpacing.elementGap),
            Text(
              title,
              style: AudyTypography.headingSmall.copyWith(
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AudySpacing.smallGap),
            Text(
              description,
              style: AudyTypography.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.95),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Activity card with clear progress indication
class AudyActivityCard extends StatelessWidget {
  const AudyActivityCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.progress,
    this.onTap,
    this.isLocked = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final double? progress;
  final VoidCallback? onTap;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isLocked ? 0.6 : 1.0,
      child: GestureDetector(
        onTap: isLocked ? null : onTap,
        child: Container(
          padding: const EdgeInsets.all(AudySpacing.cardPadding),
          decoration: BoxDecoration(
            color: AudyColors.backgroundCard,
            borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
            boxShadow: AudyShadows.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AudySpacing.smallGap),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(
                        AudySpacing.radiusMedium,
                      ),
                    ),
                    child: Icon(
                      isLocked ? Icons.lock_rounded : icon,
                      size: AudySpacing.iconMedium,
                      color: isLocked ? AudyColors.textLight : color,
                    ),
                  ),
                  const SizedBox(width: AudySpacing.elementGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AudyTypography.labelMedium),
                        Text(subtitle, style: AudyTypography.bodySmall),
                      ],
                    ),
                  ),
                  if (isLocked)
                    Icon(
                      Icons.lock_outline,
                      color: AudyColors.textLight,
                      size: AudySpacing.iconMedium,
                    ),
                ],
              ),
              if (progress != null && !isLocked) ...[
                const SizedBox(height: AudySpacing.elementGap),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AudySpacing.radiusSmall),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: color.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Reward star with animation
class AudyStar extends StatelessWidget {
  const AudyStar({
    super.key,
    required this.count,
    this.size = AudySpacing.iconMedium,
  });

  final int count;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        count,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Icon(
            Icons.star_rounded,
            color: AudyColors.starGold,
            size: size,
          ),
        ),
      ),
    );
  }
}

/// Section header with clear visual hierarchy
class AudySectionHeader extends StatelessWidget {
  const AudySectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.action,
    this.color,
  });

  final String title;
  final IconData? icon;
  final Widget? action;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final headerColor = color ?? AudyColors.skyBlue;

    return Row(
      children: [
        Container(
          width: 6,
          height: 32,
          decoration: BoxDecoration(
            color: headerColor,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: AudySpacing.elementGap),
        if (icon != null) ...[
          Icon(icon, color: headerColor, size: AudySpacing.iconMedium),
          const SizedBox(width: AudySpacing.smallGap),
        ],
        Expanded(child: Text(title, style: AudyTypography.headingSmall)),
        ...(action == null ? const <Widget>[] : <Widget>[action!]),
      ],
    );
  }
}

/// Large, friendly mascot avatar
class AudyMascot extends StatelessWidget {
  const AudyMascot({
    super.key,
    this.size = 120,
    this.emotion = MascotEmotion.happy,
  });

  final double size;
  final MascotEmotion emotion;

  Color get _emotionColor {
    switch (emotion) {
      case MascotEmotion.happy:
        return AudyColors.mintGreen;
      case MascotEmotion.excited:
        return AudyColors.activityRewards;
      case MascotEmotion.thinking:
        return AudyColors.skyBlue;
      case MascotEmotion.cheering:
        return AudyColors.blushPink;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _emotionColor.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: _emotionColor.withValues(alpha: 0.3),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: _emotionColor.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Icon(_getEmotionIcon(), size: size * 0.5, color: _emotionColor),
      ),
    );
  }

  IconData _getEmotionIcon() {
    switch (emotion) {
      case MascotEmotion.happy:
        return Icons.sentiment_very_satisfied_rounded;
      case MascotEmotion.excited:
        return Icons.celebration_rounded;
      case MascotEmotion.thinking:
        return Icons.psychology_rounded;
      case MascotEmotion.cheering:
        return Icons.emoji_events_rounded;
    }
  }
}

enum MascotEmotion { happy, excited, thinking, cheering }

/// Clear, high-contrast badge
class AudyBadge extends StatelessWidget {
  const AudyBadge({super.key, required this.label, this.color, this.icon});

  final String label;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? AudyColors.activityRewards;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AudySpacing.smallGap,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(AudySpacing.radiusCircular),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AudyColors.textPrimary),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AudyTypography.labelMedium.copyWith(
              fontSize: 14,
              color: AudyColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
