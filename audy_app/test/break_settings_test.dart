import 'dart:async';

import 'package:audy_app/src/data/models/break_settings.dart';
import 'package:audy_app/src/core/app_routes.dart';
import 'package:audy_app/src/core/audy_ui.dart';
import 'package:audy_app/src/features/feature_pages.dart';
import 'package:audy_app/src/features/meltdown/meltdown_screen.dart';
import 'package:audy_app/src/data/repositories/break_settings_repository.dart';
import 'package:audy_app/src/features/caretaker/customization/break_settings_editor.dart';
import 'package:audy_app/src/services/auth_service.dart';
import 'package:audy_app/src/state/audy_controller.dart';
import 'package:audy_app/src/state/student_break_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'support/audy_test_environment.dart';

class MemoryBreakSettings extends BreakSettingsRepository {
  MemoryBreakSettings() : super(Supabase.instance.client);
  final records = <String, BreakSettings>{};
  int remoteThreshold = 5;
  bool offline = false;
  bool conflict = false;
  Completer<BreakSettings>? pending;
  @override
  Future<BreakSettings> load(String childId) async =>
      records[childId] ?? const BreakSettings();
  @override
  Future<BreakSettings> loadForStudent() async {
    if (offline) throw Exception('offline');
    return pending?.future ?? BreakSettings(gamesBeforeBreak: remoteThreshold);
  }

  @override
  Future<BreakSettings> save(
    String childId,
    int threshold,
    int revision,
  ) async {
    if (conflict) {
      throw const PostgrestException(
        message: 'revision conflict',
        code: '40001',
      );
    }
    if (!BreakSettings.validThreshold(threshold)) {
      throw const FormatException('Invalid');
    }
    return records[childId] = BreakSettings(
      gamesBeforeBreak: threshold,
      revision: revision + 1,
    );
  }
}

class _BreakObserver extends NavigatorObserver {
  int breakPushes = 0;
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name == AppRoutes.meltdown) breakPushes++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(initializeAudyTestEnvironment);
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'threshold defaults and allowed range reject fractional or invalid data',
    () {
      expect(const BreakSettings().gamesBeforeBreak, 5);
      for (final value in [1, 5, 20]) {
        expect(BreakSettings.validThreshold(value), isTrue);
      }
      for (final value in [-1, 0, 21]) {
        expect(BreakSettings.validThreshold(value), isFalse);
      }
      expect(
        () => BreakSettings.fromJson({'games_before_break': 2.5}),
        throwsFormatException,
      );
    },
  );

  test(
    'account-scoped threshold and counter survive restarts and remain isolated',
    () async {
      final repo = MemoryBreakSettings()..remoteThreshold = 3;
      final settings = StudentBreakSettings(repo);
      settings.useAccount('A');
      await settings.refresh();
      settings.setGames(2);
      await settings.flush();
      settings.useAccount('B');
      expect(settings.threshold, 5);
      expect(settings.games, 0);
      repo.remoteThreshold = 10;
      await settings.refresh();
      settings.setGames(1);
      await settings.flush();
      settings.dispose();
      repo.offline = true;
      final restored = StudentBreakSettings(repo)..useAccount('A');
      await restored.refresh();
      expect(restored.threshold, 3);
      expect(restored.games, 2);
      restored.useAccount('B');
      await restored.refresh();
      expect(restored.threshold, 10);
      expect(restored.games, 1);
      restored.useAccount('new-child');
      await restored.refresh();
      expect(restored.threshold, 5);
      expect(restored.games, 0);
      restored.dispose();
    },
  );

  test('late network responses cannot overwrite a different child', () async {
    final repo = MemoryBreakSettings()..pending = Completer<BreakSettings>();
    final settings = StudentBreakSettings(repo)..useAccount('A');
    final first = settings.refresh();
    await Future<void>.delayed(Duration.zero);
    settings.useAccount('B');
    repo.remoteThreshold = 8;
    final pendingA = repo.pending!;
    repo.pending = null;
    await settings.refresh();
    pendingA.complete(const BreakSettings(gamesBeforeBreak: 1));
    await first;
    expect(settings.childId, 'B');
    expect(settings.threshold, 8);
    await settings.flush();
    settings.dispose();
  });

  test('cache restoration cannot discard a newly completed game', () async {
    final repo = MemoryBreakSettings()..offline = true;
    final settings = StudentBreakSettings(repo)..useAccount('A');
    settings.setGames(1);
    await settings.refresh();
    expect(settings.games, 1);
    await settings.flush();
    settings.dispose();
  });

  test(
    'actual controller triggers at configured count and resets after a break',
    () async {
      final repo = MemoryBreakSettings()..remoteThreshold = 2;
      final controller = AudyController(breakSettingsRepository: repo);
      controller.breakSettings.useAccount('A');
      await controller.refreshBreakSettings();
      await controller.trackFlashcardCompleted();
      expect(controller.shouldTriggerMeltdown, isFalse);
      await controller.trackRoadSafetyCompleted();
      expect(controller.gamesInCurrentSession, 2);
      expect(controller.shouldTriggerMeltdown, isTrue);
      await controller.resetMeltdownState();
      expect(controller.gamesInCurrentSession, 0);
      expect(controller.shouldTriggerMeltdown, isFalse);
      await controller.breakSettings.flush();
      controller.dispose();
    },
  );

  testWidgets(
    'game entry reloads the live threshold and ignores repeated taps',
    (tester) async {
      tester.view.physicalSize = const Size(900, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = MemoryBreakSettings();
      final controller = AudyController(breakSettingsRepository: repo);
      addTearDown(controller.dispose);
      controller.breakSettings.useAccount('A');
      await controller.refreshBreakSettings();
      controller.gamesInCurrentSession = 1;
      repo.pending = Completer<BreakSettings>();
      final observer = _BreakObserver();
      await tester.pumpWidget(
        AudyScope(
          controller: controller,
          child: MaterialApp(
            navigatorObservers: [observer],
            home: const GamesHubPage(),
            routes: {
              AppRoutes.meltdown: (_) =>
                  const Scaffold(body: Text('Break destination')),
            },
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.byType(AudyActionCard).first);
      await tester.pump();
      await tester.tap(find.byType(AudyActionCard).first);
      repo.pending!.complete(const BreakSettings(gamesBeforeBreak: 1));
      await tester.pumpAndSettle();
      expect(find.text('Break destination'), findsOneWidget);
      expect(observer.breakPushes, 1);
      await controller.breakSettings.flush();
    },
  );

  testWidgets(
    'completion reloads the threshold and opens only one break route',
    (tester) async {
      final repo = MemoryBreakSettings();
      final controller = AudyController(breakSettingsRepository: repo);
      addTearDown(controller.dispose);
      controller.breakSettings.useAccount('A');
      await controller.refreshBreakSettings();
      controller.gamesInCurrentSession = 1;
      repo.pending = Completer<BreakSettings>();
      final observer = _BreakObserver();
      await tester.pumpWidget(
        AudyScope(
          controller: controller,
          child: MaterialApp(
            navigatorObservers: [observer],
            routes: {
              AppRoutes.meltdown: (_) =>
                  const Scaffold(body: Text('Break destination')),
            },
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    AppRoutes.navigateAfterGameCompletion(context, controller);
                    AppRoutes.navigateAfterGameCompletion(context, controller);
                  },
                  child: const Text('Finish'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Finish'));
      repo.pending!.complete(const BreakSettings(gamesBeforeBreak: 1));
      await tester.pumpAndSettle();
      expect(find.text('Break destination'), findsOneWidget);
      expect(observer.breakPushes, 1);
      await controller.breakSettings.flush();
    },
  );

  testWidgets(
    'the break screen starts at five minutes and enables return after countdown',
    (tester) async {
      tester.view.physicalSize = const Size(900, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final controller = AudyController(
        breakSettingsRepository: MemoryBreakSettings(),
      );
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        AudyScope(
          controller: controller,
          child: const MaterialApp(home: MeltdownScreen()),
        ),
      );
      expect(find.text('05:00'), findsOneWidget);
      final button = find
          .ancestor(
            of: find.text('Return to Games'),
            matching: find.byType(GestureDetector),
          )
          .first;
      expect(tester.widget<GestureDetector>(button).onTap, isNull);
      await tester.pump(const Duration(minutes: 5, seconds: 2));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('00:00'), findsOneWidget);
      expect(tester.widget<GestureDetector>(button).onTap, isNotNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 4));
      expect(tester.takeException(), isNull);
    },
  );

  Future<AudyController> showEditor(
    WidgetTester tester,
    MemoryBreakSettings repo,
  ) async {
    final controller = AudyController(breakSettingsRepository: repo)
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
          home: BreakSettingsEditor(
            child: UserProfile(
              id: 'child-a',
              name: 'Ari',
              age: 8,
              createdAt: DateTime(2026),
              role: 'child',
            ),
            repository: repo,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return controller;
  }

  testWidgets(
    'editor validates, simulates without Student progress, saves and restores defaults',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = MemoryBreakSettings();
      final controller = await showEditor(tester, repo);
      await tester.enterText(find.byType(TextField), '0');
      await tester.pump();
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Save threshold'),
            )
            .onPressed,
        isNull,
      );
      await tester.enterText(find.byType(TextField), '1');
      await tester.pump();
      final simulate = find.text('Simulate one completed game');
      await tester.ensureVisible(simulate);
      await tester.pumpAndSettle();
      await tester.tap(simulate);
      await tester.pump();
      expect(find.text('A break would start now.'), findsOneWidget);
      expect(controller.gamesInCurrentSession, 0);
      expect(controller.gamesPlayed, 0);
      await tester.tap(find.text('Save threshold'));
      await tester.pumpAndSettle();
      expect(repo.records['child-a']!.gamesBeforeBreak, 1);
      expect(repo.records.keys, ['child-a']);
      await tester.tap(find.text('Restore default (5 games)'));
      await tester.pump();
      await tester.tap(find.text('Save threshold'));
      await tester.pumpAndSettle();
      expect(repo.records['child-a']!.gamesBeforeBreak, 5);
    },
  );

  testWidgets(
    'conflicting break save preserves the draft and requires reload',
    (tester) async {
      final repo = MemoryBreakSettings()..conflict = true;
      await showEditor(tester, repo);
      await tester.enterText(find.byType(TextField), '3');
      await tester.tap(find.text('Save threshold'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Another Caretaker saved changes'),
        findsOneWidget,
      );
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '3',
      );
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Save threshold'),
            )
            .onPressed,
        isNull,
      );
      expect(repo.records, isEmpty);
    },
  );
}
