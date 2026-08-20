import 'package:flutter/material.dart';

import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../services/debug_broadcast_service.dart';
import '../../services/sound_service.dart';

/// DEBUG tool, reached by tapping the bear on the student Profile page.
///
/// Every button here broadcasts a fake event over the backend's
/// `/ws/debug-broadcast` relay. Any other device with the app open receives
/// it and executes it exactly as if it were real: touch events are injected
/// into the same [AudyBluetoothService] stream real BLE touches use,
/// "Emotion Mimic" events resolve whichever device is on the selfie-capture
/// screen right now, and "Emotion Down" pushes the EmotionDown lock screen
/// on top of whatever every other device is currently showing. There's no
/// pairing — this is a global broadcast, so every connected device reacts.
class DebugBroadcastPage extends StatefulWidget {
  const DebugBroadcastPage({super.key});

  @override
  State<DebugBroadcastPage> createState() => _DebugBroadcastPageState();
}

class _DebugBroadcastPageState extends State<DebugBroadcastPage> {
  static const List<_TouchZone> _touchZones = [
    _TouchZone(
      label: 'Left Ear',
      icon: Icons.hearing_rounded,
      channel: 'ears',
      value: 1,
      color: AudyColors.skyBlue,
    ),
    _TouchZone(
      label: 'Right Ear',
      icon: Icons.hearing_rounded,
      channel: 'ears',
      value: 2,
      color: AudyColors.skyBlue,
    ),
    _TouchZone(
      label: 'Nose',
      icon: Icons.face_rounded,
      channel: 'nose',
      value: 1,
      color: AudyColors.blushPink,
    ),
    _TouchZone(
      label: 'Tummy',
      icon: Icons.favorite_rounded,
      channel: 'tummy',
      value: 1,
      color: AudyColors.mintGreen,
    ),
    _TouchZone(
      label: 'Left Arm',
      icon: Icons.back_hand_rounded,
      channel: 'force',
      value: 1,
      color: AudyColors.softLavender,
    ),
    _TouchZone(
      label: 'Right Arm',
      icon: Icons.back_hand_rounded,
      channel: 'force',
      value: 2,
      color: AudyColors.softLavender,
    ),
  ];

  final List<String> _log = [];

  @override
  void initState() {
    super.initState();
    DebugBroadcastService.instance.ensureConnected();
  }

  void _logEvent(String message) {
    setState(() {
      _log.insert(0, message);
      if (_log.length > 8) _log.removeLast();
    });
  }

  Future<void> _sendTouch(_TouchZone zone) async {
    SoundService.instance.playTap();
    await DebugBroadcastService.instance.sendTouch(zone.channel, zone.value);
    _logEvent('Sent: ${zone.label} (${zone.channel}:${zone.value})');
  }

  Future<void> _sendMimicResult(bool correct) async {
    SoundService.instance.playTap();
    await DebugBroadcastService.instance.sendMimicResult(correct);
    _logEvent('Sent: Emotion Mimic ${correct ? 'Correct' : 'Incorrect'}');
  }

  Future<void> _sendEmotionDown() async {
    SoundService.instance.playTap();
    await DebugBroadcastService.instance.sendEmotionDown();
    _logEvent('Sent: Emotion Down');
  }

  @override
  Widget build(BuildContext context) {
    return AudyResponsivePage(
      builder: (context, adaptive) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(adaptive),
            SizedBox(height: adaptive.space(20)),
            AudyPanel(
              adaptive: adaptive,
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AudyColors.warning,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This broadcasts to every device connected to the app '
                      'right now, not just this one.',
                      style: AudyTypography.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: adaptive.space(24)),
            AudySectionTitle(title: 'Touch Sensors'),
            SizedBox(height: adaptive.space(14)),
            AudyAdaptiveGrid(
              adaptive: adaptive,
              phoneColumns: 2,
              tabletColumns: 3,
              desktopColumns: 3,
              items: _touchZones
                  .map(
                    (zone) => _DebugActionCard(
                      label: zone.label,
                      icon: zone.icon,
                      color: zone.color,
                      onTap: () => _sendTouch(zone),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: adaptive.space(28)),
            AudySectionTitle(title: 'Emotion Mimic'),
            SizedBox(height: adaptive.space(14)),
            AudyAdaptiveGrid(
              adaptive: adaptive,
              phoneColumns: 2,
              tabletColumns: 2,
              desktopColumns: 2,
              items: [
                _DebugActionCard(
                  label: 'Mimic Correct',
                  icon: Icons.check_circle_rounded,
                  color: AudyColors.success,
                  onTap: () => _sendMimicResult(true),
                ),
                _DebugActionCard(
                  label: 'Mimic Incorrect',
                  icon: Icons.cancel_rounded,
                  color: AudyColors.error,
                  onTap: () => _sendMimicResult(false),
                ),
              ],
            ),
            SizedBox(height: adaptive.space(28)),
            AudySectionTitle(title: 'Emotion Down'),
            SizedBox(height: adaptive.space(14)),
            AudyAdaptiveGrid(
              adaptive: adaptive,
              phoneColumns: 2,
              tabletColumns: 2,
              desktopColumns: 2,
              items: [
                _DebugActionCard(
                  label: 'Trigger Emotion Down',
                  icon: Icons.sentiment_very_dissatisfied_rounded,
                  color: AudyColors.blushPink,
                  onTap: _sendEmotionDown,
                ),
              ],
            ),
            SizedBox(height: adaptive.space(28)),
            if (_log.isNotEmpty) ...[
              AudySectionTitle(title: 'Recently Sent'),
              SizedBox(height: adaptive.space(10)),
              AudyPanel(
                adaptive: adaptive,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _log
                      .map(
                        (entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            entry,
                            style: AudyTypography.bodySmall.copyWith(
                              color: AudyColors.textLight,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
            SizedBox(height: adaptive.space(20)),
          ],
        );
      },
    );
  }

  Widget _buildHeader(AudyAdaptive adaptive) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            SoundService.instance.playTap();
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
          child: SizedBox(
            width: AudySpacing.touchTargetMin,
            height: AudySpacing.touchTargetMin,
            child: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        const SizedBox(width: AudySpacing.elementGap),
        Expanded(
          child: Text('Debug Broadcast', style: AudyTypography.headingLarge),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: DebugBroadcastService.instance.isConnected,
          builder: (context, connected, _) {
            final color = connected ? AudyColors.success : AudyColors.error;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: color, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    connected ? 'Connected' : 'Connecting…',
                    style: AudyTypography.labelMedium.copyWith(color: color),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _TouchZone {
  const _TouchZone({
    required this.label,
    required this.icon,
    required this.channel,
    required this.value,
    required this.color,
  });

  final String label;
  final IconData icon;
  final String channel;
  final int value;
  final Color color;
}

class _DebugActionCard extends StatelessWidget {
  const _DebugActionCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            color: AudyColors.backgroundCard,
            borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
            border: Border.all(color: color, width: 2.5),
            boxShadow: AudyShadows.cardShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AudyTypography.labelMedium.copyWith(
                  color: AudyColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
