import 'package:flutter/material.dart';

import '../../core/audy_ui.dart';
import '../../state/audy_controller.dart';
import '../../widgets/gentle_animations.dart';

/// Room tab for customizing virtual space
/// Allows drag & drop of owned accessories
class RewardsRoomTab extends StatefulWidget {
  final AudyAdaptive adaptive;
  final AudyController controller;

  const RewardsRoomTab({
    super.key,
    required this.adaptive,
    required this.controller,
  });

  @override
  State<RewardsRoomTab> createState() => _RewardsRoomTabState();
}

class _RewardsRoomTabState extends State<RewardsRoomTab> {
  bool _showResetDialog = false;
  String? _draggedAccessoryName;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Room display area - Drop target
        AspectRatio(
          aspectRatio: 16 / 9,
          child: DragTarget<String>(
            onAcceptWithDetails: (details) {
              _handleDrop(details.data, details.offset);
            },
            onWillAcceptWithDetails: (details) {
              setState(() => _draggedAccessoryName = details.data);
              return true;
            },
            onLeave: (_) {
              setState(() => _draggedAccessoryName = null);
            },
            builder: (context, candidateData, rejectedData) {
              return Container(
                decoration: BoxDecoration(
                  color: _draggedAccessoryName != null
                      ? const Color(0xFFE7D8FA).withValues(alpha: 0.5)
                      : const Color(0xFFE8F4FD),
                  borderRadius: BorderRadius.circular(
                    widget.adaptive.space(22),
                  ),
                  border: _draggedAccessoryName != null
                      ? Border.all(color: const Color(0xFF5D4F97), width: 3)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9FAFC4).withValues(alpha: 0.14),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    widget.adaptive.space(22),
                  ),
                  child: Stack(
                    children: [
                      // Room background
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.home_outlined,
                              size: widget.adaptive.space(60),
                              color: const Color(0xFFBDD8F2),
                            ),
                            SizedBox(height: widget.adaptive.space(8)),
                            Text(
                              'Drag accessories here',
                              style: TextStyle(
                                fontSize: widget.adaptive.space(14),
                                color: const Color(0xFF60758F),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Placed accessories
                      ...widget.controller.placedAccessories.map((accessory) {
                        return Positioned(
                          left: accessory.x?.toDouble() ?? 0,
                          top: accessory.y?.toDouble() ?? 0,
                          child: GentlePulse(
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                accessory.icon,
                                size: 32,
                                color: const Color(0xFF5D4F97),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: widget.adaptive.space(20)),
        // Reset button
        ElevatedButton.icon(
          onPressed: () => setState(() => _showResetDialog = true),
          icon: const Icon(Icons.refresh, size: 20),
          label: const Text('Reset Progress'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFCDD2),
            foregroundColor: const Color(0xFFC62828),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            minimumSize: const Size(48, 48), // Autism-friendly touch target
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        SizedBox(height: widget.adaptive.space(20)),
        // Owned accessories picker - Draggable items
        Text(
          'Your Accessories',
          style: TextStyle(
            fontSize: widget.adaptive.space(18),
            fontWeight: FontWeight.w800,
            color: const Color(0xFF243A5A),
          ),
        ),
        SizedBox(height: widget.adaptive.space(12)),
        // Horizontal scroll of owned accessories
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: widget.controller.ownedAccessories.map((accessory) {
              return Padding(
                padding: EdgeInsets.only(right: widget.adaptive.space(12)),
                child: Draggable<String>(
                  data: accessory.name,
                  feedback: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7D8FA),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        accessory.icon,
                        size: 32,
                        color: const Color(0xFF5D4F97),
                      ),
                    ),
                  ),
                  childWhenDragging: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      accessory.icon,
                      size: 32,
                      color: Colors.grey[400],
                    ),
                  ),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE2E5EA),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      accessory.icon,
                      size: 32,
                      color: const Color(0xFF5D4F97),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // Reset confirmation dialog
        if (_showResetDialog)
          _ResetDialog(
            onCancel: () => setState(() => _showResetDialog = false),
            onConfirm: () async {
              await widget.controller.resetProgress();
              setState(() => _showResetDialog = false);
            },
          ),
      ],
    );
  }

  void _handleDrop(String accessoryName, Offset offset) {
    // Calculate position relative to the room container
    // The offset is global, we need to convert it to local coordinates
    final RenderBox? roomBox = context.findRenderObject() as RenderBox?;
    if (roomBox != null) {
      final localOffset = roomBox.globalToLocal(offset);
      // Adjust for padding and center the accessory
      final x = (localOffset.dx - 28)
          .clamp(0.0, roomBox.size.width - 56)
          .toInt();
      final y = (localOffset.dy - 28)
          .clamp(0.0, roomBox.size.height - 56)
          .toInt();

      widget.controller.placeAccessoryInRoom(accessoryName, x, y);
    }
    setState(() => _draggedAccessoryName = null);
  }
}

class _ResetDialog extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _ResetDialog({required this.onCancel, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GentleFade(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_rounded,
                size: 48,
                color: Color(0xFFFFA726),
              ),
              const SizedBox(height: 16),
              const Text(
                'Start Fresh?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF243A5A),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'This will reset your progress. You\'ll keep your owned accessories.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xFF60758F)),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: onCancel,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(48, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFCDD2),
                        foregroundColor: const Color(0xFFC62828),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(48, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: const Text('Reset'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
