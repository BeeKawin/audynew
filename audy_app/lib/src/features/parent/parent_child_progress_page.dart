import 'package:flutter/material.dart';

import '../../core/app_routes.dart';
import '../../data/models/child_progress_snapshot.dart';
import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../data/models/parent_portal_model.dart';
import '../../services/auth_service.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';
import '../../widgets/add_reward_dialog.dart';
import 'child_profile_selector.dart';

class ParentChildProgressPage extends StatefulWidget {
  const ParentChildProgressPage({super.key, this.forTeacher = false});

  final bool forTeacher;

  @override
  State<ParentChildProgressPage> createState() =>
      _ParentChildProgressPageState();
}

class _ParentChildProgressPageState extends State<ParentChildProgressPage> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = AudyScope.of(context);
      if (widget.forTeacher) {
        controller.loadTeacherStudents(force: true);
      } else {
        controller.loadParentChildren();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = AudyScope.of(context);
    final profiles = widget.forTeacher
        ? controller.teacherStudents
        : controller.parentChildren;
    final selectedProfileId = widget.forTeacher
        ? controller.selectedTeacherStudentId
        : controller.selectedParentChildId;
    final child = widget.forTeacher
        ? controller.selectedTeacherStudent
        : controller.selectedParentChild;
    final isLoading = widget.forTeacher
        ? controller.isLoadingTeacherStudents
        : controller.isLoadingParentChildren;
    final errorMessage = widget.forTeacher
        ? controller.teacherStudentsError
        : controller.parentChildrenError;

    return AudyResponsivePage(
      builder: (context, adaptive) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AudyBackButton(
              label: controller.tr('back_home'),
              onPressed: () {
                SoundService.instance.playTap();
                Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
              },
            ),
            SizedBox(height: adaptive.space(24)),
            Text(
              controller.tr('child_progress'),
              style: TextStyle(
                fontSize: adaptive.space(30),
                fontWeight: FontWeight.w800,
                color: AudyColors.textPrimary,
              ),
            ),
            SizedBox(height: adaptive.space(8)),
            Text(
              controller.tr('child_progress_description'),
              style: TextStyle(
                fontSize: adaptive.space(16),
                color: AudyColors.textLight,
              ),
            ),
            SizedBox(height: adaptive.space(24)),
            Wrap(
              spacing: adaptive.space(12),
              runSpacing: adaptive.space(12),
              children: [
                ProgressTabButton(
                  label: controller.tr('Progress'),
                  icon: Icons.query_stats_rounded,
                  selected: _selectedTab == 0,
                  color: const Color(0xFFBDD8F2),
                  onTap: () => _selectTab(0),
                ),
                ProgressTabButton(
                  label: controller.tr('add_rewards'),
                  icon: Icons.card_giftcard_outlined,
                  selected: _selectedTab == 1,
                  color: const Color(0xFFF8C7DF),
                  onTap: () => _selectTab(1),
                ),
              ],
            ),
            SizedBox(height: adaptive.space(20)),
            ChildProfileSelector(
              children: profiles,
              selectedChildId: selectedProfileId,
              isLoading: isLoading,
              errorMessage: errorMessage,
              label: widget.forTeacher
                  ? 'Selected student'
                  : controller.tr('selected_child'),
              emptyMessage: widget.forTeacher
                  ? 'No linked student accounts yet.'
                  : controller.tr('no_linked_children'),
              onRetry: () {
                if (widget.forTeacher) {
                  controller.loadTeacherStudents(force: true);
                } else {
                  controller.loadParentChildren(force: true);
                }
              },
              onSelected: widget.forTeacher
                  ? controller.selectTeacherStudent
                  : controller.selectParentChild,
            ),
            SizedBox(height: adaptive.space(22)),
            if (child != null && _selectedTab == 0)
              ChildLevelProgress(
                key: ValueKey('progress-${child.id}'),
                child: child,
                adaptive: adaptive,
              )
            else if (child != null && _selectedTab == 1)
              _ChildRewardsTab(
                key: ValueKey('rewards-${child.id}'),
                child: child,
                adaptive: adaptive,
              ),
          ],
        );
      },
    );
  }

  void _selectTab(int tab) {
    SoundService.instance.playTap();
    setState(() => _selectedTab = tab);
  }
}

class ChildLevelProgress extends StatefulWidget {
  const ChildLevelProgress({
    super.key,
    required this.child,
    required this.adaptive,
    this.snapshot,
  });

  final ChildProgressSnapshot? snapshot;
  final UserProfile child;
  final AudyAdaptive adaptive;

  @override
  State<ChildLevelProgress> createState() => ChildLevelProgressState();
}

class ChildLevelProgressState extends State<ChildLevelProgress> {
  final _authService = AuthService();
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final stats =
        widget.snapshot?.stats ??
        (widget.snapshot == null
            ? await _authService.fetchStudentStats(widget.child.id)
            : null);
    if (!mounted) return;
    setState(() {
      _stats = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const _LoadingPanel();

    final points = _stats?['learning_points'] as int? ?? 0;
    final gamesPlayed = _stats?['games_played'] as int? ?? 0;
    final streak = _stats?['day_streak'] as int? ?? 0;
    final level = _levelFor(points);
    final levelProgress =
        ((points - level.minimum) / (level.maximum - level.minimum)).clamp(
          0.0,
          1.0,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AudyPanel(
          adaptive: widget.adaptive,
          child: Column(
            children: [
              Text(
                '${widget.child.name}\'s learning journey',
                style: TextStyle(
                  fontSize: widget.adaptive.space(22),
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: widget.adaptive.space(20)),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: level.color,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  level.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AudyColors.textPrimary,
                  ),
                ),
              ),
              SizedBox(height: widget.adaptive.space(20)),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: levelProgress,
                  minHeight: 20,
                  backgroundColor: AudyColors.borderLight,
                  valueColor: AlwaysStoppedAnimation(level.color),
                ),
              ),
              SizedBox(height: widget.adaptive.space(10)),
              Text(
                '$points / ${level.maximum} learning points',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AudyColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: widget.adaptive.space(18)),
        Flex(
          direction: widget.adaptive.isPhone ? Axis.vertical : Axis.horizontal,
          children: [
            _ProgressMetric(
              icon: Icons.auto_awesome_rounded,
              value: '$points',
              label: 'Points',
              color: const Color(0xFFFFF2A8),
              adaptive: widget.adaptive,
            ),
            SizedBox(
              width: widget.adaptive.space(12),
              height: widget.adaptive.space(12),
            ),
            _ProgressMetric(
              icon: Icons.sports_esports_outlined,
              value: '$gamesPlayed',
              label: 'Games',
              color: const Color(0xFFBDD8F2),
              adaptive: widget.adaptive,
            ),
            SizedBox(
              width: widget.adaptive.space(12),
              height: widget.adaptive.space(12),
            ),
            _ProgressMetric(
              icon: Icons.local_fire_department_outlined,
              value: '$streak',
              label: 'Day streak',
              color: const Color(0xFFF8C7DF),
              adaptive: widget.adaptive,
            ),
          ],
        ),
      ],
    );
  }

  _LevelInfo _levelFor(int points) {
    if (points >= 1000) {
      return const _LevelInfo('Master', 1000, 2000, Color(0xFFC9E8C1));
    }
    if (points >= 500) {
      return const _LevelInfo('Expert', 500, 1000, Color(0xFFFFF2A8));
    }
    if (points >= 250) {
      return const _LevelInfo('Explorer', 250, 500, Color(0xFFE7D8FA));
    }
    if (points >= 100) {
      return const _LevelInfo('Learner', 100, 250, Color(0xFFBDD8F2));
    }
    return const _LevelInfo('Beginner', 0, 100, Color(0xFFC9E8C1));
  }
}

class _ChildRewardsTab extends StatefulWidget {
  const _ChildRewardsTab({
    super.key,
    required this.child,
    required this.adaptive,
  });

  final UserProfile child;
  final AudyAdaptive adaptive;

  @override
  State<_ChildRewardsTab> createState() => _ChildRewardsTabState();
}

class _ChildRewardsTabState extends State<_ChildRewardsTab> {
  final _authService = AuthService();
  List<ChildRewardData> _rewards = const [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rewards = await _authService.fetchChildRewards(widget.child.id);
    if (!mounted) return;
    setState(() {
      _rewards = rewards;
      _isLoading = false;
    });
  }

  Future<void> _addReward() async {
    final draft = await showDialog<RewardDraft>(
      context: context,
      builder: (context) => AddRewardDialog(adaptive: widget.adaptive),
    );
    if (draft == null || !mounted) return;

    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      final reward = await _authService.createChildReward(
        childId: widget.child.id,
        prize: draft.prize,
        conditionType: draft.condition.name,
        targetCount: draft.targetCount,
      );
      if (!mounted) return;
      setState(() => _rewards = [..._rewards, reward]);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteReward(ChildRewardData reward) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove reward?'),
          content: Text('Remove “${reward.prize}” from this child?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AudyColors.error,
                foregroundColor: AudyColors.textOnColor,
              ),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    try {
      await _authService.deleteChildReward(reward.id);
      if (!mounted) return;
      setState(() {
        _rewards = _rewards.where((item) => item.id != reward.id).toList();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const _LoadingPanel();

    final currentUserId = AudyScope.of(context).currentUser?.id;
    final activeCount = _rewards.where((reward) => !reward.isCompleted).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Rewards for ${widget.child.name}',
                style: TextStyle(
                  fontSize: widget.adaptive.space(22),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: activeCount >= 3 || _isSaving ? null : _addReward,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_rounded),
              label: const Text('Add Reward'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(48, 48),
                backgroundColor: const Color(0xFFF8C7DF),
                foregroundColor: AudyColors.textPrimary,
              ),
            ),
          ],
        ),
        if (activeCount >= 3) ...[
          SizedBox(height: widget.adaptive.space(8)),
          const Text(
            'Complete or remove an active reward before adding another.',
            style: TextStyle(color: AudyColors.textLight),
          ),
        ],
        if (_error != null) ...[
          SizedBox(height: widget.adaptive.space(12)),
          _MessagePanel(message: _error!, isError: true),
        ],
        SizedBox(height: widget.adaptive.space(18)),
        if (_rewards.isEmpty)
          AudyPanel(
            adaptive: widget.adaptive,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Icon(
                    Icons.card_giftcard_outlined,
                    size: 52,
                    color: AudyColors.skyBlue,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No rewards yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          )
        else
          ..._rewards.map(
            (reward) => Padding(
              padding: EdgeInsets.only(bottom: widget.adaptive.space(12)),
              child: _ChildRewardCard(
                reward: reward,
                adaptive: widget.adaptive,
                onDelete: reward.createdBy == currentUserId
                    ? () => _deleteReward(reward)
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}

class _ChildRewardCard extends StatelessWidget {
  const _ChildRewardCard({
    required this.reward,
    required this.adaptive,
    this.onDelete,
  });
  final ChildRewardData reward;
  final AudyAdaptive adaptive;
  final VoidCallback? onDelete;
  @override
  Widget build(BuildContext context) => AudyPanel(
    adaptive: adaptive,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.card_giftcard_outlined, color: AudyColors.skyBlue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                reward.prize,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (onDelete != null)
              IconButton(
                onPressed: onDelete,
                tooltip: 'Remove reward',
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                icon: const Icon(Icons.delete_outline),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '${reward.conditionType} · ${reward.currentProgress} / ${reward.targetCount}',
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: reward.progressRatio, minHeight: 12),
        const SizedBox(height: 8),
        Text(
          reward.isClaimed
              ? 'Claimed'
              : reward.isCompleted
              ? 'Completed'
              : 'In progress',
        ),
      ],
    ),
  );
}

class _ProgressMetric extends StatelessWidget {
  const _ProgressMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.adaptive,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final AudyAdaptive adaptive;

  @override
  Widget build(BuildContext context) {
    final panel = AudyPanel(
      adaptive: adaptive,
      child: Column(
        children: [
          Icon(icon, size: 30, color: AudyColors.textPrimary),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AudyColors.textLight),
          ),
        ],
      ),
    );
    return adaptive.isPhone
        ? SizedBox(width: double.infinity, child: panel)
        : Expanded(child: panel);
  }
}

class ProgressTabButton extends StatelessWidget {
  const ProgressTabButton({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color : Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AudyColors.textPrimary : AudyColors.borderLight,
              width: selected ? 2 : 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelInfo {
  const _LevelInfo(this.name, this.minimum, this.maximum, this.color);

  final String name;
  final int minimum;
  final int maximum;
  final Color color;
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Center(
        child: CircularProgressIndicator(color: AudyColors.skyBlue),
      ),
    );
  }
}

class _MessagePanel extends StatelessWidget {
  const _MessagePanel({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? AudyColors.error : AudyColors.success;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
      ),
      child: Text(
        message,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
