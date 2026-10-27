import 'package:audy_app/src/data/models/break_settings.dart';
import 'package:audy_app/src/data/models/game_configuration.dart';
import 'package:audy_app/src/core/audy_ui.dart';
import 'package:audy_app/src/features/caretaker/customization/game_preview.dart';
import 'package:audy_app/src/data/repositories/break_settings_repository.dart';
import 'package:audy_app/src/features/assignments_page.dart';
import 'package:audy_app/src/features/emotion_classify_game/emotion_classify_screen.dart';
import 'package:audy_app/src/features/emotion_mimic_game/emotion_mimic_screen.dart';
import 'package:audy_app/src/features/feature_pages.dart';
import 'package:audy_app/src/features/flashcard/flashcard_models.dart';
import 'package:audy_app/src/features/flashcard/flashcard_screen.dart';
import 'package:audy_app/src/features/fruit_catching_bear/fruit_catching_bear_screen.dart';
import 'package:audy_app/src/features/minipuzzle_game/minipuzzle_controller.dart';
import 'package:audy_app/src/features/minipuzzle_game/minipuzzle_game_screen.dart';
import 'package:audy_app/src/features/minipuzzle_game/minipuzzle_models.dart';
import 'package:audy_app/src/features/profile_and_rewards_pages.dart';
import 'package:audy_app/src/features/read_pronounce/read_pronounce_controller.dart';
import 'package:audy_app/src/features/read_pronounce/read_pronounce_practice.dart';
import 'package:audy_app/src/features/road_safety/road_safety_screen.dart';
import 'package:audy_app/src/features/social_chat/social_chat_page.dart';
import 'package:audy_app/src/services/auth_service.dart';
import 'package:audy_app/src/state/audy_controller.dart';
import 'package:audy_app/src/widgets/game_guide_box.dart';
import 'package:audy_app/src/widgets/add_reward_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'support/audy_test_environment.dart';

class _BreakRepository extends BreakSettingsRepository {
  _BreakRepository() : super(Supabase.instance.client);
  @override
  Future<BreakSettings> loadForStudent() async => const BreakSettings();
}

class _StudentController extends AudyController {
  _StudentController() : super(breakSettingsRepository: _BreakRepository());
  @override
  Future<void> refreshCloudChildData() async {}
}

class _AssignmentService extends AuthService {
  @override
  Future<List<Map<String, dynamic>>> fetchAssignments(String studentId) async =>
      [
        {
          'id': 'retired-sort',
          'game_type': 'sorting',
          'target_count': 99,
          'current_count': 0,
        },
        {
          'id': 'retired-reaction',
          'game_type': 'reaction_time',
          'target_count': 98,
          'current_count': 0,
        },
        {
          'id': 'current-flashcard',
          'game_type': 'flashcard',
          'target_count': 3,
          'current_count': 0,
        },
      ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(initializeAudyTestEnvironment);
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<AudyController> mount(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(1000, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = _StudentController()
      ..setUser(
        UserProfile(
          id: 'student',
          name: 'Ari',
          age: 8,
          createdAt: DateTime(2026),
          role: 'child',
        ),
      );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      AudyScope(
        controller: controller,
        child: MaterialApp(home: screen),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    return controller;
  }

  final screens = <String, Widget>{
    'Emotion classification': const EmotionClassifyScreen(),
    'Emotion mimic': const EmotionMimicScreen(),
    'FlashCard': const FlashcardScreen(difficulty: FlashcardDifficulty.easy),
    'MiniPuzzle Pattern': const MiniPuzzleGameScreen(
      gameType: MiniPuzzleType.pattern,
      difficulty: MiniPuzzleDifficulty.easy,
    ),
    'MiniPuzzle Odd One Out': const MiniPuzzleGameScreen(
      gameType: MiniPuzzleType.oddOneOut,
      difficulty: MiniPuzzleDifficulty.easy,
    ),
    'MiniPuzzle Puzzle': const MiniPuzzleGameScreen(
      gameType: MiniPuzzleType.puzzle,
      difficulty: MiniPuzzleDifficulty.easy,
    ),
    'Fruit Catch': const FruitCatchingBearScreen(),
    'Read & Speak': const ReadPronouncePracticeScreen(
      title: 'words_practice',
      subtitle: 'listen_repeat',
      module: ReadPronounceModule.words,
    ),
    'Road Safety': const RoadSafetyScreen(),
    'Social Chat': const SocialPracticePage(),
  };
  for (final entry in screens.entries) {
    testWidgets(
      '${entry.key} opens without Student tips and disposes cleanly',
      (tester) async {
        final controller = await mount(tester, entry.value);
        expect(find.byType(GameGuideBox), findsNothing);
        expect(tester.takeException(), isNull);
        if (entry.key == 'Fruit Catch') {
          Finder asset(String path) => find.byWidgetPredicate(
            (widget) =>
                widget is Image &&
                widget.image is AssetImage &&
                (widget.image as AssetImage).assetName == path,
          );
          final bear = asset('assets/images/games/basket/bear_default.png');
          final before = tester.getTopLeft(bear).dx;
          final stage = tester.getRect(
            asset('assets/images/games/basket/background.png'),
          );
          await tester.tapAt(Offset(stage.right - 20, stage.top + 60));
          await tester.pump(const Duration(milliseconds: 160));
          expect(tester.getTopLeft(bear).dx, greaterThan(before));
        }
        if (entry.key == 'Emotion classification') {
          await tester.tap(
            find.text(controller.currentClassifyQuestion.correctAnswer),
          );
          await tester.pump();
          expect(controller.classifyFeedback, isNotEmpty);
        }
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 4));
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Student Profile exposes Profile and Settings without adult dashboards',
    (tester) async {
      await mount(tester, const ProfilePage());
      expect(find.text('Parent Dashboard'), findsNothing);
      expect(find.text('Institution Panel'), findsNothing);
      final settings = find.text('Settings');
      await tester.ensureVisible(settings);
      await tester.pump();
      await tester.tap(settings);
      await tester.pumpAndSettle();
      expect(find.text('App Settings'), findsOneWidget);
      expect(find.text('Your Preferences'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final page in [const GamesHubPage(), const AssignmentsPage()]) {
    testWidgets('${page.runtimeType} has no retired game options', (
      tester,
    ) async {
      await mount(tester, page);
      await tester.pump();
      expect(find.text('Sorting Game'), findsNothing);
      expect(find.text('Reaction Time'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  for (final game in [
    CaretakerGame.flashcard,
    CaretakerGame.miniPuzzle,
    CaretakerGame.fruitCatch,
  ]) {
    testWidgets(
      'Caretaker ${game.title} preview opens and keeps Student progress unchanged',
      (tester) async {
        tester.view.physicalSize = const Size(1000, 2000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = AudyController()
          ..setUser(
            UserProfile(
              id: 'adult',
              name: 'Adult',
              age: 30,
              createdAt: DateTime(2026),
              role: 'caretaker',
            ),
          );
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          AudyScope(
            controller: controller,
            child: MaterialApp(
              home: GamePreview(
                config: GameConfiguration.defaults(game),
                childName: 'Ari',
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
        if (game == CaretakerGame.miniPuzzle) {
          await tester.tap(find.text('Start preview'));
          await tester.pump();
        }
        expect(controller.learningPoints, 0);
        expect(controller.gamesPlayed, 0);
        expect(controller.gamesInCurrentSession, 0);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 4));
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'new rewards exclude retired game conditions while stored IDs stay stable',
    (tester) async {
      await mount(
        tester,
        const AddRewardDialog(
          adaptive: AudyAdaptive(width: 1000, height: 2000),
        ),
      );
      expect(find.text('Sorting Game'), findsNothing);
      expect(find.text('Reaction Time'), findsNothing);
      expect(RewardCondition.values.map((value) => value.name), [
        'emotionClassify',
        'emotionMimic',
        'miniPuzzle',
        'sortingGame',
        'reactionTime',
        'reading',
        'socialChat',
      ]);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'retired assignments are not relabeled as Emotion or offered as playable tasks',
    (tester) async {
      await mount(tester, AssignmentsPage(authService: _AssignmentService()));
      await tester.pumpAndSettle();
      expect(find.text('0/99'), findsNothing);
      expect(find.text('0/98'), findsNothing);
      expect(find.text('0/3'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  test(
    'retired active rewards remain stored but do not block current reward slots',
    () async {
      final controller = _StudentController();
      controller.userRewards.addAll([
        UserReward(
          id: 1,
          prize: 'Legacy sorting',
          condition: RewardCondition.sortingGame,
          targetCount: 3,
          createdAt: DateTime(2026),
        ),
        UserReward(
          id: 2,
          prize: 'Legacy reaction',
          condition: RewardCondition.reactionTime,
          targetCount: 3,
          createdAt: DateTime(2026),
        ),
      ]);
      expect(controller.activeRewards, isEmpty);
      expect(controller.userRewards, hasLength(2));
      expect(controller.canAddReward, isTrue);
      await controller.addReward('Current', RewardCondition.miniPuzzle, 3);
      expect(controller.activeRewards.single.prize, 'Current');
      await controller.addReward('Retired', RewardCondition.sortingGame, 3);
      expect(controller.userRewards, hasLength(3));
      controller.dispose();
    },
  );

  for (final type in MiniPuzzleType.values) {
    for (final difficulty in MiniPuzzleDifficulty.values) {
      test(
        'MiniPuzzle ${type.name}/${difficulty.name} completes all three rounds',
        () {
          final controller = MiniPuzzleController()
            ..startGame(type, difficulty);
          for (var round = 1; round <= 3; round++) {
            switch (type) {
              case MiniPuzzleType.pattern:
                controller.submitPatternAnswer(
                  controller.patternData!.correctAnswer,
                );
              case MiniPuzzleType.oddOneOut:
                controller.submitOddOneOutAnswer(
                  controller.oddOneOutData!.correctItemId,
                );
              case MiniPuzzleType.puzzle:
                for (final piece in controller.puzzleData!.pieces) {
                  controller.placePuzzlePiece(piece.id, piece.targetSlotId);
                }
            }
            expect(controller.roundComplete, isTrue);
            if (round < 3) controller.nextRound();
          }
          expect(controller.totalCorrect, 3);
          expect(controller.pointsEarned, 9);
          expect(controller.stars, 3);
          controller.dispose();
        },
      );
    }
  }

  for (final module in ReadPronounceModule.values) {
    test(
      'Read & Speak ${module.name} validates answers and completes its session',
      () {
        final controller = ReadPronounceController()..startSession(module);
        for (
          var round = 0;
          round < ReadPronounceController.roundsPerSession;
          round++
        ) {
          expect(
            controller.submitAttempt(
              controller.currentPrompt!.acceptedAnswers.first,
            ),
            ReadPronounceAttemptOutcome.correct,
          );
          controller.advanceAfterCorrect();
        }
        expect(controller.isSessionComplete, isTrue);
        expect(controller.lastSessionResult!.accuracy, 1);
        controller.dispose();
      },
    );
  }
}
