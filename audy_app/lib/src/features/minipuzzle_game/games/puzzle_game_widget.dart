import 'package:flutter/material.dart';
import '../../../core/audy_ui.dart';
import '../minipuzzle_controller.dart';

/// Puzzle game widget
/// Drag and drop pieces into matching slots
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
  @override
  Widget build(BuildContext context) {
    final puzzleData = widget.controller.puzzleData;
    if (puzzleData == null) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          'Match the shapes!',
          style: TextStyle(
            fontSize: widget.adaptive.space(24),
            fontWeight: FontWeight.w800,
            color: const Color(0xFF243A5A),
          ),
        ),
        SizedBox(height: widget.adaptive.space(24)),

        // Instruction
        Text(
          'Drag pieces to matching slots',
          style: TextStyle(
            fontSize: widget.adaptive.space(16),
            color: const Color(0xFF60758F),
          ),
        ),
        SizedBox(height: widget.adaptive.space(32)),

        // Slots (drop targets)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: puzzleData.slots.map((slot) {
            final piece = puzzleData.pieces.firstWhere(
              (p) => p.currentSlotId == slot.id,
              orElse: () => puzzleData.pieces.firstWhere(
                (p) => p.id == 'not_found',
                orElse: () => puzzleData.pieces[0],
              ),
            );
            final hasPiece = piece.currentSlotId == slot.id;

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: widget.adaptive.space(8),
              ),
              child: DragTarget<String>(
                onWillAcceptWithDetails: (details) =>
                    !widget.controller.showingFeedback,
                onAcceptWithDetails: (details) {
                  widget.controller.placePuzzlePiece(details.data, slot.id);
                },
                builder: (context, candidateData, rejectedData) {
                  final isHighlighted = candidateData.isNotEmpty;
                  return Container(
                    width: widget.adaptive.space(90),
                    height: widget.adaptive.space(90),
                    decoration: BoxDecoration(
                      color: isHighlighted
                          ? slot.hintColor.withValues(alpha: 0.3)
                          : const Color(0xFFF0F4FA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isHighlighted
                            ? slot.hintColor
                            : const Color(0xFFD3DBE7),
                        width: isHighlighted ? 4 : 2,
                      ),
                    ),
                    child: hasPiece
                        ? Icon(
                            piece.icon,
                            size: widget.adaptive.space(50),
                            color: piece.color,
                          )
                        : Icon(
                            Icons.add_rounded,
                            size: widget.adaptive.space(32),
                            color: const Color(0xFFA0AFC4),
                          ),
                  );
                },
              ),
            );
          }).toList(),
        ),
        SizedBox(height: widget.adaptive.space(48)),

        // Divider
        Divider(
          color: const Color(0xFFE2E7EE),
          thickness: 2,
          indent: widget.adaptive.space(20),
          endIndent: widget.adaptive.space(20),
        ),
        SizedBox(height: widget.adaptive.space(32)),

        // Draggable pieces
        Text(
          'Your pieces:',
          style: TextStyle(
            fontSize: widget.adaptive.space(16),
            color: const Color(0xFF60758F),
          ),
        ),
        SizedBox(height: widget.adaptive.space(16)),
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: widget.adaptive.space(100)),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: widget.adaptive.space(16),
            runSpacing: widget.adaptive.space(16),
            children: puzzleData.pieces
                .where((p) => p.currentSlotId == null)
                .map((piece) {
                  return Draggable<String>(
                    data: piece.id,
                    feedback: Container(
                      width: widget.adaptive.space(80),
                      height: widget.adaptive.space(80),
                      decoration: BoxDecoration(
                        color: piece.color.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: piece.color, width: 3),
                      ),
                      child: Icon(
                        piece.icon,
                        size: widget.adaptive.space(44),
                        color: piece.color,
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: _PieceWidget(
                        piece: piece,
                        size: widget.adaptive.space(80),
                      ),
                    ),
                    child: GestureDetector(
                      onTap: widget.controller.showingFeedback
                          ? null
                          : () => _showSlotSelection(context, piece.id),
                      child: _PieceWidget(
                        piece: piece,
                        size: widget.adaptive.space(80),
                      ),
                    ),
                  );
                })
                .toList(),
          ),
        ),
      ],
    );
  }

  void _showSlotSelection(BuildContext context, String pieceId) {
    final puzzleData = widget.controller.puzzleData;
    if (puzzleData == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Place in which slot?'),
        content: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: puzzleData.slots.map((slot) {
            final isOccupied = puzzleData.pieces.any(
              (p) => p.currentSlotId == slot.id,
            );
            return GestureDetector(
              onTap: isOccupied
                  ? null
                  : () {
                      widget.controller.placePuzzlePiece(pieceId, slot.id);
                      Navigator.pop(context);
                    },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isOccupied
                      ? Colors.grey.shade200
                      : slot.hintColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isOccupied ? Colors.grey : slot.hintColor,
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Text(
                    isOccupied
                        ? 'Full'
                        : 'Slot ${int.parse(slot.id.split('_')[1]) + 1}',
                    style: TextStyle(
                      color: isOccupied ? Colors.grey : const Color(0xFF243A5A),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _PieceWidget extends StatelessWidget {
  final dynamic piece;
  final double size;

  const _PieceWidget({required this.piece, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: piece.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: piece.color, width: 3),
        boxShadow: [
          BoxShadow(
            color: piece.color.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(piece.icon, size: size * 0.5, color: piece.color),
    );
  }
}
