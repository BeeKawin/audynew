import 'dart:async';

import 'bluetooth_service.dart';
import 'realtime_control_service.dart';

class InteractiveInputService {
  InteractiveInputService._() {
    _incomingController = StreamController<AudyBleMessage>.broadcast(
      onListen: _startListening,
      onCancel: _stopListening,
    );
  }

  static final InteractiveInputService instance = InteractiveInputService._();

  late final StreamController<AudyBleMessage> _incomingController;
  StreamSubscription<AudyBleMessage>? _bluetoothSubscription;
  StreamSubscription<RealtimeControlEvent>? _realtimeSubscription;

  Stream<AudyBleMessage> get incomingMessages => _incomingController.stream;

  static AudyBleMessage? messageFor(RealtimeControlEvent event) {
    final input = switch (event.action) {
      RemoteControlAction.leftEar => ('ears', 1),
      RemoteControlAction.rightEar => ('ears', 2),
      RemoteControlAction.nose => ('nose', 1),
      RemoteControlAction.leftArm => ('force', 1),
      RemoteControlAction.rightArm => ('force', 2),
      RemoteControlAction.tummy => ('tummy', 1),
      RemoteControlAction.correctMimic ||
      RemoteControlAction.incorrectMimic => null,
    };
    if (input == null) return null;

    return AudyBleMessage(
      channel: input.$1,
      value: input.$2,
      receivedAt: event.sentAt,
    );
  }

  void _startListening() {
    _bluetoothSubscription ??= AudyBluetoothService.instance.incomingMessages
        .listen(_incomingController.add);
    _realtimeSubscription ??= RealtimeControlService.instance.events.listen((
      event,
    ) {
      final message = messageFor(event);
      if (message != null) _incomingController.add(message);
    });
  }

  Future<void> _stopListening() async {
    await _bluetoothSubscription?.cancel();
    await _realtimeSubscription?.cancel();
    _bluetoothSubscription = null;
    _realtimeSubscription = null;
  }
}
