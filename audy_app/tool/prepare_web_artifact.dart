import 'dart:io';

/// Remove build-only and native-only files from the static upload.
void main() {
  for (final path in const [
    'assets/assets/ai/facial_emotion_model.onnx',
    'drift_worker.dart',
    'drift_worker.js.deps',
    'drift_worker.js.map',
    'DATABASE_ASSETS.md',
    'storage_probe.js',
    'storage_probe.js.deps',
    'storage_probe.js.map',
  ]) {
    final file = File('build/web/$path');
    if (file.existsSync()) file.deleteSync();
  }
}
