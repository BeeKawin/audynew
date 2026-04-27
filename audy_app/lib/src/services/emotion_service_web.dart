import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../features/social_chat/chat_service.dart';

/// Result of emotion detection.
class EmotionResult {
  const EmotionResult({
    required this.detectedEmotion,
    required this.confidence,
    this.source = 'api',
  });

  final String detectedEmotion;
  final double confidence;
  final String source;
}

class EmotionLoadException implements Exception {
  const EmotionLoadException(this.message);
  final String message;
  @override
  String toString() => 'EmotionLoadException: $message';
}

/// Web-compatible emotion detection service using the Railway API.
class EmotionService {
  EmotionService._();

  static final _client = http.Client();

  static Future<void> init() async {}

  static bool get isReady => true;
  static String? get loadError => null;

  /// Detect emotion by uploading image bytes to the Railway API.
  ///
  /// On web, pass a [Uint8List] containing the image bytes.
  static Future<EmotionResult> detectEmotion(dynamic image) async {
    Uint8List bytes;
    String filename;

    if (image is Uint8List) {
      bytes = image;
      filename = 'photo.jpg';
    } else {
      throw EmotionLoadException(
        'Web emotion detection requires Uint8List image bytes.',
      );
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/emotion/classify');
    final request = http.MultipartRequest('POST', uri);

    final multipartFile = http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: filename,
      contentType: MediaType('image', 'jpeg'),
    );

    request.files.add(multipartFile);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw EmotionLoadException(
        'API error: ${response.statusCode} - ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    return EmotionResult(
      detectedEmotion: json['detected_emotion'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      source: 'api',
    );
  }

  static bool isConfident(EmotionResult result) {
    return result.confidence >= 0.4;
  }

  static void dispose() {
    _client.close();
  }
}
