import 'package:flutter/material.dart';

import '../../core/app_routes.dart';
import '../../services/sound_service.dart';

class ReadPronounceHub extends StatelessWidget {
  const ReadPronounceHub({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final adaptive = _AudyAdaptive(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
            );

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: adaptive.isPhone ? 20 : adaptive.space(28),
                vertical: adaptive.isPhone ? 20 : adaptive.space(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TopRow(
                    adaptive: adaptive,
                    onBack: () {
                      SoundService.instance.playTap();
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(height: adaptive.space(24)),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Read & Pronounce',
                          style: TextStyle(
                            fontSize: adaptive.space(28),
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF243A5A),
                          ),
                        ),
                        SizedBox(height: adaptive.space(8)),
                        Text(
                          'Choose your learning level.',
                          style: TextStyle(
                            fontSize: adaptive.space(15),
                            color: const Color(0xFF617691),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: adaptive.space(28)),
                  _ModuleCard(
                    adaptive: adaptive,
                    title: 'Letters',
                    subtitle: 'A B C sounds',
                    icon: Icons.abc_rounded,
                    color: const Color(0xFFFF8D91),
                    onTap: () {
                      SoundService.instance.playTap();
                      Navigator.pushNamed(context, AppRoutes.letters);
                    },
                  ),
                  SizedBox(height: adaptive.space(16)),
                  _ModuleCard(
                    adaptive: adaptive,
                    title: 'Words',
                    subtitle: 'Simple vocabulary',
                    icon: Icons.menu_book_rounded,
                    color: const Color(0xFF8FBCEC),
                    onTap: () {
                      SoundService.instance.playTap();
                      Navigator.pushNamed(context, AppRoutes.words);
                    },
                  ),
                  SizedBox(height: adaptive.space(16)),
                  _ModuleCard(
                    adaptive: adaptive,
                    title: 'Sentences',
                    subtitle: 'Short phrases',
                    icon: Icons.chat_bubble_rounded,
                    color: const Color(0xFF90F48A),
                    onTap: () {
                      SoundService.instance.playTap();
                      Navigator.pushNamed(context, AppRoutes.sentences);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ModuleCard extends StatefulWidget {
  const _ModuleCard({
    required this.adaptive,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final _AudyAdaptive adaptive;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
      lowerBound: 0.97,
      upperBound: 1.0,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _controller.reverse();
  void _onTapUp(TapUpDetails details) => _controller.forward();
  void _onTapCancel() => _controller.forward();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          constraints: const BoxConstraints(minHeight: 160),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F8FC),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: widget.color, width: 3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF99A9C0).withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: widget.adaptive.space(96),
                height: widget.adaptive.space(96),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  size: widget.adaptive.space(52),
                  color: widget.color,
                ),
              ),
              SizedBox(width: widget.adaptive.space(20)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: widget.adaptive.space(22),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF243A5A),
                      ),
                    ),
                    SizedBox(height: widget.adaptive.space(4)),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: widget.adaptive.space(14),
                        color: const Color(0xFF617691),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                size: widget.adaptive.space(28),
                color: widget.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow({required this.adaptive, required this.onBack});

  final _AudyAdaptive adaptive;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onBack,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back_rounded,
              size: adaptive.space(22),
              color: const Color(0xFF617691),
            ),
            SizedBox(width: adaptive.space(8)),
            Text(
              'Back to Home',
              style: TextStyle(
                fontSize: adaptive.space(15),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF617691),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AudyAdaptive {
  const _AudyAdaptive({required this.width, required this.height});

  final double width;
  final double height;

  bool get isPhone => width < 600;
  bool get isTablet => width >= 600 && width < 1024;
  bool get isDesktop => width >= 1024;

  double get scale => (width / 390).clamp(0.92, 1.35);
  double space(double value) => value * scale;
}
