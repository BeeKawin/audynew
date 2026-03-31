import 'package:flutter/material.dart';

import '../core/app_routes.dart';
import '../core/audy_ui.dart';
import '../state/audy_controller.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AudyResponsivePage(
      builder: (context, adaptive) {
        final controller = AudyScope.of(context);
        final activities = [
          _NavCardData(
            title: 'Games',
            subtitle: 'Short focus games',
            icon: Icons.sports_esports_outlined,
            color: const Color(0xFFF8C7DF),
            route: AppRoutes.games,
          ),
          _NavCardData(
            title: 'Read & Pronounce',
            subtitle: 'Speak with confidence',
            icon: Icons.menu_book_rounded,
            color: const Color(0xFFC9E8C1),
            route: AppRoutes.readingHub,
          ),
          _NavCardData(
            title: 'Social Chat',
            subtitle: 'Practice conversation',
            icon: Icons.chat_bubble_outline_rounded,
            color: const Color(0xFFDDD0F4),
            route: AppRoutes.social,
          ),
          _NavCardData(
            title: 'Rewards',
            subtitle: 'Celebrate progress',
            icon: Icons.workspace_premium_outlined,
            color: const Color(0xFFFFF1A8),
            route: AppRoutes.rewards,
          ),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DashboardHeader(adaptive: adaptive),
            SizedBox(height: adaptive.space(28)),
            _ProgressOverviewCard(
              adaptive: adaptive,
              progressValue: controller.dashboardProgress,
              progressLabel: controller.dashboardProgressLabel,
              detailText:
                  'Prepared ${controller.preparedRequests.length} backend-ready requests locally without sending data.',
            ),
            SizedBox(height: adaptive.space(28)),
            _SectionTitle(
              title: 'Activities',
              subtitle: 'Choose what Audy should help with today.',
              adaptive: adaptive,
            ),
            SizedBox(height: adaptive.space(16)),
            AudyAdaptiveGrid(
              adaptive: adaptive,
              phoneColumns: 2,
              tabletColumns: 2,
              desktopColumns: 4,
              items: activities
                  .map(
                    (activity) => AudyActionCard(
                      title: activity.title,
                      subtitle: activity.subtitle,
                      icon: activity.icon,
                      color: activity.color,
                      adaptive: adaptive,
                      onTap: () => Navigator.pushNamed(context, activity.route),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: adaptive.space(28)),
            _SectionTitle(
              title: 'Today\'s Plan',
              subtitle: 'Simple, predictable steps for a calm study day.',
              adaptive: adaptive,
            ),
            SizedBox(height: adaptive.space(16)),
            _PlanList(adaptive: adaptive),
            SizedBox(height: adaptive.space(28)),
            AudyAdaptiveGrid(
              adaptive: adaptive,
              phoneColumns: 1,
              tabletColumns: 2,
              desktopColumns: 2,
              items: [
                _MiniPanel(
                  title: 'Comfort Mode',
                  description:
                      'Low-noise colors and slower transitions for calm learning.',
                  icon: Icons.self_improvement_rounded,
                  accent: const Color(0xFFE5D8FF),
                  adaptive: adaptive,
                ),
                _MiniPanel(
                  title: 'Daily Reward',
                  description:
                      'Two more tasks unlock a sticker and a celebration.',
                  icon: Icons.stars_rounded,
                  accent: const Color(0xFFFFEDB3),
                  adaptive: adaptive,
                ),
              ],
            ),
            SizedBox(height: adaptive.space(28)),
            _HeroBanner(adaptive: adaptive),
            SizedBox(height: adaptive.space(28)),
            Center(
              child: Text(
                'CEDT INNOVATION SUMMIT 2026',
                style: TextStyle(
                  fontSize: adaptive.space(15),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: const Color(0xFF415674),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.adaptive});

  final AudyAdaptive adaptive;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF6B4FC3), Color(0xFF8E72D6)],
                ).createShader(bounds),
                child: Text(
                  'AUDY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: adaptive.space(42),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(height: adaptive.space(8)),
              Text(
                'AUtism buddy for stuDY',
                style: TextStyle(
                  fontSize: adaptive.space(18),
                  color: const Color(0xFF284464),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFFE7D8FA),
            minimumSize: Size(adaptive.space(58), adaptive.space(58)),
            shadowColor: const Color(0xFF7F67D1).withValues(alpha: 0.20),
            elevation: 6,
          ),
          icon: Icon(
            Icons.person_outline_rounded,
            size: adaptive.space(28),
            color: const Color(0xFF36465E),
          ),
        ),
      ],
    );
  }
}

class _ProgressOverviewCard extends StatelessWidget {
  const _ProgressOverviewCard({
    required this.adaptive,
    required this.progressValue,
    required this.progressLabel,
    required this.detailText,
  });

  final AudyAdaptive adaptive;
  final double progressValue;
  final String progressLabel;
  final String detailText;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
      borderRadius: BorderRadius.circular(adaptive.space(28)),
      child: Container(
        padding: EdgeInsets.all(adaptive.space(22)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(adaptive.space(28)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF98A7C0).withValues(alpha: 0.18),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: adaptive.isPhone
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(child: AudyMascot(size: 98)),
                  SizedBox(height: adaptive.space(14)),
                  _ProgressBody(
                    adaptive: adaptive,
                    progressValue: progressValue,
                    progressLabel: progressLabel,
                    detailText: detailText,
                  ),
                ],
              )
            : Row(
                children: [
                  const AudyMascot(size: 98),
                  SizedBox(width: adaptive.space(20)),
                  Expanded(
                    child: _ProgressBody(
                      adaptive: adaptive,
                      progressValue: progressValue,
                      progressLabel: progressLabel,
                      detailText: detailText,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ProgressBody extends StatelessWidget {
  const _ProgressBody({
    required this.adaptive,
    required this.progressValue,
    required this.progressLabel,
    required this.detailText,
  });

  final AudyAdaptive adaptive;
  final double progressValue;
  final String progressLabel;
  final String detailText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Progress',
          style: TextStyle(
            fontSize: adaptive.space(22),
            fontWeight: FontWeight.w800,
            color: const Color(0xFF17365C),
          ),
        ),
        SizedBox(height: adaptive.space(16)),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progressValue,
            minHeight: adaptive.space(16),
            backgroundColor: const Color(0xFFD5D7DD),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF16D965)),
          ),
        ),
        SizedBox(height: adaptive.space(12)),
        Text(
          progressLabel,
          style: TextStyle(
            fontSize: adaptive.space(16),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF35506F),
          ),
        ),
        SizedBox(height: adaptive.space(6)),
        Text(
          detailText,
          style: TextStyle(
            fontSize: adaptive.space(14),
            color: const Color(0xFF70829A),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
    required this.adaptive,
  });

  final String title;
  final String subtitle;
  final AudyAdaptive adaptive;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: adaptive.space(22),
            fontWeight: FontWeight.w800,
            color: const Color(0xFF17365C),
          ),
        ),
        SizedBox(height: adaptive.space(6)),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: adaptive.space(14),
            color: const Color(0xFF698099),
          ),
        ),
      ],
    );
  }
}

class _PlanList extends StatelessWidget {
  const _PlanList({required this.adaptive});

  final AudyAdaptive adaptive;

  @override
  Widget build(BuildContext context) {
    final items = [
      _PlanItem(
        time: '08:30',
        title: 'Warm-up Game',
        note: '3-minute emotion challenge',
        color: const Color(0xFFF8C7DF),
        route: AppRoutes.emotionGame,
      ),
      _PlanItem(
        time: '09:00',
        title: 'Read & Pronounce',
        note: 'Practice five words with audio',
        color: const Color(0xFFC9E8C1),
        route: AppRoutes.readingHub,
      ),
      _PlanItem(
        time: '10:00',
        title: 'Social Chat',
        note: 'Try one greeting and one question',
        color: const Color(0xFFDDD0F4),
        route: AppRoutes.social,
      ),
      _PlanItem(
        time: '10:30',
        title: 'Rewards Break',
        note: 'Open achievements and celebrate progress',
        color: const Color(0xFFFFF1A8),
        route: AppRoutes.rewards,
      ),
    ];

    return AudyPanel(
      adaptive: adaptive,
      child: Column(
        children: items.map((item) {
          return Padding(
            padding: EdgeInsets.only(bottom: adaptive.space(14)),
            child: InkWell(
              borderRadius: BorderRadius.circular(adaptive.space(20)),
              onTap: () => Navigator.pushNamed(context, item.route),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: adaptive.space(16),
                  vertical: adaptive.space(14),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FBFE),
                  borderRadius: BorderRadius.circular(adaptive.space(20)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: adaptive.space(76),
                      padding: EdgeInsets.symmetric(
                        vertical: adaptive.space(10),
                      ),
                      decoration: BoxDecoration(
                        color: item.color,
                        borderRadius: BorderRadius.circular(adaptive.space(16)),
                      ),
                      child: Text(
                        item.time,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: adaptive.space(13),
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF23415F),
                        ),
                      ),
                    ),
                    SizedBox(width: adaptive.space(14)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: adaptive.space(16),
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF17365C),
                            ),
                          ),
                          SizedBox(height: adaptive.space(4)),
                          Text(
                            item.note,
                            style: TextStyle(
                              fontSize: adaptive.space(13),
                              color: const Color(0xFF657C94),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: const Color(0xFF7B8EA5),
                      size: adaptive.space(24),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MiniPanel extends StatelessWidget {
  const _MiniPanel({
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
    required this.adaptive,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color accent;
  final AudyAdaptive adaptive;

  @override
  Widget build(BuildContext context) {
    return AudyPanel(
      adaptive: adaptive,
      child: Row(
        children: [
          Container(
            width: adaptive.space(58),
            height: adaptive.space(58),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(adaptive.space(18)),
            ),
            child: Icon(
              icon,
              size: adaptive.space(28),
              color: const Color(0xFF3B4E67),
            ),
          ),
          SizedBox(width: adaptive.space(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: adaptive.space(18),
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF17365C),
                  ),
                ),
                SizedBox(height: adaptive.space(6)),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: adaptive.space(13),
                    height: 1.4,
                    color: const Color(0xFF627991),
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

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.adaptive});

  final AudyAdaptive adaptive;

  @override
  Widget build(BuildContext context) {
    final stacked = adaptive.isPhone;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(adaptive.space(24)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(adaptive.space(30)),
        gradient: const LinearGradient(
          colors: [Color(0xFF6F5DC6), Color(0xFF9B86E8)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7060C8).withValues(alpha: 0.26),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AudyBadgeIcon(
                  icon: Icons.auto_awesome_rounded,
                  size: 72,
                  background: Color(0x33FFFFFF),
                  foreground: Colors.white,
                ),
                SizedBox(height: adaptive.space(18)),
                _HeroText(adaptive: adaptive),
              ],
            )
          : Row(
              children: [
                Expanded(child: _HeroText(adaptive: adaptive)),
                SizedBox(width: adaptive.space(18)),
                const AudyBadgeIcon(
                  icon: Icons.auto_awesome_rounded,
                  size: 96,
                  background: Color(0x33FFFFFF),
                  foreground: Colors.white,
                ),
              ],
            ),
    );
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText({required this.adaptive});

  final AudyAdaptive adaptive;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'You are doing wonderfully today.',
          style: TextStyle(
            fontSize: adaptive.space(22),
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(height: adaptive.space(8)),
        Text(
          'Audy can guide the next task, read directions out loud, and celebrate each finished step.',
          style: TextStyle(
            fontSize: adaptive.space(14),
            height: 1.5,
            color: Colors.white.withValues(alpha: 0.92),
          ),
        ),
        SizedBox(height: adaptive.space(16)),
        FilledButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.games),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF5D49BA),
            padding: EdgeInsets.symmetric(
              horizontal: adaptive.space(20),
              vertical: adaptive.space(14),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(adaptive.space(18)),
            ),
          ),
          child: Text(
            'Start Next Activity',
            style: TextStyle(
              fontSize: adaptive.space(14),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _NavCardData {
  const _NavCardData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;
}

class _PlanItem {
  const _PlanItem({
    required this.time,
    required this.title,
    required this.note,
    required this.color,
    required this.route,
  });

  final String time;
  final String title;
  final String note;
  final Color color;
  final String route;
}
