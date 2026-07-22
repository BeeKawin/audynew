import 'package:flutter/material.dart';

import '../core/audy_ui.dart';

class RobotPanelLayout extends StatelessWidget {
  const RobotPanelLayout({
    super.key,
    required this.adaptive,
    required this.child,
    required this.showPanel,
    required this.panelBuilder,
    this.virtualRobotEnabled = false,
    this.gap,
  });

  final AudyAdaptive adaptive;
  final Widget child;
  final bool showPanel;
  final Widget Function(bool isHorizontal) panelBuilder;
  final bool virtualRobotEnabled;
  final double? gap;

  @override
  Widget build(BuildContext context) {
    if (!virtualRobotEnabled || !showPanel) return child;

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
