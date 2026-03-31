import 'package:flutter/material.dart';

import '../core/audy_ui.dart';
import '../state/audy_controller.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  int selectedTab = 0;

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
                        label: 'Back to Home',
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(height: adaptive.space(28)),
                      Text(
                        'Your Rewards',
                        style: TextStyle(
                          fontSize: adaptive.space(30),
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF243A5A),
                        ),
                      ),
                      SizedBox(height: adaptive.space(8)),
                      Text(
                        'See what you\'ve earned.',
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
            _PointsBanner(adaptive: adaptive, points: controller.learningPoints),
            SizedBox(height: adaptive.space(18)),
            Wrap(
              spacing: adaptive.space(12),
              runSpacing: adaptive.space(12),
              children: [
                _RewardTabChip(
                  label: 'Progress',
                  icon: Icons.workspace_premium_outlined,
                  selected: selectedTab == 0,
                  color: const Color(0xFFBDD8F2),
                  onTap: () => setState(() => selectedTab = 0),
                ),
                _RewardTabChip(
                  label: 'Accessories',
                  icon: Icons.checkroom_outlined,
                  selected: selectedTab == 1,
                  color: const Color(0xFFF8C7DF),
                  onTap: () => setState(() => selectedTab = 1),
                ),
                _RewardTabChip(
                  label: 'Achievements',
                  icon: Icons.auto_awesome_outlined,
                  selected: selectedTab == 2,
                  color: const Color(0xFFC9E8C1),
                  onTap: () => setState(() => selectedTab = 2),
                ),
              ],
            ),
            SizedBox(height: adaptive.space(22)),
            if (selectedTab == 0)
              _RewardsProgressTab(adaptive: adaptive, controller: controller),
            if (selectedTab == 1)
              _RewardsAccessoriesTab(adaptive: adaptive, controller: controller),
            if (selectedTab == 2)
              _RewardsAchievementsTab(
                adaptive: adaptive,
                controller: controller,
              ),
          ],
        );
      },
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AudyScope.of(context);
    return AudyResponsivePage(
      builder: (context, adaptive) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AudyBackButton(
                      label: 'Back to Home',
                      onPressed: () => Navigator.pop(context),
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
                              'CEDT',
                              style: TextStyle(
                                fontSize: adaptive.space(24),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: adaptive.space(6)),
                            Text(
                              'Age: 17',
                              style: TextStyle(
                                fontSize: adaptive.space(15),
                                color: const Color(0xFF60758F),
                              ),
                            ),
                            Text(
                              'Member since January 15, 2026',
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
            const _ProfileChartsSection(),
          ],
        );
      },
    );
  }
}

class _PointsBanner extends StatelessWidget {
  const _PointsBanner({
    required this.adaptive,
    required this.points,
  });

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

class _RewardsProgressTab extends StatelessWidget {
  const _RewardsProgressTab({
    required this.adaptive,
    required this.controller,
  });

  final AudyAdaptive adaptive;
  final AudyController controller;

  @override
  Widget build(BuildContext context) {
    final levels = [
      ('Beginner', '0 - 100 points', 1.0, const Color(0xFFC9E8C1)),
      (
        'Learner',
        '100 - 250 points',
        ((controller.learningPoints.clamp(100, 250) - 100) / 150).toDouble(),
        const Color(0xFFBDD8F2),
      ),
      (
        'Explorer',
        '250 - 500 points',
        controller.learningPoints >= 250
            ? (((controller.learningPoints.clamp(250, 500) - 250) / 250)
                  .toDouble())
            : 0.0,
        const Color(0xFFE7D8FA),
      ),
      (
        'Expert',
        '500 - 1000 points',
        controller.learningPoints >= 500
            ? (((controller.learningPoints.clamp(500, 1000) - 500) / 500)
                  .toDouble())
            : 0.0,
        const Color(0xFFFFF2A8),
      ),
      (
        'Master',
        '1000 - 2000 points',
        controller.learningPoints >= 1000
            ? (((controller.learningPoints.clamp(1000, 2000) - 1000) / 1000)
                  .toDouble())
            : 0.0,
        const Color(0xFFC9E8C1),
      ),
    ];

    return AudyPanel(
      adaptive: adaptive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Your Learning Journey',
              style: TextStyle(
                fontSize: adaptive.space(22),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(height: adaptive.space(22)),
          ...levels.map((level) {
            return Padding(
              padding: EdgeInsets.only(bottom: adaptive.space(18)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          level.$1,
                          style: TextStyle(
                            fontSize: adaptive.space(16),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        level.$2,
                        style: TextStyle(
                          fontSize: adaptive.space(14),
                          color: const Color(0xFF60758F),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: adaptive.space(8)),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: level.$3,
                      minHeight: adaptive.space(16),
                      backgroundColor: const Color(0xFFE2E5EA),
                      valueColor: AlwaysStoppedAnimation(level.$4),
                    ),
                  ),
                ],
              ),
            );
          }),
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
            'Dress Up Your Cat!',
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
              onTap: item.owned ? null : () => controller.unlockAccessory(item.name),
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
            'Prepared Backend Drafts',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Text(
            'Requests prepared locally: ${controller.preparedRequests.length}',
            style: const TextStyle(fontSize: 15, color: Color(0xFF60758F)),
          ),
          const SizedBox(height: 8),
          Text(
            latest == null
                ? 'No backend drafts have been prepared yet.'
                : 'Latest draft: ${latest.method.name.toUpperCase()} ${latest.endpoint}',
            style: const TextStyle(fontSize: 15, color: Color(0xFF60758F)),
          ),
        ],
      ),
    );
  }
}

class _ProfileChartsSection extends StatelessWidget {
  const _ProfileChartsSection();

  @override
  Widget build(BuildContext context) {
    final adaptive = AudyAdaptive(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
    );

    return AudyAdaptiveGrid(
      adaptive: adaptive,
      phoneColumns: 1,
      tabletColumns: 2,
      desktopColumns: 2,
      items: const [
        _ChartCard(
          title: 'Emotion Recognition Progress',
          values: [0.58, 0.64, 0.70, 0.75, 0.80, 0.86, 0.89],
          color: Color(0xFFF7BCD8),
        ),
        _ChartCard(
          title: 'Eye Contact Duration (seconds)',
          values: [0.32, 0.41, 0.45, 0.52, 0.61, 0.69, 0.73],
          color: Color(0xFFBDD8F2),
        ),
        _SkillsCard(),
        _BarsCard(),
      ],
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

class _SkillsCard extends StatelessWidget {
  const _SkillsCard();

  @override
  Widget build(BuildContext context) {
    const skills = [
      ('Emotions', 0.84),
      ('Eye Contact', 0.72),
      ('Colors', 0.88),
      ('Reactions', 0.90),
      ('Reading', 0.76),
      ('Social', 0.66),
    ];

    final adaptive = AudyAdaptive(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
    );

    return AudyPanel(
      adaptive: adaptive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Skills Overview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          ...skills.map((skill) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    skill.$1,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: skill.$2,
                      minHeight: 12,
                      backgroundColor: const Color(0xFFE2E5EA),
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFFD8C8F5),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _BarsCard extends StatelessWidget {
  const _BarsCard();

  @override
  Widget build(BuildContext context) {
    const values = [
      ('Emotion', 12.0),
      ('Eye', 8.0),
      ('Color', 10.0),
      ('Reaction', 9.0),
      ('Reading', 6.0),
      ('Social', 2.0),
    ];

    final adaptive = AudyAdaptive(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
    );

    return AudyPanel(
      adaptive: adaptive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Game Completion Rate',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 190,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: values.map((item) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: item.$2 * 12,
                          decoration: BoxDecoration(
                            color: const Color(0xFFC9E8C1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.$1,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
