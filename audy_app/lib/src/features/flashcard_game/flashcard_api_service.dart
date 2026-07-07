import 'dart:convert';

import 'package:http/http.dart' as http;

import '../social_chat/chat_service.dart';
import 'flashcard_models.dart';

class FlashcardApiService {
  FlashcardApiService({String? baseUrl})
    : baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final String baseUrl;

  Future<FlashcardSession> createSession({
    required String language,
    required FlashcardDifficulty difficulty,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/flashcard/session'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'language': language,
            'difficulty': difficulty.apiValue,
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Flashcard session failed');
    }

    return FlashcardSession.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<FlashcardValidationResult> validate({
    required String language,
    required FlashcardDifficulty difficulty,
    required List<String> submittedCardIds,
    required List<String> availableCardIds,
    required List<String> targetCardIds,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/flashcard/validate'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'language': language,
            'difficulty': difficulty.apiValue,
            'submitted_card_ids': submittedCardIds,
            'available_card_ids': availableCardIds,
            'target_card_ids': targetCardIds,
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Flashcard validation failed');
    }

    return FlashcardValidationResult.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
