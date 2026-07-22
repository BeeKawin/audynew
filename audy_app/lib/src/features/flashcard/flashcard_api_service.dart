import 'dart:convert';

import 'package:http/http.dart' as http;

import '../social_chat/chat_service.dart';
import 'flashcard_models.dart';

class FlashcardApiService {
  FlashcardApiService({String? baseUrl})
    : baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final String baseUrl;

  Future<FlashcardRound> generateRound({
    required String language,
    required int wordCount,
    List<Map<String, dynamic>>? customCards,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/flashcard/round'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'language': language,
            'word_count': wordCount,
            'custom_cards': customCards,
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Flashcard round failed: ${response.statusCode}');
    }

    return FlashcardRound.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<FlashcardValidation> validateRound({
    required String roundId,
    required String language,
    required List<String> targetCardIds,
    required List<String> selectedCardIds,
    List<Map<String, dynamic>>? customCards,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/flashcard/validate'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'round_id': roundId,
            'language': language,
            'target_card_ids': targetCardIds,
            'selected_card_ids': selectedCardIds,
            'custom_cards': customCards,
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Flashcard validation failed: ${response.statusCode}');
    }

    return FlashcardValidation.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
