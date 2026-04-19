import 'package:flutter/material.dart';

import '../core/app_routes.dart';
import '../core/audy_ui.dart';
import '../core/audy_theme.dart';
import '../services/sound_service.dart';
import '../state/audy_controller.dart';

/// Language toggle button widget
class _LanguageToggle extends StatelessWidget {
  final AudyController controller;

  const _LanguageToggle({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SoundService.instance.playTap();
        final newLang = controller.currentLanguage == 'en' ? 'th' : 'en';
        controller.setLanguage(newLang);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: controller.currentLanguage == 'en'
              ? AudyColors.skyBlue.withValues(alpha: 0.15)
              : AudyColors.mintGreen.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: controller.currentLanguage == 'en'
                ? AudyColors.skyBlue
                : AudyColors.mintGreen,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              controller.currentLanguage == 'en' ? 'EN' : 'ไทย',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: controller.currentLanguage == 'en'
                    ? AudyColors.skyBlue
                    : AudyColors.mintGreen,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.translate_rounded,
              size: 18,
              color: controller.currentLanguage == 'en'
                  ? AudyColors.skyBlue
                  : AudyColors.mintGreen,
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AudyResponsivePage(
      builder: (context, adaptive) {
        final controller = AudyScope.of(context);

        final activities = [
          _ActivityData(
            title: controller.tr('games'),
            icon: Icons.sports_esports_rounded,
            iconColor: AudyColors.activityGames,
            borderColor: AudyColors.activityGames,
            route: AppRoutes.games,
          ),
          _ActivityData(
            title: controller.tr('read_speak'),
            icon: Icons.menu_book_rounded,
            iconColor: AudyColors.activityReading,
            borderColor: AudyColors.activityReading,
            route: AppRoutes.readingHub,
          ),
          _ActivityData(
            title: controller.tr('social_chat'),
            icon: Icons.chat_bubble_rounded,
            iconColor: AudyColors.activitySocial,
            borderColor: AudyColors.activitySocial,
            route: AppRoutes.social,
          ),
          _ActivityData(
            title: controller.tr('rewards'),
            icon: Icons.workspace_premium_rounded,
            iconColor: AudyColors.activityRewards,
            borderColor: AudyColors.activityRewards,
            route: AppRoutes.rewards,
          ),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language toggle at top left
            _LanguageToggle(controller: controller),
            const SizedBox(height: AudySpacing.elementGap),
            AudyGreetingHeader(
              greeting: controller.tr('dashboard_greeting'),
              adaptive: adaptive,
              onProfileTap: () =>
                  Navigator.pushNamed(context, AppRoutes.profile),
            ),
            const SizedBox(height: AudySpacing.sectionGap),
            AudySectionTitle(title: controller.tr('activities')),
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
                      onTap: () {
                        SoundService.instance.playTap();
                        Navigator.pushNamed(context, a.route);
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AudySpacing.sectionGap),
            // Daily Quests Section
            DailyQuestsCard(
              quests: controller.dailyQuests,
              adaptive: adaptive,
              title: controller.tr('daily_quests'),
              bonusText: '+20 ${controller.tr('bonus')}',
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
