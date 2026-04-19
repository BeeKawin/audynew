class ChatRequest {
  final String? sessionId;
  final String message;

  ChatRequest({this.sessionId, required this.message});

  Map<String, dynamic> toJson() => {
    if (sessionId != null) 'session_id': sessionId,
    'message': message,
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
