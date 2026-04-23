import 'package:flutter/material.dart';

import 'src/core/app_routes.dart';
import 'src/core/audy_theme.dart';
import 'src/data/service_locator.dart';
import 'src/features/dashboard_page.dart';
import 'src/features/emotion_classify_game/emotion_classify_game.dart';
import 'src/features/emotion_mimic_game/emotion_mimic_game.dart';
import 'src/features/feature_pages.dart';
import 'src/features/minipuzzle_game/minipuzzle_game.dart';
import 'src/features/minipuzzle_game/minipuzzle_level_select.dart';
import 'src/features/minipuzzle_game/minipuzzle_game_screen.dart';
import 'src/features/minipuzzle_game/minipuzzle_result_screen.dart';
import 'src/features/minipuzzle_game/minipuzzle_models.dart';
import 'src/features/profile_and_rewards_pages.dart';
import 'src/features/read_pronounce/read_pronounce_hub.dart';
import 'src/features/read_pronounce/read_pronounce_practice.dart';
import 'src/features/read_pronounce/read_pronounce_controller.dart';
import 'src/features/reaction_game/reaction_game_screen.dart';
import 'src/features/sorting_game/sort_level_select_screen.dart';
import 'src/services/emotion_service.dart';
import 'src/services/sound_service.dart';
import 'src/state/audy_controller.dart';
import 'src/widgets/achievement_toast.dart';
import 'src/features/social_chat/social_chat_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  try {
    await EmotionService.init();
  } catch (e) {
    debugPrint('Emotion model failed to load: $e');
  }

  // Initialize sound service
  try {
    await SoundService.instance.initialize();
    debugPrint('Sound service initialized successfully');
  } catch (e) {
    debugPrint('Sound service initialization failed: $e');
  }

  // Initialize database and storage
  bool dbInitialized = false;
  try {
    await ServiceLocator().initialize();
    dbInitialized = true;
    debugPrint('Database initialized successfully');
  } catch (e) {
    debugPrint('Database initialization failed: $e');
    dbInitialized = false;
  }

  runApp(AudyApp(dbInitialized: dbInitialized));
}

class AudyApp extends StatefulWidget {
  final bool dbInitialized;

  const AudyApp({super.key, this.dbInitialized = false});

  @override
  State<AudyApp> createState() => _AudyAppState();
}

class _AudyAppState extends State<AudyApp> {
  late final AudyController controller;
  final int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Only use storage if database was initialized successfully
    controller = AudyController(
      storage: widget.dbInitialized ? ServiceLocator().storageRepository : null,
    );

    // Set up achievement unlock callback
    controller.onAchievementUnlock = (achievement) {
      // Play achievement sound
      SoundService.instance.playAchievement();
      if (mounted) {
        AchievementToast.show(
          context,
          icon: Icons.auto_awesome_rounded,
          title: achievement.title,
          description: achievement.description,
        );
      }
    };

    // Set up level up callback
    controller.onLevelUp = (newLevel) {
      // Play level up sound
      SoundService.instance.playLevelUp();
      // Level up animation is handled in the rewards page
    };
  }

  @override
  void dispose() {
    controller.dispose();
    SoundService.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AudyScope(
      controller: controller,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AUDY - Autism-Friendly Learning',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AudyColors.backgroundPrimary,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AudyColors.skyBlue,
            primary: AudyColors.skyBlue,
            secondary: AudyColors.mintGreen,
            tertiary: AudyColors.activityRewards,
            surface: AudyColors.backgroundCard,
            brightness: Brightness.light,
          ),
          textTheme: TextTheme(
            displayLarge: AudyTypography.displayLarge,
            displayMedium: AudyTypography.displayMedium,
            headlineLarge: AudyTypography.headingLarge,
            headlineMedium: AudyTypography.headingMedium,
            headlineSmall: AudyTypography.headingSmall,
            bodyLarge: AudyTypography.bodyLarge,
            bodyMedium: AudyTypography.bodyMedium,
            bodySmall: AudyTypography.bodySmall,
            labelLarge: AudyTypography.labelLarge,
            labelMedium: AudyTypography.labelMedium,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, AudySpacing.buttonHeight),
              padding: const EdgeInsets.symmetric(
                horizontal: AudySpacing.cardPadding,
                vertical: AudySpacing.elementGap,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AudySpacing.radiusXLarge),
              ),
              elevation: 4,
              textStyle: AudyTypography.buttonText,
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
            ),
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: AudyColors.backgroundPrimary,
            foregroundColor: AudyColors.textPrimary,
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: AudyColors.backgroundCard,
            selectedItemColor: AudyColors.skyBlue,
            unselectedItemColor: AudyColors.textLight,
            type: BottomNavigationBarType.fixed,
            elevation: 8,
            selectedLabelStyle: AudyTypography.labelMedium.copyWith(
              fontSize: 14,
            ),
            unselectedLabelStyle: AudyTypography.bodySmall.copyWith(
              fontSize: 12,
            ),
          ),
        ),
        initialRoute: AppRoutes.dashboard,
        routes: {
          AppRoutes.dashboard: (_) => _HomeShell(currentIndex: _currentIndex),
          AppRoutes.games: (_) => _HomeShell(currentIndex: 1),
          AppRoutes.emotionClassify: (_) => const EmotionClassifyScreen(),
          AppRoutes.emotionMimic: (_) => const EmotionMimicScreen(),
          AppRoutes.miniPuzzle: (_) => const MiniPuzzleGameSelection(),
          AppRoutes.sortingGame: (_) => const SortLevelSelectScreen(),
          AppRoutes.reactionTime: (_) => const ReactionTimePage(),
          AppRoutes.readingHub: (_) => const ReadPronounceHub(),
          AppRoutes.letters: (_) => const ReadPronouncePracticeScreen(
            title: 'Letters Practice',
            subtitle:
                'Listen, repeat, and build confidence one sound at a time.',
            module: ReadPronounceModule.letters,
          ),
          AppRoutes.words: (_) => const ReadPronouncePracticeScreen(
            title: 'Words Practice',
            subtitle:
                'Simple familiar words with listening and speaking practice.',
            module: ReadPronounceModule.words,
          ),
          AppRoutes.sentences: (_) => const ReadPronouncePracticeScreen(
            title: 'Sentences Practice',
            subtitle: 'Say short sentences clearly and at a relaxed pace.',
            module: ReadPronounceModule.sentences,
          ),
          AppRoutes.social: (_) => const SocialPracticePage(),
          AppRoutes.rewards: (_) => _HomeShell(currentIndex: 2),
          AppRoutes.profile: (_) => _HomeShell(currentIndex: 3),
        },
        onGenerateRoute: (settings) {
          debugPrint('onGenerateRoute: ${settings.name}');
          switch (settings.name) {
            case AppRoutes.miniPuzzleLevel:
              final gameType = settings.arguments as MiniPuzzleType;
              return MaterialPageRoute(
                builder: (_) => MiniPuzzleLevelSelect(gameType: gameType),
              );
            case AppRoutes.miniPuzzleGame:
              debugPrint('Creating MiniPuzzleGameScreen route');
              debugPrint('settings.arguments: ${settings.arguments}');
              try {
                final args = settings.arguments as Map<String, dynamic>;
                debugPrint(
                  'Arguments: gameType=${args['gameType']}, difficulty=${args['difficulty']}',
                );
                return MaterialPageRoute(
                  builder: (_) => MiniPuzzleGameScreen(
                    gameType: args['gameType'] as MiniPuzzleType,
                    difficulty: args['difficulty'] as MiniPuzzleDifficulty,
                  ),
                );
              } catch (e, stackTrace) {
                debugPrint('Error creating MiniPuzzleGameScreen: $e');
                debugPrint('Stack trace: $stackTrace');
                return null;
              }
            case AppRoutes.miniPuzzleResult:
              final args = settings.arguments as Map<String, dynamic>;
              final sessionData = args['sessionData'] as MiniPuzzleSessionData;
              final controller = args['controller'] as AudyController;
              return MaterialPageRoute(
                builder: (_) => MiniPuzzleResultScreen(
                  sessionData: sessionData,
                  controller: controller,
                ),
              );
            default:
              return null;
          }
        },
      ),
    );
  }
}

class _HomeShell extends StatelessWidget {
  const _HomeShell({required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      DashboardPage(),
      GamesHubPage(),
      RewardsPage(),
      ProfilePage(),
    ];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          final routes = [
            AppRoutes.dashboard,
            AppRoutes.games,
            AppRoutes.rewards,
            AppRoutes.profile,
          ];
          Navigator.pushReplacementNamed(context, routes[index]);
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_rounded),
            label: AudyScope.of(context).tr('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.sports_esports_rounded),
            label: AudyScope.of(context).tr('games'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.workspace_premium_rounded),
            label: AudyScope.of(context).tr('rewards'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_rounded),
            label: AudyScope.of(context).tr('profile'),
          ),
        ],
      ),
    );
  }
}
