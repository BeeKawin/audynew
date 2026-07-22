import 'dart:io';

<<<<<<< HEAD
=======
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:onnxruntime/onnxruntime.dart';

>>>>>>> origin/Kongnew
import 'emotion_service_api.dart';

/// Result of emotion detection.
class EmotionResult {
  const EmotionResult({
    required this.detectedEmotion,
    required this.confidence,
<<<<<<< HEAD
    this.source = 'api',
=======
    this.source = 'onnx',
>>>>>>> origin/Kongnew
  });

  final String detectedEmotion;
  final double confidence;
<<<<<<< HEAD
  final String source; // always 'api'
=======
  final String source;
>>>>>>> origin/Kongnew

  factory EmotionResult.fromApi(EmotionApiResult apiResult) {
    return EmotionResult(
      detectedEmotion: apiResult.detectedEmotion,
      confidence: apiResult.confidence,
      source: 'api',
    );
  }
}

class EmotionLoadException implements Exception {
  const EmotionLoadException(this.message);
  final String message;
  @override
  String toString() => 'EmotionLoadException: $message';
}

<<<<<<< HEAD
/// Emotion detection service — API-only via Railway backend.
/// No local model is bundled; inference runs on the server.
class EmotionService {
  EmotionService._();

  static final EmotionApiService _apiService = EmotionApiService();

  static Future<void> init() async {
    // No local model to load.
  }

  static bool get isReady => true;
  static String? get loadError => null;

  /// Detect emotion by sending the image to the Railway API.
  static Future<EmotionResult> detectEmotion(File image) async {
    final apiResult = await _apiService.detectEmotion(image);
=======
/// Emotion detection service using local ONNX model with API fallback.
class EmotionService {
  EmotionService._();

  static OrtSession? _session;
  static bool _isReady = false;
  static String? _loadError;
  static final EmotionApiService _apiService = EmotionApiService();

  static const List<String> _classLabels = [
    'Angry',
    'Disgust',
    'Scared',
    'Happy',
    'Neutral',
    'Sad',
    'Surprise',
  ];

  static bool get isReady => _isReady;
  static String? get loadError => _loadError;

  static Future<void> init() async {
    if (_isReady) return;
    try {
      OrtEnv.instance.init();
      final sessionOptions = OrtSessionOptions();
      final rawAsset = await rootBundle.load(
        'assets/ai/facial_emotion_model.onnx',
      );
      final bytes = rawAsset.buffer.asUint8List();
      _session = OrtSession.fromBuffer(bytes, sessionOptions);
      _isReady = true;
      debugPrint('EmotionService: ONNX model loaded successfully.');
    } catch (e) {
      _loadError = e.toString();
      debugPrint('EmotionService ONNX init failed: $e');
    }
  }

  /// Detect emotion using local ONNX model, falling back to API if unavailable.
  static Future<EmotionResult> detectEmotion(File imageFile) async {
    if (!_isReady || _session == null) {
      await init();
    }

    if (_isReady && _session != null) {
      try {
        final imageBytes = await imageFile.readAsBytes();
        var decoded = img.decodeImage(imageBytes);
        if (decoded == null) {
          throw const EmotionLoadException('Could not decode image file.');
        }

        decoded = img.bakeOrientation(decoded);
        final resized = img.copyResize(decoded, width: 96, height: 96);
        final grayImage = img.grayscale(resized);

        final floatList = Float32List(1 * 96 * 96 * 3);
        int idx = 0;
        for (int y = 0; y < 96; y++) {
          for (int x = 0; x < 96; x++) {
            final pixel = grayImage.getPixel(x, y);
            floatList[idx++] = pixel.r.toDouble();
            floatList[idx++] = pixel.g.toDouble();
            floatList[idx++] = pixel.b.toDouble();
          }
        }

        final inputTensor = OrtValueTensor.createTensorWithDataList(
          floatList,
          [1, 96, 96, 3],
        );
        final runOptions = OrtRunOptions();
        final outputs = await _session!.runAsync(runOptions, {
          'input_image': inputTensor,
        });

        inputTensor.release();
        runOptions.release();

        if (outputs == null || outputs.isEmpty || outputs.first == null) {
          throw const EmotionLoadException('ONNX output null.');
        }

        final rawOutputs = outputs.first!.value;
        List<double> probs = [];
        if (rawOutputs is List && rawOutputs.isNotEmpty) {
          final first = rawOutputs.first;
          if (first is List) {
            probs = first.map((e) => (e as num).toDouble()).toList();
          }
        }

        for (var element in outputs) {
          element?.release();
        }

        if (probs.isEmpty) {
          throw const EmotionLoadException('Invalid ONNX probability output.');
        }

        int maxIdx = 0;
        double maxConf = probs[0];
        for (int i = 1; i < probs.length; i++) {
          if (probs[i] > maxConf) {
            maxConf = probs[i];
            maxIdx = i;
          }
        }

        String label = (maxIdx < _classLabels.length)
            ? _classLabels[maxIdx]
            : 'Happy';

        return EmotionResult(
          detectedEmotion: label,
          confidence: maxConf,
          source: 'onnx',
        );
      } catch (e) {
        debugPrint('ONNX inference failed, falling back to API: $e');
      }
    }

    final apiResult = await _apiService.detectEmotion(imageFile);
>>>>>>> origin/Kongnew
    return EmotionResult.fromApi(apiResult);
  }

  /// Alias for [detectEmotion].
  static Future<EmotionResult> detectEmotionRemote(File image) async {
    return detectEmotion(image);
  }

  static bool isConfident(EmotionResult result) {
    return result.confidence >= 0.4;
  }

<<<<<<< HEAD
  static void dispose() {}
}
=======
  static void dispose() {
    _session?.release();
    _session = null;
    _isReady = false;
  }
}

>>>>>>> origin/Kongnew
