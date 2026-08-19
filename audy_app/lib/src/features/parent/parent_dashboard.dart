import 'package:flutter/material.dart';
import '../../core/app_routes.dart';
import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../services/auth_service.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';
import '../dashboard_analytics.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  final _authService = AuthService();
  final _emailController = TextEditingController();

  List<UserProfile> _children = [];
  final Map<String, Map<String, dynamic>> _childrenStats = {};
  final Map<String, List<Map<String, dynamic>>> _childrenSessions = {};
  final Map<String, List<Map<String, dynamic>>> _childrenAssignments = {};
  bool _isLoading = true;
  bool _isLinking = false;
  String? _message;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadChildrenData();
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadChildrenData() async {
    setState(() => _isLoading = true);
    final user = AudyScope.of(context).currentUser;
    if (user != null) {
      final children = await _authService.fetchChildren(user.id);
      setState(() {
        _children = children;
      });

      // Load stats & session analytics for each child
      for (final child in children) {
        final stats = await _authService.fetchStudentStats(child.id);
        if (stats != null) {
          setState(() {
            _childrenStats[child.id] = stats;
          });
        }
        final sessions = await _authService.fetchStudentSessions(child.id);
        setState(() {
          _childrenSessions[child.id] = sessions;
        });
        final assignments = await _authService.fetchAssignments(child.id);
        setState(() {
          _childrenAssignments[child.id] = assignments;
        });
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _linkChild() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _message = 'Please enter your child\'s email address.';
        _isError = true;
      });
      return;
    }

    setState(() {
      _isLinking = true;
      _message = null;
    });

    SoundService.instance.playTap();

    try {
      final user = AudyScope.of(context).currentUser;
      if (user != null) {
        await _authService.linkChildToParent(user.id, email);
        setState(() {
          _message = 'Successfully linked child!';
          _isError = false;
          _emailController.clear();
        });
        await _loadChildrenData();
      }
    } catch (e) {
      setState(() {
        _message = e.toString().replaceAll('Exception: ', '');
        _isError = true;
      });
    } finally {
      setState(() => _isLinking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AudyScope.of(context);
    final user = controller.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Parent Portal',
          style: AudyTypography.headingLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              SoundService.instance.playTap();
              // Clear the whole stack and leave for login immediately so the
              // parent/teacher shell never re-renders as the student
              // dashboard while sign-out finishes in the background.
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
              await controller.logout();
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: AudyResponsivePage(
        scrollable: true,
        builder: (context, adaptive) {
          return Padding(
            padding: EdgeInsets.all(adaptive.space(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome header
                Container(
                  padding: EdgeInsets.all(adaptive.space(20)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
                    border: Border.all(color: AudyColors.skyBlue, width: 2),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.supervisor_account_rounded,
                        size: 48,
                        color: AudyColors.skyBlue,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, ${user?.name ?? 'Parent'}!',
                              style: AudyTypography.headingSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Monitor your child\'s learning progress and play sessions.',
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
                SizedBox(height: adaptive.space(24)),

                // Link child section
                _buildLinkChildCard(adaptive),
                SizedBox(height: adaptive.space(24)),

                // Children list section
                Text(
                  'Your Children',
                  style: AudyTypography.headingSmall,
                ),
                SizedBox(height: adaptive.space(12)),

                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: AudyColors.skyBlue),
                    ),
                  )
                else if (_children.isEmpty)
                  _buildEmptyChildrenCard(adaptive)
                else
                  ..._children.map((child) => _buildChildStatsCard(child, adaptive)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLinkChildCard(AudyAdaptive adaptive) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
      ),
      child: Padding(
        padding: EdgeInsets.all(adaptive.space(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Link Child Account',
              style: AudyTypography.headingSmall.copyWith(fontSize: 18),
            ),
            SizedBox(height: adaptive.space(6)),
            Text(
              'Enter the email address of your child\'s account to link it.',
              style: TextStyle(fontSize: 13, color: AudyColors.textLight),
            ),
            SizedBox(height: adaptive.space(16)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'child@email.com',
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: AudyColors.backgroundSoft.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLinking ? null : _linkChild,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AudyColors.skyBlue,
                    foregroundColor: AudyColors.textOnColor,
                    minimumSize: const Size(80, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
                    ),
                  ),
                  child: _isLinking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AudyColors.textOnColor,
                          ),
                        )
                      : const Icon(Icons.link_rounded),
                ),
              ],
            ),
            if (_message != null) ...[
              SizedBox(height: adaptive.space(12)),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isError
                      ? AudyColors.error.withValues(alpha: 0.1)
                      : AudyColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
                  border: Border.all(
                    color: _isError
                        ? AudyColors.error.withValues(alpha: 0.3)
                        : AudyColors.success.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  _message!,
                  style: TextStyle(
                    fontSize: 13,
                    color: _isError ? AudyColors.error : AudyColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChildrenCard(AudyAdaptive adaptive) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
      ),
      child: Padding(
        padding: EdgeInsets.all(adaptive.space(32)),
        child: Column(
          children: [
            const Icon(
              Icons.child_care_rounded,
              size: 64,
              color: AudyColors.borderLight,
            ),
            SizedBox(height: adaptive.space(12)),
            const Text(
              'No linked child accounts yet.',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AudyColors.textSecondary,
              ),
            ),
            SizedBox(height: adaptive.space(4)),
            const Text(
              'Link your child\'s account using their email address above.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AudyColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildStatsCard(UserProfile child, AudyAdaptive adaptive) {
    final stats = _childrenStats[child.id];
    final learningPoints = stats?['learning_points'] ?? 0;
    final gamesPlayed = stats?['games_played'] ?? 0;
    final dayStreak = stats?['day_streak'] ?? 0;
    final lastPlayedStr = stats?['last_played_at'] != null
        ? DateTime.parse(stats!['last_played_at'] as String)
            .toLocal()
            .toString()
            .split(' ')[0]
        : 'Never';

    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
        side: const BorderSide(color: AudyColors.borderLight, width: 1.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(adaptive.space(20)),
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
                        child.name,
                        style: AudyTypography.headingSmall.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Age: ${child.age} | ${child.email ?? 'No email'}',
                        style: TextStyle(fontSize: 12, color: AudyColors.textLight),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: adaptive.space(20)),
            const Divider(color: AudyColors.borderLight, height: 1),
            SizedBox(height: adaptive.space(16)),
            Row(
              children: [
                _buildStatColumn('Learning Points', '$learningPoints', Icons.auto_awesome_rounded, AudyColors.activityRewards),
                _buildStatColumn('Games Played', '$gamesPlayed', Icons.sports_esports_rounded, AudyColors.skyBlue),
                _buildStatColumn('Day Streak', '$dayStreak days', Icons.local_fire_department_rounded, Colors.orange),
              ],
            ),
            SizedBox(height: adaptive.space(20)),
            const Divider(color: AudyColors.borderLight, height: 1),
            SizedBox(height: adaptive.space(16)),
            StudentAnalyticsCharts(
              sessions: _childrenSessions[child.id] ?? const [],
              assignments: _childrenAssignments[child.id],
            ),
            SizedBox(height: adaptive.space(16)),
            Row(
              children: [
                const Icon(
                  Icons.watch_later_outlined,
                  size: 16,
                  color: AudyColors.textLight,
                ),
                const SizedBox(width: 6),
                Text(
                  'Last Active: $lastPlayedStr',
                  style: TextStyle(
                    fontSize: 12,
                    color: AudyColors.textLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon, Color color) {
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
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AudyColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
