import 'package:flutter/material.dart';

import '../core/app_routes.dart';
import '../core/audy_ui.dart';
import '../services/sound_service.dart';
import '../state/audy_controller.dart';

class GamesHubPage extends StatelessWidget {
  const GamesHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AudyScope.of(context);

    final cards = [
      _RouteCard(
        controller.tr('emotion_classify'),
        null,
        Icons.face_rounded,
        const Color(0xFFF8C7DF),
        AppRoutes.emotionClassify,
      ),
      _RouteCard(
        controller.tr('emotion_mimic'),
        null,
        Icons.camera_alt_rounded,
        const Color(0xFFDDD0F4),
        AppRoutes.emotionMimic,
      ),
      _RouteCard(
        controller.tr('mini_puzzle'),
        null,
        Icons.extension_rounded,
        const Color(0xFFBDD8F2),
        AppRoutes.miniPuzzle,
      ),
      _RouteCard(
        controller.tr('sorting_game'),
        null,
        Icons.sort_rounded,
        const Color(0xFFFFF3A6),
        AppRoutes.sortingGame,
      ),
      _RouteCard(
        controller.tr('reaction_time'),
        null,
        Icons.bolt_rounded,
        const Color(0xFFFFDAC7),
        AppRoutes.reactionTime,
      ),
    ];

    return AudyFeaturePage(
      title: controller.tr('games'),
      subtitle: controller.tr('play_and_learn'),
      leadingLabel: controller.tr('back_home'),
      mascot: const AudyMascot(size: 132),
      childBuilder: (context, adaptive) {
        return AudyAdaptiveGrid(
          adaptive: adaptive,
          phoneColumns: 1,
          tabletColumns: 2,
          desktopColumns: 2,
          items: cards
              .map(
                (card) => AudyActionCard(
                  title: card.title,
                  subtitle: card.subtitle,
                  icon: card.icon,
                  color: card.color,
                  adaptive: adaptive,
                  onTap: () {
                    SoundService.instance.playTap();
                    Navigator.pushNamed(context, card.route);
                  },
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _RouteCard {
  const _RouteCard(
    this.title,
    this.subtitle,
    this.icon,
    this.color,
    this.route,
  );

  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final String route;
}
