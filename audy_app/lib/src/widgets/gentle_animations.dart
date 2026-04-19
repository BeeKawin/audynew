import 'dart:math';

import 'package:flutter/material.dart';

/// Gentle fade animation for autism-friendly UX
class GentleFade extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final double delay;

  const GentleFade({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: child,
    );
  }
}

/// Gentle pulse animation (scale)
class GentlePulse extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const GentlePulse({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<GentlePulse> createState() => _GentlePulseState();
}

class _GentlePulseState extends State<GentlePulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1.0 + 0.05 * sin(_controller.value * pi);
        return Transform.scale(scale: scale, child: child);
      },
      child: widget.child,
    );
  }
}

/// Star burst animation for level up
class StarBurstAnimation extends StatefulWidget {
  final VoidCallback? onComplete;
  final Color color;

  const StarBurstAnimation({
    super.key,
    this.onComplete,
    this.color = const Color(0xFFF5C532),
  });

  @override
  State<StarBurstAnimation> createState() => _StarBurstAnimationState();
}

class _StarBurstAnimationState extends State<StarBurstAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Central star
            Transform.scale(
              scale: _scaleAnimation.value,
              child: Icon(
                Icons.star,
                size: 80,
                color: widget.color.withValues(
                  alpha: 1 - _scaleAnimation.value * 0.5,
                ),
              ),
            ),
            // Burst particles
            ...List.generate(8, (index) {
              final angle = index * (pi / 4);
              final distance = _scaleAnimation.value * 60;
              return Transform.translate(
                offset: Offset(distance * cos(angle), distance * sin(angle)),
                child: Icon(
                  Icons.star,
                  size: 24,
                  color: widget.color.withValues(
                    alpha: 1 - _scaleAnimation.value * 0.6,
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

/// Point earn animation - fades up
class PointEarnAnimation extends StatefulWidget {
  final int points;
  final VoidCallback? onComplete;

  const PointEarnAnimation({super.key, required this.points, this.onComplete});

  @override
  State<PointEarnAnimation> createState() => _PointEarnAnimationState();
}

class _PointEarnAnimationState extends State<PointEarnAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetY;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _offsetY = Tween<double>(
      begin: 20,
      end: -30,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 50),
    ]).animate(_controller);

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _offsetY.value),
          child: Opacity(
            opacity: _opacity.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5C532).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '+${widget.points}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFF5C532),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
