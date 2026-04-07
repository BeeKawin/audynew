import 'package:flutter/material.dart';

import '../core/app_routes.dart';
import '../core/audy_ui.dart';
import '../core/audy_theme.dart';
import '../state/audy_controller.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AudyResponsivePage(
      builder: (context, adaptive) {
        final controller = AudyScope.of(context);
        final starCount = controller.totalStars;

        final activities = [
          _ActivityData(
            title: 'Games',
            icon: Icons.sports_esports_rounded,
            iconColor: AudyColors.activityGames,
            borderColor: AudyColors.activityGames,
            route: AppRoutes.games,
          ),
          _ActivityData(
            title: 'Read & Speak',
            icon: Icons.menu_book_rounded,
            iconColor: AudyColors.activityReading,
            borderColor: AudyColors.activityReading,
            route: AppRoutes.readingHub,
          ),
          _ActivityData(
            title: 'Social Skills',
            icon: Icons.chat_bubble_rounded,
            iconColor: AudyColors.activitySocial,
            borderColor: AudyColors.activitySocial,
            route: AppRoutes.social,
          ),
          _ActivityData(
            title: 'Rewards',
            icon: Icons.workspace_premium_rounded,
            iconColor: AudyColors.activityRewards,
            borderColor: AudyColors.activityRewards,
            route: AppRoutes.rewards,
          ),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AudyGreetingHeader(
              greeting: 'Hi! What shall we learn?',
              adaptive: adaptive,
              onProfileTap: () =>
                  Navigator.pushNamed(context, AppRoutes.profile),
            ),
            const SizedBox(height: AudySpacing.sectionGap),
            AudyStarProgress(count: starCount, label: 'stars today'),
            const SizedBox(height: AudySpacing.sectionGap),
            const AudySectionTitle(title: 'Activities'),
            const SizedBox(height: AudySpacing.elementGap),
            AudyAdaptiveGrid(
              adaptive: adaptive,
              phoneColumns: 2,
              tabletColumns: 2,
              desktopColumns: 4,
              items: activities
                  .map(
                    (a) => AudyBigIconCard(
                      title: a.title,
                      icon: a.icon,
                      iconColor: a.iconColor,
                      borderColor: a.borderColor,
                      onTap: () => Navigator.pushNamed(context, a.route),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AudySpacing.sectionGap),
            const AudySectionTitle(title: 'Next Up'),
            const SizedBox(height: AudySpacing.elementGap),
            AudyNextActivityCard(
              title: 'Emotion Game',
              icon: Icons.sentiment_satisfied_rounded,
              color: AudyColors.activityGames,
              onTap: () => Navigator.pushNamed(context, AppRoutes.emotionGame),
            ),
          ],
        );
      },
    );
  }
}

class _ActivityData {
  const _ActivityData({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.borderColor,
    required this.route,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final Color borderColor;
  final String route;
}
