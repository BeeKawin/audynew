import 'dart:async';
import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

enum RemoteControlAction {
  leftEar,
  rightEar,
  nose,
  leftArm,
  rightArm,
  tummy,
  correctMimic,
  incorrectMimic,
}

extension RemoteControlActionWireName on RemoteControlAction {
  String get wireName => switch (this) {
    RemoteControlAction.leftEar => 'left_ear',
    RemoteControlAction.rightEar => 'right_ear',
    RemoteControlAction.nose => 'nose',
    RemoteControlAction.leftArm => 'left_arm',
    RemoteControlAction.rightArm => 'right_arm',
    RemoteControlAction.tummy => 'tummy',
    RemoteControlAction.correctMimic => 'correct_mimic',
    RemoteControlAction.incorrectMimic => 'incorrect_mimic',
  };

  static RemoteControlAction? fromWireName(String value) {
    for (final action in RemoteControlAction.values) {
      if (action.wireName == value) return action;
    }
    return null;
  }
}

class RealtimeControlEvent {
  const RealtimeControlEvent({
    required this.id,
    required this.action,
    required this.sentAt,
  });

  final String id;
  final RemoteControlAction action;
  final DateTime sentAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'action': action.wireName,
    'sent_at': sentAt.toUtc().toIso8601String(),
  };

  static RealtimeControlEvent? fromJson(Map<String, dynamic> json) {
    final body = json['payload'] is Map
        ? Map<String, dynamic>.from(json['payload'] as Map)
        : json;
    final id = body['id'];
    final actionName = body['action'];
    final sentAtValue = body['sent_at'];
    if (id is! String || actionName is! String || sentAtValue is! String) {
      return null;
    }

    final action = RemoteControlActionWireName.fromWireName(actionName);
    final sentAt = DateTime.tryParse(sentAtValue);
    if (action == null || sentAt == null) return null;

    return RealtimeControlEvent(id: id, action: action, sentAt: sentAt);
  }
}

String selectMimicEmotion({
  required String correctEmotion,
  required bool isCorrect,
  required List<String> availableEmotions,
  Random? random,
}) {
  if (isCorrect) return correctEmotion;

  final alternatives = availableEmotions
      .where((emotion) => emotion != correctEmotion)
      .toList(growable: false);
  if (alternatives.isEmpty) {
    throw ArgumentError('At least one incorrect emotion is required.');
  }

  return alternatives[(random ?? Random()).nextInt(alternatives.length)];
}

class RealtimeControlService {
  RealtimeControlService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client {
    _eventsController = StreamController<RealtimeControlEvent>.broadcast(
      onListen: _startListening,
      onCancel: _stopListening,
    );
  }

  static final RealtimeControlService instance = RealtimeControlService();

  static const String _channelName = 'audy-interactive-controls-v1';
  static const String _eventName = 'control';

  final SupabaseClient _client;
  late final StreamController<RealtimeControlEvent> _eventsController;
  RealtimeChannel? _channel;
  bool _isListening = false;

  Stream<RealtimeControlEvent> get events => _eventsController.stream;

  Future<void> send(RemoteControlAction action) async {
    final now = DateTime.now().toUtc();
    final event = RealtimeControlEvent(
      id: '${now.microsecondsSinceEpoch}-${Random().nextInt(1 << 32)}',
      action: action,
      sentAt: now,
    );
    final channel = _channel ??= _createChannel();

    await channel.httpSend(event: _eventName, payload: event.toJson());
  }

  RealtimeChannel _createChannel() {
    return _client.channel(
      _channelName,
      opts: const RealtimeChannelConfig(ack: true, self: false),
    );
  }

  void _startListening() {
    if (_isListening) return;
    _isListening = true;
    final channel = _channel ??= _createChannel();
    channel
        .onBroadcast(
          event: _eventName,
          callback: (payload) {
            final event = RealtimeControlEvent.fromJson(payload);
            if (event != null && !_eventsController.isClosed) {
              _eventsController.add(event);
            }
          },
        )
        .subscribe();
  }

  Future<void> _stopListening() async {
    if (!_isListening) return;
    _isListening = false;
    final channel = _channel;
    _channel = null;
    if (channel != null) {
      await _client.removeChannel(channel);
    }
  }
}
