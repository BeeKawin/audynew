enum ChatLanguage {
  english('en', 'en-US'),
  thai('th', 'th-TH');

  const ChatLanguage(this.code, this.voiceLocale);

  final String code;
  final String voiceLocale;

  static ChatLanguage fromAppLanguage(String value) =>
      value == 'th' ? thai : english;

  String recognitionLocale(Iterable<String> available) {
    String? matchingLanguage;
    for (final locale in available) {
      final normalized = locale.replaceAll('_', '-').toLowerCase();
      if (normalized == voiceLocale.toLowerCase()) return locale;
      if (normalized.split('-').first == code) matchingLanguage ??= locale;
    }
    return matchingLanguage ?? voiceLocale;
  }
}

class ChatRequest {
  final String? sessionId;
  final String message;
  final ChatLanguage language;

  ChatRequest({this.sessionId, required this.message, required this.language});

  Map<String, dynamic> toJson() => {
    if (sessionId != null) 'session_id': sessionId,
    'message': message,
    'language': language.code,
  };
}

class ChatResponse {
  final String sessionId;
  final String response;
  final DateTime timestamp;

  ChatResponse({
    required this.sessionId,
    required this.response,
    required this.timestamp,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) => ChatResponse(
    sessionId: json['session_id'] as String,
    response: json['response'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}
