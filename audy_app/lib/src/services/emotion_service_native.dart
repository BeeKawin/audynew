import 'dart:io';
import 'dart:math';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class EmotionResult {
  const EmotionResult({
    required this.detectedEmotion,
    required this.confidence,
  });

  final String detectedEmotion;
  final double confidence;
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

  static const Map<int, String> _modelLabels = {
    0: 'angry',
    1: 'fearful',
    2: 'happy',
    3: 'neutral',
    4: 'sad',
    5: 'surprised',
  };

  static const Map<String, String> _modelToApp = {
    'angry': 'Angry',
    'fearful': 'Scared',
    'happy': 'Happy',
    'neutral': 'Calm',
    'sad': 'Sad',
    'surprised': 'Surprised',
  };

  static const _modelInputSize = 48;
  static const _minConfidence = 0.4;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/emotion_model.tflite',
      );
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

  static Future<EmotionResult> detectEmotion(File image) async {
    if (_interpreter == null) {
      throw EmotionLoadException(
        _loadError ??
            'Emotion model not loaded. Call EmotionService.init() first.',
      );
    }

    final input = _preprocess(image);
    final output = List.filled(6, 0.0).reshape([1, 6]);

    _interpreter!.run(input, output);

    final probs = output[0] as List<double>;
    final softmax = _softmax(probs);
    final maxIdx = _argmax(softmax);
    final maxConf = softmax[maxIdx];

    final modelLabel = _modelLabels[maxIdx] ?? 'neutral';
    final appEmotion = _modelToApp[modelLabel] ?? 'Calm';

    return EmotionResult(detectedEmotion: appEmotion, confidence: maxConf);
  }

  static List<List<List<double>>> _preprocess(File image) {
    final bytes = image.readAsBytesSync();
    var decoded = img.decodeImage(bytes);

    decoded ??= img.Image(width: _modelInputSize, height: _modelInputSize);

    final resized = img.copyResize(
      decoded,
      width: _modelInputSize,
      height: _modelInputSize,
    );

    final grayscale = img.grayscale(resized);

    final input = List.generate(
      1,
      (_) => List.generate(
        _modelInputSize,
        (y) => List.generate(_modelInputSize, (x) {
          final pixel = grayscale.getPixel(x, y);
          final intensity = pixel.r;
          return intensity / 255.0;
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
