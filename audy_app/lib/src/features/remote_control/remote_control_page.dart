import 'package:flutter/material.dart';

import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../services/realtime_control_service.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';

class RemoteControlPage extends StatefulWidget {
  const RemoteControlPage({
    super.key,
    this.sendControl,
    this.playTap,
    this.translate,
  });

  final Future<void> Function(RemoteControlAction action)? sendControl;
  final VoidCallback? playTap;
  final String Function(String key, Map<String, String>? params)? translate;

  @override
  State<RemoteControlPage> createState() => _RemoteControlPageState();
}

class _RemoteControlPageState extends State<RemoteControlPage> {
  RemoteControlAction? _sendingAction;
  RemoteControlAction? _lastSentAction;
  bool _sendFailed = false;

  Future<void> _send(RemoteControlAction action) async {
    if (_sendingAction != null) return;

    (widget.playTap ?? SoundService.instance.playTap)();
    setState(() {
      _sendingAction = action;
      _sendFailed = false;
    });

    try {
      await (widget.sendControl ?? RealtimeControlService.instance.send)(
        action,
      );
      if (!mounted) return;
      setState(() {
        _lastSentAction = action;
        _sendFailed = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _sendFailed = true);
    } finally {
      if (mounted) setState(() => _sendingAction = null);
    }
  }

  String _tr(BuildContext context, String key, {Map<String, String>? params}) {
    final translate = widget.translate;
    if (translate != null) return translate(key, params);
    return AudyScope.of(context).tr(key, params: params);
  }

  String _labelFor(BuildContext context, RemoteControlAction action) {
    return _tr(context, switch (action) {
      RemoteControlAction.leftEar => 'control_left_ear',
      RemoteControlAction.rightEar => 'control_right_ear',
      RemoteControlAction.nose => 'control_nose',
      RemoteControlAction.leftArm => 'control_left_arm',
      RemoteControlAction.rightArm => 'control_right_arm',
      RemoteControlAction.tummy => 'control_tummy',
      RemoteControlAction.correctMimic => 'control_correct_mimic',
      RemoteControlAction.incorrectMimic => 'control_incorrect_mimic',
    });
  }

  @override
  Widget build(BuildContext context) {
    return AudyResponsivePage(
      builder: (context, adaptive) {
        final robotActions = [
          _ControlOption(
            action: RemoteControlAction.leftEar,
            icon: Icons.hearing_rounded,
            color: AudyColors.softLavender,
          ),
          _ControlOption(
            action: RemoteControlAction.rightEar,
            icon: Icons.hearing_rounded,
            color: AudyColors.softLavender,
          ),
          _ControlOption(
            action: RemoteControlAction.nose,
            icon: Icons.radio_button_checked_rounded,
            color: AudyColors.skyBlue,
          ),
          _ControlOption(
            action: RemoteControlAction.leftArm,
            icon: Icons.back_hand_rounded,
            color: AudyColors.activityRewards,
          ),
          _ControlOption(
            action: RemoteControlAction.rightArm,
            icon: Icons.back_hand_rounded,
            color: AudyColors.activityRewards,
          ),
          _ControlOption(
            action: RemoteControlAction.tummy,
            icon: Icons.favorite_rounded,
            color: AudyColors.mintGreen,
          ),
        ];
        final mimicActions = [
          _ControlOption(
            action: RemoteControlAction.correctMimic,
            icon: Icons.sentiment_very_satisfied_rounded,
            color: AudyColors.success,
          ),
          _ControlOption(
            action: RemoteControlAction.incorrectMimic,
            icon: Icons.sentiment_dissatisfied_rounded,
            color: AudyColors.error,
          ),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AudyBackButton(
              label: _tr(context, 'back'),
              onPressed: () {
                (widget.playTap ?? SoundService.instance.playTap)();
                Navigator.pop(context);
              },
            ),
            SizedBox(height: adaptive.space(18)),
            Text(
              _tr(context, 'control_page_title'),
              style: AudyTypography.headingLarge,
            ),
            SizedBox(height: adaptive.space(8)),
            Text(
              _tr(context, 'control_page_instruction'),
              style: AudyTypography.bodyMedium,
            ),
            SizedBox(height: adaptive.space(24)),
            _ControlSection(
              adaptive: adaptive,
              title: _tr(context, 'control_robot_section'),
              options: robotActions,
              sendingAction: _sendingAction,
              labelFor: (action) => _labelFor(context, action),
              onPressed: _send,
            ),
            SizedBox(height: adaptive.space(24)),
            _ControlSection(
              adaptive: adaptive,
              title: _tr(context, 'control_mimic_section'),
              options: mimicActions,
              sendingAction: _sendingAction,
              labelFor: (action) => _labelFor(context, action),
              onPressed: _send,
            ),
            SizedBox(height: adaptive.space(20)),
            Semantics(
              liveRegion: true,
              child: _ControlStatus(
                message: _statusMessage(context),
                isError: _sendFailed,
                isSending: _sendingAction != null,
              ),
            ),
          ],
        );
      },
    );
  }

  String _statusMessage(BuildContext context) {
    final sendingAction = _sendingAction;
    if (sendingAction != null) {
      return _tr(context, 'control_sending');
    }
    if (_sendFailed) {
      return _tr(context, 'control_send_failed');
    }
    final lastSentAction = _lastSentAction;
    if (lastSentAction != null) {
      return _tr(
        context,
        'control_sent',
        params: {'action': _labelFor(context, lastSentAction)},
      );
    }
    return _tr(context, 'control_ready');
  }
}

class _ControlOption {
  const _ControlOption({
    required this.action,
    required this.icon,
    required this.color,
  });

  final RemoteControlAction action;
  final IconData icon;
  final Color color;
}

class _ControlSection extends StatelessWidget {
  const _ControlSection({
    required this.adaptive,
    required this.title,
    required this.options,
    required this.sendingAction,
    required this.labelFor,
    required this.onPressed,
  });

  final AudyAdaptive adaptive;
  final String title;
  final List<_ControlOption> options;
  final RemoteControlAction? sendingAction;
  final String Function(RemoteControlAction action) labelFor;
  final ValueChanged<RemoteControlAction> onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AudyTypography.headingSmall),
        SizedBox(height: adaptive.space(14)),
        AudyAdaptiveGrid(
          adaptive: adaptive,
          phoneColumns: 2,
          tabletColumns: 3,
          desktopColumns: 3,
          items: options
              .map(
                (option) => _ControlButton(
                  adaptive: adaptive,
                  label: labelFor(option.action),
                  icon: option.icon,
                  color: option.color,
                  isSending: sendingAction == option.action,
                  onPressed: sendingAction == null
                      ? () => onPressed(option.action)
                      : null,
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.adaptive,
    required this.label,
    required this.icon,
    required this.color,
    required this.isSending,
    required this.onPressed,
  });

  final AudyAdaptive adaptive;
  final String label;
  final IconData icon;
  final Color color;
  final bool isSending;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: adaptive.space(116),
      child: Material(
        color: color.withValues(alpha: onPressed == null ? 0.08 : 0.18),
        borderRadius: BorderRadius.circular(AudySpacing.radiusSmall),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AudySpacing.radiusSmall),
          child: Ink(
            padding: EdgeInsets.all(adaptive.space(12)),
            decoration: BoxDecoration(
              border: Border.all(
                color: color.withValues(alpha: onPressed == null ? 0.35 : 0.9),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(AudySpacing.radiusSmall),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSending)
                  SizedBox(
                    width: adaptive.space(34),
                    height: adaptive.space(34),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: color,
                    ),
                  )
                else
                  Icon(icon, size: adaptive.space(38), color: color),
                SizedBox(height: adaptive.space(8)),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AudyTypography.labelMedium.copyWith(
                    fontSize: adaptive.space(15),
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

class _ControlStatus extends StatelessWidget {
  const _ControlStatus({
    required this.message,
    required this.isError,
    required this.isSending,
  });

  final String message;
  final bool isError;
  final bool isSending;

  @override
  Widget build(BuildContext context) {
    final color = isError ? AudyColors.error : AudyColors.skyBlue;
    final icon = isError
        ? Icons.error_outline_rounded
        : isSending
        ? Icons.sync_rounded
        : Icons.check_circle_outline_rounded;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: AudySpacing.touchTargetMin),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AudySpacing.radiusSmall),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: AudyTypography.labelMedium)),
        ],
      ),
    );
  }
}
