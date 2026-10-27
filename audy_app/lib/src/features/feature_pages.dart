import 'package:flutter/material.dart';

import '../core/app_routes.dart';
import '../core/audy_ui.dart';
import '../services/sound_service.dart';
import '../state/audy_controller.dart';

class GamesHubPage extends StatefulWidget {
  const GamesHubPage({super.key});

  @override
  State<GamesHubPage> createState() => _GamesHubPageState();
}

class _GamesHubPageState extends State<GamesHubPage> {
  bool _opening = false;

  Future<void> _navigateToGame(BuildContext context, String route) async {
    if (_opening) return;
    final controller = AudyScope.of(context);
    setState(() => _opening = true);
    try {
      SoundService.instance.playTap();
      final accountId = controller.currentUser?.id;
      await controller.refreshBreakSettings();
      if (!context.mounted || controller.currentUser?.id != accountId) return;
      Navigator.pushNamed(
        context,
        controller.shouldTriggerMeltdown ? AppRoutes.meltdown : route,
      );
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AudyScope.of(context);

    final cards = [
      _RouteCard(
        controller.tr('emotion_game'),
        null,
        Icons.face_rounded,
        const Color(0xFFF8C7DF),
        AppRoutes.emotionClassify,
      ),
      _RouteCard(
        controller.tr('mini_puzzle'),
        null,
        Icons.extension_rounded,
        const Color(0xFFBDD8F2),
        AppRoutes.miniPuzzle,
      ),
      _RouteCard(
        controller.tr('flashcard_game'),
        null,
        Icons.style_rounded,
        const Color(0xFFBFE7F2),
        AppRoutes.flashcard,
      ),
      // _RouteCard(
      //   controller.tr('road_safety_game'),
      //   null,
      //   Icons.traffic_rounded,
      //   const Color(0xFFFFE1B8),
      //   AppRoutes.roadSafety,
      // ),
      _RouteCard(
        controller.tr('fruit_catching_bear'),
        null,
        Icons.shopping_basket_rounded,
        const Color(0xFFC9E8C1),
        AppRoutes.fruitCatchingBear,
      ),
    ];

    return AudyFeaturePage(
      title: controller.tr('games'),
      subtitle: controller.tr('play_and_learn'),
      leadingLabel: controller.tr('back_home'),
      mascot: const AudyMascot(size: 132),
      childBuilder: (context, adaptive) {
        return Column(
          children: [
            if (_opening) const LinearProgressIndicator(),
            AudyAdaptiveGrid(
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
                      onTap: () => _navigateToGame(context, card.route),
                    ),
                  )
                  .toList(),
            ),
          ],
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
