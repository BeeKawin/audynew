import 'dart:convert';
import 'package:http/http.dart' as http;
import 'chat_models.dart';

/// Backend API configuration
///
/// For local development (Android Emulator): 'http://10.0.2.2:8000'
/// For Railway deployment: 'https://your-app.up.railway.app'
///
/// TODO: Replace with your Railway URL after deployment
class ApiConfig {
  /// Default Railway URL - replace after deployment
  static const String railwayUrl = 'https://your-app.up.railway.app';

  /// Local development URL for Android Emulator
  static const String localUrl = 'http://10.0.2.2:8000';

  /// Local development URL for iOS Simulator
  static const String localUrlIOS = 'http://localhost:8000';

  /// Get the appropriate base URL
  /// Set USE_LOCAL=true for local development
  static String get baseUrl {
    const useLocal = bool.fromEnvironment('USE_LOCAL', defaultValue: false);
    return useLocal ? localUrl : railwayUrl;
  }
}

/// Chat service for communicating with Thai NLP backend
class ChatService {
  final String baseUrl;
  String? _sessionId;

  ChatService({String? baseUrl}) : baseUrl = baseUrl ?? ApiConfig.baseUrl;

  String? get sessionId => _sessionId;

  /// Send message to backend and receive Thai response
  /// Returns ChatResponse with generated Thai message
  Future<ChatResponse> sendMessage(String message) async {
    final request = ChatRequest(sessionId: _sessionId, message: message);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/thai-chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send message: ${response.statusCode}');
      }

      final chatResponse = ChatResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );

      // Store session ID for future requests (maintains conversation context)
      _sessionId = chatResponse.sessionId;

      return chatResponse;
    } catch (e) {
      rethrow;
    }
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
    _sessionId = null;
  }
}
