import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Bluetooth Low Energy UUID constants for AUDY device
///
/// These UUIDs must match the ESP32 firmware GATT service/characteristic definitions
class BluetoothUuids {
  BluetoothUuids._();
  // Device name
  static const String deviceName = "AUDY#ABC1";
  // Service UUID
  static final Guid audyService = Guid('6755e7e6-3c34-43cf-bc4f-28f38656eca3');

  // Flutter -> robot write characteristics
  static final Guid armsCharacteristic = Guid(
    'AA01e7e6-3c34-43cf-bc4f-28f38656eca3',
  );
  static final Guid emotionCharacteristic = Guid(
    'AA02e7e6-3c34-43cf-bc4f-28f38656eca3',
  );
  static final Guid ledCharacteristic = Guid(
    'AA03e7e6-3c34-43cf-bc4f-28f38656eca3',
  );

  // Robot -> Flutter notify characteristics
  static final Guid tummyCharacteristic = Guid(
    'BB01e7e6-3c34-43cf-bc4f-28f38656eca3',
  );
  static final Guid noseCharacteristic = Guid(
    'BB02e7e6-3c34-43cf-bc4f-28f38656eca3',
  );
  static final Guid forceCharacteristic = Guid(
    'BB03e7e6-3c34-43cf-bc4f-28f38656eca3',
  );
  static final Guid earsCharacteristic = Guid(
    'BB04e7e6-3c34-43cf-bc4f-28f38656eca3',
  );
}
