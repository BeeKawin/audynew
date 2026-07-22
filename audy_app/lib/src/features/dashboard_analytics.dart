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
    required this.totalPlayTimeMinutes,
    required this.cooldownsTriggered,
    required this.emotionClassifySessions,
    required this.emotionClassifyAccuracy,
    required this.communicationSessions,
    required this.communicationAccuracy,
    required this.focusSessions,
    required this.focusAccuracy,
    required this.completedAssignments,
    required this.totalAssignments,
  });

  final int totalSessions;
  final int averageAccuracy;
  final int completionRate;
  final List<int> dailyCounts;
  final Map<String, DifficultyStat> byDifficulty;

  final int totalPlayTimeMinutes;
  final int cooldownsTriggered;

  final int emotionClassifySessions;
  final int emotionClassifyAccuracy;

  final int communicationSessions;
  final int communicationAccuracy;

  final int focusSessions;
  final int focusAccuracy;

  final int completedAssignments;
  final int totalAssignments;

  static const _difficultyOrder = ['easy', 'medium', 'hard'];

  factory StudentAnalytics.fromSessions(
    List<Map<String, dynamic>> sessions, {
    List<Map<String, dynamic>>? assignments,
  }) {
    var completedAssignments = 0;
    var totalAssignments = 0;
    if (assignments != null) {
      totalAssignments = assignments.length;
      completedAssignments = assignments
          .where((a) => (a['is_completed'] == true || a['isCompleted'] == true))
          .length;
    }

    if (sessions.isEmpty) {
      return StudentAnalytics(
        totalSessions: 0,
        averageAccuracy: 0,
        completionRate: 0,
        dailyCounts: List<int>.filled(7, 0),
        byDifficulty: const {},
        totalPlayTimeMinutes: 0,
        cooldownsTriggered: 0,
        emotionClassifySessions: 0,
        emotionClassifyAccuracy: 0,
        communicationSessions: 0,
        communicationAccuracy: 0,
        focusSessions: 0,
        focusAccuracy: 0,
        completedAssignments: completedAssignments,
        totalAssignments: totalAssignments,
      );
    }

    var accuracySum = 0;
    var fullCount = 0;
    final daily = List<int>.filled(7, 0);
    final diffAccuracy = <String, int>{};
    final diffCount = <String, int>{};

    var totalDurationSeconds = 0;
    var emotionClassifySessions = 0;
    var emotionClassifyAccuracySum = 0;
    var communicationSessions = 0;
    var communicationAccuracySum = 0;
    var focusSessions = 0;
    var focusAccuracySum = 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final s in sessions) {
      final acc = (s['accuracy_percent'] as num?)?.round() ?? 0;
      accuracySum += acc;
      if (acc >= 100) fullCount++;

      final duration = (s['duration_seconds'] as num?)?.round() ??
          (s['durationSeconds'] as num?)?.round() ??
          0;
      totalDurationSeconds += duration;

      final gameType = (s['gameType'] ?? s['game_type'] ?? '').toString();
      if (gameType == 'emotion_classify') {
        emotionClassifySessions++;
        emotionClassifyAccuracySum += acc;
      } else if (gameType == 'reading' || gameType == 'social_chat') {
        communicationSessions++;
        communicationAccuracySum += acc;
      } else if (gameType == 'reaction_time' ||
          gameType == 'minipuzzle' ||
          gameType == 'sorting') {
        focusSessions++;
        focusAccuracySum += acc;
      }

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
      totalPlayTimeMinutes: (totalDurationSeconds / 60).round(),
      cooldownsTriggered: sessions.length ~/ 5,
      emotionClassifySessions: emotionClassifySessions,
      emotionClassifyAccuracy: emotionClassifySessions > 0
          ? (emotionClassifyAccuracySum / emotionClassifySessions).round()
          : 0,
      communicationSessions: communicationSessions,
      communicationAccuracy: communicationSessions > 0
          ? (communicationAccuracySum / communicationSessions).round()
          : 0,
      focusSessions: focusSessions,
      focusAccuracy: focusSessions > 0
          ? (focusAccuracySum / focusSessions).round()
          : 0,
      completedAssignments: completedAssignments,
      totalAssignments: totalAssignments,
    );
  }
}

class DifficultyStat {
  const DifficultyStat({required this.count, required this.averageAccuracy});
  final int count;
  final int averageAccuracy;
}

class StudentAnalyticsCharts extends StatelessWidget {
  const StudentAnalyticsCharts({
    super.key,
    required this.sessions,
    this.assignments,
    this.isTeacherView = false,
    this.classAverageAccuracy,
  });

  final List<Map<String, dynamic>> sessions;
  final List<Map<String, dynamic>>? assignments;
  final bool isTeacherView;
  final double? classAverageAccuracy;

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
    final data = StudentAnalytics.fromSessions(sessions, assignments: assignments);

    if (data.totalSessions == 0 && data.totalAssignments == 0) {
      return _EmptyAnalytics();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Headline Metrics Row
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

        // 2. Class-wide comparison (Teacher only)
        if (isTeacherView && classAverageAccuracy != null) ...[
          _SectionLabel('Class-wide Comparison'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AudyColors.backgroundSoft.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
              border: Border.all(color: AudyColors.borderLight, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ComparisonBar(
                  label: 'Student Average',
                  accuracy: data.averageAccuracy,
                  color: AudyColors.skyBlue,
                ),
                const SizedBox(height: 12),
                _ComparisonBar(
                  label: 'Class Average',
                  accuracy: classAverageAccuracy!.round(),
                  color: AudyColors.borderLight.withValues(alpha: 0.8),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // 3. Engagement & Sensory/Meltdown Section
        _SectionLabel('Engagement & Sensory Protection'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _DetailMetricBox(
                icon: Icons.timer_outlined,
                label: 'Total Play Time',
                value: '${data.totalPlayTimeMinutes} mins',
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DetailMetricBox(
                icon: Icons.shield_rounded,
                label: 'Cooldowns Triggered',
                value: '${data.cooldownsTriggered}',
                color: AudyColors.mintGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _WeeklyActivityChart(counts: data.dailyCounts),
        const SizedBox(height: 24),

        // 4. Focus Areas & Skills Section
        _SectionLabel('Skill & Focus Areas'),
        const SizedBox(height: 10),
        _SkillProgressBar(
          label: 'Emotion Recognition',
          accuracy: data.emotionClassifyAccuracy,
          sessions: data.emotionClassifySessions,
          color: AudyColors.blushPink,
        ),
        const SizedBox(height: 12),
        _SkillProgressBar(
          label: 'Communication Practice',
          accuracy: data.communicationAccuracy,
          sessions: data.communicationSessions,
          color: AudyColors.skyBlue,
        ),
        const SizedBox(height: 12),
        _SkillProgressBar(
          label: 'Cognitive & Task Focus',
          accuracy: data.focusAccuracy,
          sessions: data.focusSessions,
          color: AudyColors.mintGreen,
        ),
        const SizedBox(height: 24),

        // 5. Assignment Completion Progress
        if (data.totalAssignments > 0) ...[
          _SectionLabel('Homework Assignments'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AudyColors.backgroundSoft.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
              border: Border.all(color: AudyColors.borderLight, width: 1.2),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.assignment_turned_in_rounded,
                  color: AudyColors.skyBlue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Assignment Completion',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AudyColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: data.completedAssignments / data.totalAssignments,
                          backgroundColor: AudyColors.borderLight,
                          color: AudyColors.skyBlue,
                          minHeight: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${data.completedAssignments}/${data.totalAssignments}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AudyColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // 6. Performance by Difficulty Section
        if (data.byDifficulty.isNotEmpty) ...[
          _SectionLabel('Performance by Difficulty'),
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

class _DetailMetricBox extends StatelessWidget {
  const _DetailMetricBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.2),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AudyColors.textPrimary,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AudyColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillProgressBar extends StatelessWidget {
  const _SkillProgressBar({
    required this.label,
    required this.accuracy,
    required this.sessions,
    required this.color,
  });

  final String label;
  final int accuracy;
  final int sessions;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AudyColors.textSecondary,
              ),
            ),
            Text(
              sessions > 0 ? '$accuracy% ($sessions sessions)' : 'Unplayed',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: sessions > 0 ? AudyColors.textPrimary : AudyColors.textLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 12,
            color: AudyColors.borderLight,
            child: Row(
              children: [
                if (sessions > 0)
                  Expanded(
                    flex: accuracy,
                    child: Container(color: color),
                  ),
                Expanded(
                  flex: 100 - (sessions > 0 ? accuracy : 0),
                  child: Container(color: Colors.transparent),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ComparisonBar extends StatelessWidget {
  const _ComparisonBar({
    required this.label,
    required this.accuracy,
    required this.color,
  });

  final String label;
  final int accuracy;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AudyColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                Container(height: 14, color: AudyColors.borderLight),
                FractionallySizedBox(
                  widthFactor: (accuracy / 100).clamp(0.0, 1.0),
                  child: Container(height: 14, color: color),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 36,
          child: Text(
            '$accuracy%',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AudyColors.textPrimary,
            ),
          ),
        ),
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
