import 'package:flutter/material.dart';

void main() {
  runApp(const AudyApp());
}

class AudyApp extends StatelessWidget {
  const AudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AUDY',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F8FC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7A63C7),
          brightness: Brightness.light,
        ),
        fontFamily: 'sans-serif',
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const double _designWidth = 1200;
  static const double _designHeight = 2400;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final safeWidth = width.isFinite ? width : _designWidth;
        final safeHeight = height.isFinite ? height : _designHeight;
        final scale = (safeWidth / _designWidth).clamp(0.62, 1.0);
        final bodyWidth = safeWidth > 760 ? safeWidth * 0.9 : safeWidth - 32;

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF9FCFF),
                  Color(0xFFF2F7FB),
                  Color(0xFFEDF4FA),
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: bodyWidth),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      24 * scale,
                      20 * scale,
                      24 * scale,
                      28 * scale,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: safeHeight - (32 * scale),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Header(scale: scale),
                          SizedBox(height: 28 * scale),
                          _ProgressCard(scale: scale),
                          SizedBox(height: 28 * scale),
                          _SectionTitle(
                            title: 'Activities',
                            subtitle: 'Choose what Audy should help with today',
                            scale: scale,
                          ),
                          SizedBox(height: 16 * scale),
                          _ActivityGrid(scale: scale),
                          SizedBox(height: 28 * scale),
                          _SupportRow(scale: scale),
                          SizedBox(height: 28 * scale),
                          _SectionTitle(
                            title: 'Today\'s Plan',
                            subtitle: 'Simple, predictable steps for a calm study day',
                            scale: scale,
                          ),
                          SizedBox(height: 16 * scale),
                          _PlanCard(scale: scale),
                          SizedBox(height: 28 * scale),
                          _SectionTitle(
                            title: 'Encouragement',
                            subtitle: 'Small wins matter. Audy keeps the pace gentle.',
                            scale: scale,
                          ),
                          SizedBox(height: 16 * scale),
                          _EncouragementBanner(scale: scale),
                          SizedBox(height: 28 * scale),
                          Center(
                            child: Text(
                              'CEDT INNOVATION SUMMIT 2026',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 17 * scale,
                                letterSpacing: 1.6,
                                color: const Color(0xFF3B5374),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.scale});

  final double scale;

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
                shaderCallback: (bounds) {
                  return const LinearGradient(
                    colors: [Color(0xFF6B4FC3), Color(0xFF8E72D6)],
                  ).createShader(bounds);
                },
                child: Text(
                  'AUDY',
                  style: TextStyle(
                    fontSize: 42 * scale,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 8 * scale),
              Text(
                'AUTism buddy for stuDY',
                style: TextStyle(
                  fontSize: 18 * scale,
                  color: const Color(0xFF284464),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 60 * scale,
          height: 60 * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFE7D8FA),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7F67D1).withValues(alpha: 0.16),
                blurRadius: 20 * scale,
                offset: Offset(0, 10 * scale),
              ),
            ],
          ),
          child: Icon(
            Icons.person_outline_rounded,
            size: 30 * scale,
            color: const Color(0xFF36465E),
          ),
        ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(22 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28 * scale),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF98A7C0).withValues(alpha: 0.18),
            blurRadius: 28 * scale,
            offset: Offset(0, 14 * scale),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 128 * scale,
            height: 128 * scale,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24 * scale),
              gradient: const RadialGradient(
                colors: [Color(0xFFFFF9D7), Color(0xFFFFE7A8)],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '🐱',
              style: TextStyle(fontSize: 70 * scale),
            ),
          ),
          SizedBox(width: 22 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Progress',
                  style: TextStyle(
                    fontSize: 22 * scale,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF17365C),
                  ),
                ),
                SizedBox(height: 16 * scale),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: 0.45,
                    minHeight: 16 * scale,
                    backgroundColor: const Color(0xFFD5D7DD),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF16D965)),
                  ),
                ),
                SizedBox(height: 12 * scale),
                Text(
                  '45% Complete',
                  style: TextStyle(
                    fontSize: 16 * scale,
                    color: const Color(0xFF35506F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8 * scale),
                Text(
                  'You finished reading time and one game challenge.',
                  style: TextStyle(
                    fontSize: 14 * scale,
                    color: const Color(0xFF70829A),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
    required this.scale,
  });

  final String title;
  final String subtitle;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22 * scale,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF17365C),
          ),
        ),
        SizedBox(height: 6 * scale),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14 * scale,
            color: const Color(0xFF698099),
          ),
        ),
      ],
    );
  }
}

class _ActivityGrid extends StatelessWidget {
  const _ActivityGrid({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final activities = [
      (
        icon: Icons.sports_esports_outlined,
        title: 'Games',
        subtitle: 'Short focus games',
        color: const Color(0xFFF8C7DF),
      ),
      (
        icon: Icons.menu_book_rounded,
        title: 'Read & Pronounce',
        subtitle: 'Speak with confidence',
        color: const Color(0xFFC9E8C1),
      ),
      (
        icon: Icons.chat_bubble_outline_rounded,
        title: 'Social Chat',
        subtitle: 'Practice conversation',
        color: const Color(0xFFDDD0F4),
      ),
      (
        icon: Icons.workspace_premium_outlined,
        title: 'Rewards',
        subtitle: 'Celebrate progress',
        color: const Color(0xFFFFF1A8),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 720;
        return Wrap(
          spacing: 18 * scale,
          runSpacing: 18 * scale,
          children: activities.map((activity) {
            final itemWidth = isWide
                ? (constraints.maxWidth - (18 * scale * 3)) / 4
                : (constraints.maxWidth - (18 * scale)) / 2;

            return SizedBox(
              width: itemWidth,
              child: _ActivityCard(
                icon: activity.icon,
                title: activity.title,
                subtitle: activity.subtitle,
                color: activity.color,
                scale: scale,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.scale,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150 * scale,
      padding: EdgeInsets.symmetric(
        horizontal: 18 * scale,
        vertical: 20 * scale,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24 * scale),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA5B4C7).withValues(alpha: 0.20),
            blurRadius: 20 * scale,
            offset: Offset(0, 10 * scale),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 34 * scale, color: const Color(0xFF394C67)),
          SizedBox(height: 14 * scale),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF17365C),
            ),
          ),
          SizedBox(height: 6 * scale),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12 * scale,
              color: const Color(0xFF3E5A7C),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportRow extends StatelessWidget {
  const _SupportRow({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 760;
        if (!isWide) {
          return Column(
            children: [
              _MiniPanel(
                title: 'Comfort Mode',
                description: 'Low-noise colors and slower transitions for calm learning.',
                icon: Icons.self_improvement_rounded,
                accent: const Color(0xFFE5D8FF),
                scale: scale,
              ),
              SizedBox(height: 18 * scale),
              _MiniPanel(
                title: 'Daily Reward',
                description: '2 more tasks unlock a sticker and a short celebration.',
                icon: Icons.stars_rounded,
                accent: const Color(0xFFFFEDB3),
                scale: scale,
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _MiniPanel(
                title: 'Comfort Mode',
                description: 'Low-noise colors and slower transitions for calm learning.',
                icon: Icons.self_improvement_rounded,
                accent: const Color(0xFFE5D8FF),
                scale: scale,
              ),
            ),
            SizedBox(width: 18 * scale),
            Expanded(
              child: _MiniPanel(
                title: 'Daily Reward',
                description: '2 more tasks unlock a sticker and a short celebration.',
                icon: Icons.stars_rounded,
                accent: const Color(0xFFFFEDB3),
                scale: scale,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MiniPanel extends StatelessWidget {
  const _MiniPanel({
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
    required this.scale,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color accent;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(22 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(color: accent.withValues(alpha: 0.8), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9DAFC4).withValues(alpha: 0.14),
            blurRadius: 20 * scale,
            offset: Offset(0, 10 * scale),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58 * scale,
            height: 58 * scale,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(18 * scale),
            ),
            child: Icon(icon, color: const Color(0xFF3B4E67), size: 28 * scale),
          ),
          SizedBox(width: 16 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF17365C),
                  ),
                ),
                SizedBox(height: 6 * scale),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13 * scale,
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

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        time: '08:30',
        title: 'Warm-up Game',
        note: '3-minute memory activity',
        color: const Color(0xFFF8C7DF),
      ),
      (
        time: '09:00',
        title: 'Read & Pronounce',
        note: 'Practice five words with audio',
        color: const Color(0xFFC9E8C1),
      ),
      (
        time: '10:00',
        title: 'Social Chat',
        note: 'Try one greeting and one question',
        color: const Color(0xFFDDD0F4),
      ),
      (
        time: '10:30',
        title: 'Reward Break',
        note: 'Choose a sticker and rest',
        color: const Color(0xFFFFF1A8),
      ),
    ];

    return Container(
      padding: EdgeInsets.all(22 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28 * scale),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF97A8C0).withValues(alpha: 0.16),
            blurRadius: 24 * scale,
            offset: Offset(0, 12 * scale),
          ),
        ],
      ),
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: 14 * scale),
                child: _PlanRow(
                  time: item.time,
                  title: item.title,
                  note: item.note,
                  color: item.color,
                  scale: scale,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({
    required this.time,
    required this.title,
    required this.note,
    required this.color,
    required this.scale,
  });

  final String time;
  final String title;
  final String note;
  final Color color;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16 * scale,
        vertical: 14 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFE),
        borderRadius: BorderRadius.circular(20 * scale),
      ),
      child: Row(
        children: [
          Container(
            width: 72 * scale,
            padding: EdgeInsets.symmetric(vertical: 10 * scale),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16 * scale),
            ),
            child: Text(
              time,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13 * scale,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF23415F),
              ),
            ),
          ),
          SizedBox(width: 14 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF17365C),
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  note,
                  style: TextStyle(
                    fontSize: 13 * scale,
                    color: const Color(0xFF657C94),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: const Color(0xFF7B8EA5),
            size: 24 * scale,
          ),
        ],
      ),
    );
  }
}

class _EncouragementBanner extends StatelessWidget {
  const _EncouragementBanner({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30 * scale),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You are doing wonderfully today.',
                  style: TextStyle(
                    fontSize: 22 * scale,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8 * scale),
                Text(
                  'Audy can read instructions out loud, keep each task short, and celebrate every finished step.',
                  style: TextStyle(
                    fontSize: 14 * scale,
                    height: 1.5,
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
                SizedBox(height: 16 * scale),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF5D49BA),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20 * scale,
                      vertical: 14 * scale,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18 * scale),
                    ),
                  ),
                  onPressed: () {},
                  child: Text(
                    'Start Next Activity',
                    style: TextStyle(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 18 * scale),
          Container(
            width: 108 * scale,
            height: 108 * scale,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '✨',
              style: TextStyle(fontSize: 56 * scale),
            ),
          ),
        ],
      ),
    );
  }
}
