import 'dart:io';

import 'package:audy_app/src/data/database/database.dart';
import 'package:audy_app/src/data/datasources/local_data_source.dart';
import 'package:audy_app/src/features/profile_and_rewards_pages.dart';
import 'package:audy_app/src/services/auth_service.dart';
import 'package:audy_app/src/state/audy_controller.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/audy_test_environment.dart';

class _OfflineController extends AudyController {
  @override
  Future<void> refreshCloudChildData() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(initializeAudyTestEnvironment);

  Future<List<String>> tables(AppDatabase db) async => [
    for (final row
        in await db
            .customSelect("select name from sqlite_master where type = 'table'")
            .get())
      row.read<String>('name'),
  ];

  test(
    'fresh databases seed progress and preferences without achievement tables',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final local = LocalDataSource(db);
      await local.seedInitialData();
      await local.seedInitialData();
      expect(await tables(db), isNot(contains('achievements')));
      expect(await tables(db), isNot(contains('user_achievements')));
      expect((await db.select(db.userProgress).get()).length, 1);
      expect((await local.getProgress())!.learningPoints, 0);
      expect((await local.getUserPreferences())!.ownedSkinIdSet, {0});
    },
  );

  test(
    'version 8 upgrade removes only achievement storage and preserves user data',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'audy_schema_upgrade_',
      );
      final file = File('${directory.path}/audy.db');
      var db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(() async {
        await db.close();
        await directory.delete(recursive: true);
      });
      var local = LocalDataSource(db);
      await local.seedInitialData();
      await local.saveProgress(
        ProgressData(
          learningPoints: 725,
          spentLearningPoints: 200,
          gamesPlayed: 42,
          dayStreak: 6,
          lastPlayedAt: DateTime(2026, 10, 27),
          puzzleGamesCompleted: 12,
          readingExercisesCompleted: 7,
          sortingGamesCompleted: 9,
          emotionsRecognized: 5,
          chatMessagesSent: 21,
          sortGameUnlockedLevel: 3,
          gamesInCurrentSession: 2,
        ),
      );
      await local.saveUserPreferences(
        const UserPreferences(
          communicationLevel: 2,
          sensorySensitivity: 2,
          learningPace: 0,
          favoriteInterests: 'animals,fruit',
          ownedSkinIds: '0,3',
          selectedSkinId: 3,
        ),
      );
      final rewardId = await local.addReward('Family game', 'reading', 5);
      final started = DateTime(2026, 10, 27, 10);
      await local.saveGameSession(
        GameSessionData.fromTimes(
          gameType: 'reading',
          correctActions: 3,
          totalActions: 4,
          sessionStartedAt: started,
          sessionEndedAt: started.add(const Duration(seconds: 90)),
        ),
      );

      // The four retained tables match v8. Recreate the two removed v8 tables
      // and mark the fixture as v8 to exercise the actual persisted upgrade.
      await db.customStatement(
        'create table achievements (id integer primary key, key text, title text, description text)',
      );
      await db.customStatement(
        'create table user_achievements (id integer primary key, achievement_id integer, unlocked integer, unlocked_at integer, updated_at integer, is_synced integer)',
      );
      await db.customStatement(
        "insert into achievements values (1, 'first_steps', 'First Steps', 'Legacy')",
      );
      await db.customStatement(
        'insert into user_achievements values (1, 1, 1, 1, 1, 0)',
      );
      final beforeProgress =
          (await db.customSelect('select * from user_progress').get())
              .single
              .data;
      final beforePreferences =
          (await db.customSelect('select * from user_preferences').get())
              .single
              .data;
      final beforeRewards =
          (await db.customSelect('select * from user_rewards').get())
              .single
              .data;
      final beforeSessions =
          (await db.customSelect('select * from game_sessions').get())
              .single
              .data;
      await db.customStatement('pragma user_version = 8');
      await db.close();

      db = AppDatabase.forTesting(NativeDatabase(file));
      local = LocalDataSource(db);
      expect(await tables(db), isNot(contains('achievements')));
      expect(await tables(db), isNot(contains('user_achievements')));
      expect(
        (await db.customSelect('pragma user_version').get()).single.read<int>(
          'user_version',
        ),
        9,
      );
      expect(
        (await db.customSelect('select * from user_progress').get())
            .single
            .data,
        beforeProgress,
      );
      expect(
        (await db.customSelect('select * from user_preferences').get())
            .single
            .data,
        beforePreferences,
      );
      expect(
        (await db.customSelect('select * from user_rewards').get()).single.data,
        beforeRewards,
      );
      expect(
        (await db.customSelect('select * from game_sessions').get())
            .single
            .data,
        beforeSessions,
      );
      expect((await local.getUserRewards()).single.id, rewardId);
      expect((await local.getUserPreferences())!.selectedSkinId, 3);
      expect((await local.getGameSessions()).single.durationSeconds, 90);
      expect(await db.customSelect('pragma foreign_key_check').get(), isEmpty);
      await local.seedInitialData();
      expect(await tables(db), isNot(contains('achievements')));
    },
  );

  test(
    'completion counters, rewards, levels and break count still progress',
    () async {
      final controller = AudyController();
      addTearDown(controller.dispose);
      final levels = <int>[];
      controller.onLevelUp = levels.add;
      await controller.addReward('Choose a book', RewardCondition.reading, 1);
      await controller.addReward('Family game', RewardCondition.miniPuzzle, 1);
      await controller.addReward(
        'Choose a story',
        RewardCondition.socialChat,
        1,
      );
      await controller.trackClassifyGameCompleted(durationSeconds: 5);
      await controller.trackMimicGameCompleted(durationSeconds: 5);
      await controller.trackPuzzleCompleted();
      await controller.trackReadingCompleted();
      await controller.trackFlashcardCompleted();
      await controller.trackRoadSafetyCompleted();
      await controller.trackMessageSent();
      await controller.addPoints(275);
      expect(controller.gamesPlayed, 6);
      expect(controller.gamesInCurrentSession, 6);
      expect(controller.puzzleGamesCompleted, 1);
      expect(controller.readingExercisesCompleted, 1);
      expect(controller.chatMessagesSent, 1);
      expect(controller.completedRewards.length, 3);
      expect(controller.activeRewards, isEmpty);
      expect(controller.learningPoints, 275);
      expect(controller.currentLevel, 2);
      expect(levels, [2]);
      await controller.claimReward(controller.completedRewards.first);
      expect(controller.claimedRewards.length, 1);
      expect(controller.skillPercentages['MiniPuzzle'], 1 / 20);
      expect(controller.skillPercentages['Reading'], 1 / 15);
      expect(controller.skillPercentages['Social'], 1 / 20);
    },
  );

  for (final language in ['en', 'th']) {
    testWidgets(
      'Rewards and Profile keep their remaining features in $language',
      (tester) async {
        tester.view.physicalSize = const Size(1000, 2200);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = _OfflineController()
          ..setUser(
            UserProfile(
              id: 'child',
              name: 'Ari',
              age: 8,
              createdAt: DateTime(2026),
              role: 'child',
            ),
          )
          ..setLanguage(language);
        addTearDown(controller.dispose);
        for (final page in [const RewardsPage(), const ProfilePage()]) {
          await tester.pumpWidget(
            AudyScope(
              controller: controller,
              child: MaterialApp(home: page),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text('Achievements'), findsNothing);
          expect(find.text('Your Achievements'), findsNothing);
          expect(find.text('ความสำเร็จ'), findsNothing);
          if (page is RewardsPage) {
            expect(find.text(controller.tr('Progress')), findsOneWidget);
            for (final tab in ['my_rewards', 'skins']) {
              final target = find.text(controller.tr(tab));
              await tester.ensureVisible(target);
              await tester.pumpAndSettle();
              await tester.tap(target);
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull, reason: '$language $tab');
            }
          } else {
            expect(find.text('Ari'), findsOneWidget);
            expect(find.text(controller.tr('settings')), findsOneWidget);
            expect(find.text(controller.tr('points')), findsOneWidget);
            expect(find.text(controller.tr('games_played')), findsOneWidget);
            expect(find.text(controller.tr('day_streak')), findsOneWidget);
          }
          expect(tester.takeException(), isNull);
        }
      },
    );
  }
}
