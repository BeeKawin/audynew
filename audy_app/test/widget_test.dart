import 'package:flutter_test/flutter_test.dart';
import 'package:audy_app/main.dart';

void main() {
  testWidgets('dashboard renders and routes to games', (tester) async {
    await tester.pumpWidget(const AudyApp());

    expect(find.text('AUDY'), findsOneWidget);
    expect(find.text('Assignments'), findsOneWidget);
    expect(find.text('No assignments yet'), findsOneWidget);
    expect(find.text('Activities'), findsOneWidget);
    expect(find.text('Games'), findsOneWidget);

    final gamesFinder = find.text('Games').first;
    await tester.ensureVisible(gamesFinder);
    await tester.tap(gamesFinder);
    await tester.pumpAndSettle();

    expect(find.text('Play and learn with fun activities!'), findsOneWidget);
    expect(find.text('What is this emotion?'), findsOneWidget);
  });
}
