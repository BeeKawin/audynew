import 'package:flutter/material.dart';

import '../../../core/audy_ui.dart';
import '../../../state/audy_controller.dart';
import '../minipuzzle_controller.dart';
import '../minipuzzle_models.dart';

String _tr(BuildContext context, String key, {Map<String, String>? params}) {
  return AudyScope.of(context).tr(key, params: params);
}

/// Visual match game widget.
class PuzzleGameWidget extends StatefulWidget {
  final MiniPuzzleController controller;
  final AudyAdaptive adaptive;
  final Color gameColor;

  const PuzzleGameWidget({
    super.key,
    required this.controller,
    required this.adaptive,
    required this.gameColor,
  });

  @override
  State<PuzzleGameWidget> createState() => _PuzzleGameWidgetState();
}

class _PuzzleGameWidgetState extends State<PuzzleGameWidget> {
  String? _selectedPieceId;

  double get _slotSize {
    if (widget.adaptive.isPhone) return 104;
    if (widget.adaptive.isTablet) return 118;
    return 130;
  }

  double get _pieceSize {
    if (widget.adaptive.isPhone) return 104;
    if (widget.adaptive.isTablet) return 118;
    return 130;
  }

  @override
  Widget build(BuildContext context) {
    final puzzleData = widget.controller.puzzleData;
    if (puzzleData == null) return const SizedBox.shrink();

    final unplacedPieces =
        puzzleData.pieces.where((p) => p.currentSlotId == null).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _tr(context, 'minipuzzle_match_prompt'),
          style: TextStyle(
            fontSize: widget.adaptive.space(24),
            fontWeight: FontWeight.w800,
            color: const Color(0xFF243A5A),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: widget.adaptive.space(28)),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: widget.adaptive.space(14),
          runSpacing: widget.adaptive.space(14),
          children: puzzleData.slots.map((slot) {
            PuzzlePiece? placedPiece;
            for (final piece in puzzleData.pieces) {
              if (piece.currentSlotId == slot.id) {
                placedPiece = piece;
                break;
              }
            }

            return GestureDetector(
              onTap: widget.controller.showingFeedback ||
                      _selectedPieceId == null ||
                      placedPiece != null
                  ? null
                  : () => _placeSelectedPiece(slot.id),
              child: _SlotCard(
                slot: slot,
                placedPiece: placedPiece,
                size: _slotSize,
                isActive: _selectedPieceId != null && placedPiece == null,
              ),
            );
          }).toList(),
        ),
        SizedBox(height: widget.adaptive.space(34)),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: widget.adaptive.space(14),
          runSpacing: widget.adaptive.space(14),
          children: unplacedPieces.map((piece) {
            final isSelected = piece.id == _selectedPieceId;
            return GestureDetector(
              onTap: widget.controller.showingFeedback
                  ? null
                  : () {
                      setState(() {
                        _selectedPieceId = isSelected ? null : piece.id;
                      });
                    },
              child: _PieceCard(
                piece: piece,
                size: _pieceSize,
                isSelected: isSelected,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _placeSelectedPiece(String slotId) {
    final pieceId = _selectedPieceId;
    if (pieceId == null) return;

    widget.controller.placePuzzlePiece(pieceId, slotId);
    if (mounted) {
      setState(() {
        _selectedPieceId = null;
      });
    }
  }
}

class _SlotCard extends StatelessWidget {
  final PuzzleSlot slot;
  final PuzzlePiece? placedPiece;
  final double size;
  final bool isActive;

  const _SlotCard({
    required this.slot,
    required this.placedPiece,
    required this.size,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final piece = placedPiece;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: piece == null
            ? slot.hintColor.withValues(alpha: isActive ? 0.22 : 0.12)
            : piece.color.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: piece?.color ?? slot.hintColor,
          width: isActive ? 4 : 3,
        ),
      ),
      child: Icon(
        piece?.icon ?? slot.hintIcon ?? Icons.add_rounded,
        size: size * (piece == null ? 0.56 : 0.64),
        color: piece?.color ?? slot.hintColor,
      ),
    );
  }
}

class _PieceCard extends StatelessWidget {
  final PuzzlePiece piece;
  final double size;
  final bool isSelected;

  const _PieceCard({
    required this.piece,
    required this.size,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: piece.color.withValues(alpha: isSelected ? 0.34 : 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: piece.color,
            width: isSelected ? 5 : 3,
          ),
          boxShadow: [
            BoxShadow(
              color: piece.color.withValues(alpha: isSelected ? 0.28 : 0.16),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(piece.icon, size: size * 0.66, color: piece.color),
      ),
    );
  }
}
