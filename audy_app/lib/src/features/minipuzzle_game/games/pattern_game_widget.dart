import 'package:flutter/material.dart';
import '../../../core/audy_ui.dart';
import '../minipuzzle_controller.dart';

/// Pattern recognition game widget
/// Shows a sequence and asks user to pick the next item
class PatternGameWidget extends StatelessWidget {
  final MiniPuzzleController controller;
  final AudyAdaptive adaptive;
  final Color gameColor;

  const PatternGameWidget({
    super.key,
    required this.controller,
    required this.adaptive,
    required this.gameColor,
  });

  @override
  Widget build(BuildContext context) {
    final patternData = controller.patternData;
    if (patternData == null) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          'What comes next?',
          style: TextStyle(
            fontSize: adaptive.space(24),
            fontWeight: FontWeight.w800,
            color: const Color(0xFF243A5A),
          ),
        ),
        SizedBox(height: adaptive.space(32)),

        // Pattern sequence
        Wrap(
          alignment: WrapAlignment.center,
          spacing: adaptive.space(16),
          runSpacing: adaptive.space(16),
          children: [
            ...patternData.sequence.map(
              (token) => _PatternItem(token: token, size: adaptive.space(80)),
            ),
            // Question mark placeholder
            Container(
              width: adaptive.space(80),
              height: adaptive.space(80),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: gameColor,
                  width: 3,
                  style: BorderStyle.solid,
                ),
              ),
              child: Icon(
                Icons.question_mark_rounded,
                size: adaptive.space(40),
                color: gameColor,
              ),
            ),
          ],
        ),
        SizedBox(height: adaptive.space(48)),

        // Choices
        Text(
          'Tap the answer:',
          style: TextStyle(
            fontSize: adaptive.space(18),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF60758F),
          ),
        ),
        SizedBox(height: adaptive.space(24)),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: adaptive.space(20),
          runSpacing: adaptive.space(20),
          children: patternData.choices
              .map(
                (token) => GestureDetector(
                  onTap: controller.showingFeedback
                      ? null
                      : () => controller.submitPatternAnswer(token),
                  child: _PatternItem(
                    token: token,
                    size: adaptive.space(100),
                    isSelectable: true,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _PatternItem extends StatelessWidget {
  final dynamic token;
  final double size;
  final bool isSelectable;

  const _PatternItem({
    required this.token,
    required this.size,
    this.isSelectable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: token.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: isSelectable ? Border.all(color: token.color, width: 3) : null,
        boxShadow: isSelectable
            ? [
                BoxShadow(
                  color: token.color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Icon(token.icon, size: size * 0.5, color: token.color),
    );
  }
}
