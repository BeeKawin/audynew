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
/// Robot BLE protocol:
///   Flutter -> ESP32:
///     arms characteristic: 0-4
///     emotion characteristic: 0-3
///     led characteristic: 0-19
///
///   ESP32 -> Flutter:
///     tummy characteristic: 0-1
///     nose characteristic: 0-1
///     force characteristic: 0-2
///     ears characteristic: 0-2
class AudyBluetoothService {
  AudyBluetoothService._internal();

  static final AudyBluetoothService _instance =
      AudyBluetoothService._internal();
  static AudyBluetoothService get instance => _instance;

  BluetoothDevice? _device;
  BluetoothCharacteristic? _armsCharacteristic;
  BluetoothCharacteristic? _emotionCharacteristic;
  BluetoothCharacteristic? _ledCharacteristic;
  BluetoothCharacteristic? _tummyCharacteristic;
  BluetoothCharacteristic? _noseCharacteristic;
  BluetoothCharacteristic? _forceCharacteristic;
  BluetoothCharacteristic? _earsCharacteristic;

  StreamSubscription<BluetoothConnectionState>? _connectionStateSub;
  final List<StreamSubscription<List<int>>> _incomingSubs = [];

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
        unawaited(_cancelIncomingSubscriptions());
        _clearCharacteristics();
      }
    });

    await device.connect();

    _isConnected = true;
    connectionNotifier.value = true;

    await _findRobotCharacteristics();
    await _resetOutgoingChannelsToDefault();
    await _enableIncomingNotifications();

    debugPrint('AudyBluetoothService: Connected!');
  }

  /// Find all robot command and sensor characteristics.
  Future<void> _findRobotCharacteristics() async {
    if (_device == null) {
      throw Exception('No BLE device selected');
    }

    _clearCharacteristics();

    final services = await _device!.discoverServices();

    for (final service in services) {
      if (service.uuid == BluetoothUuids.audyService) {
        for (final characteristic in service.characteristics) {
          final uuid = characteristic.uuid;

          if (uuid == BluetoothUuids.armsCharacteristic) {
            _armsCharacteristic = characteristic;
          } else if (uuid == BluetoothUuids.emotionCharacteristic) {
            _emotionCharacteristic = characteristic;
          } else if (uuid == BluetoothUuids.ledCharacteristic) {
            _ledCharacteristic = characteristic;
          } else if (uuid == BluetoothUuids.tummyCharacteristic) {
            _tummyCharacteristic = characteristic;
          } else if (uuid == BluetoothUuids.noseCharacteristic) {
            _noseCharacteristic = characteristic;
          } else if (uuid == BluetoothUuids.forceCharacteristic) {
            _forceCharacteristic = characteristic;
          } else if (uuid == BluetoothUuids.earsCharacteristic) {
            _earsCharacteristic = characteristic;
          }
        }
      }
    }

    final missing = <String>[
      if (_armsCharacteristic == null) 'arms',
      if (_emotionCharacteristic == null) 'emotion',
      if (_ledCharacteristic == null) 'led',
      if (_tummyCharacteristic == null) 'tummy',
      if (_noseCharacteristic == null) 'nose',
      if (_forceCharacteristic == null) 'force',
      if (_earsCharacteristic == null) 'ears',
    ];

    if (missing.isNotEmpty) {
      throw Exception(
        'AUDY robot characteristic(s) not found: ${missing.join(', ')}',
      );
    }

    debugPrint('AudyBluetoothService: Found robot characteristics');
  }

  /// Enable ESP32 -> Flutter notifications.
  Future<void> _enableIncomingNotifications() async {
    await _cancelIncomingSubscriptions();

    await _enableNotification('tummy', _tummyCharacteristic);
    await _enableNotification('nose', _noseCharacteristic);
    await _enableNotification('force', _forceCharacteristic);
    await _enableNotification('ears', _earsCharacteristic);

    debugPrint('AudyBluetoothService: Notifications enabled');
  }

  Future<void> _resetOutgoingChannelsToDefault() async {
    await _writeNumericCommand('arms', _armsCharacteristic, 0);
    await _writeNumericCommand('emotion', _emotionCharacteristic, 0);
    await _writeNumericCommand('led', _ledCharacteristic, 0);

    debugPrint('AudyBluetoothService: Outgoing channels reset to defaults');
  }

  Future<void> _enableNotification(
    String channel,
    BluetoothCharacteristic? characteristic,
  ) async {
    if (characteristic == null) {
      throw Exception('$channel characteristic not found');
    }

    final sub = characteristic.onValueReceived.listen(
      (value) => _handleIncomingValue(channel, value),
    );
    _incomingSubs.add(sub);

    await characteristic.setNotifyValue(true);
  }

  void _handleIncomingValue(String channel, List<int> value) {
    if (value.isEmpty) return;

    final decoded = utf8.decode(value).trim();
    final parsedValue = int.tryParse(decoded);

    if (parsedValue == null) {
      debugPrint(
        'AudyBluetoothService: Invalid $channel value: $decoded',
      );
      return;
    }

    _publishIncomingMessage(channel, parsedValue);
  }

  void _publishIncomingMessage(String channel, int value) {
    if (!_isValidIncomingMessage(channel, value)) {
      debugPrint(
        'AudyBluetoothService: Invalid incoming value: $channel:$value',
      );
      return;
    }

    final parsed = AudyBleMessage(
      channel: channel,
      value: value,
      receivedAt: DateTime.now(),
    );

    lastIncomingMessage.value = parsed;
    _incomingController.add(parsed);

    debugPrint('AudyBluetoothService: Parsed incoming: ${parsed.raw}');
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
  /// Backward-compatible wrapper for old debug commands:
  ///   A:2, EM:1, L:7
  /// Robot writes still send only the numeric value to each characteristic.
  Future<void> sendRawCommand(String message) async {
    final cleanMessage = message.trim();
    final separatorIndex = cleanMessage.indexOf(':');

    if (separatorIndex <= 0 || separatorIndex == cleanMessage.length - 1) {
      throw ArgumentError('Invalid command format: $message');
    }

    final channel = cleanMessage.substring(0, separatorIndex).trim();
    final valueText = cleanMessage.substring(separatorIndex + 1).trim();
    final value = int.tryParse(valueText);

    if (value == null) {
      throw ArgumentError('Invalid command value: $message');
    }

    switch (channel.toUpperCase()) {
      case 'A':
        await setArms(value);
        break;
      case 'EM':
        await setEmotion(value);
        break;
      case 'L':
        await setLed(value);
        break;
      default:
        throw ArgumentError('Unknown command channel: $channel');
    }
  }

  /// Arms channel:
  /// 0 = normal
  /// 1 = left hand raised
  /// 2 = right hand raised
  /// 3 = both hands raised
  /// 4 = pose and back to normal
  Future<void> setArms(int value) async {
    _validateOutgoingValue('arms', value, min: 0, max: 4);
    await _writeNumericCommand('arms', _armsCharacteristic, value);
  }

  /// Emotion channel:
  /// 0 = normal eyes
  /// 1 = heart eyes
  /// 2 = glittering eyes
  /// 3 = sad eyes
  Future<void> setEmotion(int value) async {
    _validateOutgoingValue('emotion', value, min: 0, max: 3);
    await _writeNumericCommand('emotion', _emotionCharacteristic, value);
  }

  /// LED channel:
  /// 0-19 = LED color cases
  Future<void> setLed(int value) async {
    _validateOutgoingValue('led', value, min: 0, max: 19);
    await _writeNumericCommand('led', _ledCharacteristic, value);
  }

  Future<void> _writeNumericCommand(
    String channel,
    BluetoothCharacteristic? characteristic,
    int value,
  ) async {
    if (!_isConnected || characteristic == null) {
      throw Exception('Not connected to AUDY device');
    }

    final payload = value.toString();
    debugPrint('AudyBluetoothService: Sending $channel=$payload');

    await characteristic.write(
      utf8.encode(payload),
      withoutResponse: false,
    );
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

    await _cancelIncomingSubscriptions();
    await _connectionStateSub?.cancel();

    _connectionStateSub = null;
    _clearCharacteristics();

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

  Future<void> _cancelIncomingSubscriptions() async {
    final subs = List<StreamSubscription<List<int>>>.from(_incomingSubs);
    _incomingSubs.clear();

    for (final sub in subs) {
      await sub.cancel();
    }
  }

  void _clearCharacteristics() {
    _armsCharacteristic = null;
    _emotionCharacteristic = null;
    _ledCharacteristic = null;
    _tummyCharacteristic = null;
    _noseCharacteristic = null;
    _forceCharacteristic = null;
    _earsCharacteristic = null;
  }

  /// Optional cleanup if you ever permanently destroy this service.
  Future<void> dispose() async {
    await disconnect();
    await _incomingController.close();
    connectionNotifier.dispose();
    lastIncomingMessage.dispose();
  }
}
