import 'package:flutter_test/flutter_test.dart';
import 'package:testrun1/main.dart';

void main() {
  testWidgets('dashboard renders core sections', (tester) async {
    await tester.pumpWidget(const AudyApp());

    expect(find.text('AUDY'), findsOneWidget);
    expect(find.text('Today\'s Progress'), findsOneWidget);
    expect(find.text('Activities'), findsOneWidget);
    expect(find.text('Games'), findsOneWidget);
    expect(find.text('CEDT INNOVATION SUMMIT 2026'), findsOneWidget);
  });
}
