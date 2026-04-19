import 'package:flutter/material.dart';
import '../../../core/audy_ui.dart';
import '../minipuzzle_controller.dart';

/// Sorting game widget
/// Shows an item and asks user to sort it into a category
class SortingGameWidget extends StatelessWidget {
  final MiniPuzzleController controller;
  final AudyAdaptive adaptive;
  final Color gameColor;

  const SortingGameWidget({
    super.key,
    required this.controller,
    required this.adaptive,
    required this.gameColor,
  });

  @override
  Widget build(BuildContext context) {
    final sortingData = controller.sortingData;
    if (sortingData == null) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          'Where does this go?',
          style: TextStyle(
            fontSize: adaptive.space(24),
            fontWeight: FontWeight.w800,
            color: const Color(0xFF243A5A),
          ),
        ),
        SizedBox(height: adaptive.space(48)),

        // Item to sort
        Container(
          width: adaptive.space(140),
          height: adaptive.space(140),
          decoration: BoxDecoration(
            color: sortingData.itemToSort.color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: sortingData.itemToSort.color, width: 4),
            boxShadow: [
              BoxShadow(
                color: sortingData.itemToSort.color.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            sortingData.itemToSort.icon,
            size: adaptive.space(72),
            color: sortingData.itemToSort.color,
          ),
        ),
        SizedBox(height: adaptive.space(48)),

        // Category buttons
        Text(
          'Tap a category:',
          style: TextStyle(
            fontSize: adaptive.space(18),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF60758F),
          ),
        ),
        SizedBox(height: adaptive.space(24)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: sortingData.categories.map((category) {
            final isAnimal = category == 'animal';
            final bgColor = isAnimal
                ? const Color(0xFFB8E8C4)
                : const Color(0xFFFFF2A8);
            final icon = isAnimal
                ? Icons.pets_rounded
                : Icons.restaurant_rounded;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: adaptive.space(12)),
              child: GestureDetector(
                onTap: controller.showingFeedback
                    ? null
                    : () => controller.submitSortingAnswer(category),
                child: Container(
                  width: adaptive.space(140),
                  height: adaptive.space(140),
                  decoration: BoxDecoration(
                    color: bgColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: bgColor, width: 4),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: adaptive.space(56),
                        color: const Color(0xFF243A5A),
                      ),
                      SizedBox(height: adaptive.space(8)),
                      Text(
                        isAnimal ? 'Animal' : 'Food',
                        style: TextStyle(
                          fontSize: adaptive.space(18),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF243A5A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
