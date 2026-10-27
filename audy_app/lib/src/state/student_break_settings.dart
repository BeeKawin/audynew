import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/break_settings.dart';
import '../data/repositories/break_settings_repository.dart';

/// Account-scoped break configuration and session count; never used by previews.
class StudentBreakSettings extends ChangeNotifier {
  StudentBreakSettings(this.repository);
  final BreakSettingsRepository repository;
  String? _childId;
  int _generation = 0;
  int _threshold = 5;
  int _games = 0;
  int _countVersion = 0;
  bool _disposed = false;
  Future<void> _ready = Future.value();
  Future<void>? _refreshing;
  Future<void> _writes = Future.value();
  int get threshold => _threshold;
  int get games => _games;
  String? get childId => _childId;

  void useAccount(String? id) {
    if (_childId == id) return;
    _childId = id;
    final generation = ++_generation;
    _threshold = 5;
    _games = 0;
    _refreshing = null;
    _ready = id == null
        ? Future.value()
        : _restore(id, generation, ++_countVersion);
    notifyListeners();
  }

  Future<void> _restore(String id, int generation, int countVersion) async {
    try {
      await _writes;
      final prefs = await SharedPreferences.getInstance();
      if (_disposed || generation != _generation) return;
      final value = prefs.getInt('break.threshold.$id') ?? 5;
      _threshold = BreakSettings.validThreshold(value) ? value : 5;
      final count = prefs.getInt('break.games.$id') ?? 0;
      if (countVersion == _countVersion) _games = count < 0 ? 0 : count;
      notifyListeners();
    } catch (_) {
      // Keep this child's defaults when device storage is unavailable.
    }
  }

  Future<void> refresh() async {
    final generation = _generation;
    await _ready;
    if (_disposed || generation != _generation || _childId == null) return;
    final current = _refreshing;
    if (current != null) return current;
    final operation = _load(_childId!, generation);
    _refreshing = operation;
    try {
      await operation;
    } finally {
      if (identical(_refreshing, operation)) _refreshing = null;
    }
  }

  Future<void> _load(String id, int generation) async {
    try {
      final settings = await repository.loadForStudent().timeout(
        const Duration(seconds: 3),
      );
      if (_disposed || generation != _generation || !settings.editable) return;
      _threshold = settings.gamesBeforeBreak;
      _persist('break.threshold.$id', _threshold);
      notifyListeners();
    } catch (_) {
      // Offline checks use this child's last valid configuration, or five games.
    }
  }

  void setGames(int value) {
    _countVersion++;
    _games = value < 0 ? 0 : value;
    final id = _childId;
    if (id != null) _persist('break.games.$id', _games);
    if (!_disposed) notifyListeners();
  }

  void _persist(String key, int value) {
    _writes = _writes
        .then((_) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt(key, value);
        })
        .catchError((Object _) {});
  }

  Future<void> flush() => _writes;

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    super.dispose();
  }
}
