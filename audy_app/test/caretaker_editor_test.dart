import 'package:audy_app/src/data/models/game_configuration.dart';
import 'package:audy_app/src/data/repositories/caretaker_repository.dart';
import 'package:audy_app/src/features/caretaker/customization/game_editor.dart';
import 'package:audy_app/src/services/auth_service.dart';
import 'package:audy_app/src/state/audy_controller.dart';
import 'package:audy_app/src/state/caretaker_controller.dart';
import 'package:audy_app/src/features/caretaker/children_page.dart';
import 'package:audy_app/src/features/caretaker/customization/game_preview.dart';
import 'package:audy_app/src/features/caretaker/customization/configuration_form.dart';
import 'package:audy_app/src/features/caretaker/customization/custom_cards_editor.dart';
import 'package:audy_app/src/features/caretaker/caretaker_shell.dart';
import 'package:audy_app/src/features/caretaker/child_progress_page.dart';
import 'package:audy_app/src/features/settings/app_settings_page.dart';
import 'package:audy_app/src/data/models/child_progress_snapshot.dart';
import 'package:audy_app/src/core/audy_ui.dart';
import 'package:audy_app/src/state/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MemoryConfigurations extends GameConfigurationRepository {
  MemoryConfigurations() : super(Supabase.instance.client);
  final Map<String, SavedGameConfiguration> records = {};
  bool conflict = false;
  @override
  Future<SavedGameConfiguration> load(
    String childId,
    CaretakerGame game,
  ) async =>
      records['$childId:${game.key}'] ??
      SavedGameConfiguration(GameConfiguration.defaults(game), 0);
  @override
  Future<SavedGameConfiguration> save(
    String childId,
    GameConfiguration config,
    int revision,
  ) async {
    if (conflict) {
      throw const PostgrestException(
        message: 'revision conflict',
        code: '40001',
      );
    }
    final result = SavedGameConfiguration(config, revision + 1);
    records['$childId:${config.game.key}'] = result;
    return result;
  }
}

class MemoryRoster extends CaretakerRepository {
  MemoryRoster(this.roster) : super(Supabase.instance.client);
  CaretakerRoster roster;
  int saves = 0;
  final List<String> progressReads = [];
  @override
  Future<ChildProgressSnapshot> progress(String childId) async {
    progressReads.add(childId);
    return ChildProgressSnapshot(
      stats: {
        'learning_points': childId == 'Ari' ? 275 : 150,
        'games_played': 42,
        'day_streak': 3,
        'last_played_at': '2026-10-24T09:00:00Z',
      },
      sessions: [
        {
          'game_type': 'emotion_classify',
          'difficulty': 'easy',
          'session_ended_at': '2026-10-24T09:00:00Z',
          'accuracy_percent': 80,
          'duration_seconds': 15,
        },
      ],
    );
  }

  @override
  Future<CaretakerRoster> load() async => roster;
  @override
  Future<void> save(int count, Set<String> ids, int revision) async {
    saves++;
    roster = CaretakerRoster(
      [
        for (final child in roster.children)
          CaretakerChild(child.profile, ids.contains(child.profile.id)),
      ],
      count,
      revision + 1,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final channel in [
      'xyz.luan/audioplayers',
      'xyz.luan/audioplayers.global',
      'flutter_tts',
    ]) {
      messenger.setMockMethodCallHandler(MethodChannel(channel), (call) async {
        if (channel == 'xyz.luan/audioplayers' && call.method == 'create') {
          final id = (call.arguments as Map)['playerId'];
          messenger.setMockStreamHandler(
            EventChannel('xyz.luan/audioplayers/events/$id'),
            MockStreamHandler.inline(onListen: (_, sink) {}),
          );
        }
        return 1;
      });
    }
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugin.csdcorp.com/speech_to_text'),
      (_) async => true,
    );
    messenger.setMockStreamHandler(
      const EventChannel('xyz.luan/audioplayers.global/events'),
      MockStreamHandler.inline(onListen: (_, sink) {}),
    );
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      anonKey: 'test-key',
    );
  });
  UserProfile profile(String id, String role) => UserProfile(
    id: id,
    name: id,
    age: 8,
    createdAt: DateTime(2026),
    role: role,
  );
  Future<AudyController> showEditor(
    WidgetTester tester,
    MemoryConfigurations repository,
    CaretakerGame game,
  ) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = AudyController()..setUser(profile('adult', 'caretaker'));
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      AudyScope(
        controller: controller,
        child: MaterialApp(
          home: GameEditor(
            child: profile('child-a', 'child'),
            game: game,
            repository: repository,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return controller;
  }

  testWidgets('legacy Home cards, child overview and progress navigation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = AudyController()..setUser(profile('adult', 'caretaker'));
    addTearDown(controller.dispose);
    final repo = MemoryRoster(
      CaretakerRoster(
        [
          CaretakerChild(profile('Ari', 'child'), true),
          CaretakerChild(profile('Bee', 'child'), false),
        ],
        2,
        1,
      ),
    );
    await tester.pumpWidget(
      AudyScope(
        controller: controller,
        child: MaterialApp(home: CaretakerShell(repository: repo)),
      ),
    );
    await tester.pumpAndSettle();
    final titles = tester
        .widgetList<AudyActionCard>(find.byType(AudyActionCard))
        .map((card) => card.title);
    expect(titles, [
      'Study Plan · TBD',
      'Manual (Guide) · TBD',
      'Customization',
      'Assignments & Rewards · TBD',
    ]);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Children'), findsNothing);
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Ari'), findsOneWidget);
    expect(find.text('Bee'), findsOneWidget);
    expect(find.textContaining('Linked · not selected'), findsOneWidget);
    expect(find.text('Manage Children'), findsOneWidget);
    await tester.tap(find.text('Ari'));
    await tester.pumpAndSettle();
    expect(find.byType(CaretakerChildProgress), findsOneWidget);
    expect(find.text('Explorer'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('Recorded Game History'), findsOneWidget);
    expect(find.text('Achievements'), findsNothing);
    expect(repo.progressReads, ['Ari']);
    await tester.tap(find.text('Analysis'));
    await tester.pumpAndSettle();
    expect(find.text('Learning Points'), findsOneWidget);
    expect(repo.progressReads, ['Ari']);
    expect(controller.learningPoints, 0);
  });

  for (final language in ['en', 'th']) {
    testWidgets('progress fits a narrow screen with large $language text', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final controller = AudyController()
        ..setLanguage(language)
        ..setUser(profile('adult', 'caretaker'));
      addTearDown(controller.dispose);
      final c = CaretakerController(
        'adult',
        MemoryRoster(
          CaretakerRoster(
            [CaretakerChild(profile('Ari', 'child'), true)],
            1,
            1,
          ),
        ),
      );
      await c.load();
      addTearDown(c.dispose);
      await tester.pumpWidget(
        AudyScope(
          controller: controller,
          child: MaterialApp(
            builder: (_, child) => MediaQuery(
              data: const MediaQueryData(
                size: Size(320, 900),
                textScaler: TextScaler.linear(1.8),
              ),
              child: child!,
            ),
            home: CaretakerChildProgress(controller: c),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'app settings persist on the device and remain separate from learning preferences',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final controller = AudyController()
        ..setUser(profile('adult', 'caretaker'));
      addTearDown(controller.dispose);
      final learning = controller.userPreferences;
      await tester.pumpWidget(
        AudyScope(
          controller: controller,
          child: const MaterialApp(home: AppSettingsPage()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Plain background'));
      await tester.pumpAndSettle();
      expect((await AppSettings.load()).plainBackground, isTrue);
      expect(controller.appSettings.plainBackground, isTrue);
      await tester.tap(find.text('Larger text'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('App sound effects'));
      await tester.pumpAndSettle();
      expect((await AppSettings.load()).largerText, isTrue);
      expect((await AppSettings.load()).soundEffects, isFalse);
      controller.setUser(profile('student', 'child'));
      await tester.pumpAndSettle();
      expect(find.text('App Settings'), findsOneWidget);
      expect(controller.userPreferences, same(learning));
      expect(controller.appSettings.plainBackground, isTrue);
      await controller.saveAppSettings(
        controller.appSettings.copyWith(language: 'th'),
      );
      await tester.pumpAndSettle();
      expect(find.text('การตั้งค่าแอป'), findsOneWidget);
      expect((await AppSettings.load()).language, 'th');
      final surfaces = tester.widgetList<DecoratedBox>(
        find.byType(DecoratedBox),
      );
      expect(
        surfaces.any(
          (box) =>
              box.decoration is BoxDecoration &&
              (box.decoration as BoxDecoration).image != null,
        ),
        isFalse,
      );
    },
  );

  testWidgets(
    'merged FlashCard controls save only to the selected child and reset keeps cards',
    (tester) async {
      final repo = MemoryConfigurations();
      await showEditor(tester, repo, CaretakerGame.flashcard);
      final word = find.byKey(const ValueKey('legacy-card-word'));
      await tester.ensureVisible(word);
      await tester.enterText(word, 'Apple');
      final add = find.text('Add Custom Flashcard Card');
      await tester.ensureVisible(add);
      await tester.pumpAndSettle();
      await tester.tap(add);
      await tester.pumpAndSettle();
      final save = find.text('Save settings');
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(repo.records.keys, ['child-a:flashcard']);
      expect(
        (repo.records.values.single.config.toJson()['custom_cards'] as List)
            .single['word'],
        'Apple',
      );
      final reset = find.text('Restore defaults');
      await tester.ensureVisible(reset);
      await tester.tap(reset);
      await tester.pumpAndSettle();
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(
        (repo.records.values.single.config.toJson()['custom_cards'] as List)
            .length,
        1,
      );
      expect(
        repo.records.values.single.config.toJson()['use_custom_cards'],
        false,
      );
    },
  );
  testWidgets(
    'legacy inline card form edits saved cards and rejects duplicates',
    (tester) async {
      final repo = MemoryConfigurations();
      final values =
          GameConfiguration.defaults(CaretakerGame.flashcard).toJson()
            ..['custom_cards'] = [
              {
                'id': 'old-card',
                'word': 'Apple',
                'category': 'noun',
                'image_url': null,
              },
            ];
      repo.records['child-a:flashcard'] = SavedGameConfiguration(
        GameConfiguration(CaretakerGame.flashcard, values),
        4,
      );
      await showEditor(tester, repo, CaretakerGame.flashcard);
      expect(find.text('Flashcard Custom Cards'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      final word = find.byKey(const ValueKey('legacy-card-word'));
      await tester.enterText(word, ' apple ');
      await tester.ensureVisible(find.text('Add Custom Flashcard Card'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add Custom Flashcard Card'));
      await tester.pumpAndSettle();
      expect(
        find.text('This word and word type are already in the library.'),
        findsOneWidget,
      );
      await tester.ensureVisible(find.text('Clear card form'));
      await tester.tap(find.text('Clear card form'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(InputChip));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(InputChip));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(word).controller!.text, 'Apple');
      await tester.enterText(word, 'Pear');
      await tester.ensureVisible(find.text('Update Flashcard Card'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Update Flashcard Card'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Save settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save settings'));
      await tester.pumpAndSettle();
      var cards =
          repo.records.values.single.config.toJson()['custom_cards'] as List;
      expect(cards.single['id'], 'old-card');
      expect(cards.single['word'], 'Pear');
      expect(repo.records.values.single.revision, 5);
      await tester.ensureVisible(find.byTooltip('Remove card'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Remove card'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Save settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save settings'));
      await tester.pumpAndSettle();
      cards =
          repo.records.values.single.config.toJson()['custom_cards'] as List;
      expect(cards, isEmpty);
    },
  );

  testWidgets(
    'unfinished inline card blocks save and preview and is protected on leaving',
    (tester) async {
      final repo = MemoryConfigurations();
      await showEditor(tester, repo, CaretakerGame.flashcard);
      final word = find.byKey(const ValueKey('legacy-card-word'));
      await tester.enterText(word, 'Unfinished');
      for (final action in ['Save settings', 'Preview draft']) {
        await tester.ensureVisible(find.text(action));
        await tester.pumpAndSettle();
        await tester.tap(find.text(action));
        await tester.pumpAndSettle();
        expect(
          find.textContaining('Add or update your unfinished card'),
          findsOneWidget,
        );
        expect(find.byType(GamePreview), findsNothing);
        expect(repo.records, isEmpty);
      }
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Unsaved changes'), findsOneWidget);
      await tester.tap(find.text('Stay'));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(word).controller!.text, 'Unfinished');
      await tester.ensureVisible(find.text('Clear card form'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear card form'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Save settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save settings'));
      await tester.pumpAndSettle();
      expect(
        repo.records.values.single.config.toJson()['custom_cards'],
        isEmpty,
      );
    },
  );

  for (final language in ['en', 'th']) {
    testWidgets(
      'legacy card library fits narrow screens with large $language text',
      (tester) async {
        tester.view.physicalSize = const Size(320, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = AudyController()
          ..setUser(profile('adult', 'caretaker'))
          ..setLanguage(language);
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          AudyScope(
            controller: controller,
            child: MaterialApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(2)),
                child: child!,
              ),
              home: Scaffold(
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: CustomCardsEditor(
                    cards: [
                      for (final type in [
                        'pronoun',
                        'noun',
                        'verb',
                        'adjective',
                        'adverb',
                      ])
                        {
                          'id': type,
                          'word': List.filled(40, 'W').join(),
                          'category': type,
                          'image_url': type == 'noun'
                              ? 'assets/images/games/flashcard/vetgetable/tomato.png'
                              : null,
                        },
                    ],
                    onChanged: (_) {},
                    onPendingChanged: (_) {},
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(InputChip), findsNWidgets(5));
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('conflicting save preserves draft and requires reload', (
    tester,
  ) async {
    final repo = MemoryConfigurations()..conflict = true;
    await showEditor(tester, repo, CaretakerGame.emotion);
    final save = find.text('Save settings');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(repo.records, isEmpty);
    expect(find.textContaining('Another Caretaker'), findsOneWidget);
    expect(
      find.text('Reload saved revision and keep my draft'),
      findsOneWidget,
    );
  });
  testWidgets('account change hides the previous child draft', (tester) async {
    final repo = MemoryConfigurations();
    final controller = await showEditor(tester, repo, CaretakerGame.socialChat);
    controller.clearUser();
    await tester.pumpAndSettle();
    expect(find.text('This Caretaker session has ended.'), findsOneWidget);
    expect(find.text('Save settings'), findsNothing);
  });
  testWidgets(
    'future configuration versions show an update message without parsing old controls',
    (tester) async {
      final repo = MemoryConfigurations();
      repo.records['child-a:emotion'] = SavedGameConfiguration(
        GameConfiguration(CaretakerGame.emotion, {
          'future_field': 'new format',
        }),
        2,
        schemaVersion: 2,
      );
      await showEditor(tester, repo, CaretakerGame.emotion);
      expect(
        find.text('Update the app to edit these settings.'),
        findsOneWidget,
      );
      expect(find.text('Save settings'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  for (final game in [CaretakerGame.emotion, CaretakerGame.socialChat]) {
    testWidgets(
      '${game.key} preview leaves Student progress and chat untouched',
      (tester) async {
        final controller = AudyController()
          ..setUser(profile('adult', 'caretaker'));
        addTearDown(controller.dispose);
        final points = controller.learningPoints;
        final played = controller.gamesPlayed;
        final messages = controller.thaiSocialMessages.length;
        final v = GameConfiguration.defaults(game).toJson();
        if (game == CaretakerGame.socialChat) {
          v['input_mode'] = 'text_only';
          v['starter_phrases'] = ['สวัสดี'];
        }
        await tester.pumpWidget(
          AudyScope(
            controller: controller,
            child: MaterialApp(
              home: GamePreview(
                config: GameConfiguration(game, v),
                childName: 'Child A',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        if (game == CaretakerGame.emotion) {
          await tester.ensureVisible(find.text('Happy'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Happy'));
          await tester.pump(const Duration(milliseconds: 1600));
          expect(find.textContaining('Next: make a'), findsOneWidget);
        } else {
          await tester.tap(find.text('สวัสดี'));
          await tester.pump();
          expect(find.byIcon(Icons.mic), findsNothing);
        }
        expect(controller.learningPoints, points);
        expect(controller.gamesPlayed, played);
        expect(controller.thaiSocialMessages.length, messages);
        expect(tester.takeException(), isNull);
      },
    );
  }
  for (final language in ['en', 'th']) {
    testWidgets(
      'customization forms fit narrow screens with large $language text',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = AudyController()
          ..setUser(profile('adult', 'caretaker'))
          ..setLanguage(language);
        addTearDown(controller.dispose);
        for (final game in CaretakerGame.values) {
          final values = GameConfiguration.defaults(game).toJson();
          if (game == CaretakerGame.fruitCatch) values['duration_seconds'] = -1;
          await tester.pumpWidget(
            AudyScope(
              controller: controller,
              child: MaterialApp(
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: const TextScaler.linear(2)),
                  child: child!,
                ),
                home: Scaffold(
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConfigurationForm(
                      key: ValueKey(game),
                      game: game,
                      values: values,
                      onChanged: (_, v) {},
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: game.key);
        }
      },
    );
  }
  testWidgets('care count does not remove profiles or create fake children', (
    tester,
  ) async {
    final repository = MemoryRoster(
      CaretakerRoster(
        [
          CaretakerChild(profile('child-a', 'child'), true),
          CaretakerChild(profile('child-b', 'child'), true),
        ],
        2,
        1,
      ),
    );
    final care = CaretakerController('adult', repository);
    addTearDown(care.dispose);
    await care.load();
    final controller = AudyController()..setUser(profile('adult', 'caretaker'));
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      AudyScope(
        controller: controller,
        child: MaterialApp(
          home: Scaffold(body: ChildrenPage(controller: care)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '1');
    await tester.scrollUntilVisible(
      find.text('Save care list'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save care list'));
    await tester.pumpAndSettle();
    expect(repository.saves, 0);
    expect(find.text('Choose a whole number at least 2.'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byType(TextField).first,
      -200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '3');
    await tester.scrollUntilVisible(
      find.text('Save care list'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save care list'));
    await tester.pumpAndSettle();
    expect(repository.roster.plannedCount, 3);
    expect(repository.roster.children.length, 2);
    expect(repository.saves, 1);
  });
}
