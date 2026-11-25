@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:audy_app/src/core/bluetooth_uuids.dart';
import 'package:audy_app/src/services/bluetooth_service.dart';
import 'package:flutter_blue_plus_web/flutter_blue_plus_web.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void main() {
  test(
    'web subscribes to all sensors, cleans up, and reconnects',
    () async {
      _installFakeBear();
      FlutterBluePlusWeb.registerWith(webPluginRegistrar);
      final bear = globalContext['audyBleTestBear'] as JSObject;
      final service = AudyBluetoothService.instance;
      addTearDown(service.disconnect);

      final messages = <String>[];
      final inputSub = service.incomingMessages.listen(
        (m) => messages.add(m.raw),
      );
      addTearDown(inputSub.cancel);

      final device = (await service.scanForDevice())!;
      final readySubscriptionCounts = <int>[];
      void trackReady() {
        if (service.isConnected) {
          readySubscriptionCounts.add(
            (bear['subscriptionCount'] as JSNumber).toDartInt,
          );
        }
      }

      service.connectionNotifier.addListener(trackReady);
      addTearDown(() => service.connectionNotifier.removeListener(trackReady));

      bear['failChannel'] = 'nose'.toJS;
      await expectLater(service.connect(device), throwsA(anything));
      expect(service.isConnected, isFalse);
      expect(device.isConnected, isFalse);
      expect((bear['subscriptionCount'] as JSNumber).toDartInt, 0);
      expect(readySubscriptionCounts, isEmpty);

      bear['failChannel'] = ''.toJS;
      await service.connect(device);
      expect(readySubscriptionCounts, [4]);
      await service.setArms(3);
      expect((bear['lastWrite'] as JSString).toDart, 'arms:3');

      for (final (channel, value) in [
        ('tummy', 1),
        ('nose', 1),
        ('force', 1),
        ('force', 2),
        ('ears', 2),
        ('ears', 1),
        ('ears', 0),
      ]) {
        bear.callMethod('emit'.toJS, channel.toJS, value.toJS);
      }
      await Future<void>.delayed(Duration.zero);
      expect(messages, [
        'tummy:1',
        'nose:1',
        'force:1',
        'force:2',
        'ears:1',
        'ears:2',
        'ears:0',
      ]);

      bear.callMethod('dropLink'.toJS);
      await Future<void>.delayed(Duration.zero);
      expect(service.isConnected, isFalse);
      expect(service.lastIncomingMessage.value, isNull);

      messages.clear();
      await service.connect(device);
      expect(readySubscriptionCounts, [4, 4]);
      bear.callMethod('emit'.toJS, 'ears'.toJS, 2.toJS);
      await Future<void>.delayed(Duration.zero);
      expect(messages, ['ears:1']);
      await service.disconnect();
      expect(service.isConnected, isFalse);
      expect((bear['subscriptionCount'] as JSNumber).toDartInt, 0);
    },
    timeout: const Timeout(Duration(seconds: 12)),
  );
}

void _installFakeBear() {
  final originalBluetooth = globalContext.callMethod(
    'eval'.toJS,
    '''
    Object.getOwnPropertyDescriptor(navigator, "bluetooth")
  '''
        .toJS,
  );
  addTearDown(() {
    globalContext['audyBleOriginalBluetooth'] = originalBluetooth;
    globalContext.callMethod(
      'eval'.toJS,
      '''
      if (globalThis.audyBleOriginalBluetooth) {
        Object.defineProperty(navigator, "bluetooth", globalThis.audyBleOriginalBluetooth);
      } else {
        delete navigator.bluetooth;
      }
      delete globalThis.audyBleOriginalBluetooth;
      delete globalThis.audyBleTestBear;
    '''
          .toJS,
    );
  });
  globalContext.callMethod(
    'eval'.toJS,
    '''
    (() => {
      const device = new EventTarget();
      device.id = 'test-audy';
      device.name = '${BluetoothUuids.deviceName}';
      const service = { uuid: '${BluetoothUuids.audyService.str128}', device };
      const started = new Set();
      const chars = new Map();
      const bear = globalThis.audyBleTestBear = {
        failChannel: '',
        lastWrite: '',
        get subscriptionCount() { return started.size; },
        emit(channel, value) {
          if (!started.has(channel)) throw new Error('Sensor is not subscribed');
          const characteristic = chars.get(channel);
          characteristic.value = new DataView(new TextEncoder().encode(String(value)).buffer);
          characteristic.dispatchEvent(new Event('characteristicvaluechanged'));
        },
        dropLink() { device.gatt.disconnect(); },
      };
      for (const [channel, uuid, notify] of [
        ['arms', '${BluetoothUuids.armsCharacteristic.str128}', false],
        ['emotion', '${BluetoothUuids.emotionCharacteristic.str128}', false],
        ['led', '${BluetoothUuids.ledCharacteristic.str128}', false],
        ['tummy', '${BluetoothUuids.tummyCharacteristic.str128}', true],
        ['nose', '${BluetoothUuids.noseCharacteristic.str128}', true],
        ['force', '${BluetoothUuids.forceCharacteristic.str128}', true],
        ['ears', '${BluetoothUuids.earsCharacteristic.str128}', true],
      ]) {
        chars.set(channel, Object.assign(new EventTarget(), {
          uuid,
          service,
          properties: {
            broadcast: false, read: false, writeWithoutResponse: false,
            write: !notify, notify, indicate: false, authenticatedSignedWrites: false,
          },
          getDescriptors: async () => [],
          async startNotifications() {
            if (channel === bear.failChannel) throw new Error('Notification rejected');
            started.add(channel);
            return this;
          },
          async stopNotifications() {
            started.delete(channel);
            return this;
          },
          async writeValueWithResponse(bytes) {
            bear.lastWrite = channel + ':' + new TextDecoder().decode(bytes);
          },
        }));
      }
      service.getCharacteristics = async () => [...chars.values()];
      device.gatt = {
        connected: false,
        async connect() { this.connected = true; return this; },
        getPrimaryServices: async () => [service],
        disconnect() {
          if (!this.connected) return;
          this.connected = false;
          started.clear();
          device.dispatchEvent(new Event('gattserverdisconnected'));
        },
      };
      Object.defineProperty(navigator, 'bluetooth', {
        configurable: true,
        value: { getAvailability: async () => true, requestDevice: async () => device },
      });
    })();
  '''
        .toJS,
  );
}
