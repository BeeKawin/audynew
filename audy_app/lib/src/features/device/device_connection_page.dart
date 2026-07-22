import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../core/bluetooth_uuids.dart';
import '../../services/bluetooth_service.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';

String _tr(BuildContext context, String key, {Map<String, String>? params}) {
  return AudyScope.of(context).tr(key, params: params);
}

/// Bluetooth test page for AUDY device.
///
/// Tests:
/// - Scan for AUDY#ABC1
/// - Connect
/// - Send Flutter -> ESP32 commands:
///   arms=value
///   emotion=value
///   led=value
/// - Receive ESP32 -> Flutter messages:
///   tummy:value
///   nose:value
///   force:value
///   ears:value
class DeviceConnectionPage extends StatefulWidget {
  const DeviceConnectionPage({super.key});

  @override
  State<DeviceConnectionPage> createState() => _DeviceConnectionPageState();
}

class _DeviceConnectionPageState extends State<DeviceConnectionPage> {
  final AudyBluetoothService _bluetooth = AudyBluetoothService.instance;

  StreamSubscription<AudyBleMessage>? _incomingSub;

  bool _isScanning = false;
  bool _isConnecting = false;
  bool _isSending = false;

  int _armsValue = 0;
  int _emotionValue = 0;
  int _ledValue = 0;

  String? _lastSent;
  AudyBleMessage? _lastIncoming;

  static const Map<int, String> _armsOptions = {
    0: 'device_normal',
    1: 'left_hand_raised',
    2: 'right_hand_raised',
    3: 'both_hands_raised',
    4: 'pose_back_normal',
  };

  static const Map<int, String> _emotionOptions = {
    0: 'normal_eyes',
    1: 'heart_eyes',
    2: 'glittering_eyes',
    3: 'sad_eyes',
  };

  static const Map<int, String> _ledOptions = {
<<<<<<< HEAD
    0: 'led_case_0',
    1: 'led_case_1',
    2: 'led_case_2',
    3: 'led_case_3',
    4: 'led_case_4',
    5: 'led_case_5',
    6: 'led_case_6',
    7: 'led_case_7',
    8: 'led_case_8',
    9: 'led_case_9',
    10: 'led_case_10',
    11: 'led_case_11',
    12: 'led_case_12',
    13: 'led_case_13',
    14: 'led_case_14',
    15: 'led_case_15',
    16: 'led_case_16',
    17: 'led_case_17',
    18: 'led_case_18',
    19: 'led_case_19',
    20: 'led_case_20',
    21: 'led_case_21',
    22: 'led_case_22',
=======
    0: 'ears_off_arms_off_tummy_white',
    1: 'all_red_tummy_cyan',
    2: 'all_green_tummy_magenta',
    3: 'all_blue_tummy_yellow',
    4: 'all_yellow_tummy_blue',
    5: 'all_cyan_tummy_red',
    6: 'all_magenta_tummy_green',
    7: 'all_white_tummy_off',
    8: 'ears_dim_red_arms_green_tummy_yellow',
    9: 'ears_dim_green_arms_blue_tummy_blue',
    10: 'ears_dim_blue_arms_yellow_tummy_red',
    11: 'ears_dim_yellow_arms_cyan_tummy_green',
    12: 'ears_dim_cyan_arms_magenta_tummy_off',
    13: 'ears_dim_magenta_arms_white_tummy_cyan',
    14: 'ears_dim_white_arms_red_tummy_magenta',
    15: 'split_ears_split_arms_tummy_white',
    16: 'ears_split_arms_off_tummy_green',
    17: 'ears_split_arms_off_tummy_white',
    18: 'rainbow',
    19: 'all_off',
    20: 'nose_lights',
>>>>>>> origin/Kongnew
  };
  double _space(dynamic adaptive, num value) {
    return (adaptive.space(value.toDouble()) as num).toDouble();
  }

  @override
  void initState() {
    super.initState();

    _bluetooth.initialize();

    _lastIncoming = _bluetooth.lastIncomingMessage.value;

    _incomingSub = _bluetooth.incomingMessages.listen((message) {
      if (!mounted) return;

      setState(() {
        _lastIncoming = message;
      });
    });
  }

  Future<void> _scanAndConnect() async {
    if (_isScanning || _isConnecting) return;

    SoundService.instance.playTap();

    setState(() {
      _isScanning = true;
      _lastSent = null;
    });

    try {
      final device = await _bluetooth.scanForDevice();

      if (!mounted) return;

      setState(() {
        _isScanning = false;
      });

      if (device == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_tr(context, 'device_not_found'))));
        return;
      }

      setState(() {
        _isConnecting = true;
      });

      await _bluetooth.connect(device);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_tr(context, 'connected_to_audy'))));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            _tr(context, 'connection_failed', params: {'error': e.toString()}),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _isConnecting = false;
        });
      }
    }
  }

  Future<void> _sendArms() async {
    await _sendCommand(
      payload: 'arms=$_armsValue',
      action: () => _bluetooth.setArms(_armsValue),
    );
  }

  Future<void> _sendEmotion() async {
    await _sendCommand(
      payload: 'emotion=$_emotionValue',
      action: () => _bluetooth.setEmotion(_emotionValue),
    );
  }

  Future<void> _sendLed() async {
    await _sendCommand(
      payload: 'led=$_ledValue',
      action: () => _bluetooth.setLed(_ledValue),
    );
  }

  Future<void> _sendCommand({
    required String payload,
    required Future<void> Function() action,
  }) async {
    if (_isSending) return;

    SoundService.instance.playTap();

    setState(() {
      _isSending = true;
    });

    try {
      await action();

      if (!mounted) return;

      setState(() {
        _lastSent = payload;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(_tr(context, 'sent_format', params: {'payload': payload})),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(_tr(context, 'send_failed', params: {'error': e.toString()})),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _disconnect() async {
    SoundService.instance.playTap();

    await _bluetooth.disconnect();

    if (!mounted) return;

    setState(() {
      _lastSent = null;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_tr(context, 'disconnected'))));
  }

  String _describeIncoming(AudyBleMessage message) {
    switch (message.channel) {
      case 'tummy':
        return message.value == 1
            ? _tr(context, 'tummy_clicked')
            : _tr(context, 'tummy_not_clicked');

      case 'nose':
        return message.value == 1
            ? _tr(context, 'nose_clicked')
            : _tr(context, 'nose_not_clicked');

      case 'force':
        switch (message.value) {
          case 0:
            return _tr(context, 'not_squeezed');
          case 1:
            return _tr(context, 'squeeze_left');
          case 2:
            return _tr(context, 'squeeze_right');
        }

      case 'ears':
        switch (message.value) {
          case 0:
            return _tr(context, 'no_ear_clicked');
          case 1:
            return _tr(context, 'left_ear_clicked');
          case 2:
            return _tr(context, 'right_ear_clicked');
        }
    }

    return _tr(context, 'unknown_message');
  }

  @override
  Widget build(BuildContext context) {
    return AudyResponsivePage(
      builder: (context, adaptive) {
        return ValueListenableBuilder<bool>(
          valueListenable: _bluetooth.connectionNotifier,
          builder: (context, isConnected, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    AudyBackButton(
                      label: _tr(context, 'back'),
                      onPressed: () {
                        SoundService.instance.playTap();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                SizedBox(height: adaptive.space(32)),

                // Status
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: isConnected
                              ? AudyColors.mintGreen.withValues(alpha: 0.2)
                              : Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isConnected
                              ? Icons.bluetooth_connected
                              : Icons.bluetooth,
                          size: 64,
                          color: isConnected
                              ? AudyColors.mintGreen
                              : Colors.grey,
                        ),
                      ),
                      SizedBox(height: adaptive.space(20)),
                      Text(
                        isConnected
                            ? _tr(context, 'connected')
                            : _tr(context, 'not_connected'),
                        style: TextStyle(
                          fontSize: adaptive.space(24),
                          fontWeight: FontWeight.w800,
                          color: isConnected
                              ? AudyColors.mintGreen
                              : Colors.grey,
                        ),
                      ),
                      if (isConnected) ...[
                        SizedBox(height: adaptive.space(8)),
                        Text(
                          _tr(
                            context,
                            'device_format',
                            params: {'device': BluetoothUuids.deviceName},
                          ),
                          style: TextStyle(
                            fontSize: adaptive.space(14),
                            color: AudyColors.textLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: adaptive.space(32)),

                if (!isConnected) ...[
                  _buildScanButton(adaptive),
                ] else ...[
                  _buildMessageStatusCard(),
                  SizedBox(height: adaptive.space(16)),
                  _buildCommandCard(
                    title: _tr(context, 'arms_channel'),
                    subtitle: _tr(context, 'flutter_to_esp32'),
                    value: _armsValue,
                    options: _armsOptions,
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _armsValue = value);
                    },
                    onSend: _sendArms,
                  ),
                  SizedBox(height: adaptive.space(16)),
                  _buildCommandCard(
                    title: _tr(context, 'emotion_channel'),
                    subtitle: _tr(context, 'flutter_to_esp32'),
                    value: _emotionValue,
                    options: _emotionOptions,
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _emotionValue = value);
                    },
                    onSend: _sendEmotion,
                  ),
                  SizedBox(height: adaptive.space(16)),
                  _buildCommandCard(
                    title: _tr(context, 'led_channel'),
                    subtitle: _tr(context, 'flutter_to_esp32'),
                    value: _ledValue,
                    options: _ledOptions,
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _ledValue = value);
                    },
                    onSend: _sendLed,
                  ),
                  SizedBox(height: adaptive.space(24)),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _disconnect,
                      icon: const Icon(Icons.bluetooth_disabled),
                      label: Text(_tr(context, 'disconnect')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8D91),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildScanButton(dynamic adaptive) {
    final bool loading = _isScanning || _isConnecting;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: _space(adaptive, 80),
          child: ElevatedButton(
            onPressed: loading ? null : _scanAndConnect,
            child: loading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 24.0,
                        height: 24.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Text(
                        _isScanning
                            ? _tr(context, 'scanning')
                            : _tr(context, 'connecting'),
                        style: TextStyle(fontSize: _space(adaptive, 20)),
                      ),
                    ],
                  )
                : Text(
                    _tr(context, 'scan_connect'),
                    style: TextStyle(fontSize: _space(adaptive, 20)),
                  ),
          ),
        ),
        SizedBox(height: _space(adaptive, 16)),
        Center(
          child: Text(
            'bluetooth connecting',
            style: TextStyle(
              fontSize: _space(adaptive, 14),
              color: AudyColors.textLight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageStatusCard() {
    final incoming = _lastIncoming;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tr(context, 'ble_messages'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF243A5A),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _lastSent == null
                ? _tr(context, 'last_sent_empty')
                : _tr(context, 'last_sent', params: {'value': _lastSent!}),
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            incoming == null
                ? _tr(context, 'last_received_empty')
                : _tr(
                    context,
                    'last_received',
                    params: {
                      'raw': incoming.raw,
                      'description': _describeIncoming(incoming),
                    },
                  ),
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandCard({
    required String title,
    required String subtitle,
    required int value,
    required Map<int, String> options,
    required ValueChanged<int?> onChanged,
    required Future<void> Function() onSend,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF243A5A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<int>(
            initialValue: value,
            decoration: InputDecoration(
              labelText: _tr(context, 'command_value'),
              border: const OutlineInputBorder(),
            ),
            items: options.entries.map((entry) {
              return DropdownMenuItem<int>(
                value: entry.key,
                child: Text('${entry.key} - ${_tr(context, entry.value)}'),
              );
            }).toList(),
            onChanged: _isSending ? null : onChanged,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSending ? null : () => onSend(),
              icon: const Icon(Icons.send),
              label: Text(
                _isSending ? _tr(context, 'sending') : _tr(context, 'send'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _incomingSub?.cancel();

    // Important:
    // Do not auto-disconnect here.
    // The Bluetooth service is app-wide, so leaving this page should not
    // immediately disconnect the ESP32 unless the user presses Disconnect.

    super.dispose();
  }
}
