import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/auth_service.dart';
import '../models/game_configuration.dart';
import '../models/child_progress_snapshot.dart';

class CaretakerFailure implements Exception {
  const CaretakerFailure(this.message, {this.conflict = false});
  final String message;
  final bool conflict;
  @override
  String toString() => message;
}

String caretakerError(Object error) {
  if (error is CaretakerFailure) return error.message;
  if (error is PostgrestException) {
    if (error.code == '40001') {
      return 'Another Caretaker saved changes. Reload before saving again.';
    }
    if (error.code == 'PGRST202' || error.code == '42P01') {
      return 'Caretaker storage is not installed yet. Apply the Caretaker database migration, then retry.';
    }
    if (error.code == '42501') {
      return 'This child is no longer available for your account. Reload your care list.';
    }
    if (error.code == '22023') {
      return 'Check the selected children or game settings and try again.';
    }
  }
  return 'Could not connect. Your changes are still here. Please try again.';
}

class CaretakerChild {
  CaretakerChild(this.profile, this.inCare);
  final UserProfile profile;
  final bool inCare;
}

class CaretakerRoster {
  CaretakerRoster(this.children, this.plannedCount, this.revision);
  final List<CaretakerChild> children;
  final int plannedCount;
  final int revision;
}

class CaretakerRepository {
  CaretakerRepository(this.client);
  final SupabaseClient client;
  Future<CaretakerRoster> load() async {
    final data = Map<String, dynamic>.from(
      await client.rpc('caretaker_roster'),
    );
    final children = (data['children'] as List).map((row) {
      final json = Map<String, dynamic>.from(row as Map)..['role'] = 'child';
      return CaretakerChild(
        UserProfile.fromJson(json),
        json['is_in_care'] as bool,
      );
    }).toList();
    return CaretakerRoster(
      children,
      data['planned_count'] as int,
      data['revision'] as int,
    );
  }

  Future<void> link(String email) async => await client.rpc(
    'caretaker_link_child',
    params: {'child_email': email.trim()},
  );
  Future<void> save(int count, Set<String> ids, int revision) async {
    await client.rpc(
      'caretaker_save_roster',
      params: {
        'planned_count': count,
        'child_ids': ids.toList(),
        'expected_revision': revision,
      },
    );
  }

  Future<ChildProgressSnapshot> progress(String childId) async =>
      ChildProgressSnapshot.fromJson(
        Map<String, dynamic>.from(
          await client.rpc(
            'caretaker_child_progress',
            params: {'target_child': childId},
          ),
        ),
      );

  Future<List<ClassWord>> legacyWords() async {
    final rows = await client
        .from('class_words')
        .select()
        .eq('teacher_id', client.auth.currentUser!.id);
    return rows.map(ClassWord.fromJson).toList();
  }
}

class GameConfigurationRepository {
  GameConfigurationRepository(this.client);
  final SupabaseClient client;
  Future<SavedGameConfiguration> load(
    String childId,
    CaretakerGame game,
  ) async {
    final row = await client
        .from('child_game_configs')
        .select()
        .eq('child_id', childId)
        .eq('game_key', game.key)
        .maybeSingle();
    if (row == null) {
      return SavedGameConfiguration(GameConfiguration.defaults(game), 0);
    }
    final config = GameConfiguration(
      game,
      Map<String, dynamic>.from(row['payload'] as Map),
    );
    final version = row['schema_version'] as int;
    if (version == 1 && config.validate().isNotEmpty) {
      throw const CaretakerFailure(
        'Saved settings are invalid. Please contact support before replacing them.',
      );
    }
    return SavedGameConfiguration(
      config,
      row['revision'] as int,
      schemaVersion: version,
    );
  }

  Future<Set<String>> summaries(String childId) async {
    final rows = await client
        .from('child_game_configs')
        .select('game_key')
        .eq('child_id', childId);
    return rows.map((r) => r['game_key'] as String).toSet();
  }

  Future<SavedGameConfiguration> save(
    String childId,
    GameConfiguration config,
    int revision,
  ) async {
    final errors = config.validate();
    if (errors.isNotEmpty) throw CaretakerFailure(errors.join('\n'));
    final result = await client.rpc(
      'caretaker_save_config',
      params: {
        'target_child': childId,
        'target_game': config.game.key,
        'config_payload': config.toJson(),
        'expected_revision': revision,
      },
    );
    return SavedGameConfiguration(config, (result as num).toInt());
  }
}
