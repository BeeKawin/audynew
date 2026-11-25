import 'dart:convert';

import 'package:drift/drift.dart' show Variable;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/database.dart';
import '../models/game_configuration.dart';

class StudentGameConfigurationRepository {
  StudentGameConfigurationRepository(this._client);
  final SupabaseClient _client;
  final _memory = <CaretakerGame, SavedGameConfiguration?>{};
  final _pending = <CaretakerGame, Future<GameConfiguration?>>{};
  String? _childId;
  int _generation = 0;
  int get accountGeneration => _generation;

  void useAccount(String? id) {
    if (_childId == id) return;
    _childId = id;
    _generation++;
    _memory.clear();
    _pending.clear();
  }

  Future<GameConfiguration?> load(CaretakerGame game, AppDatabase? db) {
    return _pending.putIfAbsent(game, () {
      late final Future<GameConfiguration?> request;
      request = _load(game, db).whenComplete(() {
        if (identical(_pending[game], request)) _pending.remove(game);
      });
      return request;
    });
  }

  Future<GameConfiguration?> _load(CaretakerGame game, AppDatabase? db) async {
    final child = _childId;
    final generation = _generation;
    if (child == null || !game.supportsStudentPlay) return null;
    bool current() =>
        child == _childId &&
        generation == _generation &&
        _client.auth.currentUser?.id == child;
    if (!current()) return null;

    final cached = _memory.containsKey(game)
        ? _memory[game]
        : await _readCache(
            db,
            child,
            game,
          ).timeout(const Duration(milliseconds: 350), onTimeout: () => null);
    if (!current()) return null;

    try {
      final result = await _client
          .rpc(
            'student_game_config',
            params: {
              'target_game': game.key,
              'known_revision': cached?.revision,
            },
          )
          .timeout(const Duration(seconds: 3));
      if (!current()) return null;
      final row = result is Map ? result : const {};
      final snapshot = switch (row['status']) {
        'unchanged' when row['revision'] == cached?.revision => cached,
        'active' when row['schema_version'] == 1 => _decode(
          game,
          row['payload'],
          row['revision'],
        ),
        _ => null,
      };
      return _useSnapshot(db, child, game, snapshot, current);
    } on PostgrestException catch (error) {
      if (!current()) return null;
      if (const {
        '42501',
        'PGRST202',
        'PGRST301',
        'PGRST302',
        'PGRST303',
      }.contains(error.code)) {
        return _useSnapshot(db, child, game, null, current);
      }
      return cached?.config;
    } catch (_) {
      return current() ? cached?.config : null;
    }
  }

  SavedGameConfiguration? _decode(
    CaretakerGame game,
    Object? payload,
    Object? revision,
  ) {
    if (payload is! Map || revision is! int || revision < 1) return null;
    try {
      final config = GameConfiguration(
        game,
        Map<String, dynamic>.from(payload),
      );
      return config.validate().isEmpty
          ? SavedGameConfiguration(config, revision)
          : null;
    } catch (_) {
      return null;
    }
  }

  Future<SavedGameConfiguration?> _readCache(
    AppDatabase? db,
    String child,
    CaretakerGame game,
  ) async {
    if (db == null) return null;
    try {
      final row = await db
          .customSelect(
            'SELECT revision, payload FROM student_game_config_cache WHERE child_id = ? AND game_key = ?',
            variables: [Variable(child), Variable(game.key)],
          )
          .getSingleOrNull();
      return row == null
          ? null
          : _decode(
              game,
              jsonDecode(row.read<String>('payload')),
              row.read<int>('revision'),
            );
    } catch (_) {
      return null;
    }
  }

  Future<GameConfiguration?> _useSnapshot(
    AppDatabase? db,
    String child,
    CaretakerGame game,
    SavedGameConfiguration? snapshot,
    bool Function() current,
  ) async {
    if (!current()) return null;
    _memory[game] = snapshot;
    if (db != null) {
      try {
        final write = snapshot == null
            ? db.customStatement(
                'DELETE FROM student_game_config_cache WHERE child_id = ? AND game_key = ?',
                [child, game.key],
              )
            : db.customStatement(
                'INSERT INTO student_game_config_cache (child_id, game_key, revision, payload) VALUES (?, ?, ?, ?) '
                'ON CONFLICT (child_id, game_key) DO UPDATE SET revision = excluded.revision, payload = excluded.payload '
                'WHERE excluded.revision >= student_game_config_cache.revision',
                [
                  child,
                  game.key,
                  snapshot.revision,
                  jsonEncode(snapshot.config.toJson()),
                ],
              );
        await write.timeout(const Duration(milliseconds: 350));
      } catch (_) {
        // Gameplay still works if local storage is unavailable.
      }
    }
    return current() ? snapshot?.config : null;
  }
}
