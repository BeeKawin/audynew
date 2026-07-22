import 'dart:convert';
import 'dart:io';

import 'package:audy_app/src/services/emotion_service_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  late Directory tempDirectory;
  late File imageFile;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('audy-emotion-test-');
    imageFile = File('${tempDirectory.path}/face.png');
    await imageFile.writeAsBytes(<int>[1, 2, 3]);
  });

  tearDown(() async {
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test('uploads the face image and parses the Railway response', () async {
    final client = MockClient((request) async {
      expect(
        request.url.toString(),
        'https://railway.example/api/emotion/classify',
      );
      expect(request.method, 'POST');
      expect(request.headers['content-type'], contains('multipart/form-data'));
      final multipartBody = utf8
          .decode(request.bodyBytes, allowMalformed: true)
          .toLowerCase();
      expect(multipartBody, contains('filename="face.png"'));
      expect(multipartBody, contains('content-type: image/png'));

      return http.Response(
        jsonEncode(<String, dynamic>{
          'detected_emotion': 'Happy',
          'confidence': 0.91,
          'is_confident': true,
          'model_label': 'happy',
          'all_probabilities': <String, dynamic>{'happy': 0.91},
        }),
        200,
      );
    });
    final service = EmotionApiService(
      baseUrl: 'https://railway.example',
      client: client,
    );

    final result = await service.detectEmotion(imageFile);

    expect(result.detectedEmotion, 'Happy');
    expect(result.confidence, 0.91);
    expect(result.modelLabel, 'happy');
  });

  test(
    'returns a friendly error when the Railway model is unavailable',
    () async {
      final client = MockClient((request) async => http.Response('{}', 503));
      final service = EmotionApiService(
        baseUrl: 'https://railway.example',
        client: client,
      );

      await expectLater(
        service.detectEmotion(imageFile),
        throwsA(
          isA<EmotionApiException>().having(
            (error) => error.message,
            'message',
            contains('temporarily unavailable'),
          ),
        ),
      );
    },
  );
}
