import 'package:flutter/material.dart';

import '../../core/audy_theme.dart';
import 'sorting_game_models.dart';
import 'sort_game_engine.dart';
import 'sort_game_screen.dart';

class _Responsive {
  static const double maxWidth = 420.0;
  static double sp(double width) => width.clamp(0.0, maxWidth);
}

class SortLevelSelectScreen extends StatefulWidget {
  const SortLevelSelectScreen({super.key});

  @override
  State<SortLevelSelectScreen> createState() => _SortLevelSelectScreenState();
}

class _SortLevelSelectScreenState extends State<SortLevelSelectScreen> {
  late SortGameEngine _engine;
  int _unlockedLevelIndex = 0;

  @override
  void initState() {
    super.initState();
    _engine = SortGameEngine();
  }

  @override
  void dispose() {
    _engine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final effectiveWidth = _Responsive.sp(screenWidth);
    final levels = _engine.getLevels(unlockedLevelIndex: _unlockedLevelIndex);

    return Scaffold(
      backgroundColor: AudyColors.backgroundPrimary,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: _Responsive.maxWidth),
            child: Padding(
              padding: EdgeInsets.all(effectiveWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: effectiveWidth * 0.02,
                    runSpacing: effectiveWidth * 0.01,
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(
                          AudySpacing.radiusMedium,
                        ),
                        child: SizedBox(
                          width: effectiveWidth * 0.12,
                          height: effectiveWidth * 0.12,
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            size: AudySpacing.iconMedium,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.sort_rounded,
                        size: (effectiveWidth * 0.08).clamp(24.0, 48.0),
                        color: AudyColors.skyBlue,
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: effectiveWidth * 0.5,
                        ),
                        child: Text(
                          'Sorting Game',
                          style: AudyTypography.displayMedium,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: (screenHeight * 0.03).clamp(10.0, 30.0)),
                  Center(
                    child: Text(
                      'Choose a level to play!',
                      style: AudyTypography.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: (screenHeight * 0.03).clamp(10.0, 30.0)),
                  Expanded(
                    child: ListView.separated(
                      itemCount: levels.length,
                      separatorBuilder: (context, index) => SizedBox(
                        height: (screenHeight * 0.015).clamp(5.0, 15.0),
                      ),
                      itemBuilder: (context, index) {
                        final level = levels[index];
                        return _LevelCard(
                          level: level,
                          onTap: level.isLocked
                              ? null
                              : () => _startLevel(level),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _startLevel(SortGameLevel level) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SortGameScreen(level: level)),
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        final starsEarned = result['stars'] as int? ?? 0;
        if (starsEarned >= level.starsRequired) {
          setState(() {
            _unlockedLevelIndex = _unlockedLevelIndex + 1;
          });
        }
      }
    });
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.level, required this.onTap});

  final SortGameLevel level;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final effectiveWidth = _Responsive.sp(screenWidth);
    final theme = level.theme;
    final isLocked = level.isLocked;

    return Opacity(
      opacity: isLocked ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(effectiveWidth * 0.05),
          decoration: BoxDecoration(
            color: AudyColors.backgroundCard,
            borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
            border: Border.all(
              color: isLocked
                  ? AudyColors.borderLight
                  : theme.primaryColor.withValues(alpha: 0.4),
              width: 2,
            ),
            boxShadow: AudyShadows.cardShadow,
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: effectiveWidth * 0.02,
            runSpacing: effectiveWidth * 0.01,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: effectiveWidth * 0.12,
                    height: effectiveWidth * 0.12,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isLocked ? Icons.lock_rounded : theme.icon,
                      size: (effectiveWidth * 0.08).clamp(24.0, 48.0),
                      color: isLocked
                          ? AudyColors.textLight
                          : theme.primaryColor,
                    ),
                  ),
                  SizedBox(width: effectiveWidth * 0.03),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: effectiveWidth * 0.45,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          level.name,
                          style: AudyTypography.headingSmall,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        SizedBox(height: effectiveWidth * 0.01),
                        Wrap(
                          alignment: WrapAlignment.start,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: effectiveWidth * 0.02,
                          runSpacing: effectiveWidth * 0.01,
                          children: [
                            _DifficultyBadge(difficulty: level.difficulty),
                            Text(
                              '${level.totalRounds} rounds',
                              style: AudyTypography.bodySmall.copyWith(
                                fontSize: (effectiveWidth * 0.035).clamp(
                                  12.0,
                                  16.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Icon(
                isLocked ? Icons.lock_outline : Icons.arrow_forward_rounded,
                color: isLocked ? AudyColors.textLight : AudyColors.skyBlue,
                size: (effectiveWidth * 0.06).clamp(18.0, 36.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.difficulty});

  final SortDifficulty difficulty;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final effectiveWidth = _Responsive.sp(screenWidth);
    Color badgeColor;
    String label;

    switch (difficulty) {
      case SortDifficulty.easy:
        badgeColor = AudyColors.mintGreen;
        label = 'Easy';
        break;
      case SortDifficulty.medium:
        badgeColor = AudyColors.warning;
        label = 'Medium';
        break;
      case SortDifficulty.hard:
        badgeColor = AudyColors.error;
        label = 'Hard';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: effectiveWidth * 0.025,
        vertical: effectiveWidth * 0.01,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: (effectiveWidth * 0.03).clamp(10.0, 14.0),
          fontWeight: FontWeight.w700,
          color: badgeColor,
        ),
      ),
    );
  }
}
