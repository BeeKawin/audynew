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
  // Characteristic UUID for LED control
  static final Guid ledCharacteristic = Guid(
    '7855e7e6-3c34-43cf-bc4f-28f38656eca3',
  );
}
