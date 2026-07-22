import 'package:flutter/material.dart';

import '../core/audy_ui.dart';

class RobotPanelLayout extends StatelessWidget {
  const RobotPanelLayout({
    super.key,
    required this.adaptive,
    required this.child,
    required this.showPanel,
    required this.panelBuilder,
<<<<<<< HEAD
    this.virtualRobotEnabled = false,
=======
>>>>>>> origin/Kongnew
    this.gap,
  });

  final AudyAdaptive adaptive;
  final Widget child;
  final bool showPanel;
  final Widget Function(bool isHorizontal) panelBuilder;
<<<<<<< HEAD
  final bool virtualRobotEnabled;
=======
>>>>>>> origin/Kongnew
  final double? gap;

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    if (!virtualRobotEnabled || !showPanel) return child;
=======
    if (!showPanel) return child;
>>>>>>> origin/Kongnew

    return LayoutBuilder(
      builder: (context, constraints) {
        final isHorizontal = constraints.maxWidth >= constraints.maxHeight;
        final panel = panelBuilder(isHorizontal);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            Positioned(
              top: gap ?? adaptive.space(8),
              right: gap ?? adaptive.space(8),
              child: panel,
            ),
          ],
        );
      },
    );
  }
}
