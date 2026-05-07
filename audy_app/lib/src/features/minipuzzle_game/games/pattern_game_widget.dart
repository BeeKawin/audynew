import 'package:flutter/material.dart';

import '../../../core/audy_ui.dart';
import '../../../state/audy_controller.dart';
import '../minipuzzle_controller.dart';
import '../minipuzzle_models.dart';

String _tr(BuildContext context, String key, {Map<String, String>? params}) {
  return AudyScope.of(context).tr(key, params: params);
}

/// Pattern recognition game widget.
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

  double get _sequenceSize {
    if (adaptive.isPhone) return 72;
    if (adaptive.isTablet) return 86;
    return 96;
  }

  double get _choiceSize {
    if (adaptive.isPhone) return 104;
    if (adaptive.isTablet) return 116;
    return 124;
  }

  @override
  Widget build(BuildContext context) {
    final patternData = controller.patternData;
    if (patternData == null) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _tr(context, 'minipuzzle_pattern_prompt'),
          style: TextStyle(
            fontSize: adaptive.space(24),
            fontWeight: FontWeight.w800,
            color: const Color(0xFF243A5A),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: adaptive.space(28)),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: adaptive.space(12),
          runSpacing: adaptive.space(12),
          children: [
            ...patternData.sequence.map(
              (token) => _PatternItem(token: token, size: _sequenceSize),
            ),
            _QuestionCard(size: _sequenceSize, color: gameColor),
          ],
        ),
        SizedBox(height: adaptive.space(36)),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: adaptive.space(16),
          runSpacing: adaptive.space(16),
          children: patternData.choices
              .map(
                (token) => GestureDetector(
                  onTap: controller.showingFeedback
                      ? null
                      : () => controller.submitPatternAnswer(token),
                  child: _PatternItem(
                    token: token,
                    size: _choiceSize,
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

class _QuestionCard extends StatelessWidget {
  final double size;
  final Color color;

  const _QuestionCard({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 3),
      ),
      child: Icon(
        Icons.question_mark_rounded,
        size: size * 0.55,
        color: color,
      ),
    );
  }
}

class _PatternItem extends StatelessWidget {
  final PatternToken token;
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
        border: Border.all(
          color: isSelectable ? token.color : token.color.withValues(alpha: 0.3),
          width: isSelectable ? 3 : 2,
        ),
        boxShadow: isSelectable
            ? [
                BoxShadow(
                  color: token.color.withValues(alpha: 0.22),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Icon(token.icon, size: size * 0.64, color: token.color),
    );
  }
}
