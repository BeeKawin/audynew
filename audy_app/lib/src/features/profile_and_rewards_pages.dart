import 'package:flutter/material.dart';

import '../core/app_routes.dart';
import '../core/audy_theme.dart';
import '../core/audy_ui.dart';
import '../services/sound_service.dart';
import '../state/audy_controller.dart';
import '../widgets/gentle_animations.dart';
import 'parent/parent_child_progress_page.dart';
import 'settings/app_settings_page.dart';
import 'settings/preferences_page.dart';
import 'parent/parent_profile_page.dart';
import 'teacher/teacher_child_progress_page.dart';
import 'teacher/teacher_profile_page.dart';

// Helper function to get localized string
String _tr(BuildContext context, String key, {Map<String, String>? params}) {
  return AudyScope.of(context).tr(key, params: params);
}

String _localizedLevelName(BuildContext context, String levelName) {
  switch (levelName.toLowerCase()) {
    case 'beginner':
      return _tr(context, 'beginner');
    case 'learner':
      return _tr(context, 'learner');
    case 'explorer':
      return _tr(context, 'explorer');
    case 'expert':
      return _tr(context, 'expert');
    case 'master':
      return _tr(context, 'master');
    default:
      return levelName;
  }
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
      if (controller.currentUser?.role == 'child') {
        controller.refreshCloudChildData();
      }
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
    if (controller.currentUser?.role == 'parent') {
      return const ParentChildProgressPage();
    }
    if (controller.currentUser?.role == 'teacher') {
      return const TeacherChildProgressPage();
    }
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
                        _tr(context, 'Manage your rewards'),
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
                  label: _tr(context, 'Progress'),
                  icon: Icons.workspace_premium_outlined,
                  selected: selectedTab == 0,
                  color: const Color(0xFFBDD8F2),
                  onTap: () {
                    SoundService.instance.playTap();
                    setState(() => selectedTab = 0);
                  },
                ),
                _RewardTabChip(
                  label: _tr(context, 'my_rewards'),
                  icon: Icons.card_giftcard_outlined,
                  selected: selectedTab == 1,
                  color: const Color(0xFFF8C7DF),
                  onTap: () {
                    SoundService.instance.playTap();
                    setState(() => selectedTab = 1);
                  },
                ),
                _RewardTabChip(
                  label: _tr(context, 'skins'),
                  icon: Icons.palette_outlined,
                  selected: selectedTab == 2,
                  color: const Color(0xFFE7D8FA),
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
              _RewardsMyRewardsTab(adaptive: adaptive, controller: controller),
            if (selectedTab == 2)
              _RewardsSkinsTab(adaptive: adaptive, controller: controller),
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
                Text(
                  _tr(context, 'level_up'),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF243A5A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _tr(
                    context,
                    'you_are_now',
                    params: {
                      'levelName': _localizedLevelName(
                        context,
                        levelNames[level],
                      ),
                    },
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF60758F),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _tr(context, 'good_job'),
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
                  child: Text(_tr(context, 'awesome')),
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
    if (controller.currentUser?.role == 'parent') {
      return const ParentProfilePage();
    }
    if (controller.currentUser?.role == 'teacher') {
      return const TeacherProfilePage();
    }
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
                      label: _tr(context, 'back_home'),
                      onPressed: () {
                        SoundService.instance.playTap();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  SizedBox(height: adaptive.space(20)),
                  Semantics(
                    button: true,
                    label: _tr(context, 'open_app_controls'),
                    child: Tooltip(
                      message: _tr(context, 'open_app_controls'),
                      child: InkWell(
                        onTap: () {
                          SoundService.instance.playTap();
                          Navigator.pushNamed(context, AppRoutes.remoteControl);
                        },
                        borderRadius: BorderRadius.circular(
                          AudySpacing.radiusLarge,
                        ),
                        child: const SizedBox(
                          width: 144,
                          height: 144,
                          child: Center(child: AudyMascot(size: 120)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: adaptive.space(16)),
                  Text(
                    _tr(context, 'profile'),
                    style: TextStyle(
                      fontSize: adaptive.space(30),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF243A5A),
                    ),
                  ),
                  SizedBox(height: adaptive.space(8)),
                  Text(
                    _tr(context, 'your_learning_journey'),
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
                  label: _tr(context, 'profile'),
                  icon: Icons.person_outline_rounded,
                  selected: selectedTab == 0,
                  color: const Color(0xFFE7D8FA),
                  onTap: () {
                    SoundService.instance.playTap();
                    setState(() => selectedTab = 0);
                  },
                ),
                _RewardTabChip(
                  label: _tr(context, 'settings'),
                  icon: Icons.settings_outlined,
                  selected: selectedTab == 1,
                  color: const Color(0xFFF8C7DF),
                  onTap: () {
                    SoundService.instance.playTap();
                    setState(() => selectedTab = 1);
                  },
                ),
              ],
            ),
            SizedBox(height: adaptive.space(22)),

            // Tab Content
            if (selectedTab == 0)
              _ProfileTabContent(adaptive: adaptive, controller: controller),
            if (selectedTab == 1)
              _SettingsTabContent(adaptive: adaptive, controller: controller),
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
    final profileName = user?.name ?? _tr(context, 'user');
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
                          _tr(
                            context,
                            'age_format',
                            params: {'age': '$profileAge'},
                          ),
                          style: TextStyle(
                            fontSize: adaptive.space(15),
                            color: const Color(0xFF60758F),
                          ),
                        ),
                        Text(
                          _tr(
                            context,
                            'member_since',
                            params: {'date': formattedDate},
                          ),
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
                tabletColumns: 3,
                desktopColumns: 3,
                items: [
                  _StatCard(
                    icon: Icons.star_outline_rounded,
                    value: '${controller.learningPoints}',
                    label: _tr(context, 'points'),
                    color: const Color(0xFFFFF2A8),
                  ),
                  _StatCard(
                    icon: Icons.workspace_premium_outlined,
                    value: '${controller.gamesPlayed}',
                    label: _tr(context, 'games_played'),
                    color: const Color(0xFFBDD8F2),
                  ),
                  _StatCard(
                    icon: Icons.calendar_today_outlined,
                    value: '${controller.dayStreak}',
                    label: _tr(context, 'day_streak'),
                    color: const Color(0xFFF8C7DF),
                  ),
                ],
              ),
            ],
          ),
        ),
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
          _tr(context, 'log_out'),
          style: TextStyle(
            fontSize: adaptive.space(16),
            fontWeight: FontWeight.w800,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AudyColors.error.withValues(alpha: 0.9),
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

class _SettingsTabContent extends StatelessWidget {
  const _SettingsTabContent({required this.adaptive, required this.controller});

  final AudyAdaptive adaptive;
  final AudyController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          minVerticalPadding: 16,
          leading: const Icon(Icons.settings_outlined),
          title: Text(
            controller.currentLanguage == 'th'
                ? 'การตั้งค่าแอป'
                : 'App Settings',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const AppSettingsPage()),
          ),
        ),
        const Divider(height: 32),
        // Preferences Card
        Text(
          _tr(context, 'your_preferences'),
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
              // Communication Level Display
              _buildPreferenceRow(
                _tr(context, 'communication'),
                _getCommunicationLabel(
                  context,
                  controller.userPreferences.communicationLevel,
                ),
                Icons.chat_bubble_outline,
                const Color(0xFFE7D8FA),
              ),
              const Divider(height: 24),
              // Sensory Sensitivity Display
              _buildPreferenceRow(
                _tr(context, 'sensory_sensitivity'),
                _getSensitivityLabel(
                  context,
                  controller.userPreferences.sensorySensitivity,
                ),
                Icons.hearing_outlined,
                const Color(0xFFF8C7DF),
              ),
              const Divider(height: 24),
              // Learning Pace Display
              _buildPreferenceRow(
                _tr(context, 'learning_pace'),
                _getPaceLabel(context, controller.userPreferences.learningPace),
                Icons.timer_outlined,
                const Color(0xFFC9E8C1),
              ),
              const Divider(height: 24),
              // Favorite Interests Display
              _buildInterestsRow(
                context,
                _tr(context, 'favorite_interests'),
                controller.userPreferences.interestsList,
                Icons.favorite_outline,
                const Color(0xFFFFF2A8),
              ),
            ],
          ),
        ),
        SizedBox(height: adaptive.space(24)),
        // Edit Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              SoundService.instance.playTap();
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const PreferencesPage(),
                ),
              );
            },
            icon: Icon(Icons.edit_outlined, size: adaptive.space(24)),
            label: Text(
              _tr(context, 'edit_preferences'),
              style: TextStyle(
                fontSize: adaptive.space(16),
                fontWeight: FontWeight.w800,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBDD8F2),
              foregroundColor: const Color(0xFF243A5A),
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
        ),
      ],
    );
  }

  String _getCommunicationLabel(BuildContext context, int level) {
    const labels = [
      'non_verbal',
      'single_words',
      'short_phrases',
      'full_sentences',
    ];
    return _tr(context, labels[level.clamp(0, 3)]);
  }

  String _getSensitivityLabel(BuildContext context, int level) {
    const labels = ['low', 'medium', 'high'];
    return _tr(context, labels[level.clamp(0, 2)]);
  }

  String _getPaceLabel(BuildContext context, int level) {
    const labels = ['slower', 'standard', 'faster'];
    return _tr(context, labels[level.clamp(0, 2)]);
  }

  Widget _buildPreferenceRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: adaptive.space(44),
          height: adaptive.space(44),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: adaptive.space(22),
            color: const Color(0xFF243A5A),
          ),
        ),
        SizedBox(width: adaptive.space(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: adaptive.space(14),
                  color: const Color(0xFF60758F),
                ),
              ),
              SizedBox(height: adaptive.space(2)),
              Text(
                value,
                style: TextStyle(
                  fontSize: adaptive.space(16),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF243A5A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInterestsRow(
    BuildContext context,
    String label,
    List<String> interests,
    IconData icon,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: adaptive.space(44),
          height: adaptive.space(44),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: adaptive.space(22),
            color: const Color(0xFF243A5A),
          ),
        ),
        SizedBox(width: adaptive.space(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: adaptive.space(14),
                  color: const Color(0xFF60758F),
                ),
              ),
              SizedBox(height: adaptive.space(4)),
              if (interests.isEmpty)
                Text(
                  _tr(context, 'none_selected'),
                  style: TextStyle(
                    fontSize: adaptive.space(14),
                    color: const Color(0xFF60758F).withValues(alpha: 0.6),
                  ),
                )
              else
                Wrap(
                  spacing: adaptive.space(6),
                  runSpacing: adaptive.space(6),
                  children: interests.map((interest) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: adaptive.space(10),
                        vertical: adaptive.space(4),
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _tr(context, interest),
                        style: TextStyle(
                          fontSize: adaptive.space(12),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF243A5A),
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ],
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
                _tr(context, 'learning_points'),
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
            _tr(context, 'your_learning_journey'),
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
                        _localizedLevelName(context, levelName),
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
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: widget.adaptive.space(12),
            runSpacing: widget.adaptive.space(8),
            children: [
              Text(
                _tr(
                  context,
                  'points_count',
                  params: {'points': '$points / $levelMax'},
                ),
                style: TextStyle(
                  fontSize: widget.adaptive.space(16),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF243A5A),
                ),
              ),
              if (currentLevel < levels.length - 1)
                Text(
                  _tr(
                    context,
                    'points_to_next_level',
                    params: {'points': '$pointsToNext'},
                  ),
                  style: TextStyle(
                    fontSize: widget.adaptive.space(14),
                    color: const Color(0xFF60758F),
                  ),
                )
              else
                Text(
                  _tr(context, 'max_level_exclamation'),
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

class _RewardsMyRewardsTab extends StatelessWidget {
  const _RewardsMyRewardsTab({
    required this.adaptive,
    required this.controller,
  });

  final AudyAdaptive adaptive;
  final AudyController controller;

  @override
  Widget build(BuildContext context) {
    final activeRewards = controller.activeRewards;
    final completedRewards = controller.completedRewards;
    final claimedRewards = controller.claimedRewards;

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            _tr(context, 'my_rewards'),
            style: TextStyle(
              fontSize: adaptive.space(22),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(height: adaptive.space(18)),

        // Active Rewards Section
        if (activeRewards.isNotEmpty) ...[
          _buildRewardSection(
            context,
            title: _tr(context, 'active_rewards'),
            rewards: activeRewards,
            isClaimable: false,
          ),
          SizedBox(height: adaptive.space(16)),
        ],

        // Completed Rewards Section
        if (completedRewards.isNotEmpty) ...[
          _buildRewardSection(
            context,
            title: _tr(context, 'completed_rewards'),
            rewards: completedRewards,
            isClaimable: true,
          ),
          SizedBox(height: adaptive.space(16)),
        ],

        // Claimed Rewards Section
        if (claimedRewards.isNotEmpty) ...[
          _buildRewardSection(
            context,
            title: _tr(context, 'claimed_rewards'),
            rewards: claimedRewards,
            isClaimable: false,
            isClaimed: true,
          ),
        ],

        // Empty State
        if (activeRewards.isEmpty &&
            completedRewards.isEmpty &&
            claimedRewards.isEmpty)
          _buildEmptyState(context),
      ],
    );
  }

  Widget _buildRewardSection(
    BuildContext context, {
    required String title,
    required List<UserReward> rewards,
    required bool isClaimable,
    bool isClaimed = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: adaptive.space(16),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF60758F),
          ),
        ),
        SizedBox(height: adaptive.space(12)),
        AudyAdaptiveGrid(
          adaptive: adaptive,
          phoneColumns: 1,
          tabletColumns: 2,
          desktopColumns: 2,
          items: rewards
              .map(
                (reward) => _RewardCard(
                  reward: reward,
                  adaptive: adaptive,
                  isClaimable: isClaimable,
                  isClaimed: isClaimed,
                  onClaim: () => controller.claimReward(reward),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(adaptive.space(32)),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(adaptive.space(24)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.card_giftcard_outlined,
            size: adaptive.space(64),
            color: const Color(0xFFBDD8F2),
          ),
          SizedBox(height: adaptive.space(16)),
          Text(
            _tr(context, 'no_rewards_yet'),
            style: TextStyle(
              fontSize: adaptive.space(18),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF243A5A),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: adaptive.space(8)),
          Text(
            _tr(context, 'caregiver_reward_hint'),
            style: TextStyle(
              fontSize: adaptive.space(14),
              color: const Color(0xFF60758F),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RewardsSkinsTab extends StatelessWidget {
  const _RewardsSkinsTab({required this.adaptive, required this.controller});

  final AudyAdaptive adaptive;
  final AudyController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AudyPanel(
          adaptive: adaptive,
          child: Row(
            children: [
              Container(
                width: adaptive.space(56),
                height: adaptive.space(56),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF2A8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.stars_rounded,
                  size: adaptive.space(30),
                  color: const Color(0xFFF5C532),
                ),
              ),
              SizedBox(width: adaptive.space(14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _tr(context, 'available_points'),
                      style: TextStyle(
                        fontSize: adaptive.space(14),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF60758F),
                      ),
                    ),
                    SizedBox(height: adaptive.space(4)),
                    Text(
                      '${controller.availableLearningPoints}',
                      style: TextStyle(
                        fontSize: adaptive.space(28),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF243A5A),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: adaptive.space(12),
                  vertical: adaptive.space(8),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7D8FA),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _tr(
                    context,
                    'skin_price',
                    params: {'points': '${AudyController.skinPrice}'},
                  ),
                  style: TextStyle(
                    fontSize: adaptive.space(13),
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF243A5A),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: adaptive.space(18)),
        Text(
          _tr(context, 'skins'),
          style: TextStyle(
            fontSize: adaptive.space(22),
            fontWeight: FontWeight.w800,
            color: const Color(0xFF243A5A),
          ),
        ),
        SizedBox(height: adaptive.space(12)),
        AudyAdaptiveGrid(
          adaptive: adaptive,
          phoneColumns: 1,
          tabletColumns: 2,
          desktopColumns: 3,
          items: AudyController.skinVariants.map((variant) {
            return _SkinVariantCard(
              variant: variant,
              adaptive: adaptive,
              isOwned: controller.isSkinOwned(variant.id),
              isSelected: controller.selectedSkinId == variant.id,
              canBuy: controller.availableLearningPoints >= variant.price,
              onSelect: () async {
                SoundService.instance.playTap();
                await controller.selectSkin(variant.id);
              },
              onBuy: () async {
                SoundService.instance.playTap();
                final didBuy = await controller.buySkin(variant.id);
                if (!didBuy && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_tr(context, 'need_points'))),
                  );
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SkinVariantCard extends StatelessWidget {
  const _SkinVariantCard({
    required this.variant,
    required this.adaptive,
    required this.isOwned,
    required this.isSelected,
    required this.canBuy,
    required this.onSelect,
    required this.onBuy,
  });

  final SkinVariant variant;
  final AudyAdaptive adaptive;
  final bool isOwned;
  final bool isSelected;
  final bool canBuy;
  final Future<void> Function() onSelect;
  final Future<void> Function() onBuy;

  @override
  Widget build(BuildContext context) {
    final accent = _skinColor(variant.id);
    final actionLabel = isSelected
        ? _tr(context, 'selected')
        : isOwned
        ? _tr(context, 'select')
        : canBuy
        ? _tr(context, 'buy_skin')
        : _tr(context, 'need_points');
    final actionIcon = isSelected
        ? Icons.check_circle_rounded
        : isOwned
        ? Icons.touch_app_rounded
        : canBuy
        ? Icons.shopping_bag_outlined
        : Icons.lock_outline_rounded;

    return Container(
      padding: EdgeInsets.all(adaptive.space(18)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(adaptive.space(22)),
        border: Border.all(
          color: isSelected ? accent : const Color(0xFFE2E5EA),
          width: isSelected ? 3 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: isSelected ? 0.22 : 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SkinPreview(
            adaptive: adaptive,
            variantId: variant.id,
            accent: accent,
          ),
          SizedBox(height: adaptive.space(14)),
          Row(
            children: [
              Container(
                width: adaptive.space(38),
                height: adaptive.space(38),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${variant.id}',
                  style: TextStyle(
                    fontSize: adaptive.space(15),
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF243A5A),
                  ),
                ),
              ),
              SizedBox(width: adaptive.space(10)),
              Expanded(
                child: Text(
                  variant.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: adaptive.space(16),
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF243A5A),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: adaptive.space(12)),
          Text(
            variant.price == 0
                ? _tr(context, 'free_skin')
                : _tr(
                    context,
                    'skin_cost',
                    params: {'points': '${variant.price}'},
                  ),
            style: TextStyle(
              fontSize: adaptive.space(14),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF60758F),
            ),
          ),
          SizedBox(height: adaptive.space(14)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isSelected
                  ? null
                  : isOwned
                  ? onSelect
                  : canBuy
                  ? onBuy
                  : null,
              icon: Icon(actionIcon, size: adaptive.space(20)),
              label: Text(
                actionLabel,
                style: TextStyle(
                  fontSize: adaptive.space(14),
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isOwned ? const Color(0xFFC9E8C1) : accent,
                foregroundColor: const Color(0xFF243A5A),
                disabledBackgroundColor: isSelected
                    ? const Color(0xFFC9E8C1)
                    : const Color(0xFFE2E5EA),
                disabledForegroundColor: isSelected
                    ? const Color(0xFF243A5A)
                    : const Color(0xFF60758F),
                minimumSize: const Size(48, 52),
                padding: EdgeInsets.symmetric(
                  horizontal: adaptive.space(12),
                  vertical: adaptive.space(12),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _skinColor(int id) {
    const colors = [
      Color(0xFFBDD8F2),
      Color(0xFFFFB3B3),
      Color(0xFFC9E8C1),
      Color(0xFF9FC5F8),
      Color(0xFFFFF2A8),
      Color(0xFFA8F0F2),
      Color(0xFFF8C7DF),
      Color(0xFFF5F7FA),
      Color(0xFFFFCBA8),
      Color(0xFFB6E3D4),
      Color(0xFFB7C8F6),
      Color(0xFFF8E39B),
      Color(0xFFAEEAE4),
      Color(0xFFE6C4F5),
      Color(0xFFE5EAF0),
      Color(0xFFD4E4FF),
      Color(0xFFD6F0C2),
      Color(0xFFE9EEF5),
      Color(0xFFE7D8FA),
      Color(0xFFCFD7E2),
    ];
    return colors[id % colors.length];
  }
}

class _SkinPreview extends StatelessWidget {
  const _SkinPreview({
    required this.adaptive,
    required this.variantId,
    required this.accent,
  });

  final AudyAdaptive adaptive;
  final int variantId;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: adaptive.space(98),
      width: double.infinity,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(adaptive.space(18)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: adaptive.space(62),
            height: adaptive.space(62),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: accent, width: 3),
            ),
            child: Icon(
              Icons.smart_toy_outlined,
              size: adaptive.space(34),
              color: const Color(0xFF243A5A),
            ),
          ),
          Positioned(
            left: adaptive.space(18),
            child: _PreviewDot(color: accent, size: adaptive.space(18)),
          ),
          Positioned(
            right: adaptive.space(18),
            child: _PreviewDot(
              color: _secondaryColor(variantId),
              size: adaptive.space(18),
            ),
          ),
          Positioned(
            bottom: adaptive.space(14),
            child: _PreviewDot(
              color: _tummyColor(variantId),
              size: adaptive.space(24),
            ),
          ),
        ],
      ),
    );
  }

  Color _secondaryColor(int id) {
    const colors = [
      Color(0xFFFFFFFF),
      Color(0xFFA8F0F2),
      Color(0xFFF8C7DF),
      Color(0xFFFFF2A8),
      Color(0xFF9FC5F8),
      Color(0xFFFFB3B3),
      Color(0xFFC9E8C1),
      Color(0xFFE2E5EA),
      Color(0xFFC9E8C1),
      Color(0xFF9FC5F8),
    ];
    return colors[id % colors.length];
  }

  Color _tummyColor(int id) {
    const colors = [
      Color(0xFFFFFFFF),
      Color(0xFFA8F0F2),
      Color(0xFFF8C7DF),
      Color(0xFFFFF2A8),
      Color(0xFF9FC5F8),
      Color(0xFFFFB3B3),
      Color(0xFFC9E8C1),
      Color(0xFFE2E5EA),
      Color(0xFFFFF2A8),
      Color(0xFF9FC5F8),
    ];
    return colors[id % colors.length];
  }
}

class _PreviewDot extends StatelessWidget {
  const _PreviewDot({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF243A5A), width: 1.5),
      ),
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

class _RewardCard extends StatelessWidget {
  const _RewardCard({
    required this.reward,
    required this.adaptive,
    required this.isClaimable,
    this.isClaimed = false,
    this.onClaim,
  });

  final UserReward reward;
  final AudyAdaptive adaptive;
  final bool isClaimable;
  final bool isClaimed;
  final VoidCallback? onClaim;

  @override
  Widget build(BuildContext context) {
    final progress = reward.progressRatio.clamp(0.0, 1.0);
    final isCompleted = reward.isCompleted;

    return AudyPanel(
      adaptive: adaptive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  reward.prize,
                  style: TextStyle(
                    fontSize: adaptive.space(18),
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF243A5A),
                  ),
                ),
              ),
              if (isClaimed)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: adaptive.space(8),
                    vertical: adaptive.space(4),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC9E8C1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: adaptive.space(14),
                        color: const Color(0xFF22B860),
                      ),
                      SizedBox(width: adaptive.space(4)),
                      Text(
                        _tr(context, 'claimed'),
                        style: TextStyle(
                          fontSize: adaptive.space(12),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF22B860),
                        ),
                      ),
                    ],
                  ),
                )
              else if (isCompleted)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: adaptive.space(8),
                    vertical: adaptive.space(4),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF2A8),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        size: adaptive.space(14),
                        color: const Color(0xFFF5C532),
                      ),
                      SizedBox(width: adaptive.space(4)),
                      Text(
                        _tr(context, 'completed'),
                        style: TextStyle(
                          fontSize: adaptive.space(12),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF243A5A),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: adaptive.space(12)),
          Row(
            children: [
              Icon(
                _getConditionIcon(reward.condition),
                size: adaptive.space(20),
                color: const Color(0xFF60758F),
              ),
              SizedBox(width: adaptive.space(8)),
              Text(
                _getConditionLabel(context, reward.condition),
                style: TextStyle(
                  fontSize: adaptive.space(14),
                  color: const Color(0xFF60758F),
                ),
              ),
            ],
          ),
          SizedBox(height: adaptive.space(12)),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: adaptive.space(12),
              backgroundColor: const Color(0xFFE2E5EA),
              valueColor: AlwaysStoppedAnimation(
                isCompleted ? const Color(0xFF22B860) : const Color(0xFFBDD8F2),
              ),
            ),
          ),
          SizedBox(height: adaptive.space(8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${reward.currentProgress}/${reward.targetCount}',
                style: TextStyle(
                  fontSize: adaptive.space(14),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF243A5A),
                ),
              ),
              if (isClaimable && onClaim != null)
                ElevatedButton(
                  onPressed: () {
                    SoundService.instance.playTap();
                    onClaim!();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC9E8C1),
                    foregroundColor: const Color(0xFF243A5A),
                    padding: EdgeInsets.symmetric(
                      horizontal: adaptive.space(16),
                      vertical: adaptive.space(8),
                    ),
                    minimumSize: const Size(48, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Text(
                    _tr(context, 'claim'),
                    style: TextStyle(fontSize: adaptive.space(12)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getConditionIcon(RewardCondition condition) {
    switch (condition) {
      case RewardCondition.emotionClassify:
        return Icons.sentiment_satisfied_rounded;
      case RewardCondition.emotionMimic:
        return Icons.face_rounded;
      case RewardCondition.miniPuzzle:
        return Icons.extension_rounded;
      case RewardCondition.sortingGame:
        return Icons.category_rounded;
      case RewardCondition.reactionTime:
        return Icons.flash_on_rounded;
      case RewardCondition.reading:
        return Icons.menu_book_rounded;
      case RewardCondition.socialChat:
        return Icons.chat_bubble_rounded;
    }
  }

  String _getConditionLabel(BuildContext context, RewardCondition condition) {
    final labels = {
      RewardCondition.emotionClassify: _tr(context, 'emotion_classify'),
      RewardCondition.emotionMimic: _tr(context, 'emotion_mimic'),
      RewardCondition.miniPuzzle: _tr(context, 'mini_puzzle'),
      RewardCondition.sortingGame: _tr(context, 'sorting_game'),
      RewardCondition.reactionTime: _tr(context, 'reaction_time'),
      RewardCondition.reading: _tr(context, 'reading'),
      RewardCondition.socialChat: _tr(context, 'social_chat'),
    };
    return labels[condition] ?? '';
  }
}
