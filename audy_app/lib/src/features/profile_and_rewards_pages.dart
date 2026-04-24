import 'package:flutter/material.dart';

import '../core/app_routes.dart';
import '../core/audy_theme.dart';
import '../core/audy_ui.dart';
import '../services/sound_service.dart';
import '../state/audy_controller.dart';
import '../widgets/gentle_animations.dart';

// Helper function to get localized string
String _tr(BuildContext context, String key, {Map<String, String>? params}) {
  return AudyScope.of(context).tr(key, params: params);
}

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  int selectedTab = 0;
  bool _showLevelUpAnimation = false;
  int _newLevel = 0;

  @override
  void initState() {
    super.initState();
    // Set up level up callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = AudyScope.of(context);
      controller.onLevelUp = (newLevel) {
        setState(() {
          _newLevel = newLevel;
          _showLevelUpAnimation = true;
        });
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = AudyScope.of(context);
    return AudyResponsivePage(
      builder: (context, adaptive) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AudyBackButton(
                        label: _tr(context, 'back_home'),
                        onPressed: () {
                          SoundService.instance.playTap();
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(height: adaptive.space(28)),
                      Text(
                        _tr(context, 'your_rewards'),
                        style: TextStyle(
                          fontSize: adaptive.space(30),
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF243A5A),
                        ),
                      ),
                      SizedBox(height: adaptive.space(8)),
                      Text(
                        _tr(context, 'collect_accessories'),
                        style: TextStyle(
                          fontSize: adaptive.space(16),
                          color: const Color(0xFF60758F),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!adaptive.isPhone) const AudyMascot(size: 112),
              ],
            ),
            SizedBox(height: adaptive.space(24)),
            _PointsBanner(
              adaptive: adaptive,
              points: controller.learningPoints,
            ),
            SizedBox(height: adaptive.space(18)),
            Wrap(
              spacing: adaptive.space(12),
              runSpacing: adaptive.space(12),
              children: [
                _RewardTabChip(
                  label: _tr(context, 'progress'),
                  icon: Icons.workspace_premium_outlined,
                  selected: selectedTab == 0,
                  color: const Color(0xFFBDD8F2),
                  onTap: () {
                    SoundService.instance.playTap();
                    setState(() => selectedTab = 0);
                  },
                ),
                _RewardTabChip(
                  label: _tr(context, 'accessories'),
                  icon: Icons.checkroom_outlined,
                  selected: selectedTab == 1,
                  color: const Color(0xFFF8C7DF),
                  onTap: () {
                    SoundService.instance.playTap();
                    setState(() => selectedTab = 1);
                  },
                ),
                _RewardTabChip(
                  label: _tr(context, 'achievements'),
                  icon: Icons.auto_awesome_outlined,
                  selected: selectedTab == 2,
                  color: const Color(0xFFC9E8C1),
                  onTap: () {
                    SoundService.instance.playTap();
                    setState(() => selectedTab = 2);
                  },
                ),
              ],
            ),
            SizedBox(height: adaptive.space(22)),
            if (selectedTab == 0)
              _RewardsProgressTab(adaptive: adaptive, controller: controller),
            if (selectedTab == 1)
              _RewardsAccessoriesTab(
                adaptive: adaptive,
                controller: controller,
              ),
            if (selectedTab == 2)
              _RewardsAchievementsTab(
                adaptive: adaptive,
                controller: controller,
              ),
            // Level up animation overlay
            if (_showLevelUpAnimation)
              Center(
                child: StarBurstAnimation(
                  onComplete: () {
                    setState(() => _showLevelUpAnimation = false);
                    _showLevelUpDialog(context, _newLevel);
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  void _showLevelUpDialog(BuildContext context, int level) {
    final levelNames = ['Beginner', 'Learner', 'Explorer', 'Expert', 'Master'];
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GentleFade(
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.workspace_premium_rounded,
                  size: 64,
                  color: Color(0xFFF5C532),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Level Up!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF243A5A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You reached ${levelNames[level]}!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF60758F),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Keep up the great work!',
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(0xFF60758F).withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    SoundService.instance.playTap();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBDD8F2),
                    foregroundColor: const Color(0xFF243A5A),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    minimumSize: const Size(48, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text('Awesome!'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final controller = AudyScope.of(context);
    return AudyResponsivePage(
      builder: (context, adaptive) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AudyBackButton(
                      label: 'Back to Home',
                      onPressed: () {
                        SoundService.instance.playTap();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  SizedBox(height: adaptive.space(20)),
                  const AudyMascot(size: 120),
                  SizedBox(height: adaptive.space(16)),
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: adaptive.space(30),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF243A5A),
                    ),
                  ),
                  SizedBox(height: adaptive.space(8)),
                  Text(
                    'Your learning journey',
                    style: TextStyle(
                      fontSize: adaptive.space(16),
                      color: const Color(0xFF60758F),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: adaptive.space(24)),

            // Tab Chips
            Wrap(
              spacing: adaptive.space(12),
              runSpacing: adaptive.space(12),
              children: [
                _RewardTabChip(
                  label: 'Profile',
                  icon: Icons.person_outline_rounded,
                  selected: selectedTab == 0,
                  color: const Color(0xFFE7D8FA),
                  onTap: () {
                    SoundService.instance.playTap();
                    setState(() => selectedTab = 0);
                  },
                ),
                _RewardTabChip(
                  label: 'Parent Dashboard',
                  icon: Icons.family_restroom_outlined,
                  selected: selectedTab == 1,
                  color: const Color(0xFFBDD8F2),
                  onTap: () {
                    SoundService.instance.playTap();
                    setState(() => selectedTab = 1);
                  },
                ),
                _RewardTabChip(
                  label: 'Institution Panel',
                  icon: Icons.school_outlined,
                  selected: selectedTab == 2,
                  color: const Color(0xFFC9E8C1),
                  onTap: () {
                    SoundService.instance.playTap();
                    setState(() => selectedTab = 2);
                  },
                ),
              ],
            ),
            SizedBox(height: adaptive.space(22)),

            // Tab Content
            if (selectedTab == 0)
              _ProfileTabContent(adaptive: adaptive, controller: controller),
            if (selectedTab == 1)
              _ParentDashboardTab(adaptive: adaptive, controller: controller),
            if (selectedTab == 2)
              _InstitutionPanelTab(adaptive: adaptive, controller: controller),
          ],
        );
      },
    );
  }
}

class _ProfileTabContent extends StatelessWidget {
  const _ProfileTabContent({required this.adaptive, required this.controller});

  final AudyAdaptive adaptive;
  final AudyController controller;

  @override
  Widget build(BuildContext context) {
    final user = controller.currentUser;
    final profileName = user?.name ?? 'User';
    final profileAge = user?.age ?? 10;
    final joinedDate = user?.createdAt ?? DateTime.now();
    final formattedDate =
        '${_getMonthName(joinedDate.month)} ${joinedDate.day}, ${joinedDate.year}';

    return Column(
      children: [
        AudyPanel(
          adaptive: adaptive,
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: adaptive.isPhone ? 34 : 44,
                    backgroundColor: const Color(0xFFE7D8FA),
                    child: Icon(
                      Icons.person_outline_rounded,
                      size: adaptive.space(32),
                      color: const Color(0xFF3D4E68),
                    ),
                  ),
                  SizedBox(width: adaptive.space(16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profileName,
                          style: TextStyle(
                            fontSize: adaptive.space(24),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: adaptive.space(6)),
                        Text(
                          'Age: $profileAge',
                          style: TextStyle(
                            fontSize: adaptive.space(15),
                            color: const Color(0xFF60758F),
                          ),
                        ),
                        Text(
                          'Member since $formattedDate',
                          style: TextStyle(
                            fontSize: adaptive.space(15),
                            color: const Color(0xFF60758F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: adaptive.space(20)),
              AudyAdaptiveGrid(
                adaptive: adaptive,
                phoneColumns: 2,
                tabletColumns: 4,
                desktopColumns: 4,
                items: [
                  _StatCard(
                    icon: Icons.star_outline_rounded,
                    value: '${controller.learningPoints}',
                    label: 'Points',
                    color: const Color(0xFFFFF2A8),
                  ),
                  _StatCard(
                    icon: Icons.workspace_premium_outlined,
                    value: '${controller.gamesPlayed}',
                    label: 'Games Played',
                    color: const Color(0xFFBDD8F2),
                  ),
                  _StatCard(
                    icon: Icons.bar_chart_rounded,
                    value: '${controller.unlockedAchievementCount}',
                    label: 'Achievements',
                    color: const Color(0xFFC9E8C1),
                  ),
                  _StatCard(
                    icon: Icons.calendar_today_outlined,
                    value: '${controller.dayStreak}',
                    label: 'Day Streak',
                    color: const Color(0xFFF8C7DF),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: adaptive.space(20)),
        _RequestSummaryCard(controller: controller),
        SizedBox(height: adaptive.space(20)),
        _buildLogoutButton(context, adaptive),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  Widget _buildLogoutButton(BuildContext context, AudyAdaptive adaptive) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          SoundService.instance.playTap();
          controller.logout();
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        },
        icon: const Icon(Icons.logout_rounded, size: 24),
        label: Text(
          'Log Out',
          style: TextStyle(
            fontSize: adaptive.space(16),
            fontWeight: FontWeight.w800,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AudyColors.error.withOpacity(0.9),
          foregroundColor: AudyColors.textOnColor,
          padding: EdgeInsets.symmetric(
            horizontal: adaptive.space(24),
            vertical: adaptive.space(16),
          ),
          minimumSize: const Size(48, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          elevation: 4,
        ),
      ),
    );
  }
}

class _ParentDashboardTab extends StatelessWidget {
  const _ParentDashboardTab({required this.adaptive, required this.controller});

  final AudyAdaptive adaptive;
  final AudyController controller;

  @override
  Widget build(BuildContext context) {
    final report = controller.weeklyReport;
    final skills = controller.skillPercentages.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress Tracking Section
        Text(
          'Progress Tracking',
          style: TextStyle(
            fontSize: adaptive.space(20),
            fontWeight: FontWeight.w800,
            color: const Color(0xFF243A5A),
          ),
        ),
        SizedBox(height: adaptive.space(16)),
        AudyAdaptiveGrid(
          adaptive: adaptive,
          phoneColumns: 1,
          tabletColumns: 2,
          desktopColumns: 2,
          items: [
            _ChartCard(
              title: 'Emotion Recognition Progress',
              values: controller.emotionProgressHistory,
              color: const Color(0xFFF7BCD8),
            ),
            _ChartCard(
              title: 'MiniPuzzle Progress',
              values: controller.puzzleProgressHistory,
              color: const Color(0xFFBDD8F2),
            ),
          ],
        ),
        SizedBox(height: adaptive.space(24)),

        // Skill Analytics Section
        Text(
          'Skill Analytics',
          style: TextStyle(
            fontSize: adaptive.space(20),
            fontWeight: FontWeight.w800,
            color: const Color(0xFF243A5A),
          ),
        ),
        SizedBox(height: adaptive.space(16)),
        AudyPanel(
          adaptive: adaptive,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...skills.map((skill) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        skill.key,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: skill.value,
                          minHeight: 12,
                          backgroundColor: const Color(0xFFE2E5EA),
                          valueColor: const AlwaysStoppedAnimation(
                            Color(0xFFD8C8F5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(skill.value * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF60758F),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        SizedBox(height: adaptive.space(24)),

        // Weekly Report Section
        Text(
          'Weekly Report',
          style: TextStyle(
            fontSize: adaptive.space(20),
            fontWeight: FontWeight.w800,
            color: const Color(0xFF243A5A),
          ),
        ),
        SizedBox(height: adaptive.space(16)),
        AudyPanel(
          adaptive: adaptive,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${report.weekStart.day}/${report.weekStart.month} - ${report.weekEnd.day}/${report.weekEnd.month}/${report.weekEnd.year}',
                style: TextStyle(
                  fontSize: adaptive.space(14),
                  color: const Color(0xFF60758F),
                ),
              ),
              SizedBox(height: adaptive.space(16)),
              AudyAdaptiveGrid(
                adaptive: adaptive,
                phoneColumns: 2,
                tabletColumns: 4,
                desktopColumns: 4,
                items: [
                  _StatCard(
                    icon: Icons.sports_esports_outlined,
                    value: '${report.gamesPlayed}',
                    label: 'Games Played',
                    color: const Color(0xFFBDD8F2),
                  ),
                  _StatCard(
                    icon: Icons.star_outline_rounded,
                    value: '${report.pointsEarned}',
                    label: 'Points Earned',
                    color: const Color(0xFFFFF2A8),
                  ),
                  _StatCard(
                    icon: Icons.local_fire_department_outlined,
                    value: '${report.currentStreak}',
                    label: 'Day Streak',
                    color: const Color(0xFFF8C7DF),
                  ),
                  _StatCard(
                    icon: Icons.emoji_events_outlined,
                    value: '${report.achievementsUnlocked}',
                    label: 'Achievements',
                    color: const Color(0xFFC9E8C1),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InstitutionPanelTab extends StatelessWidget {
  const _InstitutionPanelTab({
    required this.adaptive,
    required this.controller,
  });

  final AudyAdaptive adaptive;
  final AudyController controller;

  @override
  Widget build(BuildContext context) {
    final child = controller.currentChildProfile;
    final group = controller.groupPerformance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Manage Kids Section
        Text(
          'Manage Kids',
          style: TextStyle(
            fontSize: adaptive.space(20),
            fontWeight: FontWeight.w800,
            color: const Color(0xFF243A5A),
          ),
        ),
        SizedBox(height: adaptive.space(16)),
        AudyPanel(
          adaptive: adaptive,
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: adaptive.isPhone ? 30 : 40,
                    backgroundColor: const Color(0xFFE7D8FA),
                    child: Icon(
                      Icons.child_care_outlined,
                      size: adaptive.space(28),
                      color: const Color(0xFF3D4E68),
                    ),
                  ),
                  SizedBox(width: adaptive.space(16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.name,
                          style: TextStyle(
                            fontSize: adaptive.space(20),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: adaptive.space(4)),
                        Text(
                          'Age: ${child.age}',
                          style: TextStyle(
                            fontSize: adaptive.space(14),
                            color: const Color(0xFF60758F),
                          ),
                        ),
                        Text(
                          'Joined: ${child.joinedDate.day}/${child.joinedDate.month}/${child.joinedDate.year}',
                          style: TextStyle(
                            fontSize: adaptive.space(14),
                            color: const Color(0xFF60758F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: adaptive.space(16)),
              AudyAdaptiveGrid(
                adaptive: adaptive,
                phoneColumns: 2,
                tabletColumns: 4,
                desktopColumns: 4,
                items: [
                  _StatCard(
                    icon: Icons.sports_esports_outlined,
                    value: '${child.gamesPlayed}',
                    label: 'Games',
                    color: const Color(0xFFBDD8F2),
                  ),
                  _StatCard(
                    icon: Icons.star_outline_rounded,
                    value: '${child.learningPoints}',
                    label: 'Points',
                    color: const Color(0xFFFFF2A8),
                  ),
                  _StatCard(
                    icon: Icons.local_fire_department_outlined,
                    value: '${child.dayStreak}',
                    label: 'Streak',
                    color: const Color(0xFFF8C7DF),
                  ),
                  _StatCard(
                    icon: Icons.emoji_events_outlined,
                    value: '${child.achievementsUnlocked}',
                    label: 'Achievements',
                    color: const Color(0xFFC9E8C1),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: adaptive.space(24)),

        // Group Performance Section
        Text(
          'Group Performance Overview',
          style: TextStyle(
            fontSize: adaptive.space(20),
            fontWeight: FontWeight.w800,
            color: const Color(0xFF243A5A),
          ),
        ),
        SizedBox(height: adaptive.space(16)),
        AudyPanel(
          adaptive: adaptive,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Group Statistics',
                style: TextStyle(
                  fontSize: adaptive.space(16),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF243A5A),
                ),
              ),
              SizedBox(height: adaptive.space(12)),
              _InstitutionStatRow(
                label: 'Total Children',
                value: '${group.totalChildren}',
              ),
              _InstitutionStatRow(
                label: 'Avg Games per Child',
                value: group.averageGamesPerChild.toStringAsFixed(1),
              ),
              _InstitutionStatRow(
                label: 'Avg Points per Child',
                value: group.averagePointsPerChild.toStringAsFixed(0),
              ),
              _InstitutionStatRow(
                label: 'Avg Streak',
                value: group.averageStreak.toStringAsFixed(1),
              ),
              SizedBox(height: adaptive.space(16)),
              Text(
                'Average Skill Progress',
                style: TextStyle(
                  fontSize: adaptive.space(16),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF243A5A),
                ),
              ),
              SizedBox(height: adaptive.space(12)),
              ...group.averageSkillProgress.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          entry.key,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: entry.value,
                            minHeight: 8,
                            backgroundColor: const Color(0xFFE2E5EA),
                            valueColor: const AlwaysStoppedAnimation(
                              Color(0xFFC9E8C1),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(entry.value * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF60758F),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        SizedBox(height: adaptive.space(24)),

        // Export Report Section
        Text(
          'Export Report',
          style: TextStyle(
            fontSize: adaptive.space(20),
            fontWeight: FontWeight.w800,
            color: const Color(0xFF243A5A),
          ),
        ),
        SizedBox(height: adaptive.space(16)),
        AudyPanel(
          adaptive: adaptive,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Generate and export progress reports for documentation and sharing with parents or therapists.',
                style: TextStyle(
                  fontSize: adaptive.space(14),
                  color: const Color(0xFF60758F),
                ),
              ),
              SizedBox(height: adaptive.space(16)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    SoundService.instance.playTap();
                    _showExportDialog(context);
                  },
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Export Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC9E8C1),
                    foregroundColor: const Color(0xFF243A5A),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    minimumSize: const Size(48, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                size: 64,
                color: Color(0xFF22B860),
              ),
              const SizedBox(height: 16),
              const Text(
                'Report Exported!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF243A5A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The report has been generated and saved to your device.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: const Color(0xFF60758F)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  SoundService.instance.playTap();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC9E8C1),
                  foregroundColor: const Color(0xFF243A5A),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  minimumSize: const Size(48, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Text('Great!'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstitutionStatRow extends StatelessWidget {
  const _InstitutionStatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF60758F)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF243A5A),
            ),
          ),
        ],
      ),
    );
  }
}

class _PointsBanner extends StatelessWidget {
  const _PointsBanner({required this.adaptive, required this.points});

  final AudyAdaptive adaptive;
  final int points;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: adaptive.space(22),
        vertical: adaptive.space(24),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE7D8FA),
        borderRadius: BorderRadius.circular(adaptive.space(28)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA5A6D8).withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_rounded,
            size: adaptive.space(44),
            color: const Color(0xFFF5C532),
          ),
          SizedBox(width: adaptive.space(12)),
          Column(
            children: [
              Text(
                '$points',
                style: TextStyle(
                  fontSize: adaptive.space(42),
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF243A5A),
                ),
              ),
              Text(
                'Learning Points',
                style: TextStyle(
                  fontSize: adaptive.space(16),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF243A5A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RewardTabChip extends StatelessWidget {
  const _RewardTabChip({
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
          border: selected
              ? Border.all(color: const Color(0xFF5D6A7E), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFA5B4C7).withValues(alpha: 0.16),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: const Color(0xFF243A5A)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF243A5A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardsProgressTab extends StatefulWidget {
  const _RewardsProgressTab({required this.adaptive, required this.controller});

  final AudyAdaptive adaptive;
  final AudyController controller;

  @override
  State<_RewardsProgressTab> createState() => _RewardsProgressTabState();
}

class _RewardsProgressTabState extends State<_RewardsProgressTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _popController;
  late Animation<double> _scaleAnimation;
  int _displayedLevel = -1;

  @override
  void initState() {
    super.initState();
    _popController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _popController, curve: Curves.elasticOut),
    );

    // Listen for level changes
    widget.controller.addListener(_onLevelChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onLevelChanged);
    _popController.dispose();
    super.dispose();
  }

  void _onLevelChanged() {
    final currentLevel = widget.controller.currentLevel;
    if (currentLevel != _displayedLevel && _displayedLevel != -1) {
      // Level up detected - trigger pop animation
      _popController.forward().then((_) => _popController.reverse());
    }
    _displayedLevel = currentLevel;
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.controller.learningPoints;
    final currentLevel = widget.controller.currentLevel;

    // Define level thresholds and info
    final levels = [
      ('Beginner', 0, 100, const Color(0xFFC9E8C1)),
      ('Learner', 100, 250, const Color(0xFFBDD8F2)),
      ('Explorer', 250, 500, const Color(0xFFE7D8FA)),
      ('Expert', 500, 1000, const Color(0xFFFFF2A8)),
      ('Master', 1000, 2000, const Color(0xFFC9E8C1)),
    ];

    final currentLevelInfo = levels[currentLevel.clamp(0, levels.length - 1)];
    final levelName = currentLevelInfo.$1;
    final levelMin = currentLevelInfo.$2;
    final levelMax = currentLevelInfo.$3;
    final levelColor = currentLevelInfo.$4;

    // Calculate progress within current level
    final progressInLevel = points <= levelMin
        ? 0.0
        : (points - levelMin) / (levelMax - levelMin);
    final clampedProgress = progressInLevel.clamp(0.0, 1.0);

    // Points needed for next level
    final pointsToNext = levelMax - points;

    return AudyPanel(
      adaptive: widget.adaptive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title
          Text(
            'Your Learning Journey',
            style: TextStyle(
              fontSize: widget.adaptive.space(22),
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: widget.adaptive.space(28)),

          // Current Level Badge with Pop Animation
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.adaptive.space(24),
                    vertical: widget.adaptive.space(16),
                  ),
                  decoration: BoxDecoration(
                    color: levelColor,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: levelColor.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.workspace_premium_rounded,
                        size: widget.adaptive.space(28),
                        color: const Color(0xFF243A5A),
                      ),
                      SizedBox(width: widget.adaptive.space(12)),
                      Text(
                        levelName,
                        style: TextStyle(
                          fontSize: widget.adaptive.space(20),
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF243A5A),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          SizedBox(height: widget.adaptive.space(32)),

          // Single Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: clampedProgress),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: widget.adaptive.space(24),
                  backgroundColor: const Color(0xFFE2E5EA),
                  valueColor: AlwaysStoppedAnimation(levelColor),
                );
              },
            ),
          ),

          SizedBox(height: widget.adaptive.space(16)),

          // Progress Text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$points / $levelMax points',
                style: TextStyle(
                  fontSize: widget.adaptive.space(16),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF243A5A),
                ),
              ),
              if (currentLevel < levels.length - 1)
                Text(
                  '$pointsToNext to next level',
                  style: TextStyle(
                    fontSize: widget.adaptive.space(14),
                    color: const Color(0xFF60758F),
                  ),
                )
              else
                Text(
                  'Max Level!',
                  style: TextStyle(
                    fontSize: widget.adaptive.space(14),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF22B860),
                  ),
                ),
            ],
          ),

          SizedBox(height: widget.adaptive.space(24)),

          // Level indicators (dots)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: levels.asMap().entries.map((entry) {
              final index = entry.key;
              final isActive = index <= currentLevel;
              final isCurrent = index == currentLevel;

              return Container(
                width: isCurrent
                    ? widget.adaptive.space(16)
                    : widget.adaptive.space(10),
                height: isCurrent
                    ? widget.adaptive.space(16)
                    : widget.adaptive.space(10),
                margin: EdgeInsets.symmetric(
                  horizontal: widget.adaptive.space(4),
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? entry.value.$4 : const Color(0xFFE2E5EA),
                  border: isCurrent
                      ? Border.all(color: const Color(0xFF243A5A), width: 2)
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _RewardsAccessoriesTab extends StatelessWidget {
  const _RewardsAccessoriesTab({
    required this.adaptive,
    required this.controller,
  });

  final AudyAdaptive adaptive;
  final AudyController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            'Your Collection',
            style: TextStyle(
              fontSize: adaptive.space(22),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(height: adaptive.space(18)),
        AudyAdaptiveGrid(
          adaptive: adaptive,
          phoneColumns: 2,
          tabletColumns: 3,
          desktopColumns: 5,
          items: controller.accessories.map((item) {
            return InkWell(
              onTap: item.owned
                  ? null
                  : () {
                      SoundService.instance.playTap();
                      controller.unlockAccessory(item.name);
                    },
              borderRadius: BorderRadius.circular(adaptive.space(28)),
              child: AudyPanel(
                adaptive: adaptive,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon,
                      size: adaptive.space(42),
                      color: const Color(0xFF5D4F97),
                    ),
                    SizedBox(height: adaptive.space(12)),
                    Text(
                      item.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: adaptive.space(16),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: adaptive.space(10)),
                    if (item.owned)
                      Text(
                        'Owned',
                        style: TextStyle(
                          fontSize: adaptive.space(14),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF22B860),
                        ),
                      ),
                    if (!item.owned)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: adaptive.space(12),
                          vertical: adaptive.space(8),
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF2A8),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${item.cost}',
                              style: TextStyle(
                                fontSize: adaptive.space(14),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(width: adaptive.space(4)),
                            Icon(
                              Icons.star_rounded,
                              size: adaptive.space(16),
                              color: const Color(0xFFF5C532),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _RewardsAchievementsTab extends StatelessWidget {
  const _RewardsAchievementsTab({
    required this.adaptive,
    required this.controller,
  });

  final AudyAdaptive adaptive;
  final AudyController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            'Your Achievements',
            style: TextStyle(
              fontSize: adaptive.space(22),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(height: adaptive.space(18)),
        AudyAdaptiveGrid(
          adaptive: adaptive,
          phoneColumns: 1,
          tabletColumns: 2,
          desktopColumns: 2,
          items: controller.achievements.map((item) {
            final locked = !item.unlocked;
            return Container(
              padding: EdgeInsets.all(adaptive.space(20)),
              decoration: BoxDecoration(
                color: locked
                    ? Colors.white.withValues(alpha: 0.55)
                    : Colors.white,
                borderRadius: BorderRadius.circular(adaptive.space(22)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9FAFC4).withValues(alpha: 0.14),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    locked
                        ? Icons.lock_outline_rounded
                        : Icons.auto_awesome_rounded,
                    size: adaptive.space(36),
                    color: locked
                        ? const Color(0xFFB8BFCA)
                        : const Color(0xFFF59A23),
                  ),
                  SizedBox(width: adaptive.space(16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: adaptive.space(18),
                            fontWeight: FontWeight.w800,
                            color: locked
                                ? const Color(0xFF6D7887)
                                : const Color(0xFF243A5A),
                          ),
                        ),
                        SizedBox(height: adaptive.space(6)),
                        Text(
                          item.description,
                          style: TextStyle(
                            fontSize: adaptive.space(14),
                            color: const Color(0xFF728198),
                          ),
                        ),
                        SizedBox(height: adaptive.space(6)),
                        Text(
                          locked ? 'Locked' : 'Unlocked',
                          style: TextStyle(
                            fontSize: adaptive.space(13),
                            fontWeight: FontWeight.w700,
                            color: locked
                                ? const Color(0xFFB8BFCA)
                                : const Color(0xFF22B860),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: const Color(0xFF243A5A)),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFF243A5A)),
          ),
        ],
      ),
    );
  }
}

class _RequestSummaryCard extends StatelessWidget {
  const _RequestSummaryCard({required this.controller});

  final AudyController controller;

  @override
  Widget build(BuildContext context) {
    final adaptive = AudyAdaptive(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
    );
    final latest = controller.preparedRequests.isEmpty
        ? null
        : controller.preparedRequests.first;

    return AudyPanel(
      adaptive: adaptive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Placeholder',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Text(
            'Placeholder',
            style: const TextStyle(fontSize: 15, color: Color(0xFF60758F)),
          ),
          const SizedBox(height: 8),
          Text(
            latest == null ? 'Placeholder' : 'Placeholder',
            style: const TextStyle(fontSize: 15, color: Color(0xFF60758F)),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.values,
    required this.color,
  });

  final String title;
  final List<double> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final adaptive = AudyAdaptive(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
    );

    return AudyPanel(
      adaptive: adaptive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 180,
            child: CustomPaint(
              painter: _LineChartPainter(values: values, color: color),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  const _LineChartPainter({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE5EAF0)
      ..strokeWidth = 1;

    for (var i = 0; i < 4; i++) {
      final y = (size.height / 3) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final path = Path();
    final dotPaint = Paint()..color = color;
    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < values.length; i++) {
      final x = i * (size.width / (values.length - 1));
      final y = size.height - (size.height * values[i]);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }

    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.color != color;
  }
}
