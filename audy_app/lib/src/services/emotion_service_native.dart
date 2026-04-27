import 'dart:io';

import 'emotion_service_api.dart';

/// Result of emotion detection.
class EmotionResult {
  const EmotionResult({
    required this.detectedEmotion,
    required this.confidence,
    this.source = 'api',
  });

  final String detectedEmotion;
  final double confidence;
  final String source; // always 'api'

  factory EmotionResult.fromApi(EmotionApiResult apiResult) {
    return EmotionResult(
      detectedEmotion: apiResult.detectedEmotion,
      confidence: apiResult.confidence,
      source: 'api',
    );
  }
}

class EmotionLoadException implements Exception {
  const EmotionLoadException(this.message);
  final String message;
  @override
  String toString() => 'EmotionLoadException: $message';
}

/// Emotion detection service — API-only via Railway backend.
/// No local model is bundled; inference runs on the server.
class EmotionService {
  EmotionService._();

  static final EmotionApiService _apiService = EmotionApiService();

  static Future<void> init() async {
    // No local model to load.
  }

  static bool get isReady => true;
  static String? get loadError => null;

  /// Detect emotion by sending the image to the Railway API.
  static Future<EmotionResult> detectEmotion(File image) async {
    final apiResult = await _apiService.detectEmotion(image);
    return EmotionResult.fromApi(apiResult);
  }

  /// Alias for [detectEmotion].
  static Future<EmotionResult> detectEmotionRemote(File image) async {
    return detectEmotion(image);
  }

  static bool isConfident(EmotionResult result) {
    return result.confidence >= 0.4;
  }

  static void dispose() {}
}
