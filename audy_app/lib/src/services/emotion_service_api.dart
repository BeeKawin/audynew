import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../features/social_chat/chat_service.dart';

/// Emotion detection result from API
class EmotionApiResult {
  final String detectedEmotion;
  final double confidence;
  final bool isConfident;
  final String modelLabel;
  final Map<String, dynamic> allProbabilities;

  const EmotionApiResult({
    required this.detectedEmotion,
    required this.confidence,
    required this.isConfident,
    required this.modelLabel,
    required this.allProbabilities,
  });

  factory EmotionApiResult.fromJson(Map<String, dynamic> json) {
    return EmotionApiResult(
      detectedEmotion: json['detected_emotion'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      isConfident: json['is_confident'] as bool,
      modelLabel: json['model_label'] as String,
      allProbabilities: json['all_probabilities'] as Map<String, dynamic>,
    );
  }
}

/// Remote emotion detection service using Railway API
/// This works on all platforms including web
class EmotionApiService {
  final String baseUrl;

  EmotionApiService({String? baseUrl}) : baseUrl = baseUrl ?? ApiConfig.baseUrl;

  /// Detect emotion by uploading image to Railway API
  /// Works on web, mobile, and desktop
  Future<EmotionApiResult> detectEmotion(File image) async {
    try {
      // Create multipart request
      final uri = Uri.parse('$baseUrl/api/emotion/classify');
      final request = http.MultipartRequest('POST', uri);

      // Add image file
      final fileStream = http.ByteStream(image.openRead());
      final fileLength = await image.length();

      final multipartFile = http.MultipartFile(
        'image',
        fileStream,
        fileLength,
        filename: image.path.split('/').last,
        contentType: MediaType('image', 'jpeg'),
      );

      request.files.add(multipartFile);

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        throw Exception('API error: ${response.statusCode} - ${response.body}');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return EmotionApiResult.fromJson(json);
    } catch (e) {
      throw Exception('Emotion detection failed: $e');
    }
  }

  /// Check if emotion service is available
  Future<bool> isAvailable() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/emotion/health'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return json['available'] as bool;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
