import 'dart:async';
import 'dart:convert';

import 'package:audy_app/src/data/database/database.dart';
import 'package:audy_app/src/data/models/game_configuration.dart';
import 'package:audy_app/src/data/models/student_game_options.dart';
import 'package:audy_app/src/data/repositories/student_game_configuration_repository.dart';
import 'package:audy_app/src/features/emotion_classify_game/emotion_classify_screen.dart';
import 'package:audy_app/src/features/flashcard/flashcard_difficulty_screen.dart';
import 'package:audy_app/src/features/fruit_catching_bear/fruit_catching_bear_screen.dart';
import 'package:audy_app/src/features/minipuzzle_game/games/pattern_game_widget.dart';
import 'package:audy_app/src/features/minipuzzle_game/minipuzzle_game.dart';
import 'package:audy_app/src/features/minipuzzle_game/minipuzzle_game_screen.dart';
import 'package:audy_app/src/features/minipuzzle_game/minipuzzle_models.dart';
import 'package:audy_app/src/services/auth_service.dart';
import 'package:audy_app/src/state/audy_controller.dart';
import 'package:audy_app/src/widgets/student_game_entry.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'support/audy_test_environment.dart';

GameConfiguration config(CaretakerGame game, Map<String, dynamic> changes) =>
    GameConfiguration(game, {
      ...GameConfiguration.defaults(game).toJson(),
      ...changes,
    });

class _Student extends AudyController {
  GameConfiguration? saved;

  @override
  Future<void> refreshCloudChildData() async {}

  @override
  Future<GameConfiguration?> studentGameConfiguration(
    CaretakerGame game,
  ) async => saved;
}

UserProfile _profile(String id) => UserProfile(
  id: id,
  name: id,
  age: 9,
  createdAt: DateTime(2026),
  role: 'child',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(initializeAudyTestEnvironment);

  Future<_Student> mount(
    WidgetTester tester,
    Widget home, {
    GameConfiguration? saved,
  }) async {
    final app = _Student()..saved = saved;
    await app.setUser(_profile('student-a'));
    addTearDown(app.dispose);
    await tester.pumpWidget(
      AudyScope(
        controller: app,
        child: MaterialApp(home: home),
      ),
    );
    await tester.pump();
    return app;
  }

  testWidgets(
    'FlashCard entry locks the selected difficulty and invalidates on account change',
    (tester) async {
      final app = await mount(
        tester,
        StudentGameEntry(
          game: CaretakerGame.flashcard,
          builder: (saved) => FlashcardDifficultyScreen(
            options: saved == null ? null : StudentFlashcardOptions(saved),
          ),
        ),
        saved: config(CaretakerGame.flashcard, {'difficulty': 'hard'}),
      );
      expect(find.text('Hard'), findsOneWidget);
      expect(find.text('Easy'), findsNothing);
      await app.setUser(_profile('student-b'));
      await tester.pump();
      expect(find.text('Hard'), findsNothing);
    },
  );

  testWidgets(
    'MiniPuzzle restricts modes and waits for Continue in manual mode',
    (tester) async {
      final options = StudentMiniPuzzleOptions(
        config(CaretakerGame.miniPuzzle, {
          'enabled_types': ['pattern'],
          'pattern_difficulty': 'hard',
          'advance_mode': 'manual',
          'show_guide': false,
        }),
      );
      final app = await mount(
        tester,
        MiniPuzzleGameSelection(options: options),
      );
      final pattern = find.text(app.tr('minipuzzle_pattern'));
      expect(find.text(app.tr('minipuzzle_odd_one_out')), findsNothing);
      await tester.tap(pattern);
      await tester.pumpAndSettle();
      await tester.tap(find.text(app.tr('hard')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<MiniPuzzleGameScreen>(find.byType(MiniPuzzleGameScreen))
            .difficulty,
        MiniPuzzleDifficulty.hard,
      );
      final game = tester
          .widget<PatternGameWidget>(find.byType(PatternGameWidget))
          .controller;
      game.submitPatternAnswer(game.patternData!.correctAnswer);
      await tester.pump(const Duration(seconds: 2));
      expect(game.currentRound, 1);
      await tester.ensureVisible(find.text(app.tr('continue')));
      await tester.tap(find.text(app.tr('continue')));
      await tester.pump();
      expect(game.currentRound, 2);
    },
  );

  testWidgets(
    'Emotion uses two configured choices and waits before opening the camera',
    (tester) async {
      final options = StudentEmotionOptions(
        config(CaretakerGame.emotion, {
          'target_emotions': ['happy', 'sad'],
          'choice_count': 2,
          'round_count': 5,
          'advance_mode': 'manual',
          'image_mode': 'consistent',
          'show_guide': false,
        }),
      );
      final app = await mount(tester, EmotionClassifyScreen(options: options));
      expect(find.text('Happy'), findsOneWidget);
      expect(find.text('Sad'), findsOneWidget);
      expect(find.text('Angry'), findsNothing);
      expect(app.classifyTotalRounds, 5);
      expect(app.mimicTotalRounds, 5);
      final answer = find.text(app.currentClassifyQuestion.correctAnswer);
      await tester.ensureVisible(answer);
      await tester.tap(answer);
      await tester.pump(const Duration(seconds: 4));
      expect(find.text(app.tr('continue')), findsOneWidget);
      expect(app.classifyCurrentRound, 1);
      expect(app.classifyScore, 1);
      final targets = <String>[];
      for (var round = 0; round < 5; round++) {
        targets.add(app.currentClassifyQuestion.correctAnswer);
        expect(app.currentMimicTarget, targets.last);
        app.completeEmotionRound(isMatch: true, confidence: 1);
      }
      expect(targets.toSet(), {'Happy', 'Sad'});
      expect(app.isClassifyGameComplete, isTrue);
      expect(app.isMimicGameComplete, isTrue);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'Fruit Catch uses the selected spawn interval and ends a bomb-free timed session',
    (tester) async {
      final options = StudentFruitCatchOptions(
        config(CaretakerGame.fruitCatch, {
          'spawn_interval_ms': 1500,
          'fruit_ids': ['9'],
          'duration_seconds': 30,
          'bomb_probability': 0,
          'show_guide': false,
        }),
      );
      await mount(tester, FruitCatchingBearScreen(options: options));
      const image = 'assets/images/games/basket/fruits/9.png';
      final fruit = find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName == image,
      );
      await tester.pump(const Duration(milliseconds: 1000));
      expect(fruit, findsNothing);
      await tester.pump(const Duration(milliseconds: 510));
      expect(fruit, findsOneWidget);
      await tester.pump(const Duration(seconds: 29));
      expect(find.text('All done'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  test(
    'Student read uses durable cache, clears it on deactivation, and ignores old-account replies',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final payload = config(CaretakerGame.emotion, {
        'round_count': 5,
      }).toJson();
      final active = {
        'status': 'active',
        'revision': 4,
        'schema_version': 1,
        'payload': payload,
      };
      var next = active;
      var fail = false;
      Completer<http.Response>? pending;
      Completer<void>? started;
      http.Response response(Map<String, dynamic> data, {int status = 200}) =>
          http.Response(
            jsonEncode(data),
            status,
            headers: {'content-type': 'application/json'},
          );

      final client = SupabaseClient(
        'https://example.supabase.co',
        'key',
        httpClient: MockClient((request) async {
          http.Response result;
          if (pending != null) {
            started!.complete();
            result = await pending.future;
          } else {
            result = fail
                ? response({'message': 'offline'}, status: 400)
                : response(next);
          }
          return http.Response(
            result.body,
            result.statusCode,
            request: request,
            headers: result.headers,
          );
        }),
      );
      addTearDown(client.dispose);
      Future<void> signIn(String id) => client.auth.recoverSession(
        jsonEncode({
          'access_token': 'mock-token',
          'token_type': 'bearer',
          'user': {
            'id': id,
            'aud': 'authenticated',
            'created_at': '2026-01-01',
          },
        }),
      );

      await signIn('student-a');
      final repo = StudentGameConfigurationRepository(client)
        ..useAccount('student-a');
      expect((await repo.load(CaretakerGame.emotion, db))?.toJson(), payload);
      fail = true;
      final reopened = StudentGameConfigurationRepository(client)
        ..useAccount('student-a');
      expect(
        (await reopened.load(CaretakerGame.emotion, db))?.toJson(),
        payload,
      );
      fail = false;
      next = {'status': 'default'};
      expect(await reopened.load(CaretakerGame.emotion, db), isNull);
      fail = true;
      expect(await reopened.load(CaretakerGame.emotion, db), isNull);

      pending = Completer<http.Response>();
      started = Completer<void>();
      final old = reopened.load(CaretakerGame.emotion, db);
      await started.future;
      await signIn('student-b');
      reopened.useAccount('student-b');
      pending.complete(response(active));
      expect(await old, isNull);
      pending = null;
      expect(await reopened.load(CaretakerGame.emotion, db), isNull);
    },
  );
}
