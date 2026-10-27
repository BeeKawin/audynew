import 'dart:async';

import 'package:audy_app/src/core/app_routes.dart';
import 'package:audy_app/src/data/models/break_settings.dart';
import 'package:audy_app/src/data/models/parent_portal_model.dart';
import 'package:audy_app/src/data/repositories/break_settings_repository.dart';
import 'package:audy_app/src/data/repositories/caretaker_repository.dart';
import 'package:audy_app/src/features/auth/login_page.dart';
import 'package:audy_app/src/features/caretaker/caretaker_shell.dart';
import 'package:audy_app/src/services/auth_service.dart';
import 'package:audy_app/src/state/audy_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'support/audy_test_environment.dart';

UserProfile account(String role) => UserProfile(
  id: role == 'child' ? 'f7385453-50e3-4da6-817a-559b9c7bd126' : 'caretaker-id',
  name: role,
  age: 8,
  createdAt: DateTime(2026),
  role: role,
);

class DebugAuth extends AuthService {
  String? email;
  String? password;
  UserProfile? profile;
  bool fail = false;
  int signOuts = 0;
  Completer<void>? pendingSignOut;
  Completer<UserProfile?>? pendingProfile;
  final profileRequested = Completer<void>();

  @override
  Future<User> signIn({required String email, required String password}) async {
    this.email = email;
    this.password = password;
    if (fail) throw StateError('test sign-in failure');
    return User(
      id: profile!.id,
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: '2026-01-01',
    );
  }

  @override
  Future<UserProfile?> getCurrentProfile() async {
    if (!profileRequested.isCompleted) profileRequested.complete();
    return pendingProfile?.future ?? profile;
  }

  @override
  Future<void> signOut() async {
    signOuts++;
    await pendingSignOut?.future;
  }

  @override
  Stream<AuthState> get authStateStream => const Stream.empty();
  @override
  Future<List<ChildRewardData>> fetchChildRewards(String childId) async => [];
}

class DefaultBreaks extends BreakSettingsRepository {
  DefaultBreaks() : super(Supabase.instance.client);
  @override
  Future<BreakSettings> loadForStudent() async => const BreakSettings();
}

class EmptyRoster extends CaretakerRepository {
  EmptyRoster() : super(Supabase.instance.client);
  @override
  Future<CaretakerRoster> load() async => CaretakerRoster([], 0, 0);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(initializeAudyTestEnvironment);

  Future<void> showLogin(
    WidgetTester tester,
    AudyController controller,
    DebugAuth auth,
  ) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      AudyScope(
        controller: controller,
        child: MaterialApp(
          initialRoute: AppRoutes.login,
          routes: {
            AppRoutes.login: (_) => LoginPage(authService: auth),
            AppRoutes.dashboard: (_) =>
                const Scaffold(body: Text('Signed in dashboard')),
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final role in ['child', 'caretaker']) {
    testWidgets('$role debug signs in with the existing account', (
      tester,
    ) async {
      final auth = DebugAuth()..profile = account(role);
      final controller = AudyController(
        authService: auth,
        breakSettingsRepository: DefaultBreaks(),
      );
      addTearDown(controller.dispose);
      await showLogin(tester, controller, auth);
      final button = find.text(role == 'child' ? 'Student' : 'Caretaker');
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(
        auth.email,
        role == 'child' ? 'test@audy.com' : 'caretaker@gmail.com',
      );
      expect(auth.password, role == 'child' ? 'password123' : 'audy123');
      expect(controller.currentUser?.id, account(role).id);
      expect(controller.currentUser?.role, role);
      expect(find.text('Signed in dashboard'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('failed Student debug never invents a signed-in profile', (
    tester,
  ) async {
    final auth = DebugAuth()..fail = true;
    final controller = AudyController(authService: auth);
    addTearDown(controller.dispose);
    await showLogin(tester, controller, auth);
    await tester.ensureVisible(find.text('Student'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Student'));
    await tester.pumpAndSettle();
    expect(controller.currentUser, isNull);
    expect(find.byType(LoginPage), findsOneWidget);
    expect(
      find.textContaining('Could not sign in to test@audy.com'),
      findsOneWidget,
    );
  });

  testWidgets('debug rejects an account with the wrong role', (tester) async {
    final auth = DebugAuth()..profile = account('caretaker');
    final controller = AudyController(authService: auth);
    addTearDown(controller.dispose);
    await showLogin(tester, controller, auth);
    await tester.ensureVisible(find.text('Student'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Student'));
    await tester.pumpAndSettle();
    expect(auth.signOuts, 1);
    expect(controller.currentUser, isNull);
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets(
    'Caretaker logout opens Login before remote sign-out and clears the stack',
    (tester) async {
      tester.view.physicalSize = const Size(900, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final auth = DebugAuth()..pendingSignOut = Completer<void>();
      final controller = AudyController(authService: auth)
        ..setUser(account('caretaker'));
      addTearDown(controller.dispose);
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        AudyScope(
          controller: controller,
          child: MaterialApp(
            navigatorKey: navigator,
            home: ListenableBuilder(
              listenable: controller,
              builder: (_, _) => controller.isLoggedIn
                  ? CaretakerShell(initialTab: 2, repository: EmptyRoster())
                  : const Scaffold(body: Text('Signed-out guard')),
            ),
            routes: {AppRoutes.login: (_) => LoginPage(authService: auth)},
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Log out'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Log out'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(controller.currentUser, isNull);
      expect(controller.isLoggingOut, isTrue);
      expect(find.byType(LoginPage), findsOneWidget);
      expect(navigator.currentState!.canPop(), isFalse);
      expect(
        ModalRoute.of(tester.element(find.byType(LoginPage)))?.settings.name,
        AppRoutes.login,
      );
      final studentTap = tester.widget<GestureDetector>(
        find
            .ancestor(
              of: find.text('Student'),
              matching: find.byType(GestureDetector),
            )
            .first,
      );
      expect(studentTap.onTap, isNull);
      auth.pendingSignOut!.complete();
      await tester.pumpAndSettle();
      expect(controller.isLoggingOut, isFalse);
      expect(find.byType(LoginPage), findsOneWidget);
      expect(auth.signOuts, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('late profile response cannot undo logout', (tester) async {
    final auth = DebugAuth()
      ..pendingProfile = Completer<UserProfile?>()
      ..pendingSignOut = Completer<void>();
    final controller = AudyController(authService: auth);
    addTearDown(controller.dispose);
    final initializing = controller.init();
    await tester.pump();
    await auth.profileRequested.future;
    final signingOut = controller.logout();
    auth.pendingProfile!.complete(account('caretaker'));
    await initializing;
    expect(controller.currentUser, isNull);
    auth.pendingSignOut!.complete();
    await signingOut;
    expect(controller.currentUser, isNull);
  });
}
