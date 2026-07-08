import 'package:flutter/material.dart';

import '../core/app_routes.dart';
import '../core/audy_theme.dart';
import '../core/audy_ui.dart';
import '../data/models/progress_model.dart';
import '../services/auth_service.dart';
import '../services/bluetooth_service.dart';
import '../services/sound_service.dart';
import '../state/audy_controller.dart';
import 'parent/parent_dashboard.dart';
import 'teacher/teacher_dashboard.dart';

/// Language toggle button widget
class _LanguageToggle extends StatelessWidget {
  final AudyController controller;

  const _LanguageToggle({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SoundService.instance.playTap();
        final newLang = controller.currentLanguage == 'en' ? 'th' : 'en';
        controller.setLanguage(newLang);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: controller.currentLanguage == 'en'
              ? AudyColors.skyBlue.withValues(alpha: 0.15)
              : AudyColors.mintGreen.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: controller.currentLanguage == 'en'
                ? AudyColors.skyBlue
                : AudyColors.mintGreen,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              controller.currentLanguage == 'en' ? 'EN' : 'ไทย',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: controller.currentLanguage == 'en'
                    ? AudyColors.skyBlue
                    : AudyColors.mintGreen,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.translate_rounded,
              size: 18,
              color: controller.currentLanguage == 'en'
                  ? AudyColors.skyBlue
                  : AudyColors.mintGreen,
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<_DashboardAssignment> _assignments = [];
  int _nextAssignmentId = 1;

  @override
  void initState() {
    super.initState();
    _loadSupabaseAssignments();
  }

  Future<void> _loadSupabaseAssignments() async {
    final controller = AudyScope.of(context);
    final user = controller.currentUser;
    if (user != null && user.role == 'child') {
      final options = _assignmentOptions(context);
      try {
        final assignmentsData = await AuthService().fetchAssignments(user.id);
        final loaded = assignmentsData.map((data) {
          final gameType = data['game_type'] as String;
          final option = options.firstWhere(
            (o) => o.gameType == gameType,
            orElse: () => options.first,
          );
          return _DashboardAssignment(
            id: data['id'].hashCode,
            supabaseId: data['id'] as String?,
            option: option,
            difficulty: 'Normal',
            targetCount: data['target_count'] as int,
            currentProgress: data['current_count'] as int,
          );
        }).toList();
        
        if (mounted) {
          setState(() {
            _assignments = loaded;
          });
        }
      } catch (e) {
        debugPrint('Failed to load assignments: $e');
      }
    }
  }

  void _addAssignment(_AssignmentOption option, String difficulty, int target) {
    if (_assignments.length >= 3) return;

    setState(() {
      _assignments.add(
        _DashboardAssignment(
          id: _nextAssignmentId++,
          option: option,
          difficulty: difficulty,
          targetCount: target,
        ),
      );
    });
  }

  Future<void> _completeAssignmentStep(int assignmentId) async {
    final index = _assignments.indexWhere((item) => item.id == assignmentId);
    if (index == -1) return;

    final assignment = _assignments[index];
    final newProgress = (assignment.currentProgress + 1).clamp(0, assignment.targetCount);
    final isCompleted = newProgress >= assignment.targetCount;

    setState(() {
      _assignments[index] = assignment.copyWith(
        currentProgress: newProgress,
      );
    });

    if (assignment.supabaseId != null) {
      try {
        await AuthService().updateAssignmentProgress(
          assignment.supabaseId!,
          newProgress,
          isCompleted,
        );
      } catch (e) {
        debugPrint('Failed to sync assignment progress: $e');
      }
    }
  }

  void _startAssignment(BuildContext context, _DashboardAssignment assignment) {
    SoundService.instance.playTap();
    Navigator.pushNamed(context, assignment.option.route);
  }

  void _showAddAssignmentDialog(
    BuildContext context,
    AudyAdaptive adaptive, {
    _AssignmentOption? suggestedOption,
  }) {
    if (_assignments.length >= 3) return;

    showDialog(
      context: context,
      builder: (context) => _AddAssignmentDialog(
        adaptive: adaptive,
        suggestedOption: suggestedOption,
        onCreate: (option, difficulty, target) {
          _addAssignment(option, difficulty, target);
          Navigator.pop(context);
        },
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final controller = AudyScope.of(context);
    final user = controller.currentUser;

    if (user != null) {
      if (user.role == 'parent') {
        return const ParentDashboard();
      } else if (user.role == 'teacher') {
        return const TeacherDashboard();
      }
    }

    return AudyResponsivePage(
      builder: (context, adaptive) {

        final activities = [
          _ActivityData(
            title: controller.tr('games'),
            icon: Icons.sports_esports_rounded,
            iconColor: AudyColors.activityGames,
            borderColor: AudyColors.activityGames,
            route: AppRoutes.games,
          ),
          _ActivityData(
            title: controller.tr('read_speak'),
            icon: Icons.menu_book_rounded,
            iconColor: AudyColors.activityReading,
            borderColor: AudyColors.activityReading,
            route: AppRoutes.readingHub,
          ),
          _ActivityData(
            title: controller.tr('social_chat'),
            icon: Icons.chat_bubble_rounded,
            iconColor: AudyColors.activitySocial,
            borderColor: AudyColors.activitySocial,
            route: AppRoutes.social,
          ),
          _ActivityData(
            title: controller.tr('rewards'),
            icon: Icons.workspace_premium_rounded,
            iconColor: AudyColors.activityRewards,
            borderColor: AudyColors.activityRewards,
            route: AppRoutes.rewards,
          ),
          _ActivityData(
            title: controller.tr('my_device'),
            icon: Icons.bluetooth_rounded,
            iconColor: const Color(0xFF7FDBDA),
            borderColor: const Color(0xFF7FDBDA),
            route: AppRoutes.device,
          ),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language toggle at top left
            _LanguageToggle(controller: controller),
            const SizedBox(height: AudySpacing.elementGap),
            ValueListenableBuilder<bool>(
              valueListenable:
                  AudyBluetoothService.instance.connectionNotifier,
              builder: (context, isDeviceConnected, _) {
                return AudyGreetingHeader(
                  greeting: controller.tr('dashboard_greeting'),
                  adaptive: adaptive,
                  isDeviceConnected: isDeviceConnected,
                  onDeviceTap: () {
                    SoundService.instance.playTap();
                    Navigator.pushNamed(context, AppRoutes.device);
                  },
                  onProfileTap: () {
                    SoundService.instance.playTap();
                    Navigator.pushNamed(context, AppRoutes.profile);
                  },
                );
              },
            ),
            const SizedBox(height: AudySpacing.sectionGap),
            // Games Played Indicator
            _GamesPlayedCard(controller: controller, adaptive: adaptive),
            const SizedBox(height: AudySpacing.sectionGap),
            AudySectionTitle(title: controller.tr('activities')),
            const SizedBox(height: AudySpacing.elementGap),
            AudyAdaptiveGrid(
              adaptive: adaptive,
              phoneColumns: 2,
              tabletColumns: 2,
              desktopColumns: 4,
              items: activities
                  .map(
                    (a) => AudyBigIconCard(
                      title: a.title,
                      icon: a.icon,
                      iconColor: a.iconColor,
                      borderColor: a.borderColor,
                      onTap: () {
                        SoundService.instance.playTap();
                        Navigator.pushNamed(context, a.route);
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AudySpacing.sectionGap),
            _AssignmentsDashboardSection(
              adaptive: adaptive,
              controller: controller,
              assignments: _assignments,
              canAddAssignment: _assignments.length < 3,
              onAddAssignment: (suggestedOption) => _showAddAssignmentDialog(
                context,
                adaptive,
                suggestedOption: suggestedOption,
              ),
              onStartAssignment: (assignment) =>
                  _startAssignment(context, assignment),
              onCompleteStep: _completeAssignmentStep,
            ),
          ],
        );
      },
    );
  }
}

const double _assignmentRecommendationThreshold = 0.80;

class _DashboardAssignment {
  const _DashboardAssignment({
    required this.id,
    this.supabaseId,
    required this.option,
    required this.difficulty,
    required this.targetCount,
    this.currentProgress = 0,
  });

  final int id;
  final String? supabaseId;
  final _AssignmentOption option;
  final String difficulty;
  final int targetCount;
  final int currentProgress;

  bool get isCompleted => currentProgress >= targetCount;
  double get progressRatio => currentProgress / targetCount;

  _DashboardAssignment copyWith({int? currentProgress}) {
    return _DashboardAssignment(
      id: id,
      supabaseId: supabaseId,
      option: option,
      difficulty: difficulty,
      targetCount: targetCount,
      currentProgress: currentProgress ?? this.currentProgress,
    );
  }
}

class _AssignmentOption {
  const _AssignmentOption({
    required this.gameType,
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
  });

  final String gameType;
  final String title;
  final IconData icon;
  final Color color;
  final String route;
}

class _AssignmentRecommendation {
  const _AssignmentRecommendation({
    required this.option,
    required this.accuracy,
  });

  final _AssignmentOption option;
  final double accuracy;
}

List<_AssignmentOption> _assignmentOptions(BuildContext context) {
  final controller = AudyScope.of(context);

  return [
    _AssignmentOption(
      gameType: 'emotion_classify',
      title: controller.tr('emotion_classify'),
      icon: Icons.sentiment_satisfied_rounded,
      color: const Color(0xFFF8C7DF),
      route: AppRoutes.emotionClassify,
    ),
    _AssignmentOption(
      gameType: 'emotion_mimic',
      title: controller.tr('emotion_mimic'),
      icon: Icons.face_retouching_natural_rounded,
      color: const Color(0xFFE7D8FA),
      route: AppRoutes.emotionMimic,
    ),
    _AssignmentOption(
      gameType: 'minipuzzle',
      title: controller.tr('mini_puzzle'),
      icon: Icons.extension_rounded,
      color: const Color(0xFFBDD8F2),
      route: AppRoutes.miniPuzzle,
    ),
    _AssignmentOption(
      gameType: 'sorting',
      title: controller.tr('sorting_game'),
      icon: Icons.category_rounded,
      color: const Color(0xFFFFF2A8),
      route: AppRoutes.sortingGame,
    ),
    _AssignmentOption(
      gameType: 'reaction_time',
      title: controller.tr('reaction_time'),
      icon: Icons.flash_on_rounded,
      color: const Color(0xFFFFDAC7),
      route: AppRoutes.reactionTime,
    ),
    _AssignmentOption(
      gameType: 'reading',
      title: controller.tr('read_speak'),
      icon: Icons.menu_book_rounded,
      color: const Color(0xFFC9E8C1),
      route: AppRoutes.readingHub,
    ),
    _AssignmentOption(
      gameType: 'social_chat',
      title: controller.tr('social_chat'),
      icon: Icons.chat_bubble_rounded,
      color: const Color(0xFFBDEBE8),
      route: AppRoutes.social,
    ),
  ];
}

List<_AssignmentRecommendation> _assignmentRecommendations(
  BuildContext context,
  ParentAnalyticsData analytics,
) {
  final options = _assignmentOptions(context);
  final recommendations = <_AssignmentRecommendation>[];

  for (final feature in analytics.features) {
    final accuracy = feature.averageAccuracy;
    if (accuracy == null || accuracy <= _assignmentRecommendationThreshold) {
      continue;
    }

    final option = _assignmentOptionForGameType(options, feature.gameType);
    if (option != null) {
      recommendations.add(
        _AssignmentRecommendation(option: option, accuracy: accuracy),
      );
    }
  }

  recommendations.sort((a, b) => b.accuracy.compareTo(a.accuracy));
  return recommendations.take(3).toList();
}

_AssignmentOption? _assignmentOptionForGameType(
  List<_AssignmentOption> options,
  String gameType,
) {
  for (final option in options) {
    if (option.gameType == gameType) return option;
  }
  return null;
}

class _AssignmentsDashboardSection extends StatelessWidget {
  const _AssignmentsDashboardSection({
    required this.adaptive,
    required this.controller,
    required this.assignments,
    required this.canAddAssignment,
    required this.onAddAssignment,
    required this.onStartAssignment,
    required this.onCompleteStep,
  });

  final AudyAdaptive adaptive;
  final AudyController controller;
  final List<_DashboardAssignment> assignments;
  final bool canAddAssignment;
  final void Function(_AssignmentOption? option) onAddAssignment;
  final void Function(_DashboardAssignment assignment) onStartAssignment;
  final void Function(int assignmentId) onCompleteStep;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: AudySectionTitle(title: controller.tr('assignments')),
            ),
            if (canAddAssignment)
              ElevatedButton.icon(
                onPressed: () {
                  SoundService.instance.playTap();
                  onAddAssignment(null);
                },
                icon: Icon(Icons.add_rounded, size: adaptive.space(20)),
                label: Text(controller.tr('add_assignment')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF8C7DF),
                  foregroundColor: const Color(0xFF243A5A),
                  minimumSize: Size(adaptive.space(48), adaptive.space(48)),
                  padding: EdgeInsets.symmetric(
                    horizontal: adaptive.space(16),
                    vertical: adaptive.space(12),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              )
            else
              _AssignmentLimitPill(adaptive: adaptive),
          ],
        ),
        SizedBox(height: adaptive.space(12)),
        _AssignmentRecommendationPanel(
          adaptive: adaptive,
          controller: controller,
          onUseRecommendation: canAddAssignment
              ? (option) {
                  SoundService.instance.playTap();
                  onAddAssignment(option);
                }
              : null,
        ),
        SizedBox(height: adaptive.space(16)),
        if (assignments.isEmpty)
          _EmptyAssignmentsCard(adaptive: adaptive)
        else
          AudyAdaptiveGrid(
            adaptive: adaptive,
            phoneColumns: 1,
            tabletColumns: 2,
            desktopColumns: 3,
            items: assignments
                .map(
                  (assignment) => _AssignmentCard(
                    adaptive: adaptive,
                    assignment: assignment,
                    onStart: () => onStartAssignment(assignment),
                    onCompleteStep: assignment.isCompleted
                        ? null
                        : () {
                            SoundService.instance.playTap();
                            onCompleteStep(assignment.id);
                          },
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _AssignmentLimitPill extends StatelessWidget {
  const _AssignmentLimitPill({required this.adaptive});

  final AudyAdaptive adaptive;

  @override
  Widget build(BuildContext context) {
    final controller = AudyScope.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: adaptive.space(12),
        vertical: adaptive.space(8),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E5EA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: adaptive.space(16),
            color: const Color(0xFF60758F),
          ),
          SizedBox(width: adaptive.space(6)),
          Text(
            controller.tr('assignment_limit_reached'),
            style: TextStyle(
              fontSize: adaptive.space(12),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF60758F),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentRecommendationPanel extends StatelessWidget {
  const _AssignmentRecommendationPanel({
    required this.adaptive,
    required this.controller,
    required this.onUseRecommendation,
  });

  final AudyAdaptive adaptive;
  final AudyController controller;
  final void Function(_AssignmentOption option)? onUseRecommendation;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ParentAnalyticsData>(
      future: controller.getParentAnalytics(),
      builder: (context, snapshot) {
        final analytics = snapshot.data;
        final recommendations = analytics == null
            ? const <_AssignmentRecommendation>[]
            : _assignmentRecommendations(context, analytics);

        return AudyPanel(
          adaptive: adaptive,
          padding: EdgeInsets.all(adaptive.space(18)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC9E8C1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFF243A5A),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.tr('assignment_recommendations'),
                          style: TextStyle(
                            fontSize: adaptive.space(18),
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF243A5A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          controller.tr('assignment_recommendations_desc'),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF60758F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: adaptive.space(14)),
              if (snapshot.connectionState == ConnectionState.waiting)
                _RecommendationStatusText(
                  text: controller.tr('assignment_recommendations_loading'),
                )
              else if (recommendations.isEmpty)
                _RecommendationStatusText(
                  text: controller.tr('assignment_recommendations_empty'),
                )
              else
                Column(
                  children: recommendations
                      .map(
                        (recommendation) => _AssignmentRecommendationRow(
                          adaptive: adaptive,
                          recommendation: recommendation,
                          onUse: onUseRecommendation == null
                              ? null
                              : () => onUseRecommendation!(
                                    recommendation.option,
                                  ),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _RecommendationStatusText extends StatelessWidget {
  const _RecommendationStatusText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF60758F),
      ),
    );
  }
}

class _AssignmentRecommendationRow extends StatelessWidget {
  const _AssignmentRecommendationRow({
    required this.adaptive,
    required this.recommendation,
    required this.onUse,
  });

  final AudyAdaptive adaptive;
  final _AssignmentRecommendation recommendation;
  final VoidCallback? onUse;

  @override
  Widget build(BuildContext context) {
    final controller = AudyScope.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: adaptive.space(10)),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: recommendation.option.color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              recommendation.option.icon,
              color: const Color(0xFF243A5A),
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation.option.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF243A5A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  controller.tr(
                    'assignment_accuracy_value',
                    params: {
                      'percent': '${(recommendation.accuracy * 100).round()}',
                    },
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF60758F),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: adaptive.space(8)),
          OutlinedButton(
            onPressed: onUse,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF243A5A),
              minimumSize: Size(adaptive.space(48), adaptive.space(48)),
              side: const BorderSide(color: Color(0xFFBDD8F2), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Text(controller.tr('use')),
          ),
        ],
      ),
    );
  }
}

class _EmptyAssignmentsCard extends StatelessWidget {
  const _EmptyAssignmentsCard({required this.adaptive});

  final AudyAdaptive adaptive;

  @override
  Widget build(BuildContext context) {
    final controller = AudyScope.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(adaptive.space(24)),
      decoration: BoxDecoration(
        color: AudyColors.backgroundCard,
        borderRadius: BorderRadius.circular(adaptive.space(24)),
        border: Border.all(color: AudyColors.borderLight, width: 1),
        boxShadow: AudyShadows.cardShadow,
      ),
      child: Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: adaptive.space(52),
            color: const Color(0xFFBDD8F2),
          ),
          SizedBox(height: adaptive.space(10)),
          Text(
            controller.tr('no_assignments_today'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: adaptive.space(17),
              fontWeight: FontWeight.w800,
              color: const Color(0xFF243A5A),
            ),
          ),
          SizedBox(height: adaptive.space(6)),
          Text(
            controller.tr('create_assignment_hint'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: adaptive.space(13),
              color: const Color(0xFF60758F),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({
    required this.adaptive,
    required this.assignment,
    required this.onStart,
    required this.onCompleteStep,
  });

  final AudyAdaptive adaptive;
  final _DashboardAssignment assignment;
  final VoidCallback onStart;
  final VoidCallback? onCompleteStep;

  @override
  Widget build(BuildContext context) {
    final controller = AudyScope.of(context);
    final isCompleted = assignment.isCompleted;

    return Container(
      padding: EdgeInsets.all(adaptive.space(18)),
      decoration: BoxDecoration(
        color: AudyColors.backgroundCard,
        borderRadius: BorderRadius.circular(adaptive.space(24)),
        border: Border.all(
          color: isCompleted ? const Color(0xFF69E0A0) : assignment.option.color,
          width: 2,
        ),
        boxShadow: AudyShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: assignment.option.color,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  assignment.option.icon,
                  size: 30,
                  color: const Color(0xFF243A5A),
                ),
              ),
              SizedBox(width: adaptive.space(12)),
              Expanded(
                child: Text(
                  assignment.option.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: adaptive.space(17),
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF243A5A),
                  ),
                ),
              ),
              if (isCompleted)
                Icon(
                  Icons.check_circle_rounded,
                  size: adaptive.space(28),
                  color: const Color(0xFF22B860),
                ),
            ],
          ),
          SizedBox(height: adaptive.space(14)),
          Wrap(
            spacing: adaptive.space(8),
            runSpacing: adaptive.space(8),
            children: [
              _AssignmentInfoChip(
                adaptive: adaptive,
                icon: Icons.speed_rounded,
                label: _difficultyLabel(context, assignment.difficulty),
              ),
              _AssignmentInfoChip(
                adaptive: adaptive,
                icon: Icons.repeat_rounded,
                label: '${assignment.currentProgress}/${assignment.targetCount}',
              ),
            ],
          ),
          SizedBox(height: adaptive.space(14)),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: assignment.progressRatio.clamp(0.0, 1.0),
              minHeight: adaptive.space(12),
              backgroundColor: const Color(0xFFE2E5EA),
              valueColor: AlwaysStoppedAnimation(
                isCompleted ? const Color(0xFF22B860) : assignment.option.color,
              ),
            ),
          ),
          SizedBox(height: adaptive.space(16)),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onStart,
                  icon: Icon(Icons.play_arrow_rounded, size: adaptive.space(20)),
                  label: Text(controller.tr('start')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: assignment.option.color,
                    foregroundColor: const Color(0xFF243A5A),
                    minimumSize: Size(adaptive.space(48), adaptive.space(48)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
              SizedBox(width: adaptive.space(10)),
              IconButton.filled(
                onPressed: onCompleteStep,
                icon: Icon(
                  isCompleted
                      ? Icons.check_rounded
                      : Icons.task_alt_rounded,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: isCompleted
                      ? const Color(0xFFC9E8C1)
                      : const Color(0xFFE2E5EA),
                  foregroundColor: const Color(0xFF243A5A),
                  minimumSize: Size(adaptive.space(48), adaptive.space(48)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AssignmentInfoChip extends StatelessWidget {
  const _AssignmentInfoChip({
    required this.adaptive,
    required this.icon,
    required this.label,
  });

  final AudyAdaptive adaptive;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: adaptive.space(10),
        vertical: adaptive.space(8),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: adaptive.space(16), color: const Color(0xFF60758F)),
          SizedBox(width: adaptive.space(6)),
          Text(
            label,
            style: TextStyle(
              fontSize: adaptive.space(12),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF60758F),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddAssignmentDialog extends StatefulWidget {
  const _AddAssignmentDialog({
    required this.adaptive,
    required this.onCreate,
    this.suggestedOption,
  });

  final AudyAdaptive adaptive;
  final _AssignmentOption? suggestedOption;
  final void Function(_AssignmentOption option, String difficulty, int target)
  onCreate;

  @override
  State<_AddAssignmentDialog> createState() => _AddAssignmentDialogState();
}

class _AddAssignmentDialogState extends State<_AddAssignmentDialog> {
  late _AssignmentOption _selectedOption;
  String _selectedDifficulty = 'easy';
  int _targetCount = 1;
  bool _hasSelectedInitialOption = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasSelectedInitialOption) return;

    final options = _assignmentOptions(context);
    _selectedOption = widget.suggestedOption ?? options.first;
    _hasSelectedInitialOption = true;
  }

  @override
  Widget build(BuildContext context) {
    final controller = AudyScope.of(context);
    final options = _assignmentOptions(context);
    const difficultyKeys = ['easy', 'medium', 'hard'];

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(widget.adaptive.space(24)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(widget.adaptive.space(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  controller.tr('create_assignment'),
                  style: TextStyle(
                    fontSize: widget.adaptive.space(22),
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF243A5A),
                  ),
                ),
              ),
              SizedBox(height: widget.adaptive.space(22)),
              _AssignmentDialogLabel(
                adaptive: widget.adaptive,
                label: controller.tr('assignment_feature_label'),
              ),
              SizedBox(height: widget.adaptive.space(10)),
              Wrap(
                spacing: widget.adaptive.space(8),
                runSpacing: widget.adaptive.space(8),
                children: options.map((option) {
                  final isSelected = option.gameType == _selectedOption.gameType;
                  return _AssignmentChoiceChip(
                    adaptive: widget.adaptive,
                    icon: option.icon,
                    label: option.title,
                    isSelected: isSelected,
                    selectedColor: option.color,
                    onTap: () {
                      SoundService.instance.playTap();
                      setState(() => _selectedOption = option);
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: widget.adaptive.space(20)),
              _AssignmentDialogLabel(
                adaptive: widget.adaptive,
                label: controller.tr('difficulty_label'),
              ),
              SizedBox(height: widget.adaptive.space(10)),
              Wrap(
                spacing: widget.adaptive.space(8),
                runSpacing: widget.adaptive.space(8),
                children: difficultyKeys.map((difficulty) {
                  return _AssignmentChoiceChip(
                    adaptive: widget.adaptive,
                    icon: Icons.speed_rounded,
                    label: _difficultyLabel(context, difficulty),
                    isSelected: _selectedDifficulty == difficulty,
                    selectedColor: const Color(0xFFBDD8F2),
                    onTap: () {
                      SoundService.instance.playTap();
                      setState(() => _selectedDifficulty = difficulty);
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: widget.adaptive.space(20)),
              _AssignmentDialogLabel(
                adaptive: widget.adaptive,
                label: controller.tr('assignment_target_label'),
              ),
              SizedBox(height: widget.adaptive.space(12)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _AssignmentCountButton(
                    adaptive: widget.adaptive,
                    icon: Icons.remove_rounded,
                    onPressed: _targetCount > 1
                        ? () {
                            SoundService.instance.playTap();
                            setState(() => _targetCount--);
                          }
                        : null,
                  ),
                  SizedBox(width: widget.adaptive.space(16)),
                  Container(
                    constraints: BoxConstraints(
                      minWidth: widget.adaptive.space(72),
                      minHeight: widget.adaptive.space(48),
                    ),
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.adaptive.space(20),
                      vertical: widget.adaptive.space(10),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_targetCount',
                      style: TextStyle(
                        fontSize: widget.adaptive.space(24),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF243A5A),
                      ),
                    ),
                  ),
                  SizedBox(width: widget.adaptive.space(16)),
                  _AssignmentCountButton(
                    adaptive: widget.adaptive,
                    icon: Icons.add_rounded,
                    onPressed: _targetCount < 3
                        ? () {
                            SoundService.instance.playTap();
                            setState(() => _targetCount++);
                          }
                        : null,
                  ),
                ],
              ),
              SizedBox(height: widget.adaptive.space(24)),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        SoundService.instance.playTap();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE2E5EA),
                        foregroundColor: const Color(0xFF60758F),
                        minimumSize: Size(
                          widget.adaptive.space(48),
                          widget.adaptive.space(48),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(controller.tr('cancel')),
                    ),
                  ),
                  SizedBox(width: widget.adaptive.space(12)),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        SoundService.instance.playTap();
                        widget.onCreate(
                          _selectedOption,
                          _selectedDifficulty,
                          _targetCount,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF8C7DF),
                        foregroundColor: const Color(0xFF243A5A),
                        minimumSize: Size(
                          widget.adaptive.space(48),
                          widget.adaptive.space(48),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(controller.tr('create')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssignmentDialogLabel extends StatelessWidget {
  const _AssignmentDialogLabel({
    required this.adaptive,
    required this.label,
  });

  final AudyAdaptive adaptive;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: adaptive.space(14),
        fontWeight: FontWeight.w700,
        color: const Color(0xFF60758F),
      ),
    );
  }
}

class _AssignmentChoiceChip extends StatelessWidget {
  const _AssignmentChoiceChip({
    required this.adaptive,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  final AudyAdaptive adaptive;
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          constraints: BoxConstraints(minHeight: adaptive.space(48)),
          padding: EdgeInsets.symmetric(
            horizontal: adaptive.space(12),
            vertical: adaptive.space(10),
          ),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF5D6A7E)
                  : const Color(0xFFE2E5EA),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: adaptive.space(18),
                color: const Color(0xFF243A5A),
              ),
              SizedBox(width: adaptive.space(6)),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: adaptive.space(180)),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: adaptive.space(13),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF243A5A),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssignmentCountButton extends StatelessWidget {
  const _AssignmentCountButton({
    required this.adaptive,
    required this.icon,
    required this.onPressed,
  });

  final AudyAdaptive adaptive;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onPressed == null
          ? const Color(0xFFE2E5EA)
          : const Color(0xFFBDD8F2),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: adaptive.space(48),
          height: adaptive.space(48),
          child: Icon(
            icon,
            color: onPressed == null
                ? const Color(0xFFB8BFCA)
                : const Color(0xFF243A5A),
          ),
        ),
      ),
    );
  }
}

String _difficultyLabel(BuildContext context, String difficulty) {
  return AudyScope.of(context).tr(difficulty);
}

class _ActivityData {
  const _ActivityData({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.borderColor,
    required this.route,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final Color borderColor;
  final String route;
}

/// Games played indicator showing progress toward meltdown protection
class _GamesPlayedCard extends StatelessWidget {
  final AudyController controller;
  final AudyAdaptive adaptive;

  const _GamesPlayedCard({required this.controller, required this.adaptive});

  @override
  Widget build(BuildContext context) {
    const int meltdownThreshold = 5;
    final int gamesPlayed = controller.gamesInCurrentSession;
    final double progress = gamesPlayed / meltdownThreshold;
    final bool isNearThreshold = gamesPlayed >= 3;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(adaptive.space(20)),
      decoration: BoxDecoration(
        color: isNearThreshold
            ? const Color(0xFFFFF3E0).withValues(alpha: 0.5)
            : AudyColors.backgroundCard,
        borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
        border: Border.all(
          color: isNearThreshold
              ? const Color(0xFFFFB74D).withValues(alpha: 0.5)
              : AudyColors.skyBlue.withValues(alpha: 0.3),
          width: isNearThreshold ? 2 : 1,
        ),
        boxShadow: AudyShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.games_rounded,
                size: adaptive.space(24),
                color: isNearThreshold
                    ? const Color(0xFFF57C00)
                    : AudyColors.skyBlue,
              ),
              SizedBox(width: adaptive.space(8)),
              Text(
                controller.tr('games_played'),
                style: TextStyle(
                  fontSize: adaptive.space(16),
                  fontWeight: FontWeight.w700,
                  color: AudyColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '$gamesPlayed / $meltdownThreshold',
                style: TextStyle(
                  fontSize: adaptive.space(18),
                  fontWeight: FontWeight.w800,
                  color: isNearThreshold
                      ? const Color(0xFFF57C00)
                      : AudyColors.skyBlue,
                ),
              ),
            ],
          ),
          SizedBox(height: adaptive.space(10)),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () async {
                SoundService.instance.playTap();
                await controller.resetGamesPlayedCheat();
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(controller.tr('reset_count')),
              style: TextButton.styleFrom(
                foregroundColor: AudyColors.textSecondary,
                minimumSize: Size(adaptive.space(48), adaptive.space(48)),
              ),
            ),
          ),
          SizedBox(height: adaptive.space(12)),
          ClipRRect(
            borderRadius: BorderRadius.circular(AudySpacing.radiusSmall),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: AudyColors.borderLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                isNearThreshold ? const Color(0xFFFFB74D) : AudyColors.skyBlue,
              ),
              minHeight: adaptive.space(12),
            ),
          ),
          if (isNearThreshold) ...[
            SizedBox(height: adaptive.space(8)),
            Text(
              gamesPlayed >= 5
                  ? controller.tr('break_time_now')
                  : controller.tr('break_time_soon'),
              style: TextStyle(
                fontSize: adaptive.space(14),
                fontWeight: FontWeight.w600,
                color: const Color(0xFFF57C00),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
