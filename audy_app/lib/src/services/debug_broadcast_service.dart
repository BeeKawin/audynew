import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../features/social_chat/chat_service.dart' show ApiConfig;
import 'bluetooth_service.dart';

/// Result of a debug-simulated "Emotion Mimic" round, received from another
/// device over the debug broadcast relay.
class DebugMimicEvent {
  const DebugMimicEvent({required this.correct, required this.receivedAt});

  final bool correct;
  final DateTime receivedAt;
}

/// Connects to the Python backend's `/ws/debug-broadcast` relay so a DEBUG
/// page on one device can trigger a fake robot touch or emotion-mimic
/// result on every *other* connected device, as if it were a real event.
///
/// This is a bare global fan-out — no pairing, no auth, no history. Touch
/// events are injected straight into [AudyBluetoothService.incomingMessages]
/// so any screen already listening for real BLE input reacts automatically;
/// mimic-result events are exposed via [mimicEvents] for the emotion mimic
/// screen to consume directly.
class DebugBroadcastService {
  DebugBroadcastService._();

  static final DebugBroadcastService instance = DebugBroadcastService._();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  bool _connecting = false;

  final ValueNotifier<bool> isConnected = ValueNotifier<bool>(false);

  final StreamController<DebugMimicEvent> _mimicController =
      StreamController<DebugMimicEvent>.broadcast();
  Stream<DebugMimicEvent> get mimicEvents => _mimicController.stream;

  static String get _wsUrl {
    final httpBase = ApiConfig.baseUrl;
    final wsBase = httpBase
        .replaceFirst('https://', 'wss://')
        .replaceFirst('http://', 'ws://');
    return '$wsBase/ws/debug-broadcast';
  }

  /// Connects if not already connected/connecting. Safe to call repeatedly
  /// (e.g. once at app startup, and again from the debug page itself).
  Future<void> ensureConnected() async {
    if (_channel != null || _connecting) return;
    _connecting = true;

    try {
      final channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
      await channel.ready;
      _channel = channel;
      isConnected.value = true;
      _subscription = channel.stream.listen(
        _handleRaw,
        onDone: _handleDisconnect,
        onError: (Object _) => _handleDisconnect(),
      );
    } catch (e) {
      debugPrint('DebugBroadcastService: connect failed - $e');
      _channel = null;
      isConnected.value = false;
    } finally {
      _connecting = false;
    }
  }

  void _handleDisconnect() {
    isConnected.value = false;
    unawaited(_subscription?.cancel());
    _subscription = null;
    _channel = null;
  }

  void _handleRaw(dynamic raw) {
    if (raw is! String) return;

    final Map<String, dynamic> data;
    try {
      data = jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('DebugBroadcastService: bad payload - $e');
      return;
    }

    switch (data['type']) {
      case 'touch':
        final channel = data['channel'];
        final value = data['value'];
        if (channel is String && value is int) {
          AudyBluetoothService.instance.injectDebugMessage(channel, value);
        }
      case 'mimic_result':
        final correct = data['correct'];
        if (correct is bool) {
          _mimicController.add(
            DebugMimicEvent(correct: correct, receivedAt: DateTime.now()),
          );
        }
    }
  }

  Future<void> sendTouch(String channel, int value) async {
    await ensureConnected();
    _channel?.sink.add(
      jsonEncode({'type': 'touch', 'channel': channel, 'value': value}),
    );
  }

  Future<void> sendMimicResult(bool correct) async {
    await ensureConnected();
    _channel?.sink.add(
      jsonEncode({'type': 'mimic_result', 'correct': correct}),
    );
  }
}
