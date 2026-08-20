import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/core/app_routes.dart';
import 'src/core/audy_theme.dart';
import 'src/data/service_locator.dart';
import 'src/features/assignments_page.dart';
import 'src/features/auth/login_page.dart';
import 'src/features/dashboard_page.dart';
import 'src/features/emotion_classify_game/emotion_classify_screen.dart';
import 'src/features/feature_pages.dart';
import 'src/features/flashcard/flashcard_difficulty_screen.dart';
import 'src/features/fruit_catching_bear/fruit_catching_bear_screen.dart';
import 'src/features/emotiondown/emotiondown_screen.dart';
import 'src/features/meltdown/meltdown_screen.dart';
import 'src/features/passcode_bypass/passcode_bypass_screen.dart';
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
import 'src/features/road_safety/road_safety_screen.dart';
import 'src/features/sorting_game/sort_level_select_screen.dart';
import 'src/features/debug/debug_broadcast_page.dart';
import 'src/services/bluetooth_service.dart';
import 'src/services/debug_broadcast_service.dart';
import 'src/services/emotion_service.dart';
import 'src/services/sound_service.dart';
import 'src/state/audy_controller.dart';
import 'src/widgets/achievement_toast.dart';
import 'src/features/device/device_connection_page.dart';
import 'src/features/social_chat/social_chat_page.dart';
import 'src/features/settings/preferences_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase first
  await Supabase.initialize(
    url: 'https://zltkubxggxprdjnspbfk.supabase.co',
    anonKey: 'sb_publishable_oMatucQUNC7OFMhiC1SsaA_PzHzj-2z',
  );

  // Initialize services
  await EmotionService.init();

  // Initialize sound service
  try {
    await SoundService.instance.initialize();
    debugPrint('Sound service initialized successfully');
  } catch (e) {
    debugPrint('Sound service initialization failed: $e');
  }

  // Initialize Bluetooth service
  try {
    await AudyBluetoothService.instance.initialize();
    debugPrint('Bluetooth service initialized successfully');
  } catch (e) {
    debugPrint('Bluetooth service initialization failed: $e');
  }

  // Connect to the debug broadcast relay in the background — best-effort,
  // never blocks startup — and keep retrying forever if it drops. Keeps the
  // app ready to send/receive a debug event at any time, without the user
  // ever having to open the debug page first.
  DebugBroadcastService.instance.start();

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
  bool _isInitializing = true;
  final _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<void>? _emotionDownSub;

  @override
  void initState() {
    super.initState();

    // Debug-broadcast "emotion down" trigger: push the EmotionDown lock
    // screen on top of whatever this device is currently showing, the same
    // way a real anger-detection signal would.
    _emotionDownSub = DebugBroadcastService.instance.emotionDownEvents.listen(
      (_) {
        _navigatorKey.currentState?.pushNamed(AppRoutes.emotionDown);
      },
    );
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

    // Initialize controller (loads storage + checks auth)
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await controller.init();
    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  void dispose() {
    _emotionDownSub?.cancel();
    controller.dispose();
    SoundService.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show splash screen while initializing
    if (_isInitializing) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: AudyColors.backgroundPrimary,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.child_care_rounded,
                  size: 80,
                  color: AudyColors.skyBlue,
                ),
                const SizedBox(height: 24),
                Text(
                  'AUDY',
                  style: AudyTypography.displayLarge.copyWith(
                    color: AudyColors.skyBlue,
                  ),
                ),
                const SizedBox(height: 16),
                const CircularProgressIndicator(color: AudyColors.skyBlue),
              ],
            ),
          ),
        ),
      );
    }

    // Determine initial route based on auth state
    final initialRoute = controller.isLoggedIn
        ? AppRoutes.dashboard
        : AppRoutes.login;

    return AudyScope(
      controller: controller,
      child: MaterialApp(
        navigatorKey: _navigatorKey,
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
        initialRoute: initialRoute,
        routes: {
          AppRoutes.login: (_) => const LoginPage(),
          AppRoutes.dashboard: (_) => _HomeShell(currentIndex: _currentIndex),
          AppRoutes.games: (_) => _HomeShell(currentIndex: 1),
          AppRoutes.emotionClassify: (_) => const EmotionClassifyScreen(),
          AppRoutes.emotionMimic: (_) => const EmotionClassifyScreen(),
          AppRoutes.miniPuzzle: (_) => const MiniPuzzleGameSelection(),
          AppRoutes.sortingGame: (_) => const SortLevelSelectScreen(),
          AppRoutes.flashcard: (_) => const FlashcardDifficultyScreen(),
          AppRoutes.roadSafety: (_) => const RoadSafetyScreen(),
          AppRoutes.fruitCatchingBear: (_) => const FruitCatchingBearScreen(),
          AppRoutes.reactionTime: (_) => const ReactionTimePage(),
          AppRoutes.readingHub: (_) => const ReadPronounceHub(),
          AppRoutes.letters: (_) => const ReadPronouncePracticeScreen(
            title: 'letters_practice',
            subtitle: 'listen_repeat',
            module: ReadPronounceModule.letters,
          ),
          AppRoutes.words: (_) => const ReadPronouncePracticeScreen(
            title: 'words_practice',
            subtitle: 'simple_words',
            module: ReadPronounceModule.words,
          ),
          AppRoutes.sentences: (_) => const ReadPronouncePracticeScreen(
            title: 'sentences_practice',
            subtitle: 'short_sentences',
            module: ReadPronounceModule.sentences,
          ),
          AppRoutes.social: (_) => const SocialPracticePage(),
          AppRoutes.rewards: (_) => _HomeShell(currentIndex: 2),
          AppRoutes.profile: (_) => _HomeShell(currentIndex: 3),
          AppRoutes.preferences: (_) =>
              const PreferencesPage(isOnboarding: true),
          AppRoutes.meltdown: (_) => const MeltdownScreen(),
          AppRoutes.emotionDown: (_) => const EmotionDownScreen(),
          AppRoutes.passcodeBypass: (_) => const PasscodeBypassScreen(),
          AppRoutes.device: (_) => const DeviceConnectionPage(),
          AppRoutes.assignments: (_) => const AssignmentsPage(),
          AppRoutes.debugBroadcast: (_) => const DebugBroadcastPage(),
        },
        onGenerateRoute: (settings) {
          debugPrint('onGenerateRoute: ${settings.name}');
          switch (settings.name) {
            case AppRoutes.meltdown:
              // Slow, calm transition for meltdown screen (2-second cross-fade)
              return PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const MeltdownScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation.drive(
                          CurveTween(
                            curve: const Interval(
                              0.0,
                              1.0,
                              curve: Curves.easeInOut,
                            ),
                          ),
                        ),
                        child: child,
                      );
                    },
                transitionDuration: const Duration(seconds: 2),
                reverseTransitionDuration: const Duration(seconds: 1),
              );
            case AppRoutes.emotionDown:
              // Same calm cross-fade treatment as the meltdown screen.
              return PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const EmotionDownScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation.drive(
                          CurveTween(
                            curve: const Interval(
                              0.0,
                              1.0,
                              curve: Curves.easeInOut,
                            ),
                          ),
                        ),
                        child: child,
                      );
                    },
                transitionDuration: const Duration(seconds: 2),
                reverseTransitionDuration: const Duration(seconds: 1),
              );
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
    final role = AudyScope.of(context).currentUser?.role;
    // Parents and teachers get their own portal (ParentDashboard /
    // TeacherDashboard, reached via DashboardPage's role check) — they don't
    // get the student's Home/Games/Rewards/Profile navbar, and they sign out
    // via that portal's own button rather than backing out of it.
    final isStudent = role == null || role == 'child';

    final pages = const [
      DashboardPage(),
      GamesHubPage(),
      RewardsPage(),
      ProfilePage(),
    ];

    final shell = Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: !isStudent
          ? null
          : BottomNavigationBar(
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

    if (isStudent) return shell;

    return PopScope(canPop: false, child: shell);
  }
}
