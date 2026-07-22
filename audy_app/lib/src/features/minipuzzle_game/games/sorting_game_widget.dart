import 'package:flutter/material.dart';

import '../../../core/audy_ui.dart';
import '../../../services/sound_service.dart';
import '../../../state/audy_controller.dart';
import '../minipuzzle_controller.dart';
import '../minipuzzle_models.dart';

String _tr(BuildContext context, String key, {Map<String, String>? params}) {
  return AudyScope.of(context).tr(key, params: params);
}

/// Odd-one-out cognitive game widget.
class OddOneOutGameWidget extends StatelessWidget {
  final MiniPuzzleController controller;
  final AudyAdaptive adaptive;
  final Color gameColor;

  const OddOneOutGameWidget({
    super.key,
    required this.controller,
    required this.adaptive,
    required this.gameColor,
  });

  double get _cardSize {
    if (adaptive.isPhone) return 118;
    if (adaptive.isTablet) return 132;
    return 144;
  }

  @override
  Widget build(BuildContext context) {
    final data = controller.oddOneOutData;
    if (data == null) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _tr(context, 'minipuzzle_odd_prompt'),
          style: TextStyle(
            fontSize: adaptive.space(24),
            fontWeight: FontWeight.w800,
            color: const Color(0xFF243A5A),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: adaptive.space(30)),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: adaptive.space(16),
          runSpacing: adaptive.space(16),
          children: data.items
              .map(
                (item) => GestureDetector(
                  onTap: controller.showingFeedback
                      ? null
                      : () {
                          if (item.id == data.correctItemId) {
                            SoundService.instance.playCorrect();
                          } else {
                            SoundService.instance.playWrong();
                          }
                          controller.submitOddOneOutAnswer(item.id);
                        },
                  child: _OddItemCard(item: item, size: _cardSize),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _OddItemCard extends StatelessWidget {
  final OddOneOutItem item;
  final double size;

  const _OddItemCard({required this.item, required this.size});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: item.label,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: item.color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: item.color, width: 3),
          boxShadow: [
            BoxShadow(
              color: item.color.withValues(alpha: 0.18),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(item.icon, size: size * 0.66, color: item.color),
      ),
    );
  }
}
