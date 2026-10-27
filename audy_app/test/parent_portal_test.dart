import 'package:audy_app/src/data/models/parent_portal_model.dart';
import 'package:audy_app/src/features/parent/child_profile_selector.dart';
import 'package:audy_app/src/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('child reward data maps Supabase fields', () {
    final reward = ChildRewardData.fromJson({
      'id': 'reward-1',
      'child_id': 'child-1',
      'created_by': 'parent-1',
      'prize': 'Choose a family activity',
      'condition_type': 'reading',
      'target_count': 5,
      'current_progress': 2,
      'is_completed': false,
      'is_claimed': false,
      'created_at': '2026-10-21T09:00:00.000Z',
      'updated_at': '2026-10-21T09:00:00.000Z',
    });

    expect(reward.childId, 'child-1');
    expect(reward.conditionType, 'reading');
    expect(reward.progressRatio, 0.4);
  });

  testWidgets('child selector defaults to the first supplied child', (
    tester,
  ) async {
    final children = [
      UserProfile(
        id: 'first-child',
        name: 'Ari',
        age: 8,
        createdAt: DateTime(2026, 1, 1),
        role: 'child',
      ),
      UserProfile(
        id: 'second-child',
        name: 'Bee',
        age: 9,
        createdAt: DateTime(2026, 2, 1),
        role: 'child',
      ),
    ];
    String? selectedId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChildProfileSelector(
            children: children,
            selectedChildId: null,
            label: 'Selected child',
            emptyMessage: 'No children',
            onSelected: (value) => selectedId = value,
          ),
        ),
      ),
    );

    expect(find.text('Ari'), findsOneWidget);
    final selectorSize = tester.getSize(find.byType(PopupMenuButton<String>));
    expect(selectorSize.height, greaterThanOrEqualTo(56));

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bee').last);
    await tester.pumpAndSettle();

    expect(selectedId, 'second-child');
  });
}
