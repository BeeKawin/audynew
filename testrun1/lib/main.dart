import 'package:flutter/material.dart';

import 'src/core/app_routes.dart';
import 'src/features/dashboard_page.dart';
import 'src/features/feature_pages.dart';
import 'src/features/profile_and_rewards_pages.dart';

void main() {
  runApp(const AudyApp());
}

class AudyApp extends StatelessWidget {
  const AudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
          subtitle: 'Listen, repeat, and build confidence one sound at a time.',
          prompt: 'A',
          progressLabel: 'Progress: 1 / 3',
          illustrationIcon: Icons.apple_rounded,
        ),
        AppRoutes.words: (_) => const ReadingPracticePage(
          title: 'Words Practice',
          subtitle:
              'Simple familiar words with listening and speaking practice.',
          prompt: 'Dog',
          progressLabel: 'Progress: 2 / 5',
          illustrationIcon: Icons.pets_rounded,
        ),
        AppRoutes.sentences: (_) => const ReadingPracticePage(
          title: 'Sentences Practice',
          subtitle: 'Say short sentences clearly and at a relaxed pace.',
          prompt: 'I love you',
          progressLabel: 'Progress: 1 / 3',
          illustrationIcon: Icons.favorite_rounded,
        ),
        AppRoutes.social: (_) => const SocialPracticePage(),
        AppRoutes.rewards: (_) => const RewardsPage(),
        AppRoutes.profile: (_) => const ProfilePage(),
      },
    );
  }
}
