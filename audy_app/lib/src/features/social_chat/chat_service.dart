import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/build_config.dart';
import 'chat_models.dart';

/// Backend API configuration
///
/// For local development (Android Emulator): 'http://10.0.2.2:8000'
/// For Railway deployment: 'https://your-app.up.railway.app'
///
class ApiConfig {
  /// Default Railway URL - replace after deployment
  static const String railwayUrl = 'https://audynew-production.up.railway.app';

  /// Local development URL for Android Emulator
  static const String localUrl = 'http://10.0.2.2:8000';

  /// Local development URL for iOS Simulator
  static const String localUrlIOS = 'http://localhost:8000';

  /// Get the appropriate base URL
  /// Set USE_LOCAL=true for local development
  static String get baseUrl {
    if (BuildConfig.apiBaseUrl.isNotEmpty) {
      return BuildConfig.apiBaseUrl.replaceFirst(RegExp(r'/+$'), '');
    }
    const useLocal = bool.fromEnvironment('USE_LOCAL', defaultValue: false);
    return useLocal ? (kIsWeb ? localUrlIOS : localUrl) : railwayUrl;
  }
}

/// Maintains a separate server conversation for each app language.
class ChatService {
  final String baseUrl;
  final http.Client? _client;
  final _sessions = <ChatLanguage, String>{};
  int _generation = 0;

  ChatService({String? baseUrl, http.Client? client})
    : baseUrl = baseUrl ?? ApiConfig.baseUrl,
      _client = client;

  Future<ChatResponse> sendMessage(
    String message, {
    required ChatLanguage language,
  }) async {
    final generation = _generation;
    final request = ChatRequest(
      sessionId: _sessions[language],
      message: message,
      language: language,
    );
    final post = _client?.post ?? http.post;
    final response = await post(
      Uri.parse('$baseUrl/api/social-chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    ).timeout(const Duration(seconds: 30));
    if (response.statusCode != 200) {
      throw StateError('Chat request failed (${response.statusCode})');
    }
    final reply = ChatResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
    if (generation == _generation) _sessions[language] = reply.sessionId;
    return reply;
  }

  /// Check if backend is available
  Future<bool> isBackendAvailable() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Clear session (start fresh conversation)
  void clearSession() {
    _generation++;
    _sessions.clear();
  }
}
