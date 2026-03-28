import 'package:flutter/material.dart';

class AudyAdaptive {
  const AudyAdaptive({required this.width, required this.height});

  final double width;
  final double height;

  bool get isPhone => width < 600;
  bool get isTablet => width >= 600 && width < 1024;
  bool get isDesktop => width >= 1024;

  double get scale => (width / 390).clamp(0.92, 1.35);
  double space(double value) => value * scale;
  double get contentMaxWidth => isPhone ? width : (isTablet ? 860 : 1180);

  int columns({required int phone, required int tablet, required int desktop}) {
    if (isDesktop) return desktop;
    if (isTablet) return tablet;
    return phone;
  }
}

class AudyResponsivePage extends StatelessWidget {
  const AudyResponsivePage({super.key, required this.builder});

  final Widget Function(BuildContext context, AudyAdaptive adaptive) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.of(context).size.height;
        final adaptive = AudyAdaptive(width: width, height: height);

        return Scaffold(
          body: DecoratedBox(
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
                  constraints: BoxConstraints(
                    maxWidth: adaptive.contentMaxWidth,
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: adaptive.isPhone ? 20 : 28,
                      vertical: adaptive.isPhone ? 20 : 28,
                    ),
                    child: builder(context, adaptive),
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

class AudyFeaturePage extends StatelessWidget {
  const AudyFeaturePage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.leadingLabel,
    required this.childBuilder,
    this.mascot,
  });

  final String title;
  final String subtitle;
  final String leadingLabel;
  final Widget Function(BuildContext context, AudyAdaptive adaptive)
  childBuilder;
  final Widget? mascot;

  @override
  Widget build(BuildContext context) {
    return AudyResponsivePage(
      builder: (context, adaptive) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AudyBackButton(
              label: leadingLabel,
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(height: adaptive.space(22)),
            Center(
              child: Column(
                children: [
                  if (mascot != null) mascot!,
                  SizedBox(height: adaptive.space(16)),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: adaptive.space(30),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF243A5A),
                    ),
                  ),
                  SizedBox(height: adaptive.space(8)),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: adaptive.space(16),
                      color: const Color(0xFF60758F),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: adaptive.space(26)),
            childBuilder(context, adaptive),
          ],
        );
      },
    );
  }
}

class AudyActionCard extends StatelessWidget {
  const AudyActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.adaptive,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final AudyAdaptive adaptive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(adaptive.space(24)),
        child: Ink(
          padding: EdgeInsets.all(adaptive.space(18)),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(adaptive.space(24)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFA5B4C7).withValues(alpha: 0.20),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: adaptive.isPhone
                  ? adaptive.space(136)
                  : adaptive.space(150),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: adaptive.space(34),
                  color: const Color(0xFF394C67),
                ),
                SizedBox(height: adaptive.space(12)),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: adaptive.space(16),
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF17365C),
                  ),
                ),
                SizedBox(height: adaptive.space(6)),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: adaptive.space(12),
                    color: const Color(0xFF3E5A7C),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AudyAnswerCard extends StatelessWidget {
  const AudyAnswerCard({
    super.key,
    required this.label,
    required this.color,
    required this.adaptive,
    required this.onTap,
  });

  final String label;
  final Color color;
  final AudyAdaptive adaptive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(adaptive.space(18)),
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: adaptive.space(22),
            vertical: adaptive.space(20),
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(adaptive.space(18)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFAFB9CC).withValues(alpha: 0.18),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: adaptive.space(16),
                fontWeight: FontWeight.w800,
                color: const Color(0xFF243A5A),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AudyPillButton extends StatelessWidget {
  const AudyPillButton({
    super.key,
    required this.label,
    required this.color,
    required this.adaptive,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final Color color;
  final AudyAdaptive adaptive;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: icon == null
          ? const SizedBox.shrink()
          : Icon(icon, size: adaptive.space(20)),
      label: Text(
        label,
        style: TextStyle(
          fontSize: adaptive.space(14),
          fontWeight: FontWeight.w800,
        ),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: const Color(0xFF243A5A),
        padding: EdgeInsets.symmetric(
          horizontal: adaptive.space(22),
          vertical: adaptive.space(15),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        elevation: 3,
        shadowColor: const Color(0xFF9FB1C8).withValues(alpha: 0.22),
      ),
    );
  }
}

class AudyPanel extends StatelessWidget {
  const AudyPanel({
    super.key,
    required this.adaptive,
    required this.child,
    this.padding,
  });

  final AudyAdaptive adaptive;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(adaptive.space(22)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(adaptive.space(28)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF98A7C0).withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AudyBackButton extends StatelessWidget {
  const AudyBackButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.arrow_back_rounded),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF526683),
        padding: EdgeInsets.zero,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class AudyMascot extends StatelessWidget {
  const AudyMascot({super.key, this.size = 108});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [Color(0xFFFFF0B5), Color(0x00FFF0B5)],
        ),
      ),
      child: Center(
        child: AudyBadgeIcon(
          icon: Icons.pets_rounded,
          size: size * 0.68,
          background: const Color(0xFFFFE3AF),
          foreground: const Color(0xFFF28C28),
        ),
      ),
    );
  }
}

class AudyBadgeIcon extends StatelessWidget {
  const AudyBadgeIcon({
    super.key,
    required this.icon,
    required this.size,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final double size;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: foreground.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(icon, color: foreground, size: size * 0.55),
    );
  }
}

class AudyAdaptiveGrid extends StatelessWidget {
  const AudyAdaptiveGrid({
    super.key,
    required this.adaptive,
    required this.phoneColumns,
    required this.tabletColumns,
    required this.desktopColumns,
    required this.items,
  });

  final AudyAdaptive adaptive;
  final int phoneColumns;
  final int tabletColumns;
  final int desktopColumns;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    final columns = adaptive.columns(
      phone: phoneColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = adaptive.space(18);
        final itemWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items
              .map((item) => SizedBox(width: itemWidth, child: item))
              .toList(),
        );
      },
    );
  }
}
