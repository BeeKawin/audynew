// Compile temporarily into build/web to exercise real browser persistence.
import 'dart:convert';
import 'dart:js_interop';

import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

@JS('audyStorageProbeResult')
external set probeResult(JSString value);

class _ProbeUser extends QueryExecutorUser {
  @override
  int get schemaVersion => 1;

  @override
  Future<void> beforeOpen(
    QueryExecutor executor,
    OpeningDetails details,
  ) async {
    await executor.runCustom(
      'CREATE TABLE IF NOT EXISTS probe (value INTEGER)',
    );
  }
}

Future<QueryExecutor> openProbe(String name) async {
  final opened = await WasmDatabase.open(
    databaseName: name,
    sqlite3Uri: Uri.parse('/sqlite3.wasm'),
    driftWorkerUri: Uri.parse('/drift_worker.js'),
  );
  final executor = opened.resolvedExecutor;
  await executor.ensureOpen(_ProbeUser());
  return executor;
}

void main() async {
  try {
    final name = 'audy_web_probe_${DateTime.now().microsecondsSinceEpoch}';
    var accountA = await openProbe('${name}_a');
    await accountA.runInsert('INSERT INTO probe VALUES (?)', [123]);
    await accountA.close();
    accountA = await openProbe('${name}_a');
    final restored = await accountA.runSelect('SELECT value FROM probe', []);
    final accountB = await openProbe('${name}_b');
    final isolated = await accountB.runSelect('SELECT value FROM probe', []);
    await accountA.close();
    await accountB.close();
    if (restored.single['value'] != 123 || isolated.isNotEmpty) {
      throw StateError('Browser storage did not persist or isolate accounts.');
    }
    probeResult = jsonEncode({'persisted': true, 'isolated': true}).toJS;
  } catch (error) {
    probeResult = jsonEncode({'error': error.toString()}).toJS;
  }
}
