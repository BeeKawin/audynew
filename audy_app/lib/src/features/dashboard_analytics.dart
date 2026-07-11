import 'package:flutter/material.dart';

import '../core/audy_theme.dart';

/// Aggregated view over a student's recorded [game_sessions] rows, computed
/// once and handed to the dashboard charts below.
class StudentAnalytics {
  StudentAnalytics({
    required this.totalSessions,
    required this.averageAccuracy,
    required this.completionRate,
    required this.dailyCounts,
    required this.byDifficulty,
  });

  final int totalSessions;

  /// Mean of `accuracy_percent` across all sessions (0–100).
  final int averageAccuracy;

  /// Share of sessions finished at full accuracy (0–100).
  final int completionRate;

  /// Session counts for the last 7 days, oldest first (length 7).
  final List<int> dailyCounts;

  /// Average accuracy per difficulty, keyed easy/medium/hard.
  final Map<String, DifficultyStat> byDifficulty;

  static const _difficultyOrder = ['easy', 'medium', 'hard'];

  factory StudentAnalytics.fromSessions(List<Map<String, dynamic>> sessions) {
    if (sessions.isEmpty) {
      return StudentAnalytics(
        totalSessions: 0,
        averageAccuracy: 0,
        completionRate: 0,
        dailyCounts: List<int>.filled(7, 0),
        byDifficulty: const {},
      );
    }

    var accuracySum = 0;
    var fullCount = 0;
    final daily = List<int>.filled(7, 0);
    final diffAccuracy = <String, int>{};
    final diffCount = <String, int>{};

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final s in sessions) {
      final acc = (s['accuracy_percent'] as num?)?.round() ?? 0;
      accuracySum += acc;
      if (acc >= 100) fullCount++;

      final ended = DateTime.tryParse(s['session_ended_at']?.toString() ?? '');
      if (ended != null) {
        final day = DateTime(ended.year, ended.month, ended.day);
        final diff = today.difference(day).inDays;
        if (diff >= 0 && diff < 7) {
          daily[6 - diff] += 1;
        }
      }

      final rawDiff = (s['difficulty']?.toString() ?? '').toLowerCase();
      if (_difficultyOrder.contains(rawDiff)) {
        diffAccuracy[rawDiff] = (diffAccuracy[rawDiff] ?? 0) + acc;
        diffCount[rawDiff] = (diffCount[rawDiff] ?? 0) + 1;
      }
    }

    final byDifficulty = <String, DifficultyStat>{};
    for (final key in _difficultyOrder) {
      final count = diffCount[key] ?? 0;
      if (count > 0) {
        byDifficulty[key] = DifficultyStat(
          count: count,
          averageAccuracy: (diffAccuracy[key]! / count).round(),
        );
      }
    }

    return StudentAnalytics(
      totalSessions: sessions.length,
      averageAccuracy: (accuracySum / sessions.length).round(),
      completionRate: ((fullCount / sessions.length) * 100).round(),
      dailyCounts: daily,
      byDifficulty: byDifficulty,
    );
  }
}

class DifficultyStat {
  const DifficultyStat({required this.count, required this.averageAccuracy});
  final int count;
  final int averageAccuracy;
}

/// Interactive progress graphs for one student: weekly activity, headline
/// rates, and accuracy by difficulty. Pure Flutter layout — no chart package.
class StudentAnalyticsCharts extends StatelessWidget {
  const StudentAnalyticsCharts({super.key, required this.sessions});

  final List<Map<String, dynamic>> sessions;

  static const _diffColors = {
    'easy': AudyColors.mintGreen,
    'medium': AudyColors.skyBlue,
    'hard': AudyColors.blushPink,
  };
  static const _diffLabels = {
    'easy': 'Easy',
    'medium': 'Medium',
    'hard': 'Hard',
  };

  @override
  Widget build(BuildContext context) {
    final data = StudentAnalytics.fromSessions(sessions);

    if (data.totalSessions == 0) {
      return _EmptyAnalytics();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                label: 'Sessions',
                value: '${data.totalSessions}',
                color: AudyColors.skyBlue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricTile(
                label: 'Avg. Accuracy',
                value: '${data.averageAccuracy}%',
                color: AudyColors.mintGreen,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricTile(
                label: 'Completion',
                value: '${data.completionRate}%',
                color: AudyColors.softLavender,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _SectionLabel('Activity — last 7 days'),
        const SizedBox(height: 10),
        _WeeklyActivityChart(counts: data.dailyCounts),
        if (data.byDifficulty.isNotEmpty) ...[
          const SizedBox(height: 20),
          _SectionLabel('Performance by difficulty'),
          const SizedBox(height: 10),
          ...StudentAnalytics._difficultyOrder
              .where((k) => data.byDifficulty.containsKey(k))
              .map((k) {
            final stat = data.byDifficulty[k]!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _DifficultyBar(
                label: _diffLabels[k]!,
                color: _diffColors[k]!,
                accuracy: stat.averageAccuracy,
                count: stat.count,
              ),
            );
          }),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AudyColors.textSecondary,
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AudyColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AudyColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Vertical bars, one per day (oldest → today). Height scales to the busiest
/// day; today is highlighted.
class _WeeklyActivityChart extends StatelessWidget {
  const _WeeklyActivityChart({required this.counts});

  final List<int> counts;

  static const _dayInitials = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    final maxCount = counts.fold<int>(1, (m, c) => c > m ? c : m);
    final now = DateTime.now();
    // Weekday label for each bar (bar i is `6 - i` days before today).
    final labels = List<String>.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return _dayInitials[d.weekday % 7];
    });

    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final count = counts[i];
          final isToday = i == 6;
          final fraction = count / maxCount;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    count > 0 ? '$count' : '',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AudyColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: count == 0 ? 0.02 : fraction.clamp(0.06, 1),
                        child: Container(
                          decoration: BoxDecoration(
                            color: count == 0
                                ? AudyColors.borderLight
                                : (isToday
                                    ? AudyColors.skyBlue
                                    : AudyColors.skyBlue
                                        .withValues(alpha: 0.55)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                      color: isToday
                          ? AudyColors.textPrimary
                          : AudyColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// One horizontal accuracy bar for a difficulty tier.
class _DifficultyBar extends StatelessWidget {
  const _DifficultyBar({
    required this.label,
    required this.color,
    required this.accuracy,
    required this.count,
  });

  final String label;
  final Color color;
  final int accuracy;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AudyColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Container(height: 18, color: AudyColors.borderLight),
                FractionallySizedBox(
                  widthFactor: (accuracy / 100).clamp(0.0, 1.0),
                  child: Container(height: 18, color: color),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 78,
          child: Text(
            '$accuracy% · $count',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AudyColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyAnalytics extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AudyColors.backgroundSoft.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
      ),
      child: Row(
        children: [
          const Icon(Icons.insights_rounded,
              color: AudyColors.textLight, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'No play sessions yet. Graphs appear once this student plays a game.',
              style: TextStyle(fontSize: 12, color: AudyColors.textLight),
            ),
          ),
        ],
      ),
    );
  }
}
