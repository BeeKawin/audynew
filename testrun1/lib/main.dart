import 'package:flutter/material.dart';

import 'src/core/app_routes.dart';
import 'src/features/dashboard_page.dart';
import 'src/features/feature_pages.dart';
import 'src/features/profile_and_rewards_pages.dart';
import 'src/state/audy_controller.dart';

void main() {
  runApp(const AudyApp());
}

class AudyApp extends StatefulWidget {
  const AudyApp({super.key});

  @override
  State<AudyApp> createState() => _AudyAppState();
}

class _AudyAppState extends State<AudyApp> {
  late final AudyController controller;

  @override
  void initState() {
    super.initState();
    controller = AudyController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AudyScope(
      controller: controller,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AUDY',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF4F8FC),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF7A63C7),
            brightness: Brightness.light,
          ),
        ),
        initialRoute: AppRoutes.dashboard,
        routes: {
          AppRoutes.dashboard: (_) => const DashboardPage(),
          AppRoutes.games: (_) => const GamesHubPage(),
          AppRoutes.emotionGame: (_) => const EmotionGamePage(),
          AppRoutes.eyeContact: (_) => const EyeContactPage(),
          AppRoutes.colorSorting: (_) => const ColorSortingPage(),
          AppRoutes.reactionTime: (_) => const ReactionTimePage(),
          AppRoutes.readingHub: (_) => const ReadPronouncePage(),
          AppRoutes.letters: (_) => const ReadingPracticePage(
            title: 'Letters Practice',
            subtitle:
                'Listen, repeat, and build confidence one sound at a time.',
            module: ReadingModule.letters,
            illustrationIcon: Icons.apple_rounded,
          ),
          AppRoutes.words: (_) => const ReadingPracticePage(
            title: 'Words Practice',
            subtitle:
                'Simple familiar words with listening and speaking practice.',
            module: ReadingModule.words,
            illustrationIcon: Icons.pets_rounded,
          ),
          AppRoutes.sentences: (_) => const ReadingPracticePage(
            title: 'Sentences Practice',
            subtitle: 'Say short sentences clearly and at a relaxed pace.',
            module: ReadingModule.sentences,
            illustrationIcon: Icons.favorite_rounded,
          ),
          AppRoutes.social: (_) => const SocialPracticePage(),
          AppRoutes.rewards: (_) => const RewardsPage(),
          AppRoutes.profile: (_) => const ProfilePage(),
        },
      ),
    );
  }
}
