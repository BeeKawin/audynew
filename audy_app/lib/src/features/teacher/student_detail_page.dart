import 'package:flutter/material.dart';
import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../services/auth_service.dart';
import '../dashboard_analytics.dart';

class StudentDetailPage extends StatelessWidget {
  final UserProfile student;
  final Map<String, dynamic>? stats;
  final List<Map<String, dynamic>> assignments;
  final List<Map<String, dynamic>> sessions;

  const StudentDetailPage({
    super.key,
    required this.student,
    required this.stats,
    required this.assignments,
    required this.sessions,
  });

  static const List<Map<String, String>> _gameTypes = [
    {'key': 'emotion_classify', 'label': 'Emotion Recognition'},
    {'key': 'emotion_mimic', 'label': 'Emotion Mimicking'},
    {'key': 'minipuzzle', 'label': 'Mini Puzzle'},
    {'key': 'sorting', 'label': 'Shape Sorting'},
    {'key': 'reaction_time', 'label': 'Reaction Time'},
    {'key': 'reading', 'label': 'Read & Speak'},
    {'key': 'social_chat', 'label': 'Social Chat'},
  ];

  @override
  Widget build(BuildContext context) {
    final learningPoints = stats?['learning_points'] ?? 0;
    final gamesPlayed = stats?['games_played'] ?? 0;
    final dayStreak = stats?['day_streak'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Student Profile',
          style: AudyTypography.headingLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back to Classroom',
        ),
      ),
      body: AudyResponsivePage(
        scrollable: true,
        builder: (context, adaptive) {
          return Padding(
            padding: EdgeInsets.all(adaptive.space(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Profile Info Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
                    side: const BorderSide(color: AudyColors.borderLight, width: 1.5),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(adaptive.space(20)),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: AudyColors.skyBlue.withValues(alpha: 0.2),
                          child: const Icon(
                            Icons.face_rounded,
                            color: AudyColors.skyBlue,
                            size: 44,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.name,
                                style: AudyTypography.headingMedium.copyWith(fontSize: 22),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Age: ${student.age}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AudyColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                student.email ?? 'No email associated',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AudyColors.textLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: adaptive.space(20)),

                // Stats row
                Row(
                  children: [
                    _buildStatColumn('Learning Points', '$learningPoints', Icons.auto_awesome_rounded, AudyColors.activityRewards),
                    _buildStatColumn('Games Played', '$gamesPlayed', Icons.sports_esports_rounded, AudyColors.skyBlue),
                    _buildStatColumn('Day Streak', '$dayStreak days', Icons.local_fire_department_rounded, Colors.orange),
                  ],
                ),
                SizedBox(height: adaptive.space(24)),

                // Analytics Charts
                Text(
                  'Gameplay Analytics',
                  style: AudyTypography.headingSmall,
                ),
                SizedBox(height: adaptive.space(12)),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
                    side: const BorderSide(color: AudyColors.borderLight, width: 1.5),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(adaptive.space(20)),
                    child: StudentAnalyticsCharts(sessions: sessions),
                  ),
                ),
                SizedBox(height: adaptive.space(24)),

                // Assignments Section
                Text(
                  'Task Progress',
                  style: AudyTypography.headingSmall,
                ),
                SizedBox(height: adaptive.space(12)),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
                    side: const BorderSide(color: AudyColors.borderLight, width: 1.5),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(adaptive.space(20)),
                    child: assignments.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'No assignments set for this student.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AudyColors.textLight,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: assignments.map((assign) {
                              final gameName = _gameTypes.firstWhere(
                                (g) => g['key'] == assign['game_type'],
                                orElse: () => {'label': assign['game_type'] as String},
                              )['label'];
                              final double percent = (assign['current_count'] as int) / (assign['target_count'] as int);
                              final isCompleted = assign['is_completed'] as bool;

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Icon(
                                      isCompleted ? Icons.check_circle_rounded : Icons.pending_rounded,
                                      color: isCompleted ? AudyColors.success : AudyColors.textLight,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        '$gameName',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AudyColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${assign['current_count']} / ${assign['target_count']}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: isCompleted ? AudyColors.success : AudyColors.skyBlue,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      width: 100,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: percent.clamp(0.0, 1.0),
                                          minHeight: 8,
                                          backgroundColor: AudyColors.borderLight,
                                          color: isCompleted ? AudyColors.success : AudyColors.skyBlue,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
          side: const BorderSide(color: AudyColors.borderLight, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AudyColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AudyColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
