import 'dart:convert';
import 'dart:io';

void main() {
  final wasm = File('build/web/sqlite3.wasm').readAsBytesSync();
  for (final path in [
    'assets/assets/ai/facial_emotion_model.onnx',
    'storage_probe.js',
  ]) {
    if (File('build/web/$path').existsSync()) {
      throw StateError(
        'Remove build-only/native-only file before upload: $path',
      );
    }
  }
  if (wasm.length < 4 ||
      wasm[0] != 0 ||
      wasm[1] != 97 ||
      wasm[2] != 115 ||
      wasm[3] != 109) {
    throw StateError('Missing or invalid SQLite WebAssembly module.');
  }
  for (final path in [
    'drift_worker.js',
    'flutter_bootstrap.js',
    'index.html',
  ]) {
    if (!File('build/web/$path').existsSync()) {
      throw StateError('Missing $path');
    }
  }
  final source = File(
    'lib/src/features/auth/login_page.dart',
  ).readAsStringSync();
  final js = File('build/web/main.dart.js').readAsStringSync();
  if (Platform.environment['ENABLE_DEBUG_ACCOUNTS'] != 'true') {
    final credentials = RegExp(
      "(?:email|password): '([^']+)'\\s*,",
    ).allMatches(source);
    for (final match in credentials) {
      if (js.contains(match[1]!)) {
        throw StateError('Debug credential present in public build.');
      }
    }
  }
  final manifest = jsonDecode(
    File('build/web/manifest.json').readAsStringSync(),
  );
  if (manifest['short_name'] != 'AUDY') {
    throw StateError('Incorrect app manifest.');
  }
  stdout.writeln(
    'Web artifact verified: database assets, app metadata, public debug exclusion.',
  );
}
