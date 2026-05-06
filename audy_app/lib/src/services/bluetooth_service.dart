import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../core/bluetooth_uuids.dart';

/// Parsed BLE message from ESP32.
/// Expected format:
///   channel:value
///
/// Examples:
///   tummy:1
///   nose:0
///   force:2
///   ears:1
class AudyBleMessage {
  const AudyBleMessage({
    required this.channel,
    required this.value,
    required this.receivedAt,
  });

  final String channel;
  final int value;
  final DateTime receivedAt;

  String get raw => '$channel:$value';

  static AudyBleMessage? tryParse(String rawMessage) {
    final message = rawMessage.trim();
    if (message.isEmpty) return null;

    final separatorIndex = message.indexOf(':');
    if (separatorIndex <= 0 || separatorIndex == message.length - 1) {
      return null;
    }

    final rawChannel = message
        .substring(0, separatorIndex)
        .trim()
        .toLowerCase();
    final valueText = message.substring(separatorIndex + 1).trim();
    final value = int.tryParse(valueText);

    if (value == null) return null;

    final channel = switch (rawChannel) {
      't' => 'tummy',
      'n' => 'nose',
      'f' => 'force',
      'e' => 'ears',
      _ => rawChannel,
    };

    return AudyBleMessage(
      channel: channel,
      value: value,
      receivedAt: DateTime.now(),
    );
  }
}

/// Bluetooth service for AUDY device.
///
/// Text protocol:
///   Flutter -> ESP32:
///     arms:0-4
///     emotion:0-3
///     led:0-15
///
///   ESP32 -> Flutter:
///     tummy:0-1
///     nose:0-1
///     force:0-2
///     ears:0-2
class AudyBluetoothService {
  AudyBluetoothService._internal();

  static final AudyBluetoothService _instance =
      AudyBluetoothService._internal();
  static AudyBluetoothService get instance => _instance;

  BluetoothDevice? _device;
  BluetoothCharacteristic? _commandCharacteristic;

  StreamSubscription<BluetoothConnectionState>? _connectionStateSub;
  StreamSubscription<List<int>>? _incomingSub;

  final ValueNotifier<bool> connectionNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<AudyBleMessage?> lastIncomingMessage =
      ValueNotifier<AudyBleMessage?>(null);

  final StreamController<AudyBleMessage> _incomingController =
      StreamController<AudyBleMessage>.broadcast();

  bool _isConnected = false;

  bool get isConnected => _isConnected;
  String? get deviceName => _device?.platformName;
  Stream<AudyBleMessage> get incomingMessages => _incomingController.stream;

  /// Initialize Bluetooth.
  Future<void> initialize() async {
    debugPrint('AudyBluetoothService: Initializing...');

    final supported = await FlutterBluePlus.isSupported;
    if (!supported) {
      debugPrint('AudyBluetoothService: Bluetooth not supported');
      return;
    }

    final adapterState = await FlutterBluePlus.adapterState.first;

    if (adapterState == BluetoothAdapterState.off &&
        defaultTargetPlatform == TargetPlatform.android) {
      try {
        await FlutterBluePlus.turnOn();
      } catch (e) {
        debugPrint('AudyBluetoothService: Failed to turn on Bluetooth - $e');
      }
    }

    debugPrint('AudyBluetoothService: Initialized');
  }

  /// Scan for AUDY device by name.
  ///
  /// Returns the first matching BluetoothDevice, or null if not found.
  Future<BluetoothDevice?> scanForDevice({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    debugPrint(
      'AudyBluetoothService: Scanning for ${BluetoothUuids.deviceName}...',
    );

    await stopScan();

    final completer = Completer<BluetoothDevice?>();
    StreamSubscription<List<ScanResult>>? scanSub;
    Timer? timeoutTimer;

    try {
      scanSub = FlutterBluePlus.scanResults.listen((results) {
        for (final result in results) {
          if (_matchesTargetDevice(result)) {
            debugPrint('AudyBluetoothService: Found AUDY device');

            if (!completer.isCompleted) {
              completer.complete(result.device);
            }
            return;
          }
        }
      });

      await FlutterBluePlus.startScan(
        timeout: timeout,
        androidUsesFineLocation: false,
      );

      timeoutTimer = Timer(timeout + const Duration(milliseconds: 500), () {
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      });

      return await completer.future;
    } catch (e) {
      debugPrint('AudyBluetoothService: Scan failed - $e');
      rethrow;
    } finally {
      timeoutTimer?.cancel();
      await scanSub?.cancel();
      await stopScan();
    }
  }

  bool _matchesTargetDevice(ScanResult result) {
    final platformName = result.device.platformName;
    final advertisedName = result.advertisementData.advName;

    return platformName == BluetoothUuids.deviceName ||
        advertisedName == BluetoothUuids.deviceName;
  }

  /// Stop scanning.
  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (e) {
      debugPrint('AudyBluetoothService: Stop scan failed - $e');
    }
  }

  /// Connect to AUDY device.
  Future<void> connect(BluetoothDevice device) async {
    debugPrint('AudyBluetoothService: Connecting...');

    await disconnect();

    _device = device;

    _connectionStateSub = device.connectionState.listen((state) {
      final connected = state == BluetoothConnectionState.connected;

      _isConnected = connected;
      connectionNotifier.value = connected;

      debugPrint('AudyBluetoothService: Connection state: $state');

      if (!connected) {
        _commandCharacteristic = null;
      }
    });

    await device.connect();

    _isConnected = true;
    connectionNotifier.value = true;

    await _findCommandCharacteristic();
    await _enableIncomingNotifications();

    debugPrint('AudyBluetoothService: Connected!');
  }

  /// Find the command characteristic.
  ///
  /// This characteristic is used for both:
  /// - Flutter -> ESP32 writes
  /// - ESP32 -> Flutter notifications
  Future<void> _findCommandCharacteristic() async {
    if (_device == null) {
      throw Exception('No BLE device selected');
    }

    final services = await _device!.discoverServices();

    for (final service in services) {
      if (service.uuid == BluetoothUuids.audyService) {
        for (final characteristic in service.characteristics) {
          if (characteristic.uuid == BluetoothUuids.ledCharacteristic) {
            _commandCharacteristic = characteristic;
            debugPrint('AudyBluetoothService: Found command characteristic');
            return;
          }
        }
      }
    }

    throw Exception('AUDY command characteristic not found');
  }

  /// Enable ESP32 -> Flutter notifications.
  Future<void> _enableIncomingNotifications() async {
    final characteristic = _commandCharacteristic;

    if (characteristic == null) {
      throw Exception('Command characteristic not found');
    }

    await _incomingSub?.cancel();

    _incomingSub = characteristic.onValueReceived.listen(_handleIncomingBytes);

    await characteristic.setNotifyValue(true);

    debugPrint('AudyBluetoothService: Notifications enabled');
  }

  void _handleIncomingBytes(List<int> value) {
    if (value.isEmpty) return;

    final decoded = utf8.decode(value).trim();
    debugPrint('AudyBluetoothService: Received raw: $decoded');

    // Supports either:
    //   tummy:1
    //
    // or multiple messages:
    //   tummy:1\nforce:2
    final messages = decoded.split(RegExp(r'[\r\n]+'));

    for (final rawMessage in messages) {
      final parsed = AudyBleMessage.tryParse(rawMessage);

      if (parsed == null) {
        debugPrint(
          'AudyBluetoothService: Invalid incoming message: $rawMessage',
        );
        continue;
      }

      if (!_isValidIncomingMessage(parsed.channel, parsed.value)) {
        debugPrint(
          'AudyBluetoothService: Invalid incoming value: ${parsed.raw}',
        );
        continue;
      }

      lastIncomingMessage.value = parsed;
      _incomingController.add(parsed);

      debugPrint('AudyBluetoothService: Parsed incoming: ${parsed.raw}');
    }
  }

  bool _isValidIncomingMessage(String channel, int value) {
    switch (channel) {
      case 'tummy':
      case 'nose':
        return value >= 0 && value <= 1;

      case 'force':
      case 'ears':
        return value >= 0 && value <= 2;

      default:
        return false;
    }
  }

  /// Generic sender.
  ///
  /// Example:
  ///   sendCommand("arms", 2) -> sends "arms:2"
  Future<void> sendRawCommand(String message) async {
    final characteristic = _commandCharacteristic;

    if (!_isConnected || characteristic == null) {
      throw Exception('Not connected to AUDY device');
    }

    final cleanMessage = message.trim();

    debugPrint('AudyBluetoothService: Sending $cleanMessage');

    await characteristic.write(
      utf8.encode(cleanMessage),
      withoutResponse: false,
    );
  }

  /// Arms channel:
  /// 0 = normal
  /// 1 = left hand raised
  /// 2 = right hand raised
  /// 3 = both hands raised
  /// 4 = pose and back to normal
  Future<void> setArms(int value) async {
    _validateOutgoingValue('arms', value, min: 0, max: 4);
    await sendRawCommand('A:$value');
  }

  /// Emotion channel:
  /// 0 = normal eyes
  /// 1 = heart eyes
  /// 2 = glittering eyes
  /// 3 = sad eyes
  Future<void> setEmotion(int value) async {
    _validateOutgoingValue('emotion', value, min: 0, max: 3);
    await sendRawCommand('EM:$value');
  }

  /// LED channel:
  /// 0-15 = LED color cases
  Future<void> setLed(int value) async {
    _validateOutgoingValue('led', value, min: 0, max: 15);
    await sendRawCommand('L:$value');
  }

  void _validateOutgoingValue(
    String channel,
    int value, {
    required int min,
    required int max,
  }) {
    if (value < min || value > max) {
      throw ArgumentError(
        'Invalid $channel value: $value. Expected $min-$max.',
      );
    }
  }

  /// Disconnect from AUDY.
  Future<void> disconnect() async {
    debugPrint('AudyBluetoothService: Disconnecting...');

    await _incomingSub?.cancel();
    await _connectionStateSub?.cancel();

    _incomingSub = null;
    _connectionStateSub = null;
    _commandCharacteristic = null;

    if (_device != null) {
      try {
        await _device!.disconnect();
      } catch (e) {
        debugPrint('AudyBluetoothService: Disconnect failed - $e');
      }
    }

    _device = null;
    _isConnected = false;
    connectionNotifier.value = false;
  }

  /// Optional cleanup if you ever permanently destroy this service.
  Future<void> dispose() async {
    await disconnect();
    await _incomingController.close();
    connectionNotifier.dispose();
    lastIncomingMessage.dispose();
  }
}
