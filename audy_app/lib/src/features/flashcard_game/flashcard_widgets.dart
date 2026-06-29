import 'package:flutter/material.dart';

import '../../core/audy_theme.dart';
import '../../state/audy_controller.dart';
import 'flashcard_models.dart';

String _tr(BuildContext context, String key, {Map<String, String>? params}) {
  return AudyScope.of(context).tr(key, params: params);
}

/// Payload carried while dragging a card. [fromSlot] is null when the card
/// originates from the hand, or the slot index when dragged out of the rail.
class FlashDragData {
  const FlashDragData({required this.card, this.fromSlot});
  final FlashCard card;
  final int? fromSlot;
}

/// Per-card feedback glow shown during left→right submit evaluation.
enum CardGlow { none, correct, wrong }

/// The visual face of a flash card: POS label, picture glyph, word.
class FlashCardFace extends StatelessWidget {
  const FlashCardFace({
    super.key,
    required this.card,
    required this.width,
    required this.height,
    this.faded = false,
    this.glow = CardGlow.none,
  });

  final FlashCard card;
  final double width;
  final double height;
  final bool faded;

  /// Feedback glow: green (correct) / red (wrong) animated border + shadow.
  final CardGlow glow;

  @override
  Widget build(BuildContext context) {
    final color = card.color;
    final glyphSize = (height * 0.34).clamp(28.0, 56.0);
    final wordSize = (height * 0.13).clamp(15.0, 22.0);

    final Color? glowColor = switch (glow) {
      CardGlow.correct => AudyColors.mintGreen,
      CardGlow.wrong => AudyColors.error,
      CardGlow.none => null,
    };

    Widget buildCard(double t) {
      return Container(
        width: width,
        height: height,
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
        decoration: BoxDecoration(
          color: AudyColors.backgroundCard,
          borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
          border: Border.all(
            color: glowColor ?? color,
            width: glowColor != null ? 3.5 : 3,
          ),
          boxShadow: glowColor != null
              ? [
                  BoxShadow(
                    color: glowColor.withValues(alpha: 0.55 * t),
                    blurRadius: 22 * t,
                    spreadRadius: 1.5 * t,
                  ),
                ]
              : AudyShadows.cardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _tr(context, card.pos.labelKey),
                style: TextStyle(
                  fontSize: (height * 0.085).clamp(10.0, 13.0),
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: card.glyph != null
                    ? Text(card.glyph!, style: TextStyle(fontSize: glyphSize))
                    : Icon(
                        Icons.abc_rounded,
                        size: glyphSize,
                        color: color,
                      ),
              ),
            ),
            Text(
              card.word,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AudyTypography.cardTitle.copyWith(fontSize: wordSize),
            ),
          ],
        ),
      );
    }

    final faceOpacity = faded ? 0.35 : 1.0;
    if (glowColor == null) {
      return Opacity(opacity: faceOpacity, child: buildCard(0));
    }
    return Opacity(
      opacity: faceOpacity,
      child: TweenAnimationBuilder<double>(
        key: ValueKey(glow),
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOut,
        builder: (context, t, _) => buildCard(t),
      ),
    );
  }
}

/// A draggable card. Used both in the hand and inside a filled slot.
class FlashCardTile extends StatelessWidget {
  const FlashCardTile({
    super.key,
    required this.card,
    required this.width,
    required this.height,
    required this.enabled,
    this.fromSlot,
    this.onTap,
    this.glow = CardGlow.none,
  });

  final FlashCard card;
  final double width;
  final double height;
  final bool enabled;
  final int? fromSlot;
  final VoidCallback? onTap;
  final CardGlow glow;

  @override
  Widget build(BuildContext context) {
    final face =
        FlashCardFace(card: card, width: width, height: height, glow: glow);
    if (!enabled) return face;

    final data = FlashDragData(card: card, fromSlot: fromSlot);
    return GestureDetector(
      onTap: onTap,
      child: Draggable<FlashDragData>(
        data: data,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        feedback: Transform.translate(
          offset: Offset(-width / 2, -height / 2),
          child: Material(
            color: Colors.transparent,
            child: Transform.scale(
              scale: 1.06,
              child: FlashCardFace(card: card, width: width, height: height),
            ),
          ),
        ),
        childWhenDragging: FlashCardFace(
          card: card,
          width: width,
          height: height,
          faded: true,
        ),
        child: face,
      ),
    );
  }
}

/// A slot in the sentence rail. Accepts dropped cards; shows a ghost POS hint
/// when empty (per difficulty), or the placed card (itself draggable).
class SentenceSlot extends StatelessWidget {
  const SentenceSlot({
    super.key,
    required this.index,
    required this.card,
    required this.width,
    required this.height,
    required this.hint,
    required this.hintPos,
    required this.enabled,
    required this.onDropFromHand,
    required this.onDropFromSlot,
    required this.onTapCard,
    this.glow = CardGlow.none,
  });

  final int index;
  final FlashCard? card;
  final double width;
  final double height;
  final SlotHint hint;
  final PartOfSpeech? hintPos;
  final bool enabled;
  final void Function(String cardId) onDropFromHand;
  final void Function(int fromSlot) onDropFromSlot;
  final VoidCallback onTapCard;
  final CardGlow glow;

  @override
  Widget build(BuildContext context) {
    return DragTarget<FlashDragData>(
      onAcceptWithDetails: (details) {
        final data = details.data;
        if (data.fromSlot == null) {
          onDropFromHand(data.card.id);
        } else {
          onDropFromSlot(data.fromSlot!);
        }
      },
      builder: (context, candidate, rejected) {
        final hovering = candidate.isNotEmpty;
        if (card != null) {
          return FlashCardTile(
            card: card!,
            width: width,
            height: height,
            enabled: enabled,
            fromSlot: index,
            onTap: onTapCard,
            glow: glow,
          );
        }
        return _EmptySlot(
          width: width,
          height: height,
          hovering: hovering,
          hint: hint,
          hintPos: hintPos,
          slotNumber: index + 1,
        );
      },
    );
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot({
    required this.width,
    required this.height,
    required this.hovering,
    required this.hint,
    required this.hintPos,
    required this.slotNumber,
  });

  final double width;
  final double height;
  final bool hovering;
  final SlotHint hint;
  final PartOfSpeech? hintPos;
  final int slotNumber;

  @override
  Widget build(BuildContext context) {
    final hintColor = hintPos?.color ?? AudyColors.textLight;
    final showLabel = hint != SlotHint.none && hintPos != null;
    final labelOpacity = hint == SlotHint.full ? 0.9 : 0.45;

    return AnimatedContainer(
      duration: AudyAnimation.normal,
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: hovering
            ? hintColor.withValues(alpha: 0.16)
            : AudyColors.backgroundSoft.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
        border: Border.all(
          color: hovering
              ? hintColor
              : AudyColors.borderLight.withValues(alpha: 0.9),
          width: hovering ? 3 : 2,
        ),
      ),
      child: showLabel
          ? Opacity(
              opacity: labelOpacity,
              child: Text(
                _tr(context, hintPos!.labelKey),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: (height * 0.1).clamp(11.0, 15.0),
                  fontWeight: FontWeight.w700,
                  color: hintColor,
                ),
              ),
            )
          : Text(
              '$slotNumber',
              style: TextStyle(
                fontSize: (height * 0.18).clamp(16.0, 26.0),
                fontWeight: FontWeight.w700,
                color: AudyColors.textLight.withValues(alpha: 0.6),
              ),
            ),
    );
  }
}
