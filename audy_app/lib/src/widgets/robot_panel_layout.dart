import 'package:flutter/material.dart';

import '../core/audy_ui.dart';

class RobotPanelLayout extends StatelessWidget {
  const RobotPanelLayout({
    super.key,
    required this.adaptive,
    required this.child,
    required this.showPanel,
    required this.panelBuilder,
    this.gap,
  });

  final AudyAdaptive adaptive;
  final Widget child;
  final bool showPanel;
  final Widget Function(bool isHorizontal) panelBuilder;
  final double? gap;

  @override
  Widget build(BuildContext context) {
    if (!showPanel) return child;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isHorizontal = constraints.maxWidth >= constraints.maxHeight;
        final panel = panelBuilder(isHorizontal);

        if (isHorizontal) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: child),
              SizedBox(width: gap ?? adaptive.space(16)),
              panel,
            ],
          );
        }

        return Stack(
          children: [
            Positioned.fill(child: child),
            Positioned(left: 0, right: 0, bottom: 0, child: panel),
          ],
        );
      },
    );
  }
}
