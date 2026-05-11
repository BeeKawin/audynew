import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../core/bluetooth_uuids.dart';
import '../../services/bluetooth_service.dart';
import '../../services/sound_service.dart';

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
    0: '0 - Normal',
    1: '1 - Left hand raised',
    2: '2 - Right hand raised',
    3: '3 - Both hands raised',
    4: '4 - Pose and back to normal',
  };

  static const Map<int, String> _emotionOptions = {
    0: '0 - Normal eyes',
    1: '1 - Heart eyes',
    2: '2 - Glittering eyes',
    3: '3 - Sad eyes',
  };

  static const Map<int, String> _ledOptions = {
    0: '0 - Ears off / Arms off / Tummy white',
    1: '1 - All red / Tummy cyan',
    2: '2 - All green / Tummy magenta',
    3: '3 - All blue / Tummy yellow',
    4: '4 - All yellow / Tummy blue',
    5: '5 - All cyan / Tummy red',
    6: '6 - All magenta / Tummy green',
    7: '7 - All white / Tummy off',
    8: '8 - Ears dim red / Arms green / Tummy yellow',
    9: '9 - Ears dim green / Arms blue / Tummy blue',
    10: '10 - Ears dim blue / Arms yellow / Tummy red',
    11: '11 - Ears dim yellow / Arms cyan / Tummy green',
    12: '12 - Ears dim cyan / Arms magenta / Tummy off',
    13: '13 - Ears dim magenta / Arms white / Tummy cyan',
    14: '14 - Ears dim white / Arms red / Tummy magenta',
    15: '15 - Split ears / Split arms / Tummy white',
    16: '16 - Ears split / Arms off / Tummy green',
    17: '17 - Ears split / Arms off / Tummy white',
    18: '18 - Rainbow',
    19: '19 - All off',
    20: '20 - Nose lights',
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
        ).showSnackBar(const SnackBar(content: Text('Device not found')));
        return;
      }

      setState(() {
        _isConnecting = true;
      });

      await _bluetooth.connect(device);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Connected to AUDY!')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Connection failed: $e')));
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
      ).showSnackBar(SnackBar(content: Text('Sent: $payload')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Send failed: $e')));
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
    ).showSnackBar(const SnackBar(content: Text('Disconnected')));
  }

  String _describeIncoming(AudyBleMessage message) {
    switch (message.channel) {
      case 'tummy':
        return message.value == 1 ? 'Tummy clicked' : 'Tummy not clicked';

      case 'nose':
        return message.value == 1 ? 'Nose clicked' : 'Nose not clicked';

      case 'force':
        switch (message.value) {
          case 0:
            return 'Not squeezed';
          case 1:
            return 'Squeeze left';
          case 2:
            return 'Squeeze right';
        }

      case 'ears':
        switch (message.value) {
          case 0:
            return 'No ear clicked';
          case 1:
            return 'Left ear clicked';
          case 2:
            return 'Right ear clicked';
        }
    }

    return 'Unknown message';
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
                      label: 'Back',
                      onPressed: () {
                        SoundService.instance.playTap();
                        Navigator.pop(context);
                      },
                    ),
                    const Spacer(),
                    Text('Bluetooth Test', style: AudyTypography.headingMedium),
                    const Spacer(),
                    const SizedBox(width: 80),
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
                        isConnected ? 'CONNECTED' : 'NOT CONNECTED',
                        style: TextStyle(
                          fontSize: adaptive.space(24),
                          fontWeight: FontWeight.w800,
                          color: isConnected
                              ? AudyColors.mintGreen
                              : Colors.grey,
                        ),
                      ),
                      SizedBox(height: adaptive.space(8)),
                      Text(
                        isConnected
                            ? 'Device: ${BluetoothUuids.deviceName}'
                            : 'Looking for: ${BluetoothUuids.deviceName}',
                        style: TextStyle(
                          fontSize: adaptive.space(14),
                          color: AudyColors.textLight,
                        ),
                      ),
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
                    title: 'Arms Channel',
                    subtitle: 'Flutter → ESP32',
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
                    title: 'Emotion Channel',
                    subtitle: 'Flutter → ESP32',
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
                    title: 'LED Channel',
                    subtitle: 'Flutter → ESP32',
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
                      label: const Text('Disconnect'),
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
                        _isScanning ? 'Scanning...' : 'Connecting...',
                        style: TextStyle(fontSize: _space(adaptive, 20)),
                      ),
                    ],
                  )
                : Text(
                    'Scan & Connect',
                    style: TextStyle(fontSize: _space(adaptive, 20)),
                  ),
          ),
        ),
        SizedBox(height: _space(adaptive, 16)),
        Center(
          child: Text(
            'Looking for: ${BluetoothUuids.deviceName}',
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
          const Text(
            'BLE Messages',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF243A5A),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _lastSent == null ? 'Last sent: -' : 'Last sent: $_lastSent',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            incoming == null
                ? 'Last received: -'
                : 'Last received: ${incoming.raw} (${_describeIncoming(incoming)})',
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
            decoration: const InputDecoration(
              labelText: 'Command value',
              border: OutlineInputBorder(),
            ),
            items: options.entries.map((entry) {
              return DropdownMenuItem<int>(
                value: entry.key,
                child: Text(entry.value),
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
              label: Text(_isSending ? 'Sending...' : 'Send'),
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
