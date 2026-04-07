import 'package:flutter/material.dart';
import 'audy_theme.dart';

class AudyAdaptive {
  const AudyAdaptive({required this.width, required this.height});

  final double width;
  final double height;

  bool get isPhone => width < 600;
  bool get isTablet => width >= 600 && width < 1024;
  bool get isDesktop => width >= 1024;

  double get scale => (width / 390).clamp(0.92, 1.35);
  double space(double value) => value * scale;
  double get contentMaxWidth => isPhone ? width : (isTablet ? 860 : 1180);

  int columns({required int phone, required int tablet, required int desktop}) {
    if (isDesktop) return desktop;
    if (isTablet) return tablet;
    return phone;
  }
}

class AudyResponsivePage extends StatelessWidget {
  const AudyResponsivePage({super.key, required this.builder});

  final Widget Function(BuildContext context, AudyAdaptive adaptive) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.of(context).size.height;
        final adaptive = AudyAdaptive(width: width, height: height);

        return Scaffold(
          body: DecoratedBox(
            decoration: const BoxDecoration(
              color: AudyColors.backgroundPrimary,
            ),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: adaptive.contentMaxWidth,
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: adaptive.isPhone
                          ? AudySpacing.screenPadding
                          : adaptive.space(28),
                      vertical: adaptive.isPhone
                          ? AudySpacing.screenPadding
                          : adaptive.space(28),
                    ),
                    child: builder(context, adaptive),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Large, icon-first activity card designed for visual recognition
class AudyBigIconCard extends StatefulWidget {
  const AudyBigIconCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.borderColor,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  State<AudyBigIconCard> createState() => _AudyBigIconCardState();
}

class _AudyBigIconCardState extends State<AudyBigIconCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AudyAnimation.quick,
      vsync: this,
      lowerBound: 0.97,
      upperBound: 1.0,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.reverse();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.forward();
  }

  void _onTapCancel() {
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          constraints: const BoxConstraints(minHeight: 160),
          padding: const EdgeInsets.all(AudySpacing.cardPadding),
          decoration: BoxDecoration(
            color: AudyColors.backgroundCard,
            borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
            border: Border.all(color: widget.borderColor, width: 3),
            boxShadow: AudyShadows.cardShadow,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: AudySpacing.iconXLarge,
                height: AudySpacing.iconXLarge,
                decoration: BoxDecoration(
                  color: widget.iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  size: AudySpacing.iconLarge,
                  color: widget.iconColor,
                ),
              ),
              const SizedBox(height: AudySpacing.smallGap),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: AudyTypography.cardTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple "Next Activity" card with arrow
class AudyNextActivityCard extends StatelessWidget {
  const AudyNextActivityCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AudySpacing.cardPadding,
          vertical: AudySpacing.elementGap,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: AudySpacing.iconMedium,
              height: AudySpacing.iconMedium,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: AudySpacing.iconSmall, color: color),
            ),
            const SizedBox(width: AudySpacing.elementGap),
            Expanded(
              child: Text('Next: $title', style: AudyTypography.headingSmall),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              size: AudySpacing.iconMedium,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}

/// Star count display for child-friendly progress
class AudyStarProgress extends StatelessWidget {
  const AudyStarProgress({super.key, required this.count, required this.label});

  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AudySpacing.cardPadding,
          vertical: AudySpacing.elementGap,
        ),
        decoration: BoxDecoration(
          color: AudyColors.backgroundCard,
          borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
          border: Border.all(
            color: AudyColors.starGold.withValues(alpha: 0.4),
            width: 2,
          ),
          boxShadow: AudyShadows.cardShadow,
        ),
        child: Row(
          children: [
            Icon(
              Icons.star_rounded,
              size: AudySpacing.iconLarge,
              color: AudyColors.starGold,
            ),
            const SizedBox(width: AudySpacing.smallGap),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$count', style: AudyTypography.starCount),
                Text(
                  label,
                  style: AudyTypography.bodySmall.copyWith(fontSize: 14),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              size: AudySpacing.iconMedium,
              color: AudyColors.textLight,
            ),
          ],
        ),
      ),
    );
  }
}

/// Gentle greeting header with mascot
class AudyGreetingHeader extends StatelessWidget {
  const AudyGreetingHeader({
    super.key,
    required this.greeting,
    required this.adaptive,
    this.onProfileTap,
  });

  final String greeting;
  final AudyAdaptive adaptive;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AUDY',
                style: AudyTypography.displayMedium.copyWith(
                  color: AudyColors.skyBlue,
                ),
              ),
              const SizedBox(height: 4),
              Text(greeting, style: AudyTypography.greeting),
            ],
          ),
        ),
        if (onProfileTap != null)
          GestureDetector(
            onTap: onProfileTap,
            child: Container(
              width: AudySpacing.touchTargetMin,
              height: AudySpacing.touchTargetMin,
              decoration: BoxDecoration(
                color: AudyColors.softLavender.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AudyColors.softLavender.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.person_rounded,
                size: AudySpacing.iconMedium,
                color: AudyColors.softLavender,
              ),
            ),
          ),
      ],
    );
  }
}

/// Section title - simplified, no subtitle
class AudySectionTitle extends StatelessWidget {
  const AudySectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AudyTypography.headingMedium);
  }
}

/// Responsive grid for activity cards
class AudyAdaptiveGrid extends StatelessWidget {
  const AudyAdaptiveGrid({
    super.key,
    required this.adaptive,
    required this.phoneColumns,
    required this.tabletColumns,
    required this.desktopColumns,
    required this.items,
  });

  final AudyAdaptive adaptive;
  final int phoneColumns;
  final int tabletColumns;
  final int desktopColumns;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    final columns = adaptive.columns(
      phone: phoneColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = adaptive.space(20);
        final itemWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items
              .map((item) => SizedBox(width: itemWidth, child: item))
              .toList(),
        );
      },
    );
  }
}

/// Back button with larger touch target
class AudyBackButton extends StatelessWidget {
  const AudyBackButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AudySpacing.smallGap,
          vertical: 8,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back_rounded,
              size: AudySpacing.iconSmall,
              color: AudyColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AudyTypography.labelMedium.copyWith(
                color: AudyColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Backward Compatibility Aliases ───

class AudyMascot extends StatelessWidget {
  const AudyMascot({super.key, this.size = 108});
  final double size;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AudyColors.mintGreen.withValues(alpha: 0.15),
        border: Border.all(
          color: AudyColors.mintGreen.withValues(alpha: 0.3),
          width: 3,
        ),
      ),
      child: Icon(
        Icons.sentiment_satisfied_rounded,
        size: size * 0.5,
        color: AudyColors.mintGreen,
      ),
    );
  }
}

class AudyBadgeIcon extends StatelessWidget {
  const AudyBadgeIcon({
    super.key,
    required this.icon,
    required this.size,
    required this.background,
    required this.foreground,
  });
  final IconData icon;
  final double size;
  final Color background;
  final Color foreground;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: foreground.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(icon, color: foreground, size: size * 0.55),
    );
  }
}

class AudyActionCard extends StatelessWidget {
  const AudyActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.adaptive,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final AudyAdaptive adaptive;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(adaptive.space(24)),
        child: Ink(
          padding: EdgeInsets.all(adaptive.space(18)),
          decoration: BoxDecoration(
            color: AudyColors.backgroundCard,
            borderRadius: BorderRadius.circular(adaptive.space(24)),
            border: Border.all(color: color, width: 3),
            boxShadow: AudyShadows.cardShadow,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: adaptive.isPhone
                  ? adaptive.space(136)
                  : adaptive.space(150),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: adaptive.space(34), color: color),
                SizedBox(height: adaptive.space(12)),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: adaptive.space(16),
                    fontWeight: FontWeight.w800,
                    color: AudyColors.textPrimary,
                  ),
                ),
                SizedBox(height: adaptive.space(6)),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: adaptive.space(12),
                    color: AudyColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AudyFeaturePage extends StatelessWidget {
  const AudyFeaturePage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.leadingLabel,
    required this.childBuilder,
    this.mascot,
  });
  final String title;
  final String subtitle;
  final String leadingLabel;
  final Widget Function(BuildContext context, AudyAdaptive adaptive)
  childBuilder;
  final Widget? mascot;
  @override
  Widget build(BuildContext context) {
    return AudyResponsivePage(
      builder: (context, adaptive) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AudyBackButton(
              label: leadingLabel,
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(height: adaptive.space(22)),
            Center(
              child: Column(
                children: [
                  if (mascot != null) ...[mascot!],
                  SizedBox(height: adaptive.space(16)),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AudyTypography.headingLarge,
                  ),
                  SizedBox(height: adaptive.space(8)),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: AudyTypography.bodySmall,
                  ),
                ],
              ),
            ),
            SizedBox(height: adaptive.space(26)),
            childBuilder(context, adaptive),
          ],
        );
      },
    );
  }
}

class AudyPillButton extends StatelessWidget {
  const AudyPillButton({
    super.key,
    required this.label,
    required this.color,
    required this.adaptive,
    required this.onPressed,
    this.icon,
  });
  final String label;
  final Color color;
  final AudyAdaptive adaptive;
  final VoidCallback onPressed;
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: icon == null
          ? const SizedBox.shrink()
          : Icon(icon, size: adaptive.space(20)),
      label: Text(
        label,
        style: TextStyle(
          fontSize: adaptive.space(14),
          fontWeight: FontWeight.w800,
        ),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: AudyColors.textOnColor,
        padding: EdgeInsets.symmetric(
          horizontal: adaptive.space(22),
          vertical: adaptive.space(15),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        elevation: 3,
        shadowColor: AudyColors.shadowMedium,
      ),
    );
  }
}

class AudyAnswerCard extends StatelessWidget {
  const AudyAnswerCard({
    super.key,
    required this.label,
    required this.color,
    required this.adaptive,
    required this.onTap,
  });
  final String label;
  final Color color;
  final AudyAdaptive adaptive;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(adaptive.space(18)),
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: adaptive.space(22),
            vertical: adaptive.space(20),
          ),
          decoration: BoxDecoration(
            color: AudyColors.backgroundCard,
            borderRadius: BorderRadius.circular(adaptive.space(18)),
            border: Border.all(color: color, width: 2),
            boxShadow: AudyShadows.cardShadow,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: adaptive.space(16),
                fontWeight: FontWeight.w800,
                color: AudyColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AudyPanel extends StatelessWidget {
  const AudyPanel({
    super.key,
    required this.adaptive,
    required this.child,
    this.padding,
  });
  final AudyAdaptive adaptive;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(adaptive.space(22)),
      decoration: BoxDecoration(
        color: AudyColors.backgroundCard,
        borderRadius: BorderRadius.circular(adaptive.space(28)),
        border: Border.all(color: AudyColors.borderLight, width: 1),
        boxShadow: AudyShadows.cardShadow,
      ),
      child: child,
    );
  }
}
