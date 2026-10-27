import 'package:flutter/material.dart';

import '../../core/audy_theme.dart';
import '../../data/models/child_progress_snapshot.dart';
import '../../core/audy_ui.dart';
import '../../services/auth_service.dart';
import '../dashboard_analytics.dart';

class ParentChildAnalytics extends StatefulWidget {
  const ParentChildAnalytics({
    super.key,
    required this.child,
    required this.adaptive,
    this.snapshot,
  });

  final ChildProgressSnapshot? snapshot;
  final UserProfile child;
  final AudyAdaptive adaptive;

  @override
  State<ParentChildAnalytics> createState() => _ParentChildAnalyticsState();
}

class _ParentChildAnalyticsState extends State<ParentChildAnalytics> {
  final _authService = AuthService();
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _sessions = const [];
  List<Map<String, dynamic>> _assignments = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant ParentChildAnalytics oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child.id != widget.child.id ||
        oldWidget.snapshot != widget.snapshot) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final snapshot = widget.snapshot;
    if (snapshot != null) {
      setState(() {
        _stats = snapshot.stats;
        _sessions = snapshot.sessions;
        _assignments = snapshot.assignments;
        _isLoading = false;
      });
      return;
    }
    final results = await Future.wait<dynamic>([
      _authService.fetchStudentStats(widget.child.id),
      _authService.fetchStudentSessions(widget.child.id),
      _authService.fetchAssignments(widget.child.id),
    ]);
    if (!mounted) return;
    setState(() {
      _stats = results[0] as Map<String, dynamic>?;
      _sessions = results[1] as List<Map<String, dynamic>>;
      _assignments = results[2] as List<Map<String, dynamic>>;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: CircularProgressIndicator(color: AudyColors.skyBlue),
        ),
      );
    }

    final learningPoints = _stats?['learning_points'] as int? ?? 0;
    final gamesPlayed = _stats?['games_played'] as int? ?? 0;
    final dayStreak = _stats?['day_streak'] as int? ?? 0;
    final lastPlayed = _parseLastPlayed(_stats?['last_played_at']);

    return AudyPanel(
      adaptive: widget.adaptive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AudyColors.blushPink.withValues(alpha: 0.2),
                child: const Icon(
                  Icons.child_care_rounded,
                  color: AudyColors.blushPink,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.child.name,
                      style: AudyTypography.headingSmall.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Age: ${widget.child.age}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AudyColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: widget.adaptive.space(20)),
          const Divider(color: AudyColors.borderLight),
          SizedBox(height: widget.adaptive.space(12)),
          Row(
            children: [
              _StatItem(
                label: 'Learning Points',
                value: '$learningPoints',
                icon: Icons.auto_awesome_rounded,
                color: AudyColors.activityRewards,
              ),
              _StatItem(
                label: 'Games Played',
                value: '$gamesPlayed',
                icon: Icons.sports_esports_rounded,
                color: AudyColors.skyBlue,
              ),
              _StatItem(
                label: 'Day Streak',
                value: '$dayStreak days',
                icon: Icons.local_fire_department_rounded,
                color: Colors.orange,
              ),
            ],
          ),
          SizedBox(height: widget.adaptive.space(20)),
          const Divider(color: AudyColors.borderLight),
          SizedBox(height: widget.adaptive.space(16)),
          StudentAnalyticsCharts(
            sessions: _sessions,
            assignments: _assignments,
          ),
          SizedBox(height: widget.adaptive.space(16)),
          Row(
            children: [
              const Icon(
                Icons.watch_later_outlined,
                size: 18,
                color: AudyColors.textLight,
              ),
              const SizedBox(width: 6),
              Text(
                'Last active: $lastPlayed',
                style: const TextStyle(
                  fontSize: 13,
                  color: AudyColors.textLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _parseLastPlayed(dynamic value) {
    if (value is! String) return 'Never';
    final parsed = DateTime.tryParse(value)?.toLocal();
    if (parsed == null) return 'Never';
    return '${parsed.day}/${parsed.month}/${parsed.year}';
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AudyColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AudyColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
