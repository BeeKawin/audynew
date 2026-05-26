import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../core/audy_theme.dart';
import '../core/audy_ui.dart';
import '../services/sound_service.dart';
import '../state/audy_controller.dart';

class VirtualRobotPanel extends StatefulWidget {
  const VirtualRobotPanel({
    super.key,
    required this.adaptive,
    required this.isHorizontal,
    this.onTummyTap,
    this.onNoseTap,
    this.onEarsLeftTap,
    this.onEarsRightTap,
    this.onForceLeftTap,
    this.onForceRightTap,
    this.initiallyCollapsed = false,
  });

  final AudyAdaptive adaptive;
  final bool isHorizontal;
  final VoidCallback? onTummyTap;
  final VoidCallback? onNoseTap;
  final VoidCallback? onEarsLeftTap;
  final VoidCallback? onEarsRightTap;
  final VoidCallback? onForceLeftTap;
  final VoidCallback? onForceRightTap;
  final bool initiallyCollapsed;

  @override
  State<VirtualRobotPanel> createState() => _VirtualRobotPanelState();
}

class _VirtualRobotPanelState extends State<VirtualRobotPanel> {
  late bool _isCollapsed;

  @override
  void initState() {
    super.initState();
    _isCollapsed = widget.initiallyCollapsed;
  }

  String _tr(BuildContext context, String key) {
    return AudyScope.of(context).tr(key);
  }

  void _toggleCollapsed() {
    SoundService.instance.playTap();
    setState(() => _isCollapsed = !_isCollapsed);
  }

  @override
  Widget build(BuildContext context) {
    final collapsedExtent = widget.adaptive.space(72);
    final expandedExtent = widget.isHorizontal
        ? widget.adaptive.space(300)
        : widget.adaptive.space(320);
    final width = widget.isHorizontal
        ? (_isCollapsed ? collapsedExtent : expandedExtent)
        : double.infinity;
    final height = widget.isHorizontal
        ? null
        : (_isCollapsed ? collapsedExtent : expandedExtent);

    return AnimatedContainer(
      duration: AudyAnimation.normal,
      curve: Curves.easeOut,
      width: width,
      height: height,
      padding: EdgeInsets.all(widget.adaptive.space(12)),
      decoration: BoxDecoration(
        color: AudyColors.backgroundCard,
        borderRadius: BorderRadius.circular(widget.adaptive.space(20)),
        border: Border.all(color: AudyColors.borderLight, width: 2),
        boxShadow: AudyShadows.cardShadow,
      ),
      child: _isCollapsed ? _buildCollapsed(context) : _buildExpanded(context),
    );
  }

  Widget _buildCollapsed(BuildContext context) {
    return Center(
      child: IconButton(
        onPressed: _toggleCollapsed,
        tooltip: _tr(context, 'virtual_robot_expand'),
        icon: Icon(
          Icons.smart_toy_rounded,
          size: widget.adaptive.space(30),
          color: AudyColors.skyBlue,
        ),
      ),
    );
  }

  Widget _buildExpanded(BuildContext context) {
    final actions = _buildActions(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              Icons.smart_toy_rounded,
              color: AudyColors.skyBlue,
              size: widget.adaptive.space(28),
            ),
            SizedBox(width: widget.adaptive.space(10)),
            Expanded(
              child: Text(
                _tr(context, 'virtual_robot'),
                style: AudyTypography.labelLarge,
              ),
            ),
            IconButton(
              onPressed: _toggleCollapsed,
              tooltip: _tr(context, 'virtual_robot_collapse'),
              icon: Icon(
                widget.isHorizontal
                    ? Icons.chevron_right_rounded
                    : Icons.expand_more_rounded,
                size: widget.adaptive.space(28),
                color: AudyColors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: widget.adaptive.space(8)),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.adaptive.space(16)),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AudyColors.backgroundSoft,
                      border: Border.all(
                        color: AudyColors.borderLight,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Opacity(
                        opacity: 0.15,
                        child: AudyMascot(size: widget.adaptive.space(90)),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: ModelViewer(
                    src: 'assets/3d/AUDYFI.glb',
                    alt: 'AUDY virtual robot',
                    ar: false,
                    autoRotate: false,
                    cameraControls: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (actions.isNotEmpty) ...[
          SizedBox(height: widget.adaptive.space(10)),
          Text(
            _tr(context, 'virtual_robot_controls'),
            style: AudyTypography.labelMedium.copyWith(
              color: AudyColors.textSecondary,
            ),
          ),
          SizedBox(height: widget.adaptive.space(8)),
          Wrap(
            spacing: widget.adaptive.space(10),
            runSpacing: widget.adaptive.space(10),
            children: actions,
          ),
        ],
      ],
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final actions = <_RobotAction>[
      if (widget.onTummyTap != null)
        _RobotAction(
          label: _tr(context, 'virtual_tummy'),
          icon: Icons.favorite_rounded,
          color: AudyColors.mintGreen,
          onTap: widget.onTummyTap!,
        ),
      if (widget.onNoseTap != null)
        _RobotAction(
          label: _tr(context, 'virtual_nose'),
          icon: Icons.radio_button_checked_rounded,
          color: AudyColors.skyBlue,
          onTap: widget.onNoseTap!,
        ),
      if (widget.onEarsLeftTap != null)
        _RobotAction(
          label: _tr(context, 'virtual_ear_left'),
          icon: Icons.hearing_rounded,
          color: AudyColors.softLavender,
          onTap: widget.onEarsLeftTap!,
        ),
      if (widget.onEarsRightTap != null)
        _RobotAction(
          label: _tr(context, 'virtual_ear_right'),
          icon: Icons.hearing_rounded,
          color: AudyColors.softLavender,
          onTap: widget.onEarsRightTap!,
        ),
      if (widget.onForceLeftTap != null)
        _RobotAction(
          label: _tr(context, 'virtual_force_left'),
          icon: Icons.back_hand_rounded,
          color: AudyColors.activityRewards,
          onTap: widget.onForceLeftTap!,
        ),
      if (widget.onForceRightTap != null)
        _RobotAction(
          label: _tr(context, 'virtual_force_right'),
          icon: Icons.back_hand_rounded,
          color: AudyColors.activityRewards,
          onTap: widget.onForceRightTap!,
        ),
    ];

    return actions
        .map(
          (action) => _RobotControlButton(
            adaptive: widget.adaptive,
            label: action.label,
            icon: action.icon,
            color: action.color,
            onTap: () {
              SoundService.instance.playTap();
              action.onTap();
            },
          ),
        )
        .toList();
  }
}

class _RobotAction {
  const _RobotAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class _RobotControlButton extends StatelessWidget {
  const _RobotControlButton({
    required this.adaptive,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final AudyAdaptive adaptive;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: adaptive.space(92),
        minHeight: adaptive.space(AudySpacing.touchTargetMin),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(adaptive.space(18)),
          child: Ink(
            padding: EdgeInsets.symmetric(
              horizontal: adaptive.space(12),
              vertical: adaptive.space(10),
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(adaptive.space(18)),
              border: Border.all(color: color, width: 2),
              boxShadow: AudyShadows.cardShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: adaptive.space(22), color: color),
                SizedBox(height: adaptive.space(4)),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: adaptive.space(12),
                    fontWeight: FontWeight.w700,
                    color: AudyColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
