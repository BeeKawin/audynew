import 'package:flutter/material.dart';

import '../core/app_routes.dart';
import '../core/audy_theme.dart';
import '../core/audy_ui.dart';
import '../data/models/progress_model.dart';
import '../services/sound_service.dart';
import '../state/audy_controller.dart';
import '../widgets/gentle_animations.dart';

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

String _localizedFeatureTitle(BuildContext context, String gameType, String title) {
  switch (gameType) {
    case 'emotion_classify':
      return _tr(context, 'emotion_classify');
    case 'emotion_mimic':
      return _tr(context, 'emotion_mimic');
    case 'minipuzzle':
      return _tr(context, 'mini_puzzle');
    case 'sorting':
      return _tr(context, 'sorting_game');
    case 'reaction_time':
      return _tr(context, 'reaction_time');
    case 'flashcard':
      return _tr(context, 'flashcard_game');
    case 'fruit_catching_bear':
      return _tr(context, 'fruit_catching_bear');
    case 'reading':
      return _tr(context, 'read_speak');
    case 'social_chat':
      return _tr(context, 'social_chat');
    default:
      return title;
  }
}

const double _institutionHarderDifficultyThreshold = 0.75;

class _DifficultyRecommendation {
  const _DifficultyRecommendation({
    required this.gameType,
    required this.title,
    required this.score,
  });

  final String gameType;
  final String title;
  final double score;
}

List<_DifficultyRecommendation> _skillDifficultyRecommendations(
  Map<String, double> skillProgress,
) {
  final recommendations = skillProgress.entries
      .where((entry) => entry.value >= _institutionHarderDifficultyThreshold)
      .map(
        (entry) => _DifficultyRecommendation(
          gameType: _gameTypeForSkill(entry.key),
          title: entry.key,
          score: entry.value,
        ),
      )
      .toList();

  recommendations.sort((a, b) => b.score.compareTo(a.score));
  return recommendations.take(3).toList();
}

String _gameTypeForSkill(String skill) {
  switch (skill.toLowerCase()) {
    case 'emotions':
      return 'emotion_classify';
    case 'minipuzzle':
      return 'minipuzzle';
    case 'sorting':
      return 'sorting';
    case 'reaction':
      return 'reaction_time';
    case 'reading':
      return 'reading';
    case 'social':
      return 'social_chat';
    default:
      return skill;
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
                _RewardTabChip(
                  label: _tr(context, 'achievements'),
                  icon: Icons.auto_awesome_outlined,
                  selected: selectedTab == 3,
                  color: const Color(0xFFC9E8C1),
                  onTap: () {
                    SoundService.instance.playTap();
                    setState(() => selectedTab = 3);
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
            if (selectedTab == 3)
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
<<<<<<< HEAD
                  Semantics(
                    button: true,
                    label: _tr(context, 'open_app_controls'),
                    child: Tooltip(
                      message: _tr(context, 'open_app_controls'),
                      child: InkWell(
                        onTap: () {
                          SoundService.instance.playTap();
                          Navigator.pushNamed(
                            context,
                            AppRoutes.remoteControl,
                          );
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
=======
                  const AudyMascot(size: 120),
>>>>>>> origin/Kongnew
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
                  label: _tr(context, 'parent_dashboard'),
                  icon: Icons.family_restroom_outlined,
                  selected: selectedTab == 1,
                  color: const Color(0xFFBDD8F2),
                  onTap: () {
                    SoundService.instance.playTap();
                    setState(() => selectedTab = 1);
                  },
                ),
                _RewardTabChip(
                  label: _tr(context, 'institution_panel'),
                  icon: Icons.school_outlined,
                  selected: selectedTab == 2,
                  color: const Color(0xFFC9E8C1),
                  onTap: () {
                    SoundService.instance.playTap();
                    setState(() => selectedTab = 2);
                  },
                ),
                _RewardTabChip(
                  label: _tr(context, 'settings'),
                  icon: Icons.settings_outlined,
                  selected: selectedTab == 3,
                  color: const Color(0xFFF8C7DF),
                  onTap: () {
                    SoundService.instance.playTap();
                    setState(() => selectedTab = 3);
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
            if (selectedTab == 3)
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
                tabletColumns: 4,
                desktopColumns: 4,
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
                    icon: Icons.bar_chart_rounded,
                    value: '${controller.unlockedAchievementCount}',
                    label: _tr(context, 'achievements'),
                    color: const Color(0xFFC9E8C1),
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

class _ParentDashboardTab extends StatelessWidget {
  const _ParentDashboardTab({required this.adaptive, required this.controller});

  final AudyAdaptive adaptive;
  final AudyController controller;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ParentAnalyticsData>(
      future: controller.getParentAnalytics(),
      builder: (context, snapshot) {
        final analytics = snapshot.data ?? _emptyAnalytics();
        final latest = analytics.latestSession;
        final difficultyRecommendations =
            _skillDifficultyRecommendations(controller.skillPercentages);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _tr(context, 'learning_analytics'),
              style: TextStyle(
                fontSize: adaptive.space(20),
                fontWeight: FontWeight.w800,
                color: const Color(0xFF243A5A),
              ),
            ),
            SizedBox(height: adaptive.space(6)),
            Text(
              '${_formatDate(analytics.rangeStart)} - '
              '${_formatDate(analytics.rangeEnd)}',
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
                  value: '${analytics.totalSessions}',
                  label: _tr(context, 'seven_day_sessions'),
                  color: const Color(0xFFBDD8F2),
                ),
                _StatCard(
                  icon: Icons.timer_outlined,
                  value: '${analytics.totalMinutes}',
                  label: _tr(context, 'seven_day_minutes'),
                  color: const Color(0xFFFFF2A8),
                ),
                _StatCard(
                  icon: Icons.query_stats_rounded,
                  value: analytics.averageScoredAccuracy == null
                      ? '--'
                      : _formatPercent(analytics.averageScoredAccuracy!),
                  label: _tr(context, 'scored_average'),
                  color: const Color(0xFFC9E8C1),
                ),
                _StatCard(
                  icon: Icons.history_rounded,
                  value: latest == null
                      ? '--'
                      : _localizedFeatureTitle(
                          context,
                          latest.gameType,
                          latest.title,
                        ),
                  label: _tr(context, 'latest_activity'),
                  color: const Color(0xFFF8C7DF),
                ),
              ],
            ),
            SizedBox(height: adaptive.space(24)),
            _DifficultyInstructionCard(
              adaptive: adaptive,
              description: _tr(context, 'difficulty_instruction_parent_desc'),
              recommendations: difficultyRecommendations,
            ),
            SizedBox(height: adaptive.space(24)),
            _ChartCard(
              title: _tr(context, 'daily_activity'),
              subtitle: _tr(context, 'daily_activity_desc'),
              values: analytics.dailyActivityValues,
              color: const Color(0xFFBDD8F2),
            ),
            SizedBox(height: adaptive.space(24)),
            Text(
              _tr(context, 'learning_features'),
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
              desktopColumns: 3,
              items: analytics.features
                  .map(
                    (feature) => _FeatureAnalyticsCard(
                      adaptive: adaptive,
                      feature: feature,
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: adaptive.space(24)),
            Text(
              _tr(context, 'recent_sessions'),
              style: TextStyle(
                fontSize: adaptive.space(20),
                fontWeight: FontWeight.w800,
                color: const Color(0xFF243A5A),
              ),
            ),
            SizedBox(height: adaptive.space(16)),
            AudyPanel(
              adaptive: adaptive,
              child: analytics.recentSessions.isEmpty
                  ? _EmptyDashboardState(adaptive: adaptive)
                  : Column(
                      children: analytics.recentSessions
                          .map(
                            (session) => _RecentSessionRow(
                              adaptive: adaptive,
                              session: session,
                            ),
                          )
                          .toList(),
                    ),
            ),
          ],
        );
      },
    );
  }

  ParentAnalyticsData _emptyAnalytics() {
    final now = DateTime.now();
    const features = [
      ParentFeatureAnalytics(
        gameType: 'emotion_classify',
        title: 'Emotion Classify',
        sessions: 0,
        totalSeconds: 0,
        correctActions: 0,
        totalActions: 0,
      ),
      ParentFeatureAnalytics(
        gameType: 'emotion_mimic',
        title: 'Emotion Mimic',
        sessions: 0,
        totalSeconds: 0,
        correctActions: 0,
        totalActions: 0,
      ),
      ParentFeatureAnalytics(
        gameType: 'minipuzzle',
        title: 'MiniPuzzle',
        sessions: 0,
        totalSeconds: 0,
        correctActions: 0,
        totalActions: 0,
      ),
      ParentFeatureAnalytics(
        gameType: 'sorting',
        title: 'Sorting',
        sessions: 0,
        totalSeconds: 0,
        correctActions: 0,
        totalActions: 0,
      ),
      ParentFeatureAnalytics(
        gameType: 'reaction_time',
        title: 'Reaction Time',
        sessions: 0,
        totalSeconds: 0,
        correctActions: 0,
        totalActions: 0,
      ),
      ParentFeatureAnalytics(
        gameType: 'reading',
        title: 'Read & Speak',
        sessions: 0,
        totalSeconds: 0,
        correctActions: 0,
        totalActions: 0,
      ),
      ParentFeatureAnalytics(
        gameType: 'social_chat',
        title: 'Social Chat',
        sessions: 0,
        totalSeconds: 0,
        correctActions: 0,
        totalActions: 0,
      ),
      ParentFeatureAnalytics(
        gameType: 'flashcard',
        title: 'Flashcard Game',
        sessions: 0,
        totalSeconds: 0,
        correctActions: 0,
        totalActions: 0,
      ),
      ParentFeatureAnalytics(
        gameType: 'fruit_catching_bear',
        title: 'Fruit Catching Bear',
        sessions: 0,
        totalSeconds: 0,
        correctActions: 0,
        totalActions: 0,
      ),
    ];

    return ParentAnalyticsData(
      rangeStart: now.subtract(const Duration(days: 7)),
      rangeEnd: now,
      totalSessions: 0,
      totalMinutes: 0,
      averageScoredAccuracy: null,
      latestSession: null,
      features: features,
      dailyActivityValues: const [],
      recentSessions: const [],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  String _formatPercent(double value) {
    return '${(value * 100).round()}%';
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
    final difficultyRecommendations =
        _skillDifficultyRecommendations(group.averageSkillProgress);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current Child Section
        Text(
          _tr(context, 'current_child_overview'),
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
                          _tr(
                            context,
                            'age_format',
                            params: {'age': '${child.age}'},
                          ),
                          style: TextStyle(
                            fontSize: adaptive.space(14),
                            color: const Color(0xFF60758F),
                          ),
                        ),
                        Text(
                          _tr(
                            context,
                            'joined_format',
                            params: {
                              'date':
                                  '${child.joinedDate.day}/${child.joinedDate.month}/${child.joinedDate.year}',
                            },
                          ),
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
                    label: _tr(context, 'games_label'),
                    color: const Color(0xFFBDD8F2),
                  ),
                  _StatCard(
                    icon: Icons.star_outline_rounded,
                    value: '${child.learningPoints}',
                    label: _tr(context, 'points'),
                    color: const Color(0xFFFFF2A8),
                  ),
                  _StatCard(
                    icon: Icons.local_fire_department_outlined,
                    value: '${child.dayStreak}',
                    label: _tr(context, 'streak'),
                    color: const Color(0xFFF8C7DF),
                  ),
                  _StatCard(
                    icon: Icons.emoji_events_outlined,
                    value: '${child.achievementsUnlocked}',
                    label: _tr(context, 'achievements'),
                    color: const Color(0xFFC9E8C1),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: adaptive.space(24)),
        _DifficultyInstructionCard(
          adaptive: adaptive,
          description: _tr(context, 'difficulty_instruction_institution_desc'),
          recommendations: difficultyRecommendations,
        ),
        SizedBox(height: adaptive.space(24)),

        // Group Performance Section
        Text(
          _tr(context, 'single_child_summary'),
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
                _tr(context, 'current_child_statistics'),
                style: TextStyle(
                  fontSize: adaptive.space(16),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF243A5A),
                ),
              ),
              SizedBox(height: adaptive.space(12)),
              _InstitutionStatRow(
                label: _tr(context, 'children_shown'),
                value: '${group.totalChildren}',
              ),
              _InstitutionStatRow(
                label: _tr(context, 'games_completed'),
                value: group.averageGamesPerChild.toStringAsFixed(1),
              ),
              _InstitutionStatRow(
                label: _tr(context, 'learning_points'),
                value: group.averagePointsPerChild.toStringAsFixed(0),
              ),
              _InstitutionStatRow(
                label: _tr(context, 'current_streak'),
                value: group.averageStreak.toStringAsFixed(1),
              ),
              SizedBox(height: adaptive.space(16)),
              Text(
                _tr(context, 'skill_progress'),
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
          _tr(context, 'export_report'),
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
                _tr(context, 'export_report_desc'),
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
                  label: Text(_tr(context, 'export_report')),
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
              Text(
                _tr(context, 'report_exported'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF243A5A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _tr(context, 'report_saved'),
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
                child: Text(_tr(context, 'great')),
              ),
            ],
          ),
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
              Navigator.pushNamed(context, AppRoutes.preferences);
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _tr(context, 'my_rewards'),
              style: TextStyle(
                fontSize: adaptive.space(22),
                fontWeight: FontWeight.w800,
              ),
            ),
            if (controller.canAddReward)
              ElevatedButton.icon(
                onPressed: () {
                  SoundService.instance.playTap();
                  _showAddRewardDialog(context);
                },
                icon: Icon(Icons.add, size: adaptive.space(20)),
                label: Text(
                  _tr(context, 'add_reward'),
                  style: TextStyle(fontSize: adaptive.space(14)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF8C7DF),
                  foregroundColor: const Color(0xFF243A5A),
                  padding: EdgeInsets.symmetric(
                    horizontal: adaptive.space(16),
                    vertical: adaptive.space(12),
                  ),
                  minimumSize: const Size(48, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              )
            else
              Container(
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
                      Icons.info_outline,
                      size: adaptive.space(16),
                      color: const Color(0xFF60758F),
                    ),
                    SizedBox(width: adaptive.space(6)),
                    Text(
                      _tr(context, 'max_rewards_reached'),
                      style: TextStyle(
                        fontSize: adaptive.space(12),
                        color: const Color(0xFF60758F),
                      ),
                    ),
                  ],
                ),
              ),
          ],
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
                  onClaim: () => controller.claimReward(reward.id),
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
            _tr(context, 'create_reward_hint'),
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

  void _showAddRewardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AddRewardDialog(
        adaptive: adaptive,
        onCreate: (prize, condition, target) {
          controller.addReward(prize, condition, target);
          Navigator.pop(context);
        },
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
            _tr(context, 'your_achievements'),
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
                          locked
                              ? _tr(context, 'locked')
                              : _tr(context, 'unlocked'),
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

class _FeatureAnalyticsCard extends StatelessWidget {
  const _FeatureAnalyticsCard({
    required this.adaptive,
    required this.feature,
  });

  final AudyAdaptive adaptive;
  final ParentFeatureAnalytics feature;

  @override
  Widget build(BuildContext context) {
    final accuracy = feature.averageAccuracy;
    final color = _analyticsColor(feature.gameType);
    final hasSessions = feature.sessions > 0;

    return AudyPanel(
      adaptive: adaptive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _analyticsIcon(feature.gameType),
                  color: const Color(0xFF243A5A),
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _localizedFeatureTitle(context, feature.gameType, feature.title),
                  style: TextStyle(
                    fontSize: adaptive.space(17),
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF243A5A),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: adaptive.space(16)),
          Row(
            children: [
              Expanded(
                child: _MiniMetric(
                  label: _tr(context, 'sessions'),
                  value: '${feature.sessions}',
                ),
              ),
              Expanded(
                child: _MiniMetric(
                  label: _tr(context, 'minutes'),
                  value: '${feature.minutes}',
                ),
              ),
            ],
          ),
          SizedBox(height: adaptive.space(14)),
          Text(
            accuracy == null
                ? _tr(context, 'participation')
                : _tr(context, 'average_score'),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF60758F),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: accuracy ?? (hasSessions ? 1 : 0),
              minHeight: 12,
              backgroundColor: const Color(0xFFE2E5EA),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            accuracy == null
                ? (hasSessions
                    ? _tr(context, 'recorded_activity')
                    : _tr(context, 'no_sessions_yet'))
                : _tr(
                    context,
                    'percent_correct',
                    params: {'percent': '${(accuracy * 100).round()}'},
                  ),
            style: const TextStyle(fontSize: 13, color: Color(0xFF60758F)),
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF243A5A),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF60758F)),
        ),
      ],
    );
  }
}

class _RecentSessionRow extends StatelessWidget {
  const _RecentSessionRow({
    required this.adaptive,
    required this.session,
  });

  final AudyAdaptive adaptive;
  final ParentRecentSession session;

  @override
  Widget build(BuildContext context) {
    final accuracy = session.accuracy;
    final color = _analyticsColor(session.gameType);

    return Padding(
      padding: EdgeInsets.only(bottom: adaptive.space(12)),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _analyticsIcon(session.gameType),
              color: const Color(0xFF243A5A),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _localizedFeatureTitle(context, session.gameType, session.title),
                  style: TextStyle(
                    fontSize: adaptive.space(15),
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF243A5A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${_relativeSessionTime(context, session.endedAt)} - ${_formatDuration(session.durationSeconds)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF60758F),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            accuracy == null
                ? _tr(context, 'done')
                : '${session.correctActions}/${session.totalActions}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF243A5A),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyDashboardState extends StatelessWidget {
  const _EmptyDashboardState({required this.adaptive});

  final AudyAdaptive adaptive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: adaptive.space(20)),
      child: Text(
        _tr(context, 'no_learning_sessions'),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Color(0xFF60758F),
        ),
      ),
    );
  }
}

class _DifficultyInstructionCard extends StatelessWidget {
  const _DifficultyInstructionCard({
    required this.adaptive,
    required this.description,
    required this.recommendations,
  });

  final AudyAdaptive adaptive;
  final String description;
  final List<_DifficultyRecommendation> recommendations;

  @override
  Widget build(BuildContext context) {
    return AudyPanel(
      adaptive: adaptive,
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
                  Icons.trending_up_rounded,
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
                      _tr(context, 'difficulty_instruction_title'),
                      style: TextStyle(
                        fontSize: adaptive.space(18),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF243A5A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
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
          SizedBox(height: adaptive.space(16)),
          if (recommendations.isEmpty)
            Text(
              _tr(context, 'difficulty_instruction_empty'),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF60758F),
              ),
            )
          else
            Column(
              children: recommendations
                  .map(
                    (recommendation) => _DifficultyRecommendationRow(
                      adaptive: adaptive,
                      recommendation: recommendation,
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _DifficultyRecommendationRow extends StatelessWidget {
  const _DifficultyRecommendationRow({
    required this.adaptive,
    required this.recommendation,
  });

  final AudyAdaptive adaptive;
  final _DifficultyRecommendation recommendation;

  @override
  Widget build(BuildContext context) {
    final color = _analyticsColor(recommendation.gameType);

    return Padding(
      padding: EdgeInsets.only(bottom: adaptive.space(10)),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _analyticsIcon(recommendation.gameType),
              color: const Color(0xFF243A5A),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _localizedFeatureTitle(
                    context,
                    recommendation.gameType,
                    recommendation.title,
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF243A5A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _tr(context, 'try_harder_difficulty'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF60758F),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(recommendation.score * 100).round()}%',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF243A5A),
            ),
          ),
        ],
      ),
    );
  }
}

IconData _analyticsIcon(String gameType) {
  switch (gameType) {
    case 'emotion_classify':
      return Icons.sentiment_satisfied_rounded;
    case 'emotion_mimic':
      return Icons.face_retouching_natural_rounded;
    case 'minipuzzle':
      return Icons.extension_rounded;
    case 'sorting':
      return Icons.category_rounded;
    case 'reaction_time':
      return Icons.flash_on_rounded;
    case 'reading':
      return Icons.menu_book_rounded;
    case 'social_chat':
      return Icons.chat_bubble_rounded;
    default:
      return Icons.analytics_rounded;
  }
}

Color _analyticsColor(String gameType) {
  switch (gameType) {
    case 'emotion_classify':
      return const Color(0xFFF8C7DF);
    case 'emotion_mimic':
      return const Color(0xFFE7D8FA);
    case 'minipuzzle':
      return const Color(0xFFBDD8F2);
    case 'sorting':
      return const Color(0xFFFFF2A8);
    case 'reaction_time':
      return const Color(0xFFFFDAC7);
    case 'reading':
      return const Color(0xFFC9E8C1);
    case 'social_chat':
      return const Color(0xFFBDEBE8);
    default:
      return const Color(0xFFE2E5EA);
  }
}

String _relativeSessionTime(BuildContext context, DateTime date) {
  final difference = DateTime.now().difference(date);
  if (difference.inMinutes < 1) return _tr(context, 'just_now');
  if (difference.inHours < 1) {
    return _tr(
      context,
      'minutes_ago',
      params: {'count': '${difference.inMinutes}'},
    );
  }
  if (difference.inDays < 1) {
    return _tr(
      context,
      'hours_ago',
      params: {'count': '${difference.inHours}'},
    );
  }
  return _tr(context, 'days_ago', params: {'count': '${difference.inDays}'});
}

String _formatDuration(int seconds) {
  if (seconds < 60) return '${seconds}s';
  return '${(seconds / 60).ceil()}m';
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

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.values,
    required this.color,
    this.subtitle,
  });

  final String title;
  final List<double> values;
  final Color color;
  final String? subtitle;

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
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: const TextStyle(fontSize: 13, color: Color(0xFF60758F)),
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            height: 180,
            child: values.isEmpty
                ? _EmptyChartState(color: color)
                : CustomPaint(
                    painter: _LineChartPainter(values: values, color: color),
                    child: Container(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChartState extends StatelessWidget {
  const _EmptyChartState({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Center(
        child: Text(
          _tr(context, 'not_enough_session_data'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF60758F),
          ),
        ),
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

    if (values.length == 1) {
      final y = size.height - (size.height * values.first);
      canvas.drawCircle(Offset(size.width / 2, y), 5, dotPaint);
      return;
    }

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

// ==================== REWARD CARD WIDGET ====================

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

// ==================== ADD REWARD DIALOG ====================

class _AddRewardDialog extends StatefulWidget {
  const _AddRewardDialog({required this.adaptive, required this.onCreate});

  final AudyAdaptive adaptive;
  final void Function(String prize, RewardCondition condition, int target)
  onCreate;

  @override
  State<_AddRewardDialog> createState() => _AddRewardDialogState();
}

class _AddRewardDialogState extends State<_AddRewardDialog> {
  final _prizeController = TextEditingController();
  RewardCondition _selectedCondition = RewardCondition.emotionClassify;
  int _targetCount = 5;

  @override
  void dispose() {
    _prizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  _tr(context, 'create_reward'),
                  style: TextStyle(
                    fontSize: widget.adaptive.space(22),
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF243A5A),
                  ),
                ),
              ),
              SizedBox(height: widget.adaptive.space(24)),

              // Prize Field
              Text(
                _tr(context, 'prize_label'),
                style: TextStyle(
                  fontSize: widget.adaptive.space(14),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF60758F),
                ),
              ),
              SizedBox(height: widget.adaptive.space(8)),
              TextField(
                controller: _prizeController,
                decoration: InputDecoration(
                  hintText: _tr(context, 'prize_hint'),
                  hintStyle: TextStyle(color: const Color(0xFFB8BFCA)),
                  filled: true,
                  fillColor: const Color(0xFFF8F9FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: widget.adaptive.space(16),
                    vertical: widget.adaptive.space(14),
                  ),
                ),
              ),
              SizedBox(height: widget.adaptive.space(20)),

              // Condition Selector
              Text(
                _tr(context, 'condition_label'),
                style: TextStyle(
                  fontSize: widget.adaptive.space(14),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF60758F),
                ),
              ),
              SizedBox(height: widget.adaptive.space(12)),
              Wrap(
                spacing: widget.adaptive.space(8),
                runSpacing: widget.adaptive.space(8),
                children: RewardCondition.values.where((c) => c != RewardCondition.emotionMimic).map((condition) {
                  final isSelected = _selectedCondition == condition;
                  return InkWell(
                    onTap: () {
                      SoundService.instance.playTap();
                      setState(() => _selectedCondition = condition);
                    },
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: widget.adaptive.space(12),
                        vertical: widget.adaptive.space(10),
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFF8C7DF)
                            : const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(999),
                        border: isSelected
                            ? Border.all(
                                color: const Color(0xFF5D6A7E),
                                width: 1.5,
                              )
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getConditionIcon(condition),
                            size: widget.adaptive.space(18),
                            color: const Color(0xFF243A5A),
                          ),
                          SizedBox(width: widget.adaptive.space(6)),
                          Text(
                            _getConditionLabel(context, condition),
                            style: TextStyle(
                              fontSize: widget.adaptive.space(14),
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF243A5A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: widget.adaptive.space(20)),

              // Target Count
              Text(
                _tr(context, 'target_label'),
                style: TextStyle(
                  fontSize: widget.adaptive.space(14),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF60758F),
                ),
              ),
              SizedBox(height: widget.adaptive.space(12)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CountButton(
                    icon: Icons.remove,
                    onPressed: _targetCount > 1
                        ? () => setState(() => _targetCount--)
                        : null,
                    adaptive: widget.adaptive,
                  ),
                  SizedBox(width: widget.adaptive.space(16)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.adaptive.space(24),
                      vertical: widget.adaptive.space(12),
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
                  _CountButton(
                    icon: Icons.add,
                    onPressed: _targetCount < 20
                        ? () => setState(() => _targetCount++)
                        : null,
                    adaptive: widget.adaptive,
                  ),
                ],
              ),
              SizedBox(height: widget.adaptive.space(24)),

              // Buttons
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
                        padding: EdgeInsets.symmetric(
                          vertical: widget.adaptive.space(14),
                        ),
                        minimumSize: const Size(48, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(_tr(context, 'cancel')),
                    ),
                  ),
                  SizedBox(width: widget.adaptive.space(12)),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _prizeController.text.trim().isNotEmpty
                          ? () {
                              SoundService.instance.playTap();
                              widget.onCreate(
                                _prizeController.text.trim(),
                                _selectedCondition,
                                _targetCount,
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF8C7DF),
                        foregroundColor: const Color(0xFF243A5A),
                        padding: EdgeInsets.symmetric(
                          vertical: widget.adaptive.space(14),
                        ),
                        disabledBackgroundColor: const Color(0xFFE2E5EA),
                        minimumSize: const Size(48, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(_tr(context, 'create')),
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

class _CountButton extends StatelessWidget {
  const _CountButton({
    required this.icon,
    required this.onPressed,
    required this.adaptive,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final AudyAdaptive adaptive;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onPressed != null
          ? const Color(0xFFBDD8F2)
          : const Color(0xFFE2E5EA),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(adaptive.space(12)),
          child: Icon(
            icon,
            size: adaptive.space(24),
            color: onPressed != null
                ? const Color(0xFF243A5A)
                : const Color(0xFFB8BFCA),
          ),
        ),
      ),
    );
  }
}
