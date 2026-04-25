import 'dart:io';
import 'dart:math';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'emotion_service_api.dart';

class EmotionResult {
  const EmotionResult({
    required this.detectedEmotion,
    required this.confidence,
    this.source = 'local',
  });

  final String detectedEmotion;
  final double confidence;
  final String source; // 'local' or 'api'

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

class EmotionService {
  EmotionService._();

  static Interpreter? _interpreter;
  static bool _initialized = false;
  static String? _loadError;
  static final EmotionApiService _apiService = EmotionApiService();
  static bool _useApiFallback = true;

  static const Map<int, String> _modelLabels = {
    0: 'Happy',
    1: 'Sad',
    2: 'Surprised',
    3: 'Fearful',
    4: 'Angry',
    5: 'Disgusted',
    6: 'Neutral',
  };

  static const Map<String, String> _modelToApp = {
    'Angry': 'Angry',
    'Fearful': 'Scared',
    'Happy': 'Happy',
    'Neutral': 'Calm',
    'Sad': 'Sad',
    'Surprised': 'Surprised',
    'Disgusted': 'Scared',
  };

  static const _modelInputSize = 48;
  static const _minConfidence = 0.4;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/model.tflite');
      _loadError = null;
      _initialized = true;
    } catch (e) {
      _loadError = e.toString();
      _initialized = true;
      throw EmotionLoadException('Failed to load emotion model: $e');
    }
  }

  static bool get isReady => _initialized && _interpreter != null;
  static String? get loadError => _loadError;

  /// Enable or disable API fallback when local model fails
  static void setApiFallback(bool enabled) {
    _useApiFallback = enabled;
  }

  /// Detect emotion using local TFLite model with optional API fallback
  static Future<EmotionResult> detectEmotion(File image) async {
    // Try local model first
    if (_interpreter != null) {
      try {
        final result = await _detectLocal(image);
        return result;
      } catch (e) {
        // Local failed, try API if enabled
        if (_useApiFallback) {
          return await detectEmotionRemote(image);
        }
        rethrow;
      }
    }

    // No local model, use API
    if (_useApiFallback) {
      return await detectEmotionRemote(image);
    }

    throw EmotionLoadException(
      _loadError ?? 'Emotion model not loaded and API fallback disabled.',
    );
  }

  /// Detect emotion using Railway API
  /// Works on all platforms including web
  static Future<EmotionResult> detectEmotionRemote(File image) async {
    final apiResult = await _apiService.detectEmotion(image);
    return EmotionResult.fromApi(apiResult);
  }

  static Future<EmotionResult> _detectLocal(File image) async {
    final input = _preprocess(image);
    final output = List.filled(7, 0.0).reshape([1, 7]);

    _interpreter!.run(input, output);

    final probs = output[0] as List<double>;
    final softmax = _softmax(probs);
    final maxIdx = _argmax(softmax);
    final maxConf = softmax[maxIdx];

    final modelLabel = _modelLabels[maxIdx] ?? 'neutral';
    final appEmotion = _modelToApp[modelLabel] ?? 'Calm';

    return EmotionResult(
      detectedEmotion: appEmotion,
      confidence: maxConf,
      source: 'local',
    );
  }

  static List<List<List<List<double>>>> _preprocess(File image) {
    final bytes = image.readAsBytesSync();
    var decoded = img.decodeImage(bytes);

    decoded ??= img.Image(width: _modelInputSize, height: _modelInputSize);

    final resized = img.copyResize(
      decoded,
      width: _modelInputSize,
      height: _modelInputSize,
    );

    // RGB input (3 channels) - model expects color images
    final input = List.generate(
      1,
      (_) => List.generate(
        _modelInputSize,
        (y) => List.generate(_modelInputSize, (x) {
          final pixel = resized.getPixel(x, y);
          // Normalize RGB values to 0-1 range
          final r = pixel.r / 255.0;
          final g = pixel.g / 255.0;
          final b = pixel.b / 255.0;
          return [r, g, b]; // 3 channels for RGB
        }),
      ),
    );

    return input;
  }

  static List<double> _softmax(List<double> logits) {
    final maxLogit = logits.reduce((a, b) => a > b ? a : b);
    final exps = logits.map((x) => exp(x - maxLogit)).toList();
    final sumExps = exps.reduce((a, b) => a + b);
    return exps.map((x) => x / sumExps).toList();
  }

  static int _argmax(List<double> values) {
    var maxIdx = 0;
    var maxVal = values[0];
    for (var i = 1; i < values.length; i++) {
      if (values[i] > maxVal) {
        maxVal = values[i];
        maxIdx = i;
      }
    }
    return maxIdx;
  }

  static bool isConfident(EmotionResult result) {
    return result.confidence >= _minConfidence;
  }

  static void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _initialized = false;
  }
}
