import 'package:audy_app/main.dart';
import 'package:audy_app/src/features/auth/login_page.dart';
import 'package:audy_app/src/core/app_routes.dart';
import 'package:audy_app/src/features/profile_and_rewards_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/audy_test_environment.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(initializeAudyTestEnvironment);
  testWidgets('app starts at login with Student and Caretaker debug choices', (
    tester,
  ) async {
    await tester.pumpWidget(const AudyApp());
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Student'), findsOneWidget);
    expect(find.text('Caretaker'), findsOneWidget);
    expect(find.text('Parent'), findsNothing);
    expect(find.text('Teacher'), findsNothing);
    Navigator.of(
      tester.element(find.byType(LoginPage)),
    ).pushNamed(AppRoutes.profile);
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(ProfilePage), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
