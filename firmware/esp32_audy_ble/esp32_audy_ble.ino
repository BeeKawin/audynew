/*
 * AUDY Simple LED Test - ESP32 Firmware
 * 
 * UUIDs:
 * - Service: 6755e7e6-3c34-43cf-bc4f-28f38656eca3
 * - Characteristic: 7855e7e6-3c34-43cf-bc4f-28f38656eca3
 * - Device Name: AUDY#ABC1
 */

#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

// BLE UUIDs
#define SERVICE_UUID        "6755e7e6-3c34-43cf-bc4f-28f38656eca3"
#define CHARACTERISTIC_UUID "7855e7e6-3c34-43cf-bc4f-28f38656eca3"
#define DEVICE_NAME         "AUDY#ABC1"

// LED Pin
#define LED_PIN 2

BLEServer* pServer = nullptr;
BLECharacteristic* pCharacteristic = nullptr;
bool deviceConnected = false;

class ServerCallbacks: public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) {
    Serial.println("Client connected!");
    deviceConnected = true;
  }

  void onDisconnect(BLEServer* pServer) {
    Serial.println("Client disconnected");
    deviceConnected = false;
    BLEDevice::startAdvertising();
  }
};

class CharacteristicCallbacks: public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic) {
    std::string value = pCharacteristic->getValue();
    Serial.print("Received: ");
    Serial.println(value.c_str());
    
    // If received "2", turn on LED
    if (value == "2") {
      digitalWrite(LED_PIN, HIGH);
      Serial.println("LED ON");
    } else {
      digitalWrite(LED_PIN, LOW);
      Serial.println("LED OFF");
    }
  }
};

void setup() {
  Serial.begin(115200);
  Serial.println("\n=== AUDY BLE Starting ===");
  
  // Setup LED
  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, LOW);
  
  // Init BLE
  BLEDevice::init(DEVICE_NAME);
  
  // Create server
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new ServerCallbacks());
  
  // Create service
  BLEService* pService = pServer->createService(SERVICE_UUID);
  
  // Create characteristic (Write with response)
  pCharacteristic = pService->createCharacteristic(
    CHARACTERISTIC_UUID,
    BLECharacteristic::PROPERTY_WRITE
  );
  pCharacteristic->setCallbacks(new CharacteristicCallbacks());
  
  // Start service
  pService->start();
  
  // Advertise
  BLEAdvertising* pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  BLEDevice::startAdvertising();
  
  Serial.println("Ready! Advertising as " + String(DEVICE_NAME));
}

void loop() {
  delay(100);
}
