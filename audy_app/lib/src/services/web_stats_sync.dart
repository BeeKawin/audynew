import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Same elapsed-day rule as the existing controller's _updateDayStreak.
int webDayStreak(Map<String, dynamic> stats, {DateTime? now}) {
  final streak = (stats['day_streak'] as num?)?.toInt() ?? 1;
  final last = DateTime.tryParse(stats['last_played_at'] as String? ?? '');
  if (last == null) return streak;
  final days = (now ?? DateTime.now()).difference(last).inDays;
  if (days == 1) return streak + 1;
  if (days > 1) return 1;
  return streak;
}

/// A stale browser may never decrease the lifetime totals from another device.
/// Compare-and-swap retries if another client updates the row between reads.
class WebStatsSync {
  const WebStatsSync(this.client, {this.clock = DateTime.now});
  final SupabaseClient client;
  final DateTime Function() clock;

  Future<void> save(
    String studentId, {
    required int learningPoints,
    required int gamesPlayed,
    required int dayStreak,
  }) async {
    for (var attempt = 0; attempt < 4; attempt++) {
      final previous = await client
          .from('student_stats')
          .select()
          .eq('student_id', studentId)
          .maybeSingle();
      final values = {
        'student_id': studentId,
        'learning_points': max(
          learningPoints,
          (previous?['learning_points'] as num?)?.toInt() ?? 0,
        ),
        'games_played': max(
          gamesPlayed,
          (previous?['games_played'] as num?)?.toInt() ?? 0,
        ),
        // The streak is initialized from cloud before play; a stale browser
        // cannot replace the latest device's streak with its initial value.
        'day_streak': previous == null
            ? dayStreak
            : webDayStreak(previous, now: clock()),
        'last_played_at': clock().toUtc().toIso8601String(),
      };
      if (previous == null) {
        try {
          await client.from('student_stats').insert(values);
          return;
        } on PostgrestException catch (error) {
          if (error.code != '23505') rethrow;
          continue;
        }
      }
      final query = client
          .from('student_stats')
          .update(values)
          .eq('student_id', studentId)
          .eq('learning_points', previous['learning_points'])
          .eq('games_played', previous['games_played'])
          .eq('day_streak', previous['day_streak']);
      final lastPlayed = previous['last_played_at'];
      final updated =
          await (lastPlayed == null
                  ? query.isFilter('last_played_at', null)
                  : query.eq('last_played_at', lastPlayed))
              .select('student_id');
      if (updated.isNotEmpty) return;
    }
    throw StateError('Progress changed on another device. Retry the sync.');
  }
}
