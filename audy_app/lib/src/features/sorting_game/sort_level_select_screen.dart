import 'package:flutter/material.dart';

import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';
import 'sorting_game_models.dart';
import 'sort_game_engine.dart';
import 'sort_game_screen.dart';

// Helper function to get localized string
String _tr(BuildContext context, String key, {Map<String, String>? params}) {
  return AudyScope.of(context).tr(key, params: params);
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
    final levels = _engine.getLevels(unlockedLevelIndex: _unlockedLevelIndex);

    return AudyResponsivePage(
      scrollable: false,
      builder: (context, adaptive) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: adaptive.space(8),
              runSpacing: adaptive.space(4),
              children: [
                InkWell(
                  onTap: () {
                    SoundService.instance.playTap();
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
                  child: SizedBox(
                    width: adaptive.space(48),
                    height: adaptive.space(48),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      size: AudySpacing.iconMedium,
                    ),
                  ),
                ),
                Icon(
                  Icons.sort_rounded,
                  size: adaptive.space(32),
                  color: AudyColors.skyBlue,
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: adaptive.space(200)),
                  child: Text(
                    _tr(context, 'sorting_game'),
                    style: AudyTypography.displayMedium,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            SizedBox(height: adaptive.space(24)),
            Center(
              child: Text(
                _tr(context, 'choose_challenge'),
                style: AudyTypography.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: adaptive.space(24)),
            Expanded(
              child: ListView.separated(
                itemCount: levels.length,
                separatorBuilder: (context, index) =>
                    SizedBox(height: adaptive.space(12)),
                itemBuilder: (context, index) {
                  final level = levels[index];
                  return _LevelCard(
                    level: level,
                    adaptive: adaptive,
                    onTap: level.isLocked
                        ? null
                        : () {
                            SoundService.instance.playTap();
                            _startLevel(level);
                          },
                  );
                },
              ),
            ),
          ],
        );
      },
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
  const _LevelCard({
    required this.level,
    required this.adaptive,
    required this.onTap,
  });

  final SortGameLevel level;
  final AudyAdaptive adaptive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = level.theme;
    final isLocked = level.isLocked;

    return Opacity(
      opacity: isLocked ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(adaptive.space(20)),
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
            spacing: adaptive.space(8),
            runSpacing: adaptive.space(4),
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: adaptive.space(48),
                    height: adaptive.space(48),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isLocked ? Icons.lock_rounded : theme.icon,
                      size: adaptive.space(32),
                      color: isLocked
                          ? AudyColors.textLight
                          : theme.primaryColor,
                    ),
                  ),
                  SizedBox(width: adaptive.space(12)),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: adaptive.space(180)),
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
                        SizedBox(height: adaptive.space(4)),
                        Wrap(
                          alignment: WrapAlignment.start,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: adaptive.space(8),
                          runSpacing: adaptive.space(4),
                          children: [
                            _DifficultyBadge(
                              difficulty: level.difficulty,
                              adaptive: adaptive,
                            ),
                            Text(
                              _tr(
                                context,
                                'rounds_format',
                                params: {'count': level.totalRounds.toString()},
                              ),
                              style: AudyTypography.bodySmall.copyWith(
                                fontSize: adaptive.space(14),
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
                size: adaptive.space(24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.difficulty, required this.adaptive});

  final SortDifficulty difficulty;
  final AudyAdaptive adaptive;

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    String label;

    switch (difficulty) {
      case SortDifficulty.easy:
        badgeColor = AudyColors.mintGreen;
        label = _tr(context, 'easy');
        break;
      case SortDifficulty.medium:
        badgeColor = AudyColors.warning;
        label = _tr(context, 'medium');
        break;
      case SortDifficulty.hard:
        badgeColor = AudyColors.error;
        label = _tr(context, 'hard');
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: adaptive.space(10),
        vertical: adaptive.space(4),
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: adaptive.space(12),
          fontWeight: FontWeight.w700,
          color: badgeColor,
        ),
      ),
    );
  }
}
