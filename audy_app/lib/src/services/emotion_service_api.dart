import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

import '../features/social_chat/chat_service.dart';

/// Emotion detection result from API
class EmotionApiResult {
  const EmotionApiResult({
    required this.detectedEmotion,
    required this.confidence,
    required this.isConfident,
    required this.modelLabel,
    required this.allProbabilities,
  });

  final String detectedEmotion;
  final double confidence;
  final bool isConfident;
  final String modelLabel;
  final Map<String, dynamic> allProbabilities;

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

class EmotionApiException implements Exception {
  const EmotionApiException(this.message);

  final String message;

  @override
  String toString() => 'EmotionApiException: $message';
}

/// Remote emotion detection service using Railway API
/// This works on all platforms including web
class EmotionApiService {
  EmotionApiService({String? baseUrl, http.Client? client})
    : baseUrl = baseUrl ?? ApiConfig.baseUrl,
      _client = client ?? http.Client(),
      _ownsClient = client == null;

  final String baseUrl;
  final http.Client _client;
  final bool _ownsClient;

  static const Duration _requestTimeout = Duration(seconds: 30);

  /// Detect emotion by uploading image to Railway API
  /// Works on web, mobile, and desktop
  Future<EmotionApiResult> detectEmotion(File image) async {
    try {
      final uri = Uri.parse('$baseUrl/api/emotion/classify');
      final request = http.MultipartRequest('POST', uri);
      final fileStream = http.ByteStream(image.openRead());
      final fileLength = await image.length();
      final filename = path.basename(image.path);

      final multipartFile = http.MultipartFile(
        'image',
        fileStream,
        fileLength,
        filename: filename,
        contentType: _mediaTypeFor(filename),
      );

      request.files.add(multipartFile);

      final streamedResponse = await _client
          .send(request)
          .timeout(_requestTimeout);
      final response = await http.Response.fromStream(
        streamedResponse,
      ).timeout(_requestTimeout);

      if (response.statusCode != 200) {
        throw EmotionApiException(_messageForStatus(response.statusCode));
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return EmotionApiResult.fromJson(json);
    } on EmotionApiException {
      rethrow;
    } on TimeoutException {
      throw const EmotionApiException(
        'The emotion service is taking too long. Please try again.',
      );
    } on SocketException {
      throw const EmotionApiException(
        'Check the internet connection and try again.',
      );
    } catch (_) {
      throw const EmotionApiException(
        'Emotion detection is unavailable right now. Please try again.',
      );
    }
  }

  /// Check if emotion service is available
  Future<bool> isAvailable() async {
    try {
      final response = await _client
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

  void dispose() {
    if (_ownsClient) {
      _client.close();
    }
  }

  MediaType _mediaTypeFor(String filename) {
    final extension = path.extension(filename).toLowerCase();
    if (extension == '.png') {
      return MediaType('image', 'png');
    }
    if (extension == '.webp') {
      return MediaType('image', 'webp');
    }
    return MediaType('image', 'jpeg');
  }

  String _messageForStatus(int statusCode) {
    if (statusCode == 400 || statusCode == 413 || statusCode == 422) {
      return 'That photo could not be read. Please take another photo.';
    }
    if (statusCode == 503) {
      return 'Emotion detection is temporarily unavailable. Please try again.';
    }
    return 'Emotion detection is unavailable right now. Please try again.';
  }
}
