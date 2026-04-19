class EmotionResult {
  const EmotionResult({
    required this.detectedEmotion,
    required this.confidence,
  });

  final String detectedEmotion;
  final double confidence;
}

class EmotionLoadException implements Exception {
  const EmotionLoadException(this.message);
  final String message;
  @override
  String toString() => 'EmotionLoadException: $message';
}

class EmotionService {
  EmotionService._();

  static const _webMessage =
      'Emotion detection is not available on web. '
      'Please use the mobile or desktop version of this app.';

  static Future<void> init() async {
    throw EmotionLoadException(_webMessage);
  }

  static bool get isReady => false;
  static String? get loadError => _webMessage;

  static Future<EmotionResult> detectEmotion(dynamic image) async {
    throw EmotionLoadException(_webMessage);
  }

  static bool isConfident(EmotionResult result) => false;

  static void dispose() {}
}
