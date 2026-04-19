import 'package:flutter/material.dart';

import '../../core/audy_theme.dart';
import '../../state/audy_controller.dart';
import 'sorting_game_models.dart';

// Helper function to get localized string
String _tr(BuildContext context, String key, {Map<String, String>? params}) {
  return AudyScope.of(context).tr(key, params: params);
}

class _Responsive {
  static const double maxWidth = 420.0;
  static double sp(double width) => width.clamp(0.0, maxWidth);
}

class SortItemCard extends StatefulWidget {
  const SortItemCard({
    super.key,
    required this.item,
    required this.onTap,
    this.isSelected = false,
    this.isHinted = false,
    this.isDisabled = false,
  });

  final SortItem item;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isHinted;
  final bool isDisabled;

  @override
  State<SortItemCard> createState() => _SortItemCardState();
}

class _SortItemCardState extends State<SortItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AudyAnimation.quick,
      vsync: this,
      lowerBound: 0.95,
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
    if (!widget.isDisabled) _controller.reverse();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final effectiveWidth = _Responsive.sp(screenWidth);
    final cardColor = widget.item.color ?? AudyColors.skyBlue;
    final borderColor = widget.isHinted
        ? AudyColors.starGold
        : widget.isSelected
        ? AudyColors.skyBlue
        : AudyColors.borderLight;
    final borderWidth = widget.isHinted ? 4.0 : 3.0;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTap: widget.isDisabled ? null : widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: AudyAnimation.normal,
          padding: EdgeInsets.all(effectiveWidth * 0.02),
          decoration: BoxDecoration(
            color: AudyColors.backgroundCard,
            borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: widget.isHinted
                ? [
                    BoxShadow(
                      color: AudyColors.starGold.withValues(alpha: 0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ]
                : AudyShadows.cardShadow,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              final availableHeight = constraints.maxHeight;
              final iconSize = (availableWidth * 0.4).clamp(28.0, 60.0);
              final maxIconSize = (availableHeight * 0.6).clamp(28.0, 60.0);
              final finalIconSize = iconSize < maxIconSize
                  ? iconSize
                  : maxIconSize;
              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: finalIconSize,
                    height: finalIconSize,
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.item.icon,
                        size: finalIconSize * 0.55,
                        color: cardColor,
                      ),
                    ),
                  ),
                  SizedBox(height: effectiveWidth * 0.01),
                  Flexible(
                    child: Text(
                      widget.item.label,
                      textAlign: TextAlign.center,
                      style: AudyTypography.labelMedium.copyWith(
                        fontSize: (effectiveWidth * 0.035).clamp(12.0, 16.0),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class SortCategoryTarget extends StatelessWidget {
  const SortCategoryTarget({
    super.key,
    required this.category,
    required this.onTap,
    this.itemCount = 0,
    this.isHighlighted = false,
  });

  final SortCategory category;
  final VoidCallback onTap;
  final int itemCount;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final effectiveWidth = _Responsive.sp(screenWidth);
    final catColor = category.color ?? AudyColors.skyBlue;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AudyAnimation.normal,
        padding: EdgeInsets.all(effectiveWidth * 0.04),
        decoration: BoxDecoration(
          color: catColor.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
          border: Border.all(
            color: isHighlighted ? catColor : catColor.withValues(alpha: 0.4),
            width: isHighlighted ? 4 : 2,
          ),
          boxShadow: isHighlighted
              ? [
                  BoxShadow(
                    color: catColor.withValues(alpha: 0.4),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ]
              : AudyShadows.cardShadow,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final availableHeight = constraints.maxHeight;
            final iconSize = (availableWidth * 0.4).clamp(28.0, 60.0);
            final maxIconSize = (availableHeight * 0.5).clamp(28.0, 60.0);
            final finalIconSize = iconSize < maxIconSize
                ? iconSize
                : maxIconSize;
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: finalIconSize,
                  height: finalIconSize,
                  child: Container(
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      category.icon,
                      size: finalIconSize * 0.55,
                      color: catColor,
                    ),
                  ),
                ),
                SizedBox(height: effectiveWidth * 0.01),
                Flexible(
                  child: Text(
                    category.label,
                    textAlign: TextAlign.center,
                    style: AudyTypography.labelMedium.copyWith(
                      fontSize: (effectiveWidth * 0.035).clamp(12.0, 16.0),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (itemCount > 0) ...[
                  SizedBox(height: effectiveWidth * 0.01),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: effectiveWidth * 0.02,
                      vertical: effectiveWidth * 0.005,
                    ),
                    decoration: BoxDecoration(
                      color: catColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$itemCount',
                      style: TextStyle(
                        fontSize: (effectiveWidth * 0.03).clamp(10.0, 14.0),
                        fontWeight: FontWeight.w700,
                        color: AudyColors.textOnColor,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class ABAGameFeedbackOverlay extends StatelessWidget {
  const ABAGameFeedbackOverlay({
    super.key,
    required this.message,
    required this.isCorrect,
  });

  final String message;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final effectiveWidth = _Responsive.sp(screenWidth);

    return AnimatedOpacity(
      duration: AudyAnimation.normal,
      opacity: 1.0,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: effectiveWidth * 0.05,
          vertical: effectiveWidth * 0.03,
        ),
        decoration: BoxDecoration(
          color: isCorrect
              ? AudyColors.mintGreen.withValues(alpha: 0.95)
              : AudyColors.warning.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(AudySpacing.radiusXLarge),
          boxShadow: AudyShadows.cardShadow,
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: effectiveWidth * 0.02,
          children: [
            Icon(
              isCorrect ? Icons.check_circle_rounded : Icons.info_rounded,
              size: (effectiveWidth * 0.08).clamp(24.0, 48.0),
              color: AudyColors.textOnColor,
            ),
            Flexible(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: (effectiveWidth * 0.05).clamp(16.0, 24.0),
                  fontWeight: FontWeight.w700,
                  color: AudyColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StarRewardDisplay extends StatelessWidget {
  const StarRewardDisplay({
    super.key,
    required this.starsEarned,
    required this.maxStars,
    this.starSize = 48,
  });

  final int starsEarned;
  final int maxStars;
  final double starSize;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      spacing: 4,
      runSpacing: 4,
      children: List.generate(maxStars, (index) {
        final filled = index < starsEarned;
        return AnimatedScale(
          scale: filled ? 1.1 : 0.9,
          duration: AudyAnimation.emphasis,
          child: Icon(
            Icons.star_rounded,
            size: starSize,
            color: filled ? AudyColors.starGold : AudyColors.starSilver,
          ),
        );
      }),
    );
  }
}

class SortGameProgress extends StatelessWidget {
  const SortGameProgress({
    super.key,
    required this.currentRound,
    required this.totalRounds,
    required this.remainingItems,
  });

  final int currentRound;
  final int totalRounds;
  final int remainingItems;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final effectiveWidth = _Responsive.sp(screenWidth);

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      runAlignment: WrapAlignment.center,
      spacing: effectiveWidth * 0.02,
      runSpacing: effectiveWidth * 0.01,
      children: [
        Text(
          _tr(
            context,
            'round_format',
            params: {
              'current': currentRound.toString(),
              'total': totalRounds.toString(),
            },
          ),
          style: AudyTypography.labelLarge,
        ),
        if (remainingItems > 0)
          Text(
            _tr(
              context,
              'items_left',
              params: {'count': remainingItems.toString()},
            ),
            style: AudyTypography.labelMedium.copyWith(
              color: AudyColors.textSecondary,
            ),
          ),
      ],
    );
  }
}
